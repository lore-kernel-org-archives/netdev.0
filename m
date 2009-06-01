From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Mon, 01 Jun 2009 18:06:03 -0400
Message-ID: <1243893963.3966.325.camel@dogo.mojatatu.com>
References: <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <1243684218.3966.83.camel@dogo.mojatatu.com>
	 <20090531081213.GC2756@ami.dom.local>
	 <1243776293.3966.241.camel@dogo.mojatatu.com>
	 <20090531195557.GA2777@ami.dom.local>
	 <1243813216.3966.254.camel@dogo.mojatatu.com>
	 <20090601060638.GA4256@ff.dom.local>
	 <1243861410.3966.268.camel@dogo.mojatatu.com>
	 <20090601204957.GA2760@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:10745 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbZFAWHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 18:07:03 -0400
Received: by qw-out-2122.google.com with SMTP id 5so5295068qwd.37
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2009 15:07:05 -0700 (PDT)
In-Reply-To: <20090601204957.GA2760@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-01 at 22:49 +0200, Jarek Poplawski wrote:

> 
> Actually, I'd insist with the old rock and handling that other rude
> u32 case, at least until it's fixed in place. So I attach my version
> of your patch (additionally I removed a pair of braces because of
> checkpatch warning).

Sure, it doesnt complicate anything - Minoru, this is the version to go
for.

> Alas, I still think we don't need to change so much in -stable to
> fix the cls_cgroup oops, so I attach a patch which I think is
> enough for -stable and probably -net too. It could be "reverted"
> in -net-next just after applying cls_api patch. Of course, treat
> it only as my humble proposal, and feel free to recommend to David
> your version, no problem (really).


My view is the same - that the second patch doesnt fix the root
cause; and it is not that complicated to fix the root cause. So I humbly
disagree with you.

The issue is that a classifer (cls_group in this example) is being
misconfigured. It rejects the config - but the tp has already been
added. 
It then tries to use the tp in the fast and fails. 

If you look as closely as you did with the patch i posted, youd find
ways to construct similar hostile misconfigs for other classifiers.
You just need to create the scenario where the attributes will fail to
validate. 

I actually suspect the most common scenario for such a failure is not
that head is null (I doubt in Minoru case that allocation will fail);
rather it is some reference to head->something.

cheers,
jamal

