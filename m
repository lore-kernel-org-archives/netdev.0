From: Alexei Starovoitov <ast@kernel.org>
Subject: Re: [PATCH net-next 1/2] net: filter: split filter.c into two files
Date: Wed, 23 Jul 2014 09:49:16 -0700
Message-ID: <20140723164915.GA5461@pg-vmw-gw1>
References: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
 <1406095319-3627-2-git-send-email-ast@plumgrid.com>
 <53CF522E.9090408@gmail.com>
 <53CF782C.2040401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Varka Bhadram <varkabhadram@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:53676 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757951AbaGWQtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 12:49:21 -0400
Content-Disposition: inline
In-Reply-To: <53CF782C.2040401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 10:54:04AM +0200, Daniel Borkmann wrote:
> On 07/23/2014 08:11 AM, Varka Bhadram wrote:
> >On 07/23/2014 11:31 AM, Alexei Starovoitov wrote:
> >>BPF is used in several kernel components. This split creates logical boundary
> >>between generic eBPF core and the rest
> >>
> >>kernel/bpf/core.c: eBPF interpreter
> >>
> >>net/core/filter.c: classic->eBPF converter, classic verifiers, socket filters
> >>
> >>This patch only moves functions.
> >
> >If we are moving the code also its good to do cleanup.
> >
> >Run checkpatch.pl on this...
> 
> Not sure what you understand as a cleanup, but there's nothing
> wrong with it and most things reported are either intentional or
> false positives as you might have seen already. The only thing

+1. interpreter code is quite polished already.
Few lines are longer than 80 char, but wrapping will look ugly.
The rest are false positives, since checkpatch is struggling to
understand jump-threaded code.

> one could do later on perhaps is to rename related functions to
> have consistently a 'bpf' prefix instead of 'sk' since they
> won't be under net/ anymore.

yes. it's on my todo list. The sk_* functions and 'struct sk_filter'
look out of place in kernel/bpf/*
The first renaming patch of sock_filter_int->bpf_insn I've sent as rfc:
http://patchwork.ozlabs.org/patch/371332/

'struct sk_filter' I'm thinking to rename as 'struct bpf_prog'

Speaking of kernel/bpf/* comment style...
I would prefer to keep networking comments to save lines.
