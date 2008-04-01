From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 4 of 5] IPv6: fix lifetime calculation on temporary
 address creation
Date: Wed, 02 Apr 2008 08:41:14 +0900 (JST)
Message-ID: <20080402.084114.60517414.yoshfuji@linux-ipv6.org>
References: <ec551b4a5bb25cda00ff.1206305172@pirzuine>
	<20080328.120401.89511262.yoshfuji@linux-ipv6.org>
	<20080401215657.GP475@pirzuine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59669 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900AbYDAXjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 19:39:40 -0400
In-Reply-To: <20080401215657.GP475@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080401215657.GP475@pirzuine> (at Tue, 1 Apr 2008 23:56:57 +0200), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:

> On Fri, Mar 28, 2008 at 12:04:01PM +0900, YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > In article <ec551b4a5bb25cda00ff.1206305172@pirzuine> (at Sun, 23 Mar 2008 21:46:12 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
> > 
> > > IPv6: fix lifetime calculation on temporary address creation
> [snip]
> > > +	now = jiffies;
> > > +	elapsed = (now - ifp->tstamp) / HZ;
> > > +	if (elapsed >= ifp->valid_lft)
> > > +		tmp_valid_lft = 0;
> > > +	else
> > > +		tmp_valid_lft = min_t(__u32,
> > > +				      ifp->valid_lft - elapsed,
> > > +				      idev->cnf.temp_valid_lft);
> > > +	if (elapsed >= ifp->prefered_lft)
> > > +		tmp_prefered_lft = 0;
> > > +	else
> > > +		tmp_prefered_lft = min_t(__u32,
> > > +					 ifp->prefered_lft - elapsed,
> > > +					 idev->cnf.temp_prefered_lft - desync_factor / HZ);
> > 
> > Basically I agree, but it is possible to expire the temporary
> > address AFTER public address, which is not good.  Please fix this.
> 
> do you mean because of the rounding of 'elapsed' ? otherwise I don't see
> what the problem is, sorry.

Right.  Maybe we could substruct "now" by adj = (now - ifp->tstamp) % HZ;
   now = jiffies
   elapsed = (now - ifp->tstamp) / HZ;
   now -= (now - ifp->tstamp) % HZ;

--yoshfuji
