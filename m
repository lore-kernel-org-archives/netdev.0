From: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Subject: Re[2]: [PATCH] vxlan: Fix error that was resulting in VXLAN MTU size being 10 bytes too large
Date: Tue, 04 Dec 2012 09:48:12 +0900
Message-ID: <20121204094809.9689.C42C3789@sakura.ad.jp>
References: <20121119080351.477525b3@nehalam.linuxnetplumber.net> <CAOzFzEh0X3CcjBYWVDAtu7=jRSc1_P2OQSF_YWjnBSeugo3W6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Joseph Glanville <joseph.glanville@orionvm.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sakura.ad.jp ([210.224.172.11]:22359 "EHLO
	mail.sakura.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab2LDBDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 20:03:16 -0500
In-Reply-To: <CAOzFzEh0X3CcjBYWVDAtu7=jRSc1_P2OQSF_YWjnBSeugo3W6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all

Sharing my testlab resut for you ;-)

A First Look At VXLAN over Infiniband Network On Linux 3.7-rc7
http://slidesha.re/TsCKWc

plz enjyoi it.

--
Naoto

On Tue, 4 Dec 2012 02:26:18 +1100
Joseph Glanville <joseph.glanville@orionvm.com.au> wrote:

> On 20 November 2012 03:03, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > On Mon, 19 Nov 2012 22:33:50 +1100
> > Joseph Glanville <joseph.glanville@orionvm.com.au> wrote:
> >
> >> On 14 November 2012 08:33, Stephen Hemminger <shemminger@vyatta.com> wrote:
> >> > On Tue, 13 Nov 2012 14:37:19 -0500 (EST)
> >> > David Miller <davem@davemloft.net> wrote:
> >> >
> >> >> From: Alexander Duyck <alexander.h.duyck@intel.com>
> >> >> Date: Fri, 09 Nov 2012 15:35:24 -0800
> >> >>
> >> >> > This change fixes an issue I found where VXLAN frames were fragmented when
> >> >> > they were up to the VXLAN MTU size.  I root caused the issue to the fact that
> >> >> > the headroom was 4 + 20 + 8 + 8.  This math doesn't appear to be correct
> >> >> > because we are not inserting a VLAN header, but instead a 2nd Ethernet header.
> >> >> > As such the math for the overhead should be 20 + 8 + 8 + 14 to account for the
> >> >> > extra headers that are inserted for VXLAN.
> >> >> >
> >> >> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> >> >>
> >> >> Applied, thanks for the detailed commit message.
> >> >
> >> > Probably need smarter code there to look at header length requirement
> >> > of underlying device as well, maybe someone will be perverse and runn
> >> > vxlan over a tunnel or IPoIB.
> >>
> >> Forgive my ignorance but why would running VXLAN on IPoIB require
> >> special header handling? (and would it work or behave strangely?)
> >>
> >> I was planning on giving this a go when 3.7 is released but I might do
> >> that sooner if problems are anticipated.
> >>
> >> > --
> >> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> > the body of a message to majordomo@vger.kernel.org
> >> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >> Joseph.
> >>
> >
> > Some lower layers require bigger (or smaller headers). As it was, vxlan
> > was only allocating skb with a fixed amount of headroom. This would lead to
> > lower layers having to copy the skb.
> >
> > My suggestion has already been addressed by a later patch.
> 
> Hi,
> 
> I have tested VXLAN on IPoIB and it works perfectly. :)
> 
> Joseph.
> 
> 
> -- 
> CTO | Orion Virtualisation Solutions | www.orionvm.com.au
> Phone: 1300 56 99 52 | Mobile: 0428 754 846
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
SAKURA Internet Inc. / Senior Researcher
Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
SAKURA Research Center <http://research.sakura.ad.jp/>
