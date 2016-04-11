From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Mon, 11 Apr 2016 10:56:29 -0700
Message-ID: <20160411175557.GA68004@kafai-mba.local>
References: <CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
 <20160403023349.GA57008@lichen-mbp.local.DHCP.thefacebook.com>
 <CAM_iQpXV8UrBycmmTn3-FFEoR69OSvc4cWZMGbPnGiHF5aF7Dg@mail.gmail.com>
 <20160405.195654.681016570979164308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <edumazet@google.com>,
	<weiwan@google.com>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>, <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:25578 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751085AbcDKR4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 13:56:42 -0400
Content-Disposition: inline
In-Reply-To: <20160405.195654.681016570979164308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2016 at 07:56:54PM -0400, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon, 4 Apr 2016 13:45:02 -0700
>
> > On Sat, Apr 2, 2016 at 7:33 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> >> One thing to note is that this patch uses the addresses from the sk
> >> instead of iph when updating sk->sk_dst_cache.  It is basically the
> >> same logic that the __ip6_datagram_connect() is doing, so some
> >> refactoring works in the first two patches.
> >>
> >> AFAIK, a UDP socket can become connected after sending out some
> >> datagrams in un-connected state.  or It can be connected
> >> multiple times to different destinations.  I did some quick
> >> tests but I could be wrong.
> >>
> >> I am thinking if there could be a chance that the skb->data, which
> >> has the original outgoing iph, is not related to the current
> >> connected address.  If it is possible, we have to specifically
> >> use the addresses in the sk instead of skb->data (i.e. iph) when
> >> updating the sk->sk_dst_cache.
> >>
> >> If we need to use the sk addresses (and other info) to find out a
> >> new dst for a connected udp socket, it is better not doing it while
> >> the userland is connecting to somewhere else.
> >>
> >> If the above case is impossible, we can keep using the info from iph to
> >> do the dst update for a connected-udp sk without taking the lock.
> >
> > I see your point, but calling __ip6_datagram_connect() seems overkill
> > here, we don't need to update so many things in the pmtu update context,
> > at least IPv4 doesn't do that either. I don't think you have to do that.
> >
> > So why just updating the dst cache (also some addr cache) here is not
> > enough?
>
> I think we are steadily getting closer to a version of this fix that
> we have some agreement on, right?
>
> Martin can you address Cong's feedback and spin another version of this
> series?
Dave, I will spin v2 shortly with some minor changes.

Cong, I believe the loose ends have been tied up after the last email thread
since last Thursday?
