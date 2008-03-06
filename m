From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 6 Mar 2008 23:12:53 +0100
Message-ID: <20080306221253.GD2876@ami.dom.local>
References: <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local> <1204837000.4457.108.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:22903 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754702AbYCFWHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 17:07:01 -0500
Received: by py-out-1112.google.com with SMTP id u52so163414pyb.10
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 14:07:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1204837000.4457.108.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 03:56:40PM -0500, jamal wrote:
> On Thu, 2008-06-03 at 21:25 +0100, Jarek Poplawski wrote:
> 
> > It's really strange: I can't reproduce this, 
> 
> I couldnt either - are you using 2.6.25-rc4?

No, David's net-2.6 tree so 2.6.25-rc3 plus something...

> 
> > and if it were so easy we
> > would get really a lot of similar reports. It looks like you have
> > something special. This lockdep report with this kind of problem
> > usually looks different too. The good side is it's easy to reproduce.
> > So, could you try the patch below? (It's only supposed to fix the lockdep
> > warning, not lockups).
> 
> This is more out of ignorance: Why is ifb needing the extra teaching for
> lockdep? It is a netdevice - shouldnt the two global lockdeps you
> described earlier not be sufficient?

As I've written in the previous message, currently lockdep tracks
dev->queue_lock and dev->ingress_lock as only two locks used by all
net devices (unless they were annotated individually). So, it's like
A and B lock, and it's really not right to them AB in one place, and
BA in another. In reality each net_device's locks are independent,
so ifb has C and D. And it's not AB vs. BA, but: AB (eth/lo->queue_lock,
eth/lo->ingress_lock), CD (the same for ifb) and BC (eth/lo->ingress_lock,
ifb->queue_lock) - all legal combinations, and no inversion.

Cheers,
Jarek P.
