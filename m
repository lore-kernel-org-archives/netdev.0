From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 6/7] openvswitch: Add force commit.
Date: Tue, 7 Feb 2017 09:14:34 -0800
Message-ID: <CAOrHB_CLwEno6_0WHMwEPx6apwg85WyCCYR4E-tOPKp5L1FSnw@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
 <1486084206-109903-6-git-send-email-jarno@ovn.org> <CAOrHB_DgjJ9cYpnAeS_dtt0d=rTxhtR4wH_OU_o-tunWUHfddQ@mail.gmail.com>
 <CAPWQB7Hy02uM+kqnhgwhq0OhqnQUWTzWjtAeqaz6T2W55AD2pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:32910 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754502AbdBGROj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:14:39 -0500
Received: from mfilter2-d.gandi.net (mfilter2-d.gandi.net [217.70.178.140])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id AFD91FB8A3
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 18:14:36 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter2-d.gandi.net (mfilter2-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id qwD8PKIsM7x1 for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 18:14:35 +0100 (CET)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 55976FB88B
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 18:14:35 +0100 (CET)
Received: by mail-wm0-f43.google.com with SMTP id c85so169900237wmi.1
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 09:14:35 -0800 (PST)
In-Reply-To: <CAPWQB7Hy02uM+kqnhgwhq0OhqnQUWTzWjtAeqaz6T2W55AD2pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 11:28 PM, Joe Stringer <joe@ovn.org> wrote:
> On 6 February 2017 at 09:08, Pravin Shelar <pshelar@ovn.org> wrote:
>> On Thu, Feb 2, 2017 at 5:10 PM, Jarno Rajahalme <jarno@ovn.org> wrote:
>>> Stateful network admission policy may allow connections to one
>>> direction and reject connections initiated in the other direction.
>>> After policy change it is possible that for a new connection an
>>> overlapping conntrack entry already exist, where the connection
>>> original direction is opposed to the new connection's initial packet.
>>>
>>> Most importantly, conntrack state relating to the current packet gets
>>> the "reply" designation based on whether the original direction tuple
>>> or the reply direction tuple matched.  If this "directionality" is
>>> wrong w.r.t. to the stateful network admission policy it may happen
>>> that packets in neither direction are correctly admitted.
>>>
>> Why not have the check in all commit actions? I am not sure in which
>> case user would not want forced commit considering this can cause
>> packet admission issue?
>
> Seems like this case has involved one direction of a connection being
> handled by a flow that committed the connection. Then something has
> changed and you end up with a flow handling the opposite direction,
> committing the connection. What if the first flow wasn't actually
> removed? Plausibly you could end up with constant ct entry churn as
> the connection is recreated each time there is a packet from an
> alternating direction. Having a separate flag may assist with respect
> to shooting one's own foot..

I see. Thanks for explanation.
