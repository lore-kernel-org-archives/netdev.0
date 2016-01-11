From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] openvswitch: compute needed headroom for internal
 vports
Date: Mon, 11 Jan 2016 09:43:08 +0100
Message-ID: <1452501788.5027.13.camel@redhat.com>
References: <0d85bf752132423483b8c5708bb9188805a99ff9.1452289759.git.pabeni@redhat.com>
	 <CAOrHB_ARw+FC69yfhq_b0GDvxyQhTLLqUwJ81nYCA5XqrTNwOA@mail.gmail.com>
	 <CAEh+42hN8wL7bbALB8SGCKvum2pzT3R0kXUtMfQPg-XP-QZ7Dg@mail.gmail.com>
	 <CAOrHB_Bo2iqp2xGaZpOb2AvriGTTruC_O72hQ7LqKnkbR_CAeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Flavio Leitner <fbl@sysclose.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758643AbcAKInO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 03:43:14 -0500
In-Reply-To: <CAOrHB_Bo2iqp2xGaZpOb2AvriGTTruC_O72hQ7LqKnkbR_CAeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-08 at 18:44 -0800, pravin shelar wrote:
> On Fri, Jan 8, 2016 at 4:42 PM, Jesse Gross <jesse@kernel.org> wrote:
> > On Fri, Jan 8, 2016 at 2:53 PM, pravin shelar <pshelar@ovn.org> wrote:
> >> On Fri, Jan 8, 2016 at 1:50 PM, Paolo Abeni <pabeni@redhat.com> wrote:
> >>> Currently the ovs internal vports always use a default needed_headroom.
> >>> This leads to a skb head copy while xmitting on ovs swith via vport
> >>> that add some kind of encapsulation (gre, geneve, etc.).
> >>>
> >>> This patch add book-keeping for the maximum needed_headroom used by
> >>> the non internal vports in any dp, updating it on vport creation and
> >>> deletion.
> >>>
> >>> Said value is than used as needed_headroom for internal vports,
> >>> avoiding the above copy.
> >>>
> >> Why is this done only for internal devices? In most common case of
> >> traffic the packet enters OVS from tap or other netdev type vport
> >> device.
> >
> > How would you influence the allocation for non-internal devices?
> 
> Today there is no way of influencing this. But we could add new
> skb-headroom parameter to netdev for packets that are received on the
> device. This new parameter could be controlled from master devices
> like OVS, Bridge, etc. To set this value we need new ndo operation. So
> that it can work on devices like tap where it would just set this new
> value and in case of ovs-internal or veth device, it can also update
> needed_headroom.

My idea was to continue working along this lines.

However I thought to get there incrementally, i.e. handle internal
vports only first. Can this be ok for you?

Cheers,

Paolo
