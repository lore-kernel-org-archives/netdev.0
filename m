From: Ingo Molnar <mingo@elte.hu>
Subject: Re: gettimeofday scalability
Date: Tue, 5 Oct 2004 21:18:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005191858.GA14082@elte.hu>
References: <4162CD76.4070204@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrea Arcangeli <andrea@suse.de>
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
Content-Disposition: inline
In-Reply-To: <4162CD76.4070204@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* P@draigBrady.com <P@draigBrady.com> wrote:

> In particular I was wondering about reducing the overhead of
> calling do_gettimeofday.

> 2.6.8.1 uses seqlock, which contains the comment that it's not as
> cache friendly as brlock.

that comment is way too modest! Seqlocks are very cache-friendly in the
read path. There is no reason to use brlocks anymore for fixed-frequency
writers like the timer seqlock. (writers can starve seqlock readers but
in the timer case the writers occur only once every 1 msec.)

so please benchmark 2.6, it should scale linearly in this area.

	Ingo
