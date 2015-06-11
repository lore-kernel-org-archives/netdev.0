From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 1/3 v3] net: track link-status of ipv4 nexthops
Date: Thu, 11 Jun 2015 07:50:54 -0700
Message-ID: <5579A04E.2060400@redhat.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com> <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com> <CAE4R7bAnPDA_S=tjaM-qLbb4ZM0_FcTPQH6jC7_Mgmc==1c6wA@mail.gmail.com> <20150611112313.GA588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbbFKOuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 10:50:55 -0400
In-Reply-To: <20150611112313.GA588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/11/2015 04:23 AM, Andy Gospodarek wrote:
> On Wed, Jun 10, 2015 at 11:07:28PM -0700, Scott Feldman wrote:
>> On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
>> <gospo@cumulusnetworks.com> wrote:
>>> Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
>>> reachable via an interface where carrier is off.  No action is taken,
>>> but additional flags are passed to userspace to indicate carrier status.
>> Andy, it seems now RTNH_F_LINKDOWN and RTNH_F_DEAD are very similar
>> and I'm wondering if this could be done without introducing a new flag
>> and just use RTNH_F_DEAD.  The link change event would set RTNH_F_DEAD
>> on nh on dev link down, and clear on link up.  The sysctl knob would
>> be something like "nexthop_dead_on_linkdown", default off.  So
>> basically expanding the ways RTNH_F_DEAD can be set.  That would
>> simplify the patch set quite a bit and require no changes to iproute2.
>>
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
>   this point I think I prefer the additional data provided by the new
> flag exported to userspace.

I preferred the 2 flag solution as the original solution still required 
2 flags, it just only exposed 1 to user-space.  As a result it was much 
more error prone since it was fairly easy to get into a confused state 
about why the link was dead.

With the 2 flag solution it becomes much easier to sort out why the 
route is not functional and it is much easier to isolate for things like 
the sysctl which only disables the use of LINKDOWN and not DEAD.

- Alex
