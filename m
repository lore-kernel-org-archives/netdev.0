From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] rocker: forward packets to CPU when port is
 joined to openvswitch
Date: Thu, 16 Jul 2015 00:09:39 -0700
Message-ID: <CAE4R7bANdQqxkU_0yUh1W0+o2bPvTnw7u_3ruNsfaPFm-Vs=Yg@mail.gmail.com>
References: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
 <CAE4R7bCBaMZKAhUbW4MC3Z5hmic2kUZuBn94zB6j+kY1Z2piag@mail.gmail.com> <20150716065827.GA2145@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34056 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbGPHJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 03:09:59 -0400
Received: by oigd21 with SMTP id d21so2304477oig.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 00:09:59 -0700 (PDT)
In-Reply-To: <20150716065827.GA2145@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 11:58 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Jul 16, 2015 at 08:40:31AM CEST, sfeldma@gmail.com wrote:
>>On Wed, Jul 15, 2015 at 6:39 PM, Simon Horman
>><simon.horman@netronome.com> wrote:
>>> Teach rocker to forward packets to CPU when a port is joined to Open vSwitch.
>>> There is scope to later refine what is passed up as per Open vSwitch flows
>>> on a port.
>>>
>>> This does not change the behaviour of rocker ports that are
>>> not joined to Open vSwitch.
>>>
>>> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>>
>>Acked-by: Scott Feldman <sfeldma@gmail.com>
>>
>>Now, OVS flows on a port.  Strange enough, that was the first RFC
>>implementation for switchdev/rocker where we hooked into ovs-kernel
>>module and programmed flows into hw.  We pulled all of that code
>>because, IIRC, the ovs folks didn't want us hooking into the kernel
>>module directly.  We dropped the ovs hooks and focused on hooking
>>kernel's L2/L3.  The device (rocker) didn't really change: OF-DPA
>>pipeline was used for both.  Might be interesting to try hooking it
>>again.
>
>
> I think that now we have an infrastructure prepared for that. I mean,
> what we need to do is to introduce another generic switchdev object
> called "ntupleflow" and hook-up again into ovs datapath and cls_flower
> and insert/remove the object from those codes. Should be pretty easy to do.

That sounds right.  Is the ovs datapath hooking still happening in the
ovs-kernel module?  Remind me again, what was the objection the last
time we tried that?
