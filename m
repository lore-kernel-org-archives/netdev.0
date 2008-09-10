From: "Ranjit Manomohan" <ranjitm@google.com>
Subject: Re: [PATCH 0/2] Traffic control cgroups subsystem
Date: Wed, 10 Sep 2008 16:37:57 -0700
Message-ID: <166fe7950809101637o1bf22869g4939707a35a3c93b@mail.gmail.com>
References: <Pine.LNX.4.64.0809101026190.7050@ranjit.corp.google.com>
	 <20080910.132251.73509521.davem@davemloft.net>
	 <166fe7950809101344l7a5e2b7pfba8b2a7c03814a1@mail.gmail.com>
	 <20080910221206.GI20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	akpm@linux-foundation.org, lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:7430 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbYIJXiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:38:09 -0400
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id m8ANbxfR008344
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 00:37:59 +0100
Received: from rv-out-0708.google.com (rvbk29.prod.google.com [10.140.87.29])
	by spaceape13.eur.corp.google.com with ESMTP id m8ANbvgA013564
	for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:37:58 -0700
Received: by rv-out-0708.google.com with SMTP id k29so83898rvb.0
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 16:37:57 -0700 (PDT)
In-Reply-To: <20080910221206.GI20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2008 at 3:12 PM, Thomas Graf <tgraf@suug.ch> wrote:
> * Ranjit Manomohan <ranjitm@google.com> 2008-09-10 13:44
>> On Wed, Sep 10, 2008 at 1:22 PM, David Miller <davem@davemloft.net> wrote:
>> >
>> > I definitely prefer Thomas Graf's work, this stuff is very ugly
>> > and way overengineered.
>> >
>>
>> Could you be more specific? Thomas' work is almost identical to this
>> (except that he does not store the cgroup id into the socket which is
>> a trivial change which has downsides which I have pointed out).
>>
>> Additionally this approach has only minor modifications to the core
>> networking stack. What portions do you consider ugly and over
>> engineered and what alternative implementations would you prefer?
>> Please see the follow up I have sent to Thomas' proposal about why we
>> need this design approach to handle the inbound case.
>
> WRT the inbound case, after some experiments I decided to dismiss the
> ingress case at all and stick to something as simple as possible for
> egress. The reason for this is that it is a very expensive operation
> to associate a packet with a task on classifier level. Taking this
> cost, it does not add up with the very limited capabilities of ingress
> shaping. Ingress shaping is best effort at best. It works fairly well
> with a very limited number of bulk data streams but usualy fails
> miserably in common congestion situations where a cgroup classifier
> would be useful.

Could you elaborate on the failure cases? We have found this to be
useful in practice to prevent applications from reading large amounts
of data off the network so it would be nice if it were supported.

-Thanks,
Ranjit
>
>> I'd be ok if you accepted either change since  we just want a standard
>> kernel mechanism to do this.
>
> Agreed. I think your approach is very reasonable but considering the
> reasons I've given above and in the other thread I found it could be done
> in a more simple and direct way.
>
