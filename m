From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted
	to managed
Date: Thu, 4 Oct 2007 14:15:16 -0400
Message-ID: <20071004181516.GH6037@tuxdriver.com>
References: <20071004113343.552139D502B@zog.reactivated.net> <200710041706.06182.mb@bu3sch.de> <20071004151956.GE6037@tuxdriver.com> <200710041311.37997.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, Daniel Drake <dsd@gentoo.org>,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3578 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759230AbXJDSi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 14:38:58 -0400
Content-Disposition: inline
In-Reply-To: <200710041311.37997.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 01:11:33PM -0400, Michael Wu wrote:
> On Thursday 04 October 2007 11:19, John W. Linville wrote:
> > > The reason why BUG_ON exists is to catch bugs that happen, although
> > > they Should Never Happen (tm) ;)
> >
> > Precisely.

> No really, this bug will never happen. This is function is merely a helper 
> function which is called from interface removal code (where the interface 
> *has* to be down) or from changing the interface type (which ensures that the 
> interface is down first). There are an unlimited number of bugs which Should 
> Never Happen. That doesn't mean we should start adding BUG_ONs for every 
> single one of them. That gives some sort of protection against cosmic rays 
> flipping bits, but down here on earth, it's bloat.

Falling back on bloat as an argument against a BUG_ON in a
configuration path seems a bit weak. :-)

Programming with assertions (and BUG_ON is a form of that) is
generally a good practice.  Almost any book or other source on
good programming practices will agree.  Yes, it can be overdone.
But I don't really think that is the case here, since the check is
relatively inexpensive and the consequence should it ever *somehow*
happen could be a something wierd (crash, corruption, etc) w/o any
other indication of what occured.

Anyway, the point is probably moot in this case if there is no great
objection to the alternative patch I proposed.

John
-- 
John W. Linville
linville@tuxdriver.com
