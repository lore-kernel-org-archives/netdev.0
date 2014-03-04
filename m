From: Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next] be2net: do external loopback test only when it
 is requested
Date: Tue, 4 Mar 2014 19:03:26 +0000
Message-ID: <154e570c-599b-4e7d-ab7e-d08fc2ca2883@CMEXHTCAS2.ad.emulex.com>
References: <1393956295-25436-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sathya Perla <Sathya.Perla@Emulex.Com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:50599 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbaCDTDb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 14:03:31 -0500
In-Reply-To: <1393956295-25436-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> Sent: Tuesday, March 04, 2014 12:05 PM
> To: netdev@vger.kernel.org
> Cc: Sathya Perla; Subramanian Seetharaman; Ajit Khaparde
> Subject: [PATCH net-next] be2net: do external loopback test only when it is
> requested
> 
> Cc: sathya.perla@emulex.com
> Cc: subbu.seetharaman@emulex.com
> Cc: ajit.khaparde@emulex.com
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com>

> ---
>  drivers/net/ethernet/emulex/benet/be_ethtool.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> index cf09d8f..957848f 100644
> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> @@ -809,9 +809,12 @@ be_self_test(struct net_device *netdev, struct
> ethtool_test *test, u64 *data)
>  						&data[1]) != 0) {
>  			test->flags |= ETH_TEST_FL_FAILED;
>  		}
> -		if (be_loopback_test(adapter,
> BE_ONE_PORT_EXT_LOOPBACK,
> -						&data[2]) != 0) {
> -			test->flags |= ETH_TEST_FL_FAILED;
> +		if (test->flags & ETH_TEST_FL_EXTERNAL_LB) {
> +			if (be_loopback_test(adapter,
> BE_ONE_PORT_EXT_LOOPBACK,
> +					     &data[2]) != 0) {
> +				test->flags |= ETH_TEST_FL_FAILED;
> +			}
> +			test->flags |= ETH_TEST_FL_EXTERNAL_LB_DONE;
>  		}
>  	}
> 
> --
> 1.8.3.2
