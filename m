From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 18:50:00 +0400
Message-ID: <20091018145000.GA16925@ioremap.net>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <200910141319.43884.bcook@bpointsys.com> <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org> <20091018125014.GH27747@prithivi.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Deri <deri@ntop.org>, Brent Cook <bcook@bpointsys.com>,
	Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:60652 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbZJROt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 10:49:57 -0400
Content-Disposition: inline
In-Reply-To: <20091018125014.GH27747@prithivi.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 18, 2009 at 02:50:14PM +0200, Harald Welte (laforge@gnumonks.org) wrote:
> > contrary to other socket types, PF_RING allows
> > - packets to be filtered using both BPF and ACL-like filters
> > - parsing information is returned as metadata with the packet (i.e.
> > you don't have to parse the packet again as it happens with BPF)
> > - ACL-like filters allows you to specify advanced features such as
> > port ranges or packet payload match
> 
> So it seems there is some added features over the existing functionality, plus
> probably increased performance mainly to hooking earlier in the packet receive
> flow.
> 
> What would normally be done is to try to make incremental changes
> to the existing code and extend their features/performacne, rather than
> adding something relatively similar alternative.

PF_PACKET as is can not be made faster - it requires a packet copy, so
virtually this is an end of the game, while mapped packet socket is
quite different and does not require that expensive copy. And while
currently difference between both goes down, it still exists and may
hummer some use cases.

PF_RING uses another ring structure and I saw comparisons of both (many
years ago though), where pf_ring was faster. Unfortunately there is no
way to easily adopt its mapping into pf_packet ring without breaking
compatibility, but I wonder whether performance different between both
still exists and can it be a main factor for the preference. If
difference is not visible, than I believe the only way for PF_RING is to
extend existing packet sockets with its other features.

-- 
	Evgeniy Polyakov
