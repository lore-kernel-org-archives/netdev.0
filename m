From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 29 Sep 2014 14:38:42 -0700
Message-ID: <CA+mtBx_6HcZh5Ys1FJFBXkZ2bWX1gP6bTcjY7gbR6RG_TOy50Q@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
	<CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
	<CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:41912 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbaI2Vin (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:38:43 -0400
Received: by mail-ig0-f179.google.com with SMTP id uq10so3204456igb.6
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 14:38:42 -0700 (PDT)
In-Reply-To: <CAJ3xEMhf6b75TQDFqEPMSXCpL9ToWG1q0OMPtrEuHNSm=-PSwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 2:10 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 29, 2014 at 11:53 PM, Tom Herbert <therbert@google.com> wrote:
>> On Mon, Sep 29, 2014 at 12:59 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>> On Mon, Sep 29, 2014 at 6:50 AM, Tom Herbert <therbert@google.com> wrote:
>>>> Add ndo_gso_check which a device can define to indicate whether is
>>>> is capable of doing GSO on a packet. This funciton would be called from
>>>> the stack to determine whether software GSO is needed to be done.
>>>
>>> please, no...
>>>
>>> We should strive to have a model/architecture under which the driver
>>> can clearly advertize up something (bits, collection of bits,
>>> whatever) which the stack can run through some dec-sion making code
>>> and decide if to GSO yes/no, do it ala SW or ala HW. As life, this
>>> model need not be perfect and can be biased towards being
>>> simple/robust/conservative and developed incrementally.
>>>
>> Please make a specific proposal then.
>
> We 1st need to bring the system back into a consistent state, see my
> band-aid proposal. BTW, this band-aid might turn to be the basis for
> the longer term solution too. I admit that saying "no" is ten (100)
> times harder vs. say "let's do it this way", but IMHO the fm10k call
> chain I pointed on is what you are suggesting more-or-less and is
> no-no
>
I'd much rather have drivers do this, than inflict the stack with more
complexity. As you describe "the driver can clearly advertise up
something (bits, collection of bits, whatever) which the stack can run
through some dec-sion making code and decide if to GSO yes/no"-- seems
very complex to me. My proposed alternative is to just ask the driver
and they can implement whatever policy they want, stack should doesn't
care about the specifics, just needs an answer. Neither does this
necessarily mean that driver needs to inspect packet, for instance I
suspect that just be looking at inner header lengths and skb->protocol
being TEB would be standard check to match VXLAN.

In any case, if you can formulate your proposal in a patch that would
be very helpful.

>
>>> We certainly don't want each driver that support some sort of HW
>>> offloads for tunnels (today we have 4-5, tomorrow maybe 40...) to
>>> implement their super sophisticated/efficient "dig in a packet and
>>> tell myself if I can GSO/CSUM it or not" code, while repeating (expect
>>> many copy/paste bugs...) the other drivers' code.
>>>
>> I would encourage vendors to implement protocol agnostic, generic
>> mechanisms so that they don't need to dig into the packet.
>
> M2.
>
> But wait, in Linux we support 20y old HW and it seems now will likely
> to continue doing so for maybe the next 10 or 20 coming years - I
> recall that one of the sessions in the coming Linux Con/KVM Forum/LPC
> conference series deals with practices to test kernel changes over
> driver code for which the HW is totally out of stock. Do we even have
> EOL procedure for upstream HW drivers...?
>
> So with this in mind, new NIC HW can (and should) definitely be
> developed along design guidelines such as being fully generic and
> simple. But, fact is that we have HW today and more coming up which is
> not 100% along this vision and their drivers are upstream and we want
> the kernel to be generic and hopefully using robust/simple SW model,
> right?
>
> Or.
