From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Network privilege separation.
Date: Mon, 12 Jan 2009 21:14:35 +0100
Message-ID: <20090112201435.GC23848@one.firstfloor.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <12821.1231785850@turing-police.cc.vt.edu> <20090112194333.GB23848@one.firstfloor.org> <200901122147.57731.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Valdis.Kletnieks@vt.edu,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757233AbZALUAm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200901122147.57731.rdenis@simphalempin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Expanding the heap,

That's a problem agreed  Ok you can just always use very
bss arrays sized for the worst case.

> Getting timestamps. 

At least on 64bit that's done in ring 3 only with a vsyscall.

> Waiting on futexes, 
> catching signals, polling file descriptors. Seeking, doing vectorized I/O. 
> Cloning.

That all can be done by the frontend reading/feeding
data into the pipe. But it shouldn't directly access the user data
to be immune against attacks.

> Codecs don't like to read/write raw video through a pipe...

I don't think that's given. It would need some restructuring,
but I think the end result would be likely worth it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
