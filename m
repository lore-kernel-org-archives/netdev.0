From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 12:09:05 +0200
Message-ID: <20070807100905.GC3223@ff.dom.local>
References: <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731132037.GC1046@ff.dom.local> <4bacf17f0708060000n5a00bb77i74adc3b4b28ac42b@mail.gmail.com> <20070806070300.GA4509@elte.hu> <46B75DD4.5080709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46B75DD4.5080709@redhat.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 06, 2007 at 01:43:48PM -0400, Chuck Ebbert wrote:
> On 08/06/2007 03:03 AM, Ingo Molnar wrote:
> > 
> > But, since level types don't need this retriggers too much I think
> > this "don't mask interrupts by default" idea should be rethinked:
> > is there enough gain to risk such hard to diagnose errors?
> >   
> > 
> 
> I reverted those masking changes in Fedora and the baffling problem
> with 3Com 3C905 network adapters went away.
> 
> Before, they would print:
> 
> eth0: transmit timed out, tx_status 00 status e601.
>   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
> eth0: Interrupt posted but not delivered -- IRQ blocked by another device?
>   Flags; bus-master 1, dirty 295757(13) current 295757(13)
>   Transmit list 00000000 vs. f7150a20.
>   0: @f7150200  length 80000070 status 0c010070
>   1: @f71502a0  length 80000070 status 0c010070
>   2: @f7150340  length 8000005c status 0c01005c
> 
> Now they just work, apparently...
> 
> So why not just revert the change?
> 

Ingo has written about such possibility. But, it would be good
to know which precisely place is to blame, as well. Since this
diagnosing takes time, I think Chuck is right, and maybe at least
this temporary patch for resend.c without this warning, should
be recomended for stables (2.6.21 and 2.6.22)?

Jarek P.
