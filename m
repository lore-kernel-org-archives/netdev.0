From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: netjet requires VIRT_TO_BUS
Date: Fri, 15 Mar 2013 08:16:59 -0400 (EDT)
Message-ID: <20130315.081659.636423702994054939.davem@davemloft.net>
References: <1363298204-8014-4-git-send-email-arnd@arndb.de>
	<CAMuHMdVhjnX_hag5Y5VvDWVcjPK8tMM-qx-TQ2x=M88yTZQwYg@mail.gmail.com>
	<201303151015.00746.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: geert@linux-m68k.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, isdn@linux-pingi.de,
	netdev@vger.kernel.org, dhowells@redhat.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201303151015.00746.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 15 Mar 2013 10:15:00 +0000

> David Howells brought up the topic of endian checks recently, noting
> that the way we define __BIG_ENDIAN and __LITTLE_ENDIAN in the kernel
> is incompatible to how do it in user space, and not much better either.
> 
> A few architectures that are bi-endian (arc, arm, c6x, mips, sh) already
> have CONFIG_CPU_IS_LITTLE_ENDIAN and CONFIG_CPU_IS_BIG_ENDIAN. I guess
> it would be a good idea to provide these on all architectures.

I do not want to see us add such a Kconfig dependency knob.

Then the real tendency will exist to make new drivers little-endian
only, refuse to fix endian-broken old drivers, etc.

Which means that allmodconfig on my architecture will have build
coverage on less code, which is really the only thing that matters
for me.  I want all drivers that could be effected by my changes
to be compile testable on as many platforms as possible.
