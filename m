From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Fri, 6 Jun 2008 13:03:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu>  <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
  <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>  <20080605142244.GA19216@elte.hu>
  <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi> <1212708571.19522.10.camel@tng>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-516156546-1212746582=:16829"
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50722 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200AbYFFKDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:03:08 -0400
In-Reply-To: <1212708571.19522.10.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-516156546-1212746582=:16829
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 5 Jun 2008, Patrick McManus wrote:

> On Fri, 2008-06-06 at 00:13 +0300, Ilpo Järvinen wrote:
> 
> > 
> > I'm out of new ideas what could be still wrong (I got confused and
> > lost 
> > track number of times while I tried to verify socket locking today and 
> > probably don't have more time for that now)... Unless somebody else 
> > (Patrick?) comes up with something quickly,
> 
> Sorry, I don't see anything - it seems to boil down to the same code in
> the DA and non-DA case as far as I can tell, but after a while all the
> twisty passages seem to look alike.

:-)
 
This Ingo's testcase should anyway be quite "simple", I mean that distcc 
shouldn't do anything unexpected in a sense it shouldn't abort the flows 
by not sending data, close the listening socket or other things like that.

> If Ingo confirms that the recv end was running the locking patch code,
> it would be interesting to just confirm the sysreq+t looks the same as
> before - it is possible the patch turned the race into a non-obvious
> deadlock.

...Yes, but we want that from the receiver's host rather than from the 
sender end. Also checking that sender is still doing window probes once 
per 2min is probably worth of it though a change in that is quite 
unlikely.

> I'm sure your smaller revert will make the problem go away just as the
> larger one did, fwiw. 

I'd very much except it to.

> The other odd thing is that Ingo did a lot of experimentation and was
> only making this happen on localhost before (though I agree there is
> nothing inherent about that lock and localhost) - isn't it odd that the
> first trigger of it now is between two hosts? What do you make of that?

...No, it occurred couple of times in the past between host as well, 
nothing new in that.

-- 
 i.
---696208474-516156546-1212746582=:16829--
