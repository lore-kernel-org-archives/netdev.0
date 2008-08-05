From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [BUG] before() integer overflow
Date: Tue, 5 Aug 2008 18:40:04 +0100
Message-ID: <20080805174003.GA10471@solarflare.com>
References: <87y73bqt0p.fsf@chdir.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Nicolas Bareil <nico@chdir.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:40840 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759931AbYHERkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 13:40:16 -0400
Content-Disposition: inline
In-Reply-To: <87y73bqt0p.fsf@chdir.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Bareil wrote:
> 
> Hello!
> 
> 
> In include/net/tcp.h, the before() function is defined like this :
> 
>  241 /*
>  242  * The next routines deal with comparing 32 bit unsigned ints
>  243  * and worry about wraparound (automatic with unsigned arithmetic).
>  244  */
>  245 
>  246 static inline int before(__u32 seq1, __u32 seq2)
>  247 {
>  248         return (__s32)(seq1-seq2) < 0;
>  249 }
>  250 #define after(seq2, seq1)   before(seq1, seq2)
> 
> 
> If seq1 = 0xffffff and seq2 = 0 (so seq1 > seq2), the difference is
> equal to 0xffffff, or -1 as a 32 bits signed number.
> 
>  => before() will return true instead of false.
[...]

That's exactly what we want.  The initial sequence number is random (and
TCP streams are not limited to 4GB) so the sequence can wrap around.  0
follows 0xffffffff.  If we were to compare sequence numbers from two
packets more than 2GB apart in the stream, this comparison would give
the wrong answer, but currently this is not likely to be a problem.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
