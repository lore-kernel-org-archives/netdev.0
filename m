From: "Chung-Chi Lo" <linolo@gmail.com>
Subject: Re: [PATCH net-2.6.25 4/7][ATM]: [br2864] routed support
Date: Wed, 16 Jan 2008 12:16:46 +0800
Message-ID: <3f696b20801152016r52048016g7c293dbfdc6c9f29@mail.gmail.com>
References: <200712300107.lBU17O8i003566@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.227]:55792 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbYAPEQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 23:16:47 -0500
Received: by nz-out-0506.google.com with SMTP id s18so118762nze.1
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2008 20:16:46 -0800 (PST)
In-Reply-To: <200712300107.lBU17O8i003566@cmf.nrl.navy.mil>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 30, 2007 9:07 AM, chas williams - CONTRACTOR
<chas@cmf.nrl.navy.mil> wrote:
> commit fea6b121bcc150fc91186e5012466c91944ce64d
> Author: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
> Date:   Fri Oct 26 08:05:08 2007 -0400
>
>     [ATM]: [br2864] routed support
>
>     From: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
>     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
>
> @@ -320,35 +361,50 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
>         } else {
>                 /* first 2 chars should be 0 */
>                 if (*((u16 *) (skb->data)) != 0) {
>                         brdev->stats.rx_errors++;
>                         dev_kfree_skb(skb);
>                         return;
>                 }
> +               skb_pull(skb, BR2684_PAD_LEN + ETH_HLEN); /* pad, dstmac, srcmac, ethtype */
> +               skb->protocol = eth_type_trans(skb, net_dev);
>         }

Question to decode the encaps=VCMUX and bridge mode:

This line

skb_pull((skb, BR2684_PAD_LEN + ETH_HLEN);

should be replaced by

skb_pull((skb, BR2684_PAD_LEN);

?

By the way, this routed mode patch doesn't include encaps=VCMUX and
RFC2684 routed
protocol decapsulation?

-- 
Lino, Chung-Chi Lo
