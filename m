From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v4] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 08:51:28 -0700
Message-ID: <o2k65634d661004160851wc00c609p7136a22fd07503c1@mail.gmail.com>
References: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>
	 <20100412171205.561a1aec@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, Ingo Molnar <mingo@elte.hu>,
	Paul Turner <pjt@google.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:43912 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758191Ab0DPPvb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 11:51:31 -0400
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o3GFpULO031181
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 08:51:30 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by kpbe11.cbf.corp.google.com with ESMTP id o3GFpST6032457
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 10:51:29 -0500
Received: by pwj4 with SMTP id 4so2018793pwj.8
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 08:51:28 -0700 (PDT)
In-Reply-To: <20100412171205.561a1aec@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are two sometimes conflicting models:
>
> One model is to have the flow's be dispersed and let the scheduler
> be smarter about running the applications on the right CPU's where
> the packets arrive.
>
> The other is to have the flows redirected to the CPU where the applic=
ation
> previously ran which is what RFS does.
>
> For benchmarks and private fixed configuration systems it is tempting
> to just nail everything down: i.e. use hard SMP affinity, for hardwar=
e, processes,
> and flows. =A0But this is the wrong solution for general purpose syst=
ems with
> varying workloads and requirements. =A0How well does RFS really work =
when
> applications, processes, and sockets come and go or get migrated amon=
g
> CPU's by the scheduler? My concern is this is overlapping scheduler
> design and might be a step backwards.
>
This is true.  There is a fundamental question of whether scheduler
should lead networking or vice versa.  The advantages of networking
following scheduler seem to become more apparent on heavily loaded
systems or with threads that handle more than one flow.

I'm not sure these two models have to be mutually exclusive, we are
looking at some ways to make a hybrid model.

The statement about pinning down resources is also true, we are
actively try to squash any instances this in our applications!

Tom

>
> --
>
