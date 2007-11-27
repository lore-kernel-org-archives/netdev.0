From: "Andy Gospodarek" <andy@greyhouse.net>
Subject: Re: [Bridge] Re: [RFC] bridging: don't forward EAPOL frames
Date: Tue, 27 Nov 2007 10:24:01 -0500
Message-ID: <bdfc5d6e0711270724i3ce7cf41lb5f01dd5dcac98f9@mail.gmail.com>
References: <1195737808.6323.102.camel@johannes.berg>
	 <20071126093626.08c22a9d@freepuppy.rosehill.pdx.hemminger.net>
	 <1196169854.6058.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	bridge <bridge@linux-foundation.org>
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:8273 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbXK0PYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 10:24:03 -0500
Received: by nf-out-0910.google.com with SMTP id g13so987481nfb
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2007 07:24:02 -0800 (PST)
In-Reply-To: <1196169854.6058.16.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 27, 2007 8:24 AM, Johannes Berg <johannes@sipsolutions.net> wrote:
>
> > > +   if (unlikely(skb->protocol = htons(ETH_P_PAE)))
> > > +           goto drop;
> > > +
> > >     switch (p->state) {
> > >     case BR_STATE_FORWARDING:
> >
> > Not needed because the bridge is already handling it:
> >
> > 1) If running STP (ie true bridge), then all link local multicast is only received by
> > the bridge and never forwarded.
>
> Well, typical access point setups bridge the wireless AP interface with
> wired, EAPOL frames can be unicast (and 802.11 specifies to do so) and
> we want to avoid having them unicast to another host.
>
> Also, 802.1X in C.3.3 recommends not bridging the *ethertype* rather
> than depending on the link-local multicast address because otherwise
> eapol frames can be unicast into the network behind the (authorized)
> port which is undesirable.
>
> johannes
>
>

I agree with Stephen, that based on the way it's likely people use
linux bridges it seems like this is something that could be configured
rather than simply dropping those frames without any chance to forward
them.  There are probably quite a few people out there who will not
expect this change, so it should be easy to change during runtime.

Don't forget that a simple ebtables rule could also drop EAPOL if needed.
