From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/3 v3] net: track link-status of ipv4 nexthops
Date: Thu, 11 Jun 2015 07:47:57 -0700
Message-ID: <CAE4R7bAp5eWzu9kAZiikmpwikr7pXbpfNYG6rn7LezSnNuRDEw@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
 <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bAnPDA_S=tjaM-qLbb4ZM0_FcTPQH6jC7_Mgmc==1c6wA@mail.gmail.com> <20150611112313.GA588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:35918 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbFKOsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 10:48:18 -0400
Received: by qgep100 with SMTP id p100so2705331qge.3
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 07:48:17 -0700 (PDT)
In-Reply-To: <20150611112313.GA588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 4:23 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Wed, Jun 10, 2015 at 11:07:28PM -0700, Scott Feldman wrote:
>> On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
>> <gospo@cumulusnetworks.com> wrote:
>> > Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
>> > reachable via an interface where carrier is off.  No action is taken,
>> > but additional flags are passed to userspace to indicate carrier status.
>>
>> Andy, it seems now RTNH_F_LINKDOWN and RTNH_F_DEAD are very similar
>> and I'm wondering if this could be done without introducing a new flag
>> and just use RTNH_F_DEAD.  The link change event would set RTNH_F_DEAD
>> on nh on dev link down, and clear on link up.  The sysctl knob would
>> be something like "nexthop_dead_on_linkdown", default off.  So
>> basically expanding the ways RTNH_F_DEAD can be set.  That would
>> simplify the patch set quite a bit and require no changes to iproute2.
>>
>
> You are absolutely correct that what you describe would be less churn to
> userspace.  From a functionality standpoint that is close to what was
> originally proposed, but Alex specifically did not like the behavioral
> change to what having RTNH_F_DEAD set (at least that was what I
> understood).
>
> That was what made me make the move to add this additional flag that was
> exported to userspace, so it was possible to differentiate the old dead
> routes/nexthop functionality from those that were not going to be dead
> due to link being down.

Why does user space need to know _why_ a nh is dead?  User space
already knows the state (admin/link) of the nh dev.

I not seeing why user space needs to differentiate why nh is dead.
The kernel only needs to know if nh is dead to exclude nh from ecmp
selection.  Same for an offload device.

Can you explain how this new flag provides user space more information
than what's already available from RTM_NEWLINK notifications?

> At this point I think I prefer the additional data provided by the new
> flag exported to userspace.
