From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [git patches] net driver fixes
Date: Thu, 16 Mar 2006 16:42:40 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0603161639450.3618@g5.osdl.org>
References: <20060317003041.GA28029@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Scott Bardone <sbardone@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752469AbWCQAmq@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20060317003041.GA28029@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Mar 2006, Jeff Garzik wrote:
>
> Please pull from 'upstream-fixes' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

The commit comments for the Chelsio driver fix are a bit unfortunate.

The array clearly _does_ have three elements, it's just that the code used 
to access the fourth (that didn't exist), and now it accesses the third.

So when the commit says "The array should contain 2 elements" it's just 
being really confused.

Of course, using an array index of "cmdQ_restarted[2]" without any 
explanation for why it's index 2, the bug was inevitable. Maybe a symbolic 
value for the magic array indices?

		Linus
