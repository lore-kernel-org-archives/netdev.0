From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Thu, 19 Mar 2015 06:59:17 -0700
Message-ID: <550AD635.8040502@intel.com>
References: <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com> <CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com> <20150309064043.GB2053@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com> <20150309160754.GA2169@nanopsycho.lan> <E4CD12F19ABA0C4D8729E087A761DC35067E6EF0@ORSMSX101.amr.corp.intel.com> <20150310063926.GA1995@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com> <20150310082817.GC1995@nanopsycho.orion> <550752BA.5040702@gmail.com> <20150317070046.GB2042@nanopsycho.orion> <55083AB6.4060003@intel.com> <55088E2C.5000405@cumulusnetworks.com> <5508C3EA.80009@intel.com> <55091B4C.7090507@cumulusnetworks.com> <550998C7.7080108@gmail.com> <CAE4R7bB2GC3_vMvKAcYie1SP0xB9hm-himzP_
 BGHX5B2gZKisw@mail.gmail.com> <550ACF51.20005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: roopa <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56301 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755657AbbCSN7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 09:59:30 -0400
In-Reply-To: <550ACF51.20005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 06:29 AM, roopa wrote:
> On 3/18/15, 10:49 PM, Scott Feldman wrote:
>> On Wed, Mar 18, 2015 at 8:24 AM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>>> [...]
>>>> I am not sure how this would be and what other issues you will hit if
>>>> you are planning to bypass the kernel and directly go to the switch
>>>> driver for all l2 and l3 in the stacked netdevice case. For l3, its
>>>> better to use the in-kernel route fib offload mechanism which was
>>>> recently submitted by scott feldman.
>>>>
>>> Why? I saw the patched and liked it but noted that the existing policy
>>> wont actually work for real networks. Its a good start. My proposal
>>> is to add a flag to l3 to similarly fail to load a rule if it can't
>>> be pushed at hardware same as l2.
>> RIght, what we have is a start to get the basic plumbing in place.
>> Agreed, the current would be inadequate for a real switch that can't
>> handle a software fallback.
>>
>> Maybe the next step is to not flush hw of all routes on failure to add
>> the Nth one, but rather just fail the Nth completely (don't install in
>> hw or sw and return err to user).  This would keep the switch alive,
>> but now moves a decision to the user.  The user must decide what to do
>> with the failed Nth route.
> I would prefer this. The routing daemon probably already has policies to handle routes
>  that don't get installed in the FIB (It should not really care if the FIB is hardware accelerated or not).
> 

+1 this works for me as well.

>>
>> We also added the netlink flag RTNH_F_EXTERNAL to mark routes
>> offloaded to hardware, but the marking is only done internally now, by
>> the kernel.  What I'm hoping is we can use that same flag in the
>> user's netlink msg to work like you describe: if user requests
>> RTNH_F_EXTERNAL, and it can't be loaded into hw, don't load into sw.
>> Or something like that.  Again, punting the decision on what to do
>> next to the user.
> yes, however this requires change in userspace (routing daemon) to explicitly set this flag.
> It definitely can be optional IMO for people who need it (maybe JohnF)

Yes it would be helpful for some software but I think getting the above
case working first seems to be the right approach to me.

>>
>> This part of the discussion should probably move to a new thread;
>> maybe someone brave can propose a patch to move us to the next level?
>>
> ack, I will try and get to it this week, unless somebody beats me to it.
> 

Thanks.

> Thanks,
> Roopa
> 
> 
