From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 2/2] netpoll: Don't poll for received packets
Date: Thu, 13 Mar 2014 13:48:29 -0700
Message-ID: <8738il6d0i.fsf@xmission.com>
References: <871ty9qvaf.fsf_-_@xmission.com> <87vbvlpgnk.fsf_-_@xmission.com>
	<1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com> <87wqg1dsyw.fsf_-_@xmission.com>
	<CAM_iQpVRkHR7_coMDUSLkVmhAgbO==b4BVPuKTMpKz+SRz=WjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Satyam Sharma <satyam.sharma@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:55214 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbaCMUsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 16:48:36 -0400
In-Reply-To: <CAM_iQpVRkHR7_coMDUSLkVmhAgbO==b4BVPuKTMpKz+SRz=WjA@mail.gmail.com>
	(Cong Wang's message of "Wed, 12 Mar 2014 11:39:49 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> writes:

> On Tue, Mar 11, 2014 at 1:45 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> -       work = napi->poll(napi, budget);
>> -       trace_napi_poll(napi);
>> +       /* Use a budget of 0 to request the drivers not process
>> +        * their receive queue.  Warn when they do anyway.
>> +        */
>> +       work = napi->poll(napi, 0);
>> +       WARN_ON_ONCE(work != 0);
>>
>
> Adding more printk's in netpoll call path would only bring more
> troubles.

That is why I used WARN_ON_ONCE.  So we are alerted to problems but
because it only prints once service won't be denied if nothing except
that warning cares.

Eric
