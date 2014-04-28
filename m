From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Mon, 28 Apr 2014 13:19:29 -0700
Message-ID: <CA+mtBx8uiOw8GnpOgQamPLg-MPLYHr4=rALpW9OKGW1hR+KK_w@mail.gmail.com>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
	<535E99F3.3050404@enst-bretagne.fr>
	<CA+mtBx-umd3vmNggurFiugQXr_gb+14HvHo=jdaPnpC4cL=tdA@mail.gmail.com>
	<535EADFD.4050508@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:42309 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197AbaD1UTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 16:19:30 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so5282217igd.10
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 13:19:30 -0700 (PDT)
In-Reply-To: <535EADFD.4050508@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 12:37 PM, Florent Fourcot
<florent.fourcot@enst-bretagne.fr> wrote:
>
>>>
>>> By enabling auto_flowlabels, we can have conflict between the flow label
>>> manager policy, and a randomly generated label.
>>>
>> What would be the consequences of such a conflict? Per RFC6437
>> stateless and stateful flow labels are selected from the same space,
>> the probability of collision between them is assumed to be non-zero.
>> We obviously can't make any assumptions on RX.
>>
>
> In the new RFC world, perhaps. But the flow label manager is older than
> that, and implement a strong policy on flow labels.
>
> Since we cannot know who is using it, and how there are using it, I'm
> against this new behaviour. Disabling the manager is ok for me, but not
> by default.
>
But the RFC defines the on-the-wire protocol and we can never assume
that a site only uses Linux. As you pointed out BSD already has this
functionality, and we cannot assume any stateful association in
received flow labels. If someone is implementing a strong policy for
flow labels (like dropping based on it), it would be incorrect.
RFC6437 is clear on this:

  "A node that sets the flow label MAY also take part in a flow state
   establishment method that results in assigning specific treatments to
   specific flows, possibly including signaling.  Any such method MUST
   NOT disturb nodes taking part in the stateless scenario just
   described.  Thus, any node that sets flow label values according to a
   stateful scheme MUST choose labels that conform to Section 3 of this
   specification.  Further details are not discussed in this document."

> As second point, the name of auto_flowlabel is in my opinion not a
> perfect choice if you set a label it only on tunnels. This is exactly
> the same name that a BSD sysctl, setting a random label on all sockets
> (TCP, UDP...). The flow label world is already hard enough to
> understand, thanks to various implementations.
>
This is not just for tunnels, but would apply to transports and
potentially obviates the need for a lot of UDP encapsulation (like
ESP/UDP). So it would appear that this is pretty much the same thing
as what the BSD implementation does and same sysctl name (a happy
coincidence). Looks like the default in BSD is on btw.

Thanks,
Tom

> Regards,
>
> --
> Florent.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
