From: "Tom Herbert" <therbert@google.com>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Tue, 11 Mar 2008 09:20:55 -0700
Message-ID: <65634d660803110920g5103dc60ya055a10f999b4e25@mail.gmail.com>
References: <20080305205116.5989A412541@localhost>
	 <20080305.132112.01598419.davem@davemloft.net>
	 <47D19147.9070609@qualcomm.com>
	 <36D9DB17C6DE9E40B059440DB8D95F52049D5CE5@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Max Krasnyanskiy" <maxk@qualcomm.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Steven Rostedt" <rostedt@goodmis.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:34634 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbYCKQVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 12:21:06 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m2BGKwR4003991
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 09:20:58 -0700
Received: from wr-out-0506.google.com (wrac55.prod.google.com [10.54.54.55])
	by zps38.corp.google.com with ESMTP id m2BGKW9V018434
	for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 09:20:58 -0700
Received: by wr-out-0506.google.com with SMTP id c55so1595056wra.11
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2008 09:20:58 -0700 (PDT)
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52049D5CE5@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  Could we use something like this to reschedule NAPI onto other
>  processors?  If we get unlucky enough to have multiple napi routines
>  polling on a single CPU, and one or more completely idle CPUs (idle at
>  least for softirq) then we could really use one or the other of these
>  solutions.

Jesse,

This patch does provide a general mechanism to schedule (or
reschedule) NAPI to other CPUs.  We implemented two scheduling
algorithms: 1) round robin scheduling of NAPI poll function across a
set of CPUs on a per device basis 2) scheduling stack processing by
directing packets to a CPU (using backlog queue); a hash is done on
the 4-tuple to direct the packets for a connection to same CPU thus
emulating HW RSS (we will add support for those devices that can
provide the computed hash per packet).

An algorithm that reschedules NAPI based on load is possible.  In the
case you described, maybe the scheduling could take into account the
number of devices in the poll list for the CPU.

Tom
