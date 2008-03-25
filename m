From: Chr <chunkeey@web.de>
Subject: Re: IPv6 unique local address flushes on up/down
Date: Tue, 25 Mar 2008 18:16:31 +0100
Message-ID: <200803251816.31709.chunkeey@web.de>
References: <200803251557.21563.chunkeey@web.de> <200803251707.52528.chunkeey@web.de> <20080326.012039.59874360.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: hostap@lists.shmoo.com, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?iso-2022-jp?q?=1B=24B5HF=231QL=40=1B=28B?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:49839 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbYCYRSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 13:18:16 -0400
In-Reply-To: <20080326.012039.59874360.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 March 2008 17:20:39 YOSHIFUJI Hideaki / 吉藤英明 wrote:
> In article <200803251707.52528.chunkeey@web.de> (at Tue, 25 Mar 2008 
17:07:52 +0100), Chr <chunkeey@web.de> says:
> > On Tuesday 25 March 2008 16:24:28 YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > > In article <200803251557.21563.chunkeey@web.de> (at Tue, 25 Mar 2008
> >
> > 15:57:21 +0100), Chr <chunkeey@web.de> says:
> > > > Now my question, which _one_ should we fix the applications or the
> > > > stack?! I think the network stack, but I don't know if there are RFC
> > > > about this issue... or is there already some flag/setting which I've
> > > > missed so far?
> > >
> > > Well..., in fact, this is known as an uneasy-to-fix issue.
> > > The behavior han not been changed for long time, so you definately
> > > need to have work-around for this issue, anyway.
> > >
> > > From specification point of view, we need to re-perform DAD (duplicate
> > > address detection) after down-up cycle or even link-down and up.
> > > One possible way is to add "tentative" flag for static addresses
> > > (instead of purging them) when the interface is going down and
> > > reperform DAD for all of such addresses when the interface is coming
> > > up. If the link is being down, we might want to use "Optimistic" DAD
> > > instead.
> >
> > Ah yeah, ok... I guess... alright! ...
> >
> > but another question, about this issue form the userspace side.
> >
> > Since I'm going to use the stateful DHCPv6 way... I'm wondering how I can
> > set the tentative flag from userspace?
>
> Tentative flag cannot be set from userspace.
> So, if we're going this way, we might need new flag for "admin" or
> "static" or something alike for manual / static addresses
> (including link-local addresses, probably).
>
> --yoshfuji
ok, this is a blocker... so, what about a "static flag" per interface instead 
of  per addresses (maybe add something 
like /proc/sys/net/ipv6/conf/ethX/address_flush).

So that on the first initialization of the interface (modprobe time) we create 
always generate a link-local address (like now)... But then on every down/up 
cycle we check the _new_ static flag.

if it is not set then we do the _old_ behaviour... (flushing everything)
and if it is set we just leave everything in place.... (and on "up", we just 
use the old link-local again instead of making a new one)

Will this work? or are there some pitfalls with this approach?
 
Regards,
	Christian
