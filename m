From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v4] net: sched: convert qdisc linked list to hashtable
Date: Thu, 28 Jul 2016 09:52:57 -0700
Message-ID: <CAM_iQpWbCuhG0_8ow=iszpJKMp4z-2gqoBf2gN6SDftyb2t54A@mail.gmail.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160414151813.GE3715@orbyte.nwl.cc> <alpine.LNX.2.00.1604141807350.27368@cbobk.fhfr.pm>
 <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
 <5710E1C1.2090209@mojatatu.com> <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LNX.2.00.1607071102010.24757@cbobk.fhfr.pm> <alpine.LNX.2.00.1607072234190.24757@cbobk.fhfr.pm>
 <alpine.LNX.2.00.1607111557080.24757@cbobk.fhfr.pm> <alpine.LNX.2.00.1607281155020.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35915 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932581AbcG1QxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 12:53:18 -0400
In-Reply-To: <alpine.LNX.2.00.1607281155020.24757@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 28, 2016 at 2:56 AM, Jiri Kosina <jikos@kernel.org> wrote:
> From: Jiri Kosina <jkosina@suse.cz>
>
> Convert the per-device linked list into a hashtable. The primary
> motivation for this change is that currently, we're not tracking all the
> qdiscs in hierarchy (e.g. excluding default qdiscs), as the lookup
> performed over the linked list by qdisc_match_from_root() is rather
> expensive.
>
> The ultimate goal is to get rid of hidden qdiscs completely, which will
> bring much more determinism in user experience.
>
> As we're adding hashtable.h include into generic netdevice.h, we have to
> make sure HASH_SIZE macro is now non-conflicting with local definitions.
>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
> v1 -> v2:     fix up RCU hastable usage wrt. rtnl
>               fix compilation of .c files which define their own
>               HASH_SIZE that now oncflicts with the one from
>               hashtable.h (newly included via netdevice.h)
>
> v2 -> v3:     resolve HASH_SIZE identifier conflicts in a cleaner way
>               fix up the number of hash bucket bits (4 bits for 16 buckets)
>
> v3 -> v4:     put the hastable into struct netdevice only if
>               CONFIG_NET_SCHED has been enabled

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
