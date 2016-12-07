From: Michal Tesar <mtesar@redhat.com>
Subject: Re: [PATCH] igmp: Make igmp group member RFC 3376 compliant
Date: Wed, 7 Dec 2016 13:38:57 +0100
Message-ID: <20161207123857.GA3632@sparky-lenivo.brq.redhat.com>
References: <20161107.201345.1974283028907025304.davem@davemloft.net>
 <20161108092625.GA14456@sparky-lenivo.brq.redhat.com>
 <20161116062045.GB17935@leo.usersys.redhat.com>
 <20161116.111943.1827868712701090468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: haliu@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:34912 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbcLGMjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:39:00 -0500
Received: by mail-wj0-f181.google.com with SMTP id v7so359358237wjy.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 04:38:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161116.111943.1827868712701090468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 11:19:43AM -0500, David Miller wrote:

> From: Hangbin Liu <haliu@redhat.com>
> Date: Wed, 16 Nov 2016 14:20:45 +0800
> 
> > Hi David,
> > 
> > On Tue, Nov 08, 2016 at 10:26:25AM +0100, Michal Tesar wrote:
> >> On Mon, Nov 07, 2016 at 08:13:45PM -0500, David Miller wrote:
> >> 
> >> > From: Michal Tesar <mtesar@redhat.com>
> >> > Date: Thu, 3 Nov 2016 10:38:34 +0100
> >> > 
> >> > >  2. If the received Query is a General Query, the interface timer is
> >> > >     used to schedule a response to the General Query after the
> >> > >     selected delay.  Any previously pending response to a General
> >> > >     Query is canceled.
> >> > > --8<--
> >> > > 
> >> > > Currently the timer is rearmed with new random expiration time for
> >> > > every incoming query regardless of possibly already pending report.
> >> > > Which is not aligned with the above RFE.
> >> > 
> >> > I don't read it that way.  #2 says if this is a general query then any
> >> > pending response to a general query is cancelled.  And that's
> >> > effectively what the code is doing right now.
> >> 
> >> Hi David,
> >> I think that it is important to notice that the RFC says also 
> >> that only the first matching rule is applied.
> >> 
> >> "
> >> When new Query with the Router-Alert option arrives on an
> >> interface, provided the system has state to report, a delay for a
> >> response is randomly selected in the range (0, [Max Resp Time]) where
> >> Max Resp Time is derived from Max Resp Code in the received Query
> >> message.  The following rules are then used to determine if a Report
> >> needs to be scheduled and the type of Report to schedule.  The rules
> >> are considered in order and only the first matching rule is applied.
> > 
> >  ^^
> > 
> > Would you like to reconsider about this? I also agree with Michal that we
> > need to choose the sooner timer. Or if we receive query very quickly, we
> > will keep refresh the timer and may never reply the report.
> 
> I'm still thinking about this, please be patient, I review a hundred
> patches or more per day so it takes me time to get to tasks that
> require deep thinking or real consideration on any level.

Hi Dave,
would it be possible to have another look at this patch and reconsider
its behavior? I really believe that current code does not behave
correctly.

Best regards Michal Tesar
