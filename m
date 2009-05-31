From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 09:24:53 -0400
Message-ID: <1243776293.3966.241.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	 <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <1243684218.3966.83.camel@dogo.mojatatu.com>
	 <20090531081213.GC2756@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:4950 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbZEaNZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 09:25:51 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4689999qwd.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 06:25:53 -0700 (PDT)
In-Reply-To: <20090531081213.GC2756@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-05-31 at 10:12 +0200, Jarek Poplawski wrote:

> If somebody runs tc add filter with a new priority but existing handle
> a newly created (and not linked now) tc would be handled with goto
> errout and would leak, I guess.

This would imply the classifier is buggy. I will stare at the different
classifier - and if any exhibits such traits it needs to be fixed

> The change (in the two spots) is:
> > +               if (n->nlmsg_type == RTM_NEWTFILTER &&
> > +                   (n->nlmsg_flags&(NLM_F_CREATE|NLM_F_EXCL))) {
> > 
> 
> Sorry, but I don't think this change is enough; tc filter replace
> with only this (n->nlmsg_type == RTM_NEWTFILTER &&
> (n->nlmsg_flags&(NLM_F_CREATE))) can get here with an "old" tp
> and will relink it or destroy depending on the ->change() return.
> 

Excellent point - there could be buggy user space apps that will do
that. Minoru change the check to:

+               if (n->nlmsg_type == RTM_NEWTFILTER &&
+                   (n->nlmsg_flags&NLM_F_CREATE &&
+                    n->nlmsg_flags&NLM_F_EXCL)) {

cheers,
jamal

