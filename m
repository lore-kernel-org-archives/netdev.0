From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Tue, 14 May 2013 12:59:06 -0700
Message-ID: <5192978A.30300@intel.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com>  <1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com>  <CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com>  <1368146064.4131.279.camel@deadeye.wl.decadent.org.uk>  <CAJZOPZ+fe7wx=3Xod-PoF-v5s+s+L0j1VjakWNdv97V_u_CQfA@mail.gmail.com> <1368551556.2741.8.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52904 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757767Ab3ENT7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 May 2013 15:59:07 -0400
In-Reply-To: <1368551556.2741.8.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/14/2013 10:12 AM, Ben Hutchings wrote:
> On Mon, 2013-05-13 at 00:48 +0300, Or Gerlitz wrote:
>> On Fri, May 10, 2013 at 3:34 AM, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>>> On Fri, 2013-05-10 at 02:17 +0300, Or Gerlitz wrote:
>>>> On Thu, May 9, 2013 at 6:24 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:
>>>>>
>>>>> On Wed, 2013-05-08 at 16:45 +0300, Or Gerlitz wrote:
>>>>>> Here's a suggestion for API and implementation that lets the admin to
>>>>>> configure
>>>>>> the link state of the VF / SRIOV eSwitch vPORT. Basically, it has three
>>>>>> states
>>>>>>
>>>>>> Auto -        the VF link state will reflect the PF link state
>>>>>>
>>>>>> Enable - VF link stat will be always up, traffic from VF to VF can
>>>>>>         work even if PF link is down.
>>>>>
>>>>> It seems like it would be useful to implement these two options on the PF as well.
>>>>
>>>> You mean that PF <--> VF communication on the same node can be made to
>>>> work even when the physical link is down? this is a bit problematic to
>>>> model/implement I think. Generally speaking it makes things easier to
>>>> grasp if PF is considered to be the uplink of the eSwitch whos link is
>>>> 1:1 as the physical link, but need to think that a bit more.
>>>
>>> Yeah.  In some ways it could be better for a PF driver to create two net
>>> devices, one which acts as a vswitch port and one which bypasses it (if possible).
>>
>> That's interesting approach, any rough thoughts what you think it would by us?
>
> There are many attributes that could differ between the external port
> (or ports - there could be more than one on the same integrated switch)
> and the PF's switch port, including at least:
>
> - Link state
> - Packet counters
> - MTU
> - VLAN filtering
>
> So long as we conflate these two (or more) ports into a single net
> device, there will be confusion about what the attributes mean.
>

One more example is all the control protocols we run over these
ports, LLDP being one example. Its not really clear who your peer
is when we have only a single netdevice. Is it the embedded bridge
or the peer of the external port?

.John
