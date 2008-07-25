From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Traffic control cgroups subsystem
Date: Thu, 24 Jul 2008 21:18:21 -0400
Message-ID: <6599ad830807241818k5cb288e2l3e62a01c2f102913@mail.gmail.com>
References: <Pine.LNX.4.64.0807221041210.1091@ranjit.corp.google.com>
	 <20080724234553.GC20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ranjit Manomohan" <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	lizf@cn.fujitsu.com, kaber@trash.net
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:6097 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbYGYBSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 21:18:31 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id m6P1INrL016088
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 02:18:23 +0100
Received: from rv-out-0506.google.com (rvbg37.prod.google.com [10.140.83.37])
	by wpaz24.hot.corp.google.com with ESMTP id m6P1ILtm026168
	for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 18:18:22 -0700
Received: by rv-out-0506.google.com with SMTP id g37so2556819rvb.21
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2008 18:18:21 -0700 (PDT)
In-Reply-To: <20080724234553.GC20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 7:45 PM, Thomas Graf <tgraf@suug.ch> wrote:
>
> It might have been easier to simply write a classifier which maps pids
> to classes. The interface could be as simple as two nested attributes,
> ADD_MAPS, REMOVE_MAPS which both take lists of pid->class mappings to
> either add or remove from the classifier.

You mean as processes fork/exit or move between cgroups you have to
update the pid->class mappings in the kernel's filter? That sounds way
too fragile to me.

>
> I have been working on this over the past 2 weeks, it includes the
> classifier as just stated, a cgroup module which sends notifications
> about events

What types of events? We discussed how to send cgroup notifications to
userspace in the containers mini-summit on Tuesday. Netlink was one of
the options discussed, but suffers from the problem that netlink
sockets are tied to a particular network namespaces. The solution that
seemed most favoured was to have pollable cgroup control files that
represent events (and optionally support event data via a fifo).

> as netlink messages and a daemon which creates qdiscs,
> classes and filters on the fly according to the configured distribution.

> It works both ingress (with some tricks) and egress.
>
> IMHO, there is no point in a cgroup interface if the user has to create
> qdiscs, classes and filters manually anyway.
>

The user can use whatever middleware they want (e.g. your daemon,
libcg, etc) to set up qdiscs and classes. I don't think that requiring
any particular userspace implementation is the right way to go. The
point of this patch was to provide a minimal way to tag
sockets/packets as belonging to a particular cgroup, in order to make
use of the existing traffic controll APIs.

Paul
