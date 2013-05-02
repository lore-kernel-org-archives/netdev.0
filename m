From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Wed, 1 May 2013 21:37:38 -0700
Message-ID: <CA+55aFzinZSQAS6GW6vYOyQ06+GSMqkCGb8Fu829s_MxY0L0QA@mail.gmail.com>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
	<CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	hayeswang <hayeswang@realtek.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:62060 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab3EBEhj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 00:37:39 -0400
In-Reply-To: <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 1, 2013 at 6:28 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Lowlight: it completely breaks my machine with r8169 ethernet.  In th=
e
> networkmanager applet, it claims no cable connection, which is a bit
> odd, because (a) it works with an older kernel and (b) the kernel
> messages actually say
>
>   r8169 0000:01:00.0 eth0: link up
>
> but nothing actually works.
>
>  r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>  r8169 0000:01:00.0 eth0: RTL8168d/8111d at 0xffffc90010ece000,
> e0:cb:4e:95:1a:d7, XID 083000c0 IRQ 53
>  r8169 0000:01:00.0 eth0: jumbo features [frames: 9200 bytes, tx
> checksumming: ko]
>
> Any ideas?

Hmm. I bisected it.

And my machine is broken by commit 8ad227ff89a7 ("net: vlan: add
802.1ad support"). I booted several times just to make sure, and it's
consistent. The previous commit (86a9bad3ab6b) works fine, and
8ad227ff89a7 is broken.

I don't see what could be broken in that commit, and I'd *like* to
just revert it on top of current -git, but that causes problems
("error: =E2=80=98NETIF_F_HW_VLAN_STAG_TX_BIT=E2=80=99 undeclared"), so=
 I can't just
do a straight revert to double-check with the current tree state. But
the bisection was very straightforward, and as mentioned, I checked
that boundary several times just because it looked so odd.

Maybe somebody who knows the code better just goes "Duh!". Anybody?

                Linus
