From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 18 Aug 2008 10:53:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808181044470.23854@wrl-59.cs.helsinki.fi>
References: <48A086B6.2000901@linux-foundation.org>
 <20080811.141501.01468546.davem@davemloft.net>
 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi> <1219025114.25933.6.camel@ymzhang>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1947864013-1219046005=:23854"
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46176 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbYHRHx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 03:53:27 -0400
In-Reply-To: <1219025114.25933.6.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1947864013-1219046005=:23854
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 18 Aug 2008, Zhang, Yanmin wrote:

> 
> On Tue, 2008-08-12 at 11:13 +0300, Ilpo Järvinen wrote: 
> > On Mon, 11 Aug 2008, David Miller wrote:
> > 
> > > From: Christoph Lameter <cl@linux-foundation.org>
> > > Date: Mon, 11 Aug 2008 13:36:38 -0500
> > > 
> > > > It seems that the network stack becomes slower over time? Here is a list of
> > > > tbench results with various kernel versions:
> > > > 
> > > > 2.6.22		3207.77 mb/sec
> > > > 2.6.24		3185.66
> > > > 2.6.25		2848.83
> > > > 2.6.26		2706.09
> > > > 2.6.27(rc2)	2571.03
> > > > 
> > > > And linux-next is:
> > > > 
> > > > 2.6.28(l-next)	2568.74
> > > > 
> > > > It shows that there is still have work to be done on linux-next. Too close to
> > > > upstream in performance.
> > > > 
> > > > Note the KT event between 2.6.24 and 2.6.25. Why is that?
> > > 
> > > Isn't that when some major scheduler changes went in?  I'm not blaming
> > > the scheduler, but rather I'm making the point that there are other
> > > subsystems in the kernel that the networking interacts with that
> > > influences performance at such a low level.
> > 
> > ...IIRC, somebody in the past did even bisect his (probably netperf) 
> > 2.6.24-25 regression to some scheduler change (obviously it might or might 
> > not be related to this case of yours)...
> I did find much regression with netperf TCP-RR-1/UDP-RR-1/UDP-RR-512. I start
> 1 serve and 1 client while binding them to a different logical processor in
> different physical cpu.
> 
> Comparing with 2.6.22, the regression of TCP-RR-1 on 16-core tigerton is:
> 2.6.23		6%
> 2.6.24		6%
> 2.6.25		9.7%
> 2.6.26		14.5%
> 2.6.27-rc1	22%
> 
> Other regressions on other machines are similar.

I btw reorganized tcp_sock for 2.6.26, it shouldn't cause this but it's 
not always obvious what even a small change in field ordering does for 
performance (it's b79eeeb9e48457579cb742cd02e162fcd673c4a3 in case you 
want to check that).

Also, there was this 83f36f3f35f4f83fa346bfff58a5deabc78370e5 fix to 
current -rcs but I guess it might not be that significant in your case 
(but I don't know well enough :-)).

-- 
 i.
---696208474-1947864013-1219046005=:23854--
