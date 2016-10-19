From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v12 5/9] openvswitch: add processing of L3
 packets
Date: Wed, 19 Oct 2016 18:52:06 +0200
Message-ID: <20161019185206.7347e189@griffin>
References: <cover.1476708212.git.jbenc@redhat.com>
        <a4590d690c169e0021031405463c8629a6e9ecb8.1476708213.git.jbenc@redhat.com>
        <CAOrHB_B1-29CM=DWpWuRVbTRriW2ViJRZULMS22+NSPwW_J_=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35082 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756690AbcJSQwL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 12:52:11 -0400
In-Reply-To: <CAOrHB_B1-29CM=DWpWuRVbTRriW2ViJRZULMS22+NSPwW_J_=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Oct 2016 22:13:45 -0700, Pravin Shelar wrote:
> On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> > -       skb_reset_network_header(skb);
> > +               skb->protocol = parse_ethertype(skb);
> 
> I am not sure about changing skb->protocol here.
> By changing this skb loosing information about packet type. Therefore
> if packet re-enters OVS (through different bridge), this packet would
> look like L3 packet. function key_extract_mac_proto() would not see
> TEB type packet.

This should be okay. If the packet is sent out to an Ethernet interface
(whatever interface it is), skb->protocol needs to contain the payload
type. We're not interested in ETH_P_TEB. If the packet is sent out to
an ARPHRD_NONE interface, ETH_P_TEB is pushed back.

Basically, what we're doing here is unconditionally converting
ETH_P_TEB packets *coming from ARPHRD_NONE interfaces* (this is
important) into regular Ethernet packets. Which is exactly what we want.

Am I missing something?

 Jiri
