From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 3 Oct 2012 13:31:30 -0400
Message-ID: <OFFFC99DDA.1BD04FA3-ON85257A8C.005A8E9B-85257A8C.00604444@us.ibm.com>
References: <506955F3.8050304@googlemail.com>	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>	 <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
	 <1349249328.12401.1364.camel@edumazet-glaptop>	 <OFA39D9FC0.CDC6EE41-ON85257A8C.00458030-85257A8C.00461EF4@us.ibm.com>
	 <1349270151.12401.2372.camel@edumazet-glaptop>	 <OF8CC7A8E7.DA3B059E-ON85257A8C.004C258C-85257A8C.004DCE49@us.ibm.com> <1349278153.12401.2811.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: chris2553@googlemail.com, Dave Jones <davej@redhat.com>,
	David Miller <davem@davemloft.net>, gpiez@web.de,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:59658 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368Ab2JCRbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 13:31:40 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 3 Oct 2012 11:31:39 -0600
In-Reply-To: <1349278153.12401.2811.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/03/2012 11:29:13 AM:

> >         Of course. I think our difference is on the definition of 
> > "receives".
> 
> A receive is a packet delivered to this host.
> Interface being promiscuous or not doesnt really matter.

        A receive is a packet *addressed* to this host. My point was
that running tcpdump/wireshark to look at other hosts' traffic
shouldn't affect any UDP MIB (these are ordinarily filtered by IP),
but I forgot that we are checking in software, as well as the HW multicast
address filter, for multicast group membership. So promiscuous mode and
imperfect NIC MAF hashes shouldn't actually result in local delivery
and that problem isn't there at all.

        I do think, still, that it is common to have broadcasts and
multicasts (for joined groups, even) with traffic completely uninteresting
to this host and that having a drop counter going up for those will
appear to be losses and errors when they are completely harmless and
irrelevant.
        But since it can't be incremented for items that are not actually
addressed to the local host, as I originally thought, I don't object
anymore. Sorry for the sidetrack -- I should've verified that originally.

                                                        +-DLS
