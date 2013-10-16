From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 13:11:11 -0400
Message-ID: <525EC8AF.6000902@redhat.com>
References: <525C62D5.3090004@mojatatu.com> <20131014144156.6dc52a78@nehalam.linuxnetplumber.net> <525E9AB1.6090502@mojatatu.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab3JPRLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 13:11:16 -0400
In-Reply-To: <525E9AB1.6090502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2013 09:54 AM, Jamal Hadi Salim wrote:
> On 10/14/13 17:41, Stephen Hemminger wrote:
>
>> Unfortunately, by now this is all set in ABI.
>> It was a side effect of the per-feature evolutionary style of
>> development.
>
> Sadly, I agree. This is the dark side of "have code will travel";
> you let these things out in the wild, they breed and you cant
> take them back.
> BTW: I dont think what i suggested will be a harmful refactoring because
> no existing interfaces are removed - your call.
>
> In similar vein:
> What is the motivation behind IFLA_EXT_MASK?

This was to display or filter out virtual function data.

> Could you not have used
> ifm ifindex to relay the interface of interest? Currently the ifindex is
> not used at all. IMO, the following interfaces are useful:
> - get attributes for all bridge ports (this is there)
> - get attributes for bridge interface XXX; there using IFLA_EXT_MASK
> I think it should be using ifm->ifindex

I probably doesn't need to use this as we want the bridge data, not the 
VF data stored as part of PF interface.

> - get attributes for all bridge ports for bridge br-blah (not there)
> you could also use the ifindex of br-blah here instead

This would be usefull.


>
> Separate issue:
> To provide equivalence to brctl:
> - PF_BRIDGE should allow me to attach a bridge port to bridge of choice
> with SETLINK

You can already do this with:

	ip link set dev ethX master brX

I know, not very intuative, but it's there :(

-vlad



>
> cheers,
> jamal
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
