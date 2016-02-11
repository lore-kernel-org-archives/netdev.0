From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Thu, 11 Feb 2016 23:54:15 +0100
Message-ID: <1455231255.4135.46.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
	 <1454526665.14366.22.camel@tiscali.nl>
	 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
	 <1454591389.14366.49.camel@tiscali.nl>
	 <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
	 <1454593604.14366.65.camel@tiscali.nl>
	 <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
	 <1454598375.14366.72.camel@tiscali.nl>
	 <CACT4Y+aNN8AAtRSvxxrP5RfsTZdd49odnQ_GRq86Y=jXr=pANw@mail.gmail.com>
	 <1454688387.28847.34.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454688387.28847.34.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

On vr, 2016-02-05 at 17:06 +0100, Paul Bolle wrote:
> On vr, 2016-02-05 at 14:28 +0100, Dmitry Vyukov wrote:
> > I wonder why you don't see the leak I am seeing...
> 
> So do I, for a few days now.

0) I finally managed to reliably trigger this leak on an i686, single
core machine (yet another ThinkPad).

1) Note that on that machine the leak was noticeable under the kmalloc
-512 line (struct ser_cardstate is 456 bytes on that machine). I'm
_guessing_ the kmalloc-2048 line, which I stared at for quite some time,
is only relevant here for x86_64 and when there's a bit of
instrumentation, or whatever, added to the slab objects (as they are in
your VM?).

2) More important was that this i686 machine ran a tree that actually
included the offending commit:
	25cad69f21f5 ("base/platform: Fix platform drivers with no probe callback").

See, after staring at the gigaset code for way too long I decided to
just use brute force. Ie, I bisected this issue.

2) Anyhow, thanks again for the report. Now on to the next question: how
on earth does that commit make ser_gigaset leak struct ser_cardstate?

To be continued,


Paul Bolle
