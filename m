From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Sat, 22 May 2010 08:26:32 -0400
Message-ID: <20100522122632.GA2075@localhost.localdomain>
References: <20100520172918.GA17613@shamino.rdu.redhat.com>
 <20100520231630.GA22593@gondor.apana.org.au>
 <20100521003939.GA2223@localhost.localdomain>
 <20100520.224944.102694876.davem@davemloft.net>
 <20100521105128.GA29521@hmsreliant.think-freely.org>
 <20100521110847.GA29878@gondor.apana.org.au>
 <20100521164054.GB29521@hmsreliant.think-freely.org>
 <20100522014957.GA8779@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	bmb@athenacr.com, tgraf@redhat.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33456 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625Ab0EVM0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 08:26:44 -0400
Content-Disposition: inline
In-Reply-To: <20100522014957.GA8779@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 22, 2010 at 11:49:57AM +1000, Herbert Xu wrote:
> On Fri, May 21, 2010 at 12:40:54PM -0400, Neil Horman wrote:
> > 
> > There may also be an issue with the setting of the classid (possible use of the
> > wrong subsys id value when grabbing our cgroup_subsys_state), but I'm checking
> > on that now.
> 
> Actually, I think it's because my patch mistook CONFIG_CGROUP
> for CONFIG_CGROUPS.
> 
Thats definately part of it yes.  But its not all of it, although I think the
rest doesn't have anything to do with your patch.  I fixed that straight away,
but I was still alwasy getting classids of zero in the qemu processes.  Looking
at the cgroup classifier, I'm wondering how this cgroup code ever worked in the
first place.  When we register the cgroup subsystem, we don't register an attach
method, so we never get a chance to assign task_cls_sate(tsk)->classid to any
non-zero value.  I've got a version of the patch that add that, but for some
reason, even though I set task_cls_state(tsk)->classid to the cgroup classid on
attach, task_cls_classid still returns zero.  I'm not sure why that is yet, but
I'm looking into it.

Neil

> 
