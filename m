From: Roland Dreier <roland@topspin.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: 12 May 2004 15:05:07 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <52hdul9u98.fsf@topspin.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org>
	<20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com>
	<20040512193349.GA14936@elte.hu>
	<Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
	<20040512200305.GA16078@elte.hu>
	<Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com>
	<20040512211255.GA20800@elte.hu>
	<1084398565.27252.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	Davide Libenzi <davidel@xmailserver.org>,
	Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S261439AbUELWF0@vger.kernel.org>
To: Zan Lynx <zlynx@acm.org>
In-Reply-To: <1084398565.27252.42.camel@localhost.localdomain>
List-Id: netdev.vger.kernel.org

  > Being curious, I tried that and got the same results.  But this:
  > 
  > int f(unsigned int x)
  > {
  >         return x * (1000 / 1000);
  > }
  > 
  > creates this:
  > f:
  >         pushl   %ebp
  >         movl    %esp, %ebp
  >         movl    8(%ebp), %eax
  >         leave
  >         ret

Of course the compiler can optimize (1000 / 1000) into 1 at compile
time.  However, the original code was doing something like

	x * HZ / 1000

if you change that to

	x * (HZ / 1000)

then obviously that breaks if HZ is not a multiple of 1000.

 - Roland
