From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Skipping past TCP lost packet in userspace
Date: Tue, 31 May 2011 07:12:23 -0400
Message-ID: <20110531111223.GA3012@hmsreliant.think-freely.org>
References: <4DE44218.4070306@krellan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Josh Lehan <linux@krellan.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46016 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab1EaLM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 07:12:29 -0400
Content-Disposition: inline
In-Reply-To: <4DE44218.4070306@krellan.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 30, 2011 at 06:19:20PM -0700, Josh Lehan wrote:
> Hello.  I looked, but could not find an answer.  Is there already an
> ioctl() or something like that in Linux, that would allow a userspace
> TCP socket to skip past a lost packet?
> 
> The kernel already will continue to queue up packets, and with TCP SACK,
> the kernel can acknowledge reception of further packets beyond the lost
> packet, allowing the queue to continue growing.  However, all these
> queued packets won't be delivered to userspace until the original lost
> packet is received again, after it has been retransmitted.
> 
> Is there a way for a userspace program to prevent this needless stall?
> It would be great if there was an ioctl() or similar call, that would
> tell the kernel that it's OK to leave a gap in the data stream, and
> resume supplying userspace with more data.  An obvious application would
> be media streaming, and many high-level media protocols do their own
> block framing anyway, so resynchronization after the data gap would not
> be a problem.
> 
> This sounds like something that would be a FAQ, and if so, please point
> me to the answer.  Thank you!
> 
No, TCP doesn't and won't do that by design

If you want to allow frames to come in to an application as they arrive at the
system regarless of prior loss, use UDP

If you still want ordering and reliability, look at SCTP.
Neil

> Josh Lehan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
