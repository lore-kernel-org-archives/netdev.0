From: Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next v2] be2net: do external loopback test only when
 it is requested
Date: Wed, 5 Mar 2014 21:34:36 +0000
Message-ID: <0a4e999a-05de-4395-a3bf-c4566ee0161e@CMEXHTCAS2.ad.emulex.com>
References: <1394016845-5376-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sathya Perla <Sathya.Perla@Emulex.Com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:47377 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757270AbaCEVem convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 16:34:42 -0500
In-Reply-To: <1394016845-5376-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Wednesday, March 05, 2014 4:54 AM
> To: netdev@vger.kernel.org
> Cc: Sathya Perla; Subramanian Seetharaman; Ajit Khaparde;
> sergei.shtylyov@cogentembedded.com
> Subject: [PATCH net-next v2] be2net: do external loopback test only when it
> is requested
> 
> v2: remove unnecessary braces from all 'loopback' if-blocks (thx Sergei)
> 
> Cc: sathya.perla@emulex.com
> Cc: subbu.seetharaman@emulex.com
> Cc: ajit.khaparde@emulex.com
> Cc: sergei.shtylyov@cogentembedded.com
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com> 

> ---
>  drivers/net/ethernet/emulex/benet/be_ethtool.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> index cf09d8f..66759b6 100644
> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> @@ -802,16 +802,18 @@ be_self_test(struct net_device *netdev, struct
> ethtool_test *test, u64 *data)
> 
>  	if (test->flags & ETH_TEST_FL_OFFLINE) {
>  		if (be_loopback_test(adapter, BE_MAC_LOOPBACK,
> -						&data[0]) != 0) {
> +				     &data[0]) != 0)
>  			test->flags |= ETH_TEST_FL_FAILED;
> -		}
> +
>  		if (be_loopback_test(adapter, BE_PHY_LOOPBACK,
> -						&data[1]) != 0) {
> -			test->flags |= ETH_TEST_FL_FAILED;
> -		}
> -		if (be_loopback_test(adapter,
> BE_ONE_PORT_EXT_LOOPBACK,
> -						&data[2]) != 0) {
> +				     &data[1]) != 0)
>  			test->flags |= ETH_TEST_FL_FAILED;
> +
> +		if (test->flags & ETH_TEST_FL_EXTERNAL_LB) {
> +			if (be_loopback_test(adapter,
> BE_ONE_PORT_EXT_LOOPBACK,
> +					     &data[2]) != 0)
> +				test->flags |= ETH_TEST_FL_FAILED;
> +			test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
>  		}
>  	}
> 
> --
> 1.8.3.2
