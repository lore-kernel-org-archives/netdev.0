From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igmp: Make igmp group member RFC 3376 compliant
Date: Wed, 16 Nov 2016 11:19:43 -0500 (EST)
Message-ID: <20161116.111943.1827868712701090468.davem@davemloft.net>
References: <20161107.201345.1974283028907025304.davem@davemloft.net>
        <20161108092625.GA14456@sparky-lenivo.brq.redhat.com>
        <20161116062045.GB17935@leo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtesar@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org
To: haliu@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43560 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753032AbcKPQTr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 11:19:47 -0500
In-Reply-To: <20161116062045.GB17935@leo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hangbin Liu <haliu@redhat.com>
Date: Wed, 16 Nov 2016 14:20:45 +0800

> Hi David,
> 
> On Tue, Nov 08, 2016 at 10:26:25AM +0100, Michal Tesar wrote:
>> On Mon, Nov 07, 2016 at 08:13:45PM -0500, David Miller wrote:
>> 
>> > From: Michal Tesar <mtesar@redhat.com>
>> > Date: Thu, 3 Nov 2016 10:38:34 +0100
>> > 
>> > >  2. If the received Query is a General Query, the interface timer is
>> > >     used to schedule a response to the General Query after the
>> > >     selected delay.  Any previously pending response to a General
>> > >     Query is canceled.
>> > > --8<--
>> > > 
>> > > Currently the timer is rearmed with new random expiration time for
>> > > every incoming query regardless of possibly already pending report.
>> > > Which is not aligned with the above RFE.
>> > 
>> > I don't read it that way.  #2 says if this is a general query then any
>> > pending response to a general query is cancelled.  And that's
>> > effectively what the code is doing right now.
>> 
>> Hi David,
>> I think that it is important to notice that the RFC says also 
>> that only the first matching rule is applied.
>> 
>> "
>> When new Query with the Router-Alert option arrives on an
>> interface, provided the system has state to report, a delay for a
>> response is randomly selected in the range (0, [Max Resp Time]) where
>> Max Resp Time is derived from Max Resp Code in the received Query
>> message.  The following rules are then used to determine if a Report
>> needs to be scheduled and the type of Report to schedule.  The rules
>> are considered in order and only the first matching rule is applied.
> 
>  ^^
> 
> Would you like to reconsider about this? I also agree with Michal that we
> need to choose the sooner timer. Or if we receive query very quickly, we
> will keep refresh the timer and may never reply the report.

I'm still thinking about this, please be patient, I review a hundred
patches or more per day so it takes me time to get to tasks that
require deep thinking or real consideration on any level.
