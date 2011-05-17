From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 13:17:14 -0700
Message-ID: <1305663434.8149.936.camel@tardy>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	 <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:7933 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab1EQURa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 16:17:30 -0400
In-Reply-To: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 13:02 -0700, Tom Herbert wrote:
> I like it!  And this sounds like the sort of algorithm that NICs might
> be able to implement to solve the UDP/RSS unpleasantness, so even
> better.

Do (m)any devices take "shortcuts" with UDP datagrams these days?  By
that I mean that back in the day, the HP-PB and "Slider" FDDI
cards/drivers did checksum offload for fragmented UDP datagrams by
sending the first fragment, the one with the UDP header and thus
checksum, last.  It did that to save space on the card and make use of
the checksum accumulator.

rick jones

> 
> Tom
> 
> On Tue, May 17, 2011 at 11:33 AM, David Miller <davem@davemloft.net> wrote:
> >
> > It seems to me that we can solve the UDP fragmentation problem for
> > flow steering very simply by creating a (saddr/daddr/IPID) entry in a
> > table that maps to the corresponding RPS flow entry.
> >
> > When we see the initial frag with the UDP header, we create the
> > saddr/daddr/IPID mapping, and we tear it down when we hit the
> > saddr/daddr/IPID mapping and the packet has the IP_MF bit clear.
> >
> > We only inspect the saddr/daddr/IPID cache when iph->frag_off is
> > non-zero.
> >
> > It's best effort and should work quite well.
> >
> > Even a one-behind cache, per-NAPI instance, would do a lot better than
> > what happens at the moment.  Especially since the IP fragments mostly
> > arrive as one packet train.
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


