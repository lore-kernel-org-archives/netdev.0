From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] bnx2x: fix TCP offload for tunneling ipv4 over ipv6
Date: Mon, 03 Jun 2013 15:27:47 +0400
Message-ID: <51AC7DB3.70908@cogentembedded.com>
References: <1370251721-24668-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ariel Elior <ariele@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:37483 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757173Ab3FCL1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 07:27:51 -0400
Received: by mail-la0-f52.google.com with SMTP id fo13so3341207lab.11
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 04:27:49 -0700 (PDT)
In-Reply-To: <1370251721-24668-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03-06-2013 13:28, Dmitry Kravkov wrote:

> FW was initialized with data from wrong header, this caused TSO packets
> have wrong IP csum.

> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 13 ++++++-------
>   1 file changed, 6 insertions(+), 7 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index c80f1d2..37c1495 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -3198,11 +3198,11 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
>   		rc |= XMIT_CSUM_TCP;
>
>   	if (skb_is_gso_v6(skb)) {
> -		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP | XMIT_CSUM_V6);
> +		rc |= (XMIT_GSO_V6 | XMIT_CSUM_TCP);

   Maybe it's time to drop the useless ()?

>   		if (rc & XMIT_CSUM_ENC)
>   			rc |= XMIT_GSO_ENC_V6;
>   	} else if (skb_is_gso(skb)) {
> -		rc |= (XMIT_GSO_V4 | XMIT_CSUM_V4 | XMIT_CSUM_TCP);
> +		rc |= (XMIT_GSO_V4 | XMIT_CSUM_TCP);

    Oh, here as well...

WBR, Sergei
