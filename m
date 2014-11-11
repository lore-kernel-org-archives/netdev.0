From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v2 00/10] introduce rocker switch driver with
 hardware accelerated datapath api - phase 1: bridge fdb offload
Date: Tue, 11 Nov 2014 17:51:47 +0900
Message-ID: <20141111085145.GB4280@vergenet.net>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <5460319B.2010605@mojatatu.com>
 <20141110034612.GB17246@vergenet.net>
 <5460391C.3010107@mojatatu.com>
 <20141110045830.GC17246@vergenet.net>
 <54613AD3.7030600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusn
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:39597 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbaKKIwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 03:52:13 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so10246073pab.13
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 00:52:13 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54613AD3.7030600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 02:23:15PM -0800, John Fastabend wrote:
> On 11/09/2014 08:58 PM, Simon Horman wrote:
> >On Sun, Nov 09, 2014 at 11:03:40PM -0500, Jamal Hadi Salim wrote:
> >>Hi Simon,
> >>
> >>On 11/09/14 22:46, Simon Horman wrote:
> >>>Hi Jamal, Hi Jiri,
> >>>
> >>>On a somewhat related note I am also wondering what if any progress has
> >>>been made regarding discussions of (and code for) the following:
> >>>
> >>>1. Exposing flow tables to user-space
> >>>    - I realise that this is Open vSwitch specific to some extent
> >>>      but I am in no way implying that it should be done instead of
> >>>      non-Open vSwitch specific work.
> >>>    - Jiri, IIRC this was part ~v2 of your earlier offload patchset
> >>>
> >>
> >>I dont know what Rocker crowd is doing; however, I know
> >>John F. has been doing some work which i have stared at
> >>and I was hoping to join in with Ben's effort and show tc flow
> >>offload on the realtek chip in my infinite spare time unles.
> >>(for both Linux bridge and ports).
> >>The priority is to merge the obvious bits first.
> >
> >Merging the obvious bits first is quite fine my me.
> >
> 
> +1
> 
> >>>2. Describing Switch Hardware
> >>>    - I see John Fastabend moving forwards on this in his git repository
> >>>      https://github.com/jrfastab/flow-net-next
> >>>
> >>>The way that I see things is that both of the above could be exposed via
> >>>netlink. And that the first at least could be backed by NDOs.  As such I
> >>>see this work as complementary and perhaps applying on top of this
> >>>patchset. If I am mistaken in this regards it would be good to know :)
> >>>
> >>
> >>You are correct - I will let John speak on his work, but
> >>that is the intent.
> >>The challenge is there are many schools of thoughts and i am hoping
> >>it is not an arms race.
> >
> >That is also my hope.
> 
> My intent is to submit the Flow API bits once the base rocker switch
> gets committed. I've implemented the Flow API against ixgbe and a
> sadly a proprietary SDK. I'll implement it against the rocker switch
> as well.

Understood, that seems like a good approach to me.

> >>>I am of course also interested to know if the above are moving forwards.
> >>>To be clear I am very interested in being able to use these APIs to
> >>>perform Open vSwitch offloads and I am very happy to help.
> >>>(Jamal: I'm also interested in non-Open vSwitch offloads :)
> >>>
> >>
> 
> I think they are moving forward. I have some code cleanup to do on
> the flow API, but its mostly in place. Then I want to implement
> an example on Rocker switch so we could experiment with something
> why we wait for a real hardware driver. From my side assuming I at
> least got it close to correct should be doable in the next few week.
> 
> After that I want to work with Jesse/Jamal and look at integrating
> with OVS and other stacks. I thought a bit about the OVS integration
> path but I'll hold that discussion for the moment.

I am looking forward to that discussion.

> Simon, if your feeling adventurous any feedback on the repo link
> would be great. I still need to smash the commit log into something
> coherent though at the moment you can see all the errors and rewrites,
> etc as I made them.

Sure, will do.  I took a look over your code about two weeks ago but I
believe you have made some updates since then.

> >>Hey, OVS should be able to use these APIs; i am just interested in making
> >>sure they are not just for OVS or OF. Then we are all happy;->
> >
> >I think we are all happy :)
> 
> I'm happy :) Also my intent is the flow API is more general then
> just OVS. My view is OVS should be one user of the API.

I agree entirely.
