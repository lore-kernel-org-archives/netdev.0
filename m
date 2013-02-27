From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Fwd: [linux] [PATCH] ATH6KL: "Fix the byte alignment rule to
 avoid loss of bytes in a TCP segment" (#27)
Date: Wed, 27 Feb 2013 12:42:07 -0500
Message-ID: <20130227174207.GB2082@tuxdriver.com>
References: <torvalds/linux/pull/27@github.com>
 <CA+55aFxmE+hEm53f2gjFetNREW6J8X1GfpzeVxhHnECC-h6D7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Myoungje Kim <mjei78@gmail.com>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54118 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760176Ab3B0RpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 12:45:20 -0500
Content-Disposition: inline
In-Reply-To: <CA+55aFxmE+hEm53f2gjFetNREW6J8X1GfpzeVxhHnECC-h6D7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks!  I'll ask Kalle to take a look, since ath6kl is his baby...

On Wed, Feb 27, 2013 at 09:19:09AM -0800, Linus Torvalds wrote:
> "How do I hate GitHub pull requests? Let me count the ways...."
> 
> That said, the bug description alone makes this worth forwarding,
> despite the cluelessness of GitHub pull requests. Myoungje Kim spent
> some time explaining the issue, so while I despise the github pull
> request format, I'm not faulting the effort spent on describing the
> patch.
> 
>                   Linus
> 
> ---------- Forwarded message ----------
> From: Steven Kim <notifications@github.com>
> Date: Tue, Feb 26, 2013 at 9:17 PM
> Subject: [linux] [PATCH] ATH6KL: "Fix the byte alignment rule to avoid
> loss of bytes in a TCP segment" (#27)
> To: torvalds/linux <linux@noreply.github.com>
> 
> 
> I found the driver bug which occur loss of some bytes on the TCP/IP stack.
> 
> Either first 3 bytes of the first received tcp segment or last one
> over MTU size file can be loss due to the byte alignment problem.
> Although ATH6KL_HTC_ALIGN_BYTES was defined
> for 'extra bytes for htc header alignment'
> in the patch "Fix buffer alignment for scatter-gather I/O"(1df94a8),
> there exists the bytes loss issue which means that it will be truncated
> 3 bytes in the transmitted file contents if a file which
> has over MTU size is transferred through TCP/IP stack.
> It doesn't look like TCP/IP stack bug of 3.5 or the latest version of
> kernel but the byte alignment issue.
> This patch is to use the roundup() function for the byte alignment
> rather than the predefined ATH6KL_HTC_ALIGN_BYTES.
> 
> Signed-off-by: Myoungje Kim mjei78@gmail.com
> 
> ________________________________
> 
> You can merge this Pull Request by running
> 
>   git pull https://github.com/kingpotato/linux master
> 
> Or view, comment on, or merge it at:
> 
>   https://github.com/torvalds/linux/pull/27
> 
> Commit Summary
> 
> ath6kl: Fix the byte alignment rule to avoid loss of bytes in a TCP segment
> 
> File Changes
> 
> M drivers/net/wireless/ath/ath6kl/init.c (4)
> M drivers/net/wireless/ath/ath6kl/main.c (4)
> 
> Patch Links:
> 
> https://github.com/torvalds/linux/pull/27.patch
> https://github.com/torvalds/linux/pull/27.diff
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
