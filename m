From: Daniel Mack <daniel@zonque.org>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 17:51:44 +0200
Message-ID: <7e607709-eca0-2ab6-2379-99cec519d859@zonque.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-4-git-send-email-daniel@zonque.org>
 <20160817142047.GB4021@htj.duckdns.org>
 <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
 <20160817150646.GB6299@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
	kafai@fb.com, fw@strlen.de, pablo@netfilter.org, harald@redhat.com,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47751 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764AbcHQPxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 11:53:15 -0400
In-Reply-To: <20160817150646.GB6299@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2016 05:06 PM, Tejun Heo wrote:
> What I'd suggest is keeping two sets of pointers, one set for the
> programs explicitly attached to the cgroup and the other for programs
> which are to be executed for the cgroup.  The two pointers in the
> latter set will point to the closest non-null program in its ancestry.
> Note that the pointers may point to programs belonging to different
> ancestors.
> 
> 	A - B - C
>               \ D - E
> 
> Let's say B has both ingress and egress programs and D only has
> egress.  E's execution pointers should point to D's egress program and
> B's ingress program.
> 
> The pointers would need to be updated
> 
> 1. When a program is installed or removed.  For simplicity's sake, we
>    can just walk the whole hierarchy.  If that's too expensive
>    (shouldn't be), we can find out the closest ancestor where both
>    programs can be determined and then walk from there.
> 
> 2. When a new cgroup is created, it should inherit its execution table
>    from its parent.

Ok, yes, that sounds sane to me. Will implement that scheme.


Thanks!
Daniel
