From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v10 4/5] openvswitch: add layer 3 flow/port
 support
Date: Fri, 17 Jun 2016 15:53:40 +0900
Message-ID: <20160617065337.GB24833@vergenet.net>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-5-git-send-email-simon.horman@netronome.com>
 <CAOrHB_Cy-Gtt3OJSpAdZu3M07xNWv5dYNAbYbD6ei3H-r66vyA@mail.gmail.com>
 <20160607024609.GC31696@vergenet.net>
 <CAOrHB_DvRmXwm19yWg9f+4sX_bK8Je_qWEFPHs9tS1QE1AiTqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34709 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbcFQGxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 02:53:49 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so25800418pad.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 23:53:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_DvRmXwm19yWg9f+4sX_bK8Je_qWEFPHs9tS1QE1AiTqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 03:45:58PM -0700, pravin shelar wrote:
> On Mon, Jun 6, 2016 at 7:46 PM, Simon Horman <simon.horman@netronome.com> wrote:
> > On Thu, Jun 02, 2016 at 03:02:18PM -0700, pravin shelar wrote:
> >> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
> >> <simon.horman@netronome.com> wrote:

[...]

> >> > diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> >> > index 0bb650f4f219..1e1392c3c0ed 100644
> >> > --- a/net/openvswitch/flow_netlink.c
> >> > +++ b/net/openvswitch/flow_netlink.c
> >
> > [...]
> >
> >> > @@ -355,6 +359,7 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
> >> >         [OVS_KEY_ATTR_CT_ZONE]   = { .len = sizeof(u16) },
> >> >         [OVS_KEY_ATTR_CT_MARK]   = { .len = sizeof(u32) },
> >> >         [OVS_KEY_ATTR_CT_LABELS] = { .len = sizeof(struct ovs_key_ct_labels) },
> >> > +       [OVS_KEY_ATTR_PACKET_ETHERTYPE] = { .len = sizeof(__be16) },
> >> >  };
> >> >
> >> I do not see need for OVS_KEY_ATTR_PACKET_ETHERTYPE, we can use
> >> existing OVS_KEY_ATTR_ETHERTYPE to serialize the flow key. If there is
> >> no OVS_KEY_ATTR_ETHERNET attribute then its l3 packet.
> >
> > The idea of OVS_KEY_ATTR_PACKET_ETHERTYPE is to allow communication of
> > the L2 type of the packet which is not present in an L3 packet. In terms
> > of GRE (non-TEB) this correlates to the Protocol Type field in the GRE
> > header.
> 
> How about using OVS_KEY_ATTR_ETHERTYPE to communicate the protocol type?

Yes, I believe that I now have that working locally. The assumption that
I am now working with is that OVS_KEY_ATTR_ETHERTYPE provides the type
metadata for Layer 3 packets if OVS_KEY_ATTR_ETHERNET (the Mac addresses)
is absent.
