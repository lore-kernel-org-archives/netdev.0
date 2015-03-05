From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Thu, 05 Mar 2015 12:43:56 -0800
Message-ID: <54F8C00C.2010303@cumulusnetworks.com>
References: <1425428129-48365-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bArwsNUdtNM25Zm=ZccrmVqC8e45E6qsjMdO3s0FrOVog@mail.gmail.com> <54F6C788.2010201@cumulusnetworks.com> <20150305080218.GB2033@nanopsycho.orion> <54F86E4B.9040403@cumulusnetworks.com> <CAE4R7bCQHcR4Ne-ssCRRvw0czKxRJfykcBFY6c_9haRF3pRJYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40610 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbbCEUn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:43:59 -0500
Received: by padfb1 with SMTP id fb1so36262273pad.7
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:43:58 -0800 (PST)
In-Reply-To: <CAE4R7bCQHcR4Ne-ssCRRvw0czKxRJfykcBFY6c_9haRF3pRJYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/15, 12:06 PM, Scott Feldman wrote:
> On Thu, Mar 5, 2015 at 6:55 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 3/5/15, 12:02 AM, Jiri Pirko wrote:
>>> Wed, Mar 04, 2015 at 09:51:20AM CET, roopa@cumulusnetworks.com wrote:
>>>> On 3/3/15, 11:02 PM, Scott Feldman wrote:
> [cut]
>
>>>>> Rocker setlink wasn't broken prior to the NETIF_F_HW_SWITCH_OFFLOAD
>>>>> patches.
>>>>>    Now it is,
>>>> sure, I can submit a patch to remove the flag on rocker ports if thats
>>>> what
>>>> you prefer.
>>> I don't believe that Scott prefers that. The offload flag is there not
>>> only for this case, but also for many future switch offloading cases.
>> I very well understand that.
>>> Rocker port have to have that port set by default. I do not really
>>> understand why you suggest removing it...
>>>
>> I was just making sure scott is on board with the use of the flag.
>> I added it on rocker ports for l2 and learning might be broken because of
>> that. Which i am trying to fix.
>> also, scotts l3 patches dont seem to use the flag.
> That's an oversight due to work starting on L3 patches way before
> NETIF_F_HW_SWITCH_OFFLOAD was introduced ; I'll add checks for that
> flag to the L3 patches.
ok, i was not sure if you were planning to. I did post a comment on v2.
>> So, if the patch in this thread is not the right way to fix it..,.i was just
>> trying to give scott an option to remove the flag to keep l2 working and for
>> him to bring back the flag when he is ready.
> When I'm ready for what?  I ready for it to work like it did before
> NETIF_F_HW_SWITCH_OFFLOAD and your setlink changes went in.  ;-)
well, to be fair scott, my current patch in this thread is trying to get 
to it, if you let me :)

>
> We want two sets of IFLA_PROTINFO attrs for a bridge port.   The first
> set is the bridge side of the port, so these attrs like learning or
> flooding control the how the bridge (software) manages the port.  The
> second set is the device side of the port, so attrs here control how
> the (offload) device manages the port.  The two sets are independent.
> For example, you could have learning turned OFF on the bridge side and
> learning turned ON on the device side.  The device side will
> initialize its set.  The bridge will initialize its set.   The user
> can see both sets with cmd
>
>      bridge -d link show.
>
> The user can set the bridge's attr with one of cmds:
>
>      bridge link set <attr> dev <port>
>      bridge link set <attr> dev <port> master
>
> The user can set the device's attr with cmd:
>
>      bridge link set <attr> dev <port> self
>
> The driver setlink/getlink ops should only be called in the SELF
> context because the driver is the SELF side of the port.  Somehow we
> got away from that.
True, If all attributes that the bridge setlink sets need to go 
separately to kernel and hardware and
  we will never mirror them. That is not the case however. vlans is an 
example and there will be more bridge port attributes in the future.

>   We talked about IFLA_AF_SPEC being handled
> differently for VLANs.  For IFLA_PROTINFO, what do we need to get back
> to what I have above?

If I understand you correctly, you are saying that ndo_bridge_setlink 
when it comes to offloads
should only be used for IFLA_PROTINFO ?
