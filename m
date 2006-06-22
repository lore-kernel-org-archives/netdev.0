From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 source address selection in addrconf.c (2.6.17)
Date: Thu, 22 Jun 2006 09:26:59 +0900 (JST)
Message-ID: <20060622.092659.76693840.yoshfuji@linux-ipv6.org>
References: <44986AE6.6090102@poczta.fm>
	<44994CB3.6070302@poczta.fm>
	<4499CEF4.2050308@poczta.fm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:13576 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751530AbWFVA0H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 20:26:07 -0400
To: stlman@poczta.fm
In-Reply-To: <4499CEF4.2050308@poczta.fm>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4499CEF4.2050308@poczta.fm> (at Thu, 22 Jun 2006 00:57:56 +0200), Lukasz Stelmach <stlman@poczta.fm> says:

> Lukasz Stelmach wrote:
> > Lukasz Stelmach wrote:
> > 
> >> [...] when trying to connect to
> >>
> >> 2001:200:0:8002:203:47ff:fea5:3085 (www.kame.net)
> >>
> >> with two global addresses assigned to the ethernet card
> >>
> >> fd24:6f44:46bd:face::254
> >> 2002:531f:d667:face::254
> >>
> >> rule 8 does not work and the first address is chosen.
> > 
> > The answer is that fc00::/7 matches 2001:: better because it gets the same
> > label (ipv6_saddr_label()). Although fc00::/7 addresses are defined as global
> > unicast IMHO they should be treated *slightly* different. This is the patch.
> > Since 6to4 has its own label I have decided to assign one to Teredo too.
> 
> There still, however, remains one issue. Aditional labels prevent kernel from
> selecting fc00::/7 prematurly. But there is no way to stop it from selecting
> it in rule 7. A wrong assumption has been taken that there is only one
> "private" address per interface and it is always the best choice. If there are
> four addresses on the interface:
> 
> fd24:6f44:46bd:face:EUI64 fd24:6f44:46bd:face:RANDOM
> and
> 2002:531f:d667:face:EUI64 2002:531f:d667:face::RANDOM
> 
> there seem to be no way to prefere 2002:: over fc00:: in rule 7 and it will be
> selected as long as it is before 2002:: on the list. I can see here that an
> implicit assumption has been made that an interface either is multihomed or
> "private". The seventh rule should not IMHO break the whole process of
> selection but rather mark as selectable all "private" (random) addresses. And
> it should rather be done before rule 6.

Hmm? We do not have such intention.
In above case, when you connect to 2001:200:0:8002:203:47ff:fea5:3085,
either 2002:531f:d667:face:EUI64 or 2002:531f:d667:face::RANDOM
should be selected (depending on if use_tempaddr >= 2),
by the longest matching rule (Rule 8).

--yoshfuji
