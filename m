From: =?UTF-8?B?QXNiasO4cm4gU2xvdGggVMO4bm5lc2Vu?= <ast@fiberby.net>
Subject: Bridge VLAN kernel/iproute2 incompatibility
Date: Mon, 12 Aug 2013 16:24:06 +0000
Message-ID: <52090C26.4090001@fiberby.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Let's start with a little history:

=46eb 20:   Vlad Yasevich got his VLAN-aware bridge patchset included i=
n
          the 3.9 merge window.
          In the kernel commit 6cbdceeb, he added attribute support to
          bridge GETLINK requests sent with rtgenmsg.

Mar 6th:  Vlad got this iproute2 reference implementation of the bridge
          vlan netlink interface accepted (iproute2 9eff0e5c)

Apr 25th: iproute2 switched from using rtgenmsg to ifinfomsg (63338dca)
          http://patchwork.ozlabs.org/patch/239602/
          http://marc.info/?t=3D136680900700007

Apr 28th: Linus released 3.9

Apr 30th: Stephen released iproute2 3.9.0

The `bridge vlan show` command haven't been working since the switch to
ifinfomsg, or in a released version of iproute2. Since the kernel side
only supports rtgenmsg, which iproute2 switched away from just prior to
the iproute2 3.9.0 release.

I haven't been able to find any documentation, about neither rtgenmsg
nor ifinfomsg, and in which situation to use which, but kernel commit
88c5b5ce seams to suggest that ifinfomsg should be used.

=46ixing this in kernel will break compatibility, but I doubt that anyb=
ody
have been using it due to this bug in the user space reference
implementation, at least not without noticing this bug. That said the
functionality is still fully functional in 3.9, when reversing iproute2
commit 63338dca.

This could also be fixed in iproute2, but thats an ugly patch that woul=
d
reintroduce rtgenmsg in iproute2, and from searching in netdev it seams
like rtgenmsg usage is discouraged. I'm assuming that the only reason
that Vlad implemented the kernel side to use rtgenmsg, was because
iproute2 was using it at the time.

I will reply with kernel patch, I can also post the alternative iproute=
2
patch if requested.

--=20
Best regards
Asbj=C3=B8rn Sloth T=C3=B8nnesen
Network engineer
=46iberby ApS - AS42541
