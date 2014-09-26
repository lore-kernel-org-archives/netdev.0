From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 1/5] udp: Generalize skb_udp_segment
Date: Fri, 26 Sep 2014 12:56:43 -0700
Message-ID: <CA+mtBx9SQDz9WOZAEQUXu+D=+ZizfbEHxMCM_gduYYTyOp=Jig@mail.gmail.com>
References: <CAADnVQJgoW1SbkK6hoJcRtTwyKxgNBtFYqBF-5aW9D4=Zi5ofg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:55138 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719AbaIZT4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 15:56:44 -0400
Received: by mail-ig0-f173.google.com with SMTP id l13so134957iga.6
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 12:56:43 -0700 (PDT)
In-Reply-To: <CAADnVQJgoW1SbkK6hoJcRtTwyKxgNBtFYqBF-5aW9D4=Zi5ofg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 12:39 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Sep 26, 2014 at 9:22 AM, Tom Herbert <therbert@google.com> wrote:
>> skb_udp_segment is the function called from udp4_ufo_fragment to
>> segment a UDP tunnel packet. This function currently assumes
>> segmentation is transparent Ethernet bridging (i.e. VXLAN
>> encapsulation). This patch generalizes the function to
>> operate on either Ethertype or IP protocol.
>
> this is great generalization.
> Do you envision that type_ether will cover vlan and mpls, right?

This design should allow providing GSO for any encapsulation of IP
protocol or Ethertype of UDP (as long as encapsulation headers don't
need to be modified for each segment). This actually covers quite a
lot of possibilities.

> What if somebody crazy adds a new thing after udp encap
> that is neither ethernet nor ip header?
> Like encryption header?

We could add an internal offloads table for that. This would entail a
new inner protocol type and then use inner_protocol to set offload
flavor which we can define. This also might be the path to some sort
of GSO for application layer protocols (like QUIC maybe...?)

> I think it would fit this model well...
