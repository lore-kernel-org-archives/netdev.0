From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/3] ser_gigaset: fix up NULL checks
Date: Tue, 8 Dec 2015 22:16:57 +0000
Message-ID: <20151208221657.71fd0d71@lxorguk.ukuu.org.uk>
References: <cover.1449570042.git.tilman@imap.cc>
	<ed83fae92c8c56e659f59c9a3709c86bd3a7d0c4.1449570042.git.tilman@imap.cc>
	<1449603913.2384.16.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449603913.2384.16.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Should we backport this all the way to v2.6.32 (currently the oldest
> stable tree)?

We need to be able to explain how the case being tested can occur, then
explain the situation in which it actually prevents a race condition.

If nobody can do that then it shouldn't be backported because its change
without value and just risk. 

The right fix as far as I can see is to remove the tests although
WARN_ON() combined with your tty->ops change might be safer.

> It's pretty obvious that this should have been part of commit
>  f34d7a5b7010 ("tty: The big operations rework"). That being said, these

It ahould probably have been fixed around the same time or in one of the
tty locking reviews, but drivers/isdn and net/irda weren't traditionally
part of the general tty maintenance but handled separately/

> test puzzle me. It's not obvious why they're needed. Ie, can the null
> dereferences they try to catch really happen? But I can try to figure
> out that in the future, if I ever feel the urge to do so. Anyhow:
> 
> Acked-by: Paul Bolle <pebolle@tiscali.nl>

Nacked-by: Alan Cox <alan@linux.intel.com>
