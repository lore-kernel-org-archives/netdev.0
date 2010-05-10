From: kaber@trash.net
Subject: [PATCH 00/84] netfilter: netfilter update for 2.6.35
Date: Mon, 10 May 2010 22:17:31 +0200
Message-ID: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

appologies for not sending this earlier in smaller batches, as mentioned
earlier I ran into some problems with git. Following is a first netfilter
update for 2.6.35, containing:

- various smaller cleanups, optimizations, Kconfig updates etc.

- merging of the xt_MARK module with xt_mark and xt_CONNMARK with xt_connmark
  to decrease overhead when using modular kernels, saving 14k on 32 bit,
  from Jan

- scheduling of the NOTRACK module for removal, obsoleted by the CT module

- removal of the compat /proc directory of xt_recent

- addition of an entry reaper to the recent module, from Tim Gardner

- support for changing UID/GID of the recent /proc files, from Jan

- use of NFPROTO values in NF_HOOK calls in IPv4/IPv6/bridging/DECnet, from Jan

- a change to the xtables ->checkentry() function signature to support
  returning errno codes, from Jan

- removal of old revisions of the hashlimit, multiport and string matches,
  from Jan

- ctnetlink message size computation fixes with conntrack accounting,
  from Jiri Pirko

- hashlimit match RCU conversion, from Eric

- userspace queuing checksum fixes, from Herbert

- fixes for netfilter RCU warnings, from myself

- fixes for the LED target to avoid invalid errors when replacing the
  ruleset

- fixes for iproute compilation breakage due to XT_ALIGN cleanups, from
  Alexey Dobriyan

- bridge netfilter cleanups, simplification and comment updates from Bart

- bridge netfilter MAC header fixes when using DNAT

- bridge netfilter refragmentation fixes for PPPoe, from Bart

- a change to the IPv6 POST_ROUTING invocation to make it receive
  unfragmented packets like IPv4, from Jan

- a fix for the IPv6 xfrm lookup in ip6_route_me_harder, from Ulrich Weber

- more appropriate default log level (KERNL_NOTICE instead of KERN_EMERG) for
  the IPv4 and IPv6 LOG targets, from myself

- addition of the TEE target, which can be used to clone packets and send
  them to other hosts, f.i. IDS or logging hosts, from Jan

- a patch to make iptables and ip6tables reentrant by moving the jump stack
  to a seperately allocated area. This will allow to get rid of the per
  CPU ruleset duplication in the future. From Jan.

The patches won't apply cleanly because of some conflicts resolved during
merges, please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!

