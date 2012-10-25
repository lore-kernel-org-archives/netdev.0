From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [RFC] back on nf_tables (plus compatibility layer)
Date: Fri, 26 Oct 2012 00:02:56 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1210252352420.13437@nerf07.vanv.qr>
References: <20121025170632.GA4890@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:56397 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab2JYWC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 18:02:57 -0400
In-Reply-To: <20121025170632.GA4890@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 2012-10-25 19:06, Pablo Neira Ayuso wrote:

>Hi,
>
>I've been working for a while to recover nf_tables kernel patches and
>to implement a compatibility layer so it can be used with existing
>x_tables target/match extensions. [...]
>2) Provide a fast path to merge this into mainstream. We'll have both
>   iptables and nftables interfaces during some time in the Linux kernel,
>   then remove iptables infrastructure at some point. iptables scripts
>   would not break as we'll have the iptables emulation over nftables.
>[...]
>One final thing: nftables does not support atomic table commit. The
>point here is if we really need this for the emulation utility or we
>can live without that. Implementing atomic table replacement in
>nftables is not trivial. I have hard time to find this commit table
>feature useful.

Meanwhile, I am on xtables2 that actually reproduces the set of
_really important_ features that currently are in the setsockopt
iptables, like atomic table replace and atomic dump.

I have updated to the newest tree, and the first set is
available in the git repository at:
  git://git.inai.de/linux xt2-20121025
----------------------------------------------------------------
      netfilter: xtables2: initial table skeletal functions
      netfilter: xtables2: initial Netlink interface
      netfilter: xtables2: chain creation and deletion
      netfilter: xtables2: chain renaming support
      netfilter: xtables2: transaction commit operation
      netfilter: xtables2: table replace support
      netfilter: xtables2: transaction abort support
      netfilter: xtables2: redirect writes into transaction buffer
      netfilter: xtables2: supply a revision number

 include/net/netfilter/xt_core.h                  |   48 ++
 include/uapi/linux/netfilter/Kbuild              |    1 +
 include/uapi/linux/netfilter/nfnetlink.h         |    3 +-
 include/uapi/linux/netfilter/nfnetlink_xtables.h |   52 ++
 net/netfilter/Kconfig                            |    8 +-
 net/netfilter/Makefile                           |    2 +
 net/netfilter/xt_core.c                          |  204 ++++++++
 net/netfilter/xt_nfnetlink.c                     |  602 ++++++++++++++++++++++
 net/netfilter/xt_nfnetlink.h                     |    7 +
 9 files changed, 925 insertions(+), 2 deletions(-)
 create mode 100644 include/net/netfilter/xt_core.h
 create mode 100644 include/uapi/linux/netfilter/nfnetlink_xtables.h
 create mode 100644 net/netfilter/xt_core.c
 create mode 100644 net/netfilter/xt_nfnetlink.c
 create mode 100644 net/netfilter/xt_nfnetlink.h
---snip---

with userspace
available in the git repository at:
  git://git.inai.de/libnetfilter_xtables master

which contains a test utility xtnl-test to try the code paths that
have been added so far on the kernel side.

Getting the locking right is sort of a time killer; I hope
Eric Dumazet might get interested to have a look on that part,
since he has done so much w.r.t. locking in ip_tables already :)
