From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll:
 Implement basic statistics
Date: Tue, 29 Jan 2013 01:21:13 +0000
Message-ID: <FD9AD8C5375B924CABC56D982DB3A802079D377A@EXMB1.micrel.com>
References: <FD9AD8C5375B924CABC56D982DB3A802079D33CE@EXMB1.micrel.com>
 <20130128.183941.768670834017645797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>,
	"joe@perches.com" <joe@perches.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o143.mxlogic.net ([208.65.145.66]:47362 "EHLO
	p01c12o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3A2BVV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 20:21:21 -0500
In-Reply-To: <20130128.183941.768670834017645797.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David Miller,

Thank you for your comments.

After receiving your reply, I check my patches that I have submitted.
On Jan. 23, I submitted my patches twice: One at 10:46AM, another at 11:36AM at my local time.

After submitting the first patch, Joe commented 2 issues that you mentioned.
-Indentation issue
-else if() issue

The 2nd patch resolved those 2 issues mentioned above.
I am pretty sure that your comment is based on my first patch on Jan 23.

I sent my 2nd patch to Joe@perches.com and you were in the loop. The reason why I sent to Joe was that he commented about my first patch.

Could you take a look at my last patch? If you want, I will submit it again.
Thank you for your effort and time.

Regards,
David J. Choi


-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Monday, January 28, 2013 3:40 PM
To: Choi, David
Cc: netdev@vger.kernel.org; Doong, Ping; joe@perches.com; bhutchings@solarflare.com
Subject: Re: [PATCH net-next] drivers/net/ethernet/micrel/ks8851_mll: Implement basic statistics

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Wed, 23 Jan 2013 18:46:37 +0000

> From: David J. Choi <david.choi@micrel.com>
>  
> Summary of changes:
>   add codes to collect basic statistical information about Ethernet packets.

This is awkward.  Just state in sentences what is happening in the
commit.

There is no need for formalities like "and here comes the summary
of the changes" that's implicit in what this is, a commit log message.

> -		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
> +		if (unlikely(!skb)) {
> +			/* discard the packet from the device */
> +			ks_wrreg16(ks, KS_RXQCR, ks->rc_rxqcr | RXQCR_RRXEF);
> +			netdev->stats.rx_dropped++;
> +		}
> +
> +		else if (likely((frame_hdr->sts & RXFSHR_RXFV) &&
>  			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {

Because this last condition goes from a plain

	if ()

to

	else if()

the next line is not not indented properly, you must fix that up.

Also, do not split up the closing brace and the next part of the
conditional as you did here, that's wrong.  Do this:

	} else if (...

Do not do this:

	}
	else if (...

You've been submitting patches way to long to be making so many
mistakes like this, my review efforts feel entirely wasted.
