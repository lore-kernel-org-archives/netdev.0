From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] be2net: do external loopback test only when
 it is requested
Date: Tue, 04 Mar 2014 23:17:53 +0300
Message-ID: <531634F1.4070109@cogentembedded.com>
References: <1393956295-25436-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com
To: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:63575 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755916AbaCDTRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 14:17:53 -0500
Received: by mail-lb0-f175.google.com with SMTP id w7so5898567lbi.34
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 11:17:51 -0800 (PST)
In-Reply-To: <1393956295-25436-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/04/2014 09:04 PM, Ivan Vecera wrote:

> Cc: sathya.perla@emulex.com
> Cc: subbu.seetharaman@emulex.com
> Cc: ajit.khaparde@emulex.com

> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>   drivers/net/ethernet/emulex/benet/be_ethtool.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> index cf09d8f..957848f 100644
> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> @@ -809,9 +809,12 @@ be_self_test(struct net_device *netdev, struct ethtool_test *test, u64 *data)
>   						&data[1]) != 0) {
>   			test->flags |= ETH_TEST_FL_FAILED;
>   		}
> -		if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
> -						&data[2]) != 0) {
> -			test->flags |= ETH_TEST_FL_FAILED;
> +		if (test->flags & ETH_TEST_FL_EXTERNAL_LB) {
> +			if (be_loopback_test(adapter, BE_ONE_PORT_EXT_LOOPBACK,
> +					     &data[2]) != 0) {
> +				test->flags |= ETH_TEST_FL_FAILED;
> +			}

    {} not needed here, according to Documentation/CodingStyle. I'm surprised 
scripts/checkpatch.pl passed, it used to catch those.

WBR, Sergei
