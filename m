From: Ingo Molnar <mingo@elte.hu>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 22:03:05 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040512200305.GA16078@elte.hu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265212AbUELUIV@vger.kernel.org>
To: Davide Libenzi <davidel@xmailserver.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
List-Id: netdev.vger.kernel.org


* Davide Libenzi <davidel@xmailserver.org> wrote:

> > why is it wrong?
> 
> For HZ == 1000 it's fine, even if it'd better to explicitly make it HZ
> dependent and let the compiler to discard them.

the compiler cannot discard the multiplication and the division from the
following:

	x * 1000 / 1000

due to overflows. But we know that HZ is 1000 in the arch-dependent
param.h, and in sched.c we use the HZ dependent variant:

 #ifndef JIFFIES_TO_MSEC
 # define JIFFIES_TO_MSEC(x) ((x) * 1000 / HZ)
 #endif
 #ifndef MSEC_TO_JIFFIES
 # define MSEC_TO_JIFFIES(x) ((x) * HZ / 1000)
 #endif

	Ingo
