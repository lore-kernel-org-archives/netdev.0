From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 11:22:42 -0700
Message-ID: <AANLkTimnBqkiO26wqEQOm+AgSJgQLtQmAe8R-kB6CqtZ@mail.gmail.com>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<87sk1kiu5m.fsf@basil.nowhere.org>
	<201009081142.31610.sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: b.a.t.m.a.n@lists.open-mesh.org, Andi Kleen <andi@firstfloor.org>,
	davem@davemloft.net, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.net
To: Sven Eckelmann <sven.eckelmann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:48675 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab0IHSWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 14:22:44 -0400
Received: by iwn5 with SMTP id 5so207574iwn.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 11:22:43 -0700 (PDT)
In-Reply-To: <201009081142.31610.sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 8, 2010 at 2:42 AM, Sven Eckelmann <sven.eckelmann@gmx.de> wrote:
> Hi,
>
> here are some raw references without any judgment. Maybe Marek will send some
> more information about that topic later.
>
> Andi Kleen wrote:
>> Sven Eckelmann <sven.eckelmann@gmx.de> writes:
>> > B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
>> > protocol for multi-hop ad-hoc mesh networks. The networks may be wired or
>> > wireless. See http://www.open-mesh.org/ for more information and user
>> > space tools.
>>
>> It seems rather unusual to have the complete routing protocol in
>> kernel. And this is a lot of code. The normal way to do such things is
>> to have the routing policy etc. in a user daemon and only let the kernel
>> provide some services to this.
>>
>> Could you elaborate a bit why this approach was not chosen?
>>
>> I assume if it needs a switch it could have a switching "hot path" layer
>> in kernel and the policy somewhere else.

Potentially one way to do this is to build on top of Open vSwitch.  It
contains a pretty generic flow-based kernel module for forwarding data
packets and making simple modifications.  Control packets can be sent
to userspace to handle the routing logic, while data packets remain in
the kernel for performance.  This would dramatically reduce the amount
of code that needs to be in the kernel and may even help performance
by simplifying the fast path.

I don't know the details of your protocol well enough to know if this
is feasible but it seems like something you might want to look into.
Open vSwitch is currently in the process of finalizing its interfaces
to prepare for upstreaming.
