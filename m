From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Wed, 17 Aug 2016 10:48:14 -0700
Message-ID: <20160817174813.GA98226@ast-mbp.thefacebook.com>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-4-git-send-email-daniel@zonque.org>
 <20160817142047.GB4021@htj.duckdns.org>
 <95e8b773-416f-72cc-4045-dd10d94e6484@zonque.org>
 <20160817150646.GB6299@htj.duckdns.org>
 <7e607709-eca0-2ab6-2379-99cec519d859@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@fb.com>, daniel@iogearbox.net, ast@fb.com,
	davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33756 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbcHQRsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 13:48:21 -0400
Received: by mail-pf0-f196.google.com with SMTP id i6so8489588pfe.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 10:48:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <7e607709-eca0-2ab6-2379-99cec519d859@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 05:51:44PM +0200, Daniel Mack wrote:
> On 08/17/2016 05:06 PM, Tejun Heo wrote:
> > What I'd suggest is keeping two sets of pointers, one set for the
> > programs explicitly attached to the cgroup and the other for programs
> > which are to be executed for the cgroup.  The two pointers in the
> > latter set will point to the closest non-null program in its ancestry.
> > Note that the pointers may point to programs belonging to different
> > ancestors.
> > 
> > 	A - B - C
> >               \ D - E
> > 
> > Let's say B has both ingress and egress programs and D only has
> > egress.  E's execution pointers should point to D's egress program and
> > B's ingress program.
> > 
> > The pointers would need to be updated
> > 
> > 1. When a program is installed or removed.  For simplicity's sake, we
> >    can just walk the whole hierarchy.  If that's too expensive
> >    (shouldn't be), we can find out the closest ancestor where both
> >    programs can be determined and then walk from there.
> > 
> > 2. When a new cgroup is created, it should inherit its execution table
> >    from its parent.
> 
> Ok, yes, that sounds sane to me. Will implement that scheme.

That makes sense to me as well. Sounds quite flexible and fast
with only one check per packet per direction.
