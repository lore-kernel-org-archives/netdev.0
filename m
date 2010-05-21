From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: bug fix patch lost: git problem or just incorrect merge?
Date: Fri, 21 May 2010 10:04:35 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005210947440.4243@i5.linux-foundation.org>
References: <1274456515.9022.14.camel@mulgrave.site> <alpine.LFD.2.00.1005210931010.4243@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>
To: James Bottomley <James.Bottomley@suse.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1005210931010.4243@i5.linux-foundation.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 21 May 2010, Linus Torvalds wrote:
> 
> > Either way, of course, we need the patch back ...
> 
> I'll fix it up.

Hmm. Pushed that out as appended, since that is the correct resolve.

HOWEVER - the code still doesn't actually make any sense. It does

	if (sk_sleep(sock->sk)) {

and that sk_sleep() today is an inline function that just does

	return &sk->sk_wq->wait;

and testing the result of an address-of operation for NULL is almost 
certainly totally non-sensical. Sure, it _might_ work (maybe 'wait' is the 
first element in the 'sk_wq' data structure, and sk_wq is NULL), but that 
kind of code is always total and utterl crap regardless.

So I pushed it out because I had done the resolve already, and it's no 
worse than it was before, but it's still a steaming buggy pile of shit.

It being iscsi, I can't bring myself to care. But somebody who does, 
should really look at it. The most likely resolution is to remove the test 
entirely, since I don't think it's ever valid to have a socket that 
doesn't have a sk_wq (there's a _lot_ of unconditional use of sk_sleep()).

		Linus
