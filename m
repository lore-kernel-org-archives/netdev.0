From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v10 3/5] openvswitch: add support to push and pop
 mpls for layer3 packets
Date: Tue, 7 Jun 2016 15:45:42 -0700
Message-ID: <CAOrHB_B3phbNub9sdnCM0EFDSL3fRHB-unKjUgjFMX5ZHqM3Dw@mail.gmail.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
 <1464848686-7656-4-git-send-email-simon.horman@netronome.com>
 <CAOrHB_D0XoGUjSXztNMdektGgTMPxeVfbNF0WcTZuTbR4VYz5g@mail.gmail.com> <20160607025130.GD31696@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:57855 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcFGWpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:45:47 -0400
Received: from mfilter41-d.gandi.net (mfilter41-d.gandi.net [217.70.178.173])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id 747F8A80CD
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 00:45:45 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter41-d.gandi.net (mfilter41-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id jewRijHmhISw for <netdev@vger.kernel.org>;
	Wed,  8 Jun 2016 00:45:44 +0200 (CEST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(Authenticated sender: pshelar@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id DCB10A80C6
	for <netdev@vger.kernel.org>; Wed,  8 Jun 2016 00:45:43 +0200 (CEST)
Received: by mail-it0-f49.google.com with SMTP id h62so50168942itb.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 15:45:43 -0700 (PDT)
In-Reply-To: <20160607025130.GD31696@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 6, 2016 at 7:51 PM, Simon Horman <simon.horman@netronome.com> wrote:
> On Thu, Jun 02, 2016 at 03:02:00PM -0700, pravin shelar wrote:
>> On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>> > Allow push and pop mpls actions to act on layer 3 packets by teaching
>> > them not to access non-existent L2 headers of such packets.
>> >
>> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
>> > ---
>> > v10
>> > * Limit scope of hdr in {push,pop}_mpls()
>> >
>> > v9
>> > * New Patch
>> > ---
>> >  net/openvswitch/actions.c | 19 ++++++++++++-------
>> >  1 file changed, 12 insertions(+), 7 deletions(-)
>> >
>> > diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> > index 9a3eb7a0ebf4..15f130e4c22b 100644
>> > --- a/net/openvswitch/actions.c
>> > +++ b/net/openvswitch/actions.c
>> > @@ -172,7 +172,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>> >
>> >         skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
>> >
>> > -       update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
>> > +       if (skb->mac_len)
>> > +               update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
>> We can move all ethernet related code in this if block. for example memmove().
>
> My assumption is that the memmove() does nothing if skb->mac_len is zero
> and from my point of view it seems clean to leave it where it is unless
> the code around it also moves.
>
> Is there other code you think could/should be moved into the
> if (skb->mac_len) block?
>
yes, the code is correct. But I think grouping l2 related updated
together makes code easier to follow.
