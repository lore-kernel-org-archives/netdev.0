From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] BUG: bonding module can only be loaded once
Date: Tue, 09 Jun 2009 10:24:11 -0700
Message-ID: <13521.1244568251@death.nxdomain.ibm.com>
References: <20090608151127.70146505@nehalam> <200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam> <4A2E80B3.6010600@trash.net> <4752.1244564082@death.nxdomain.ibm.com> <4A2E8D62.6090004@trash.net>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bonding-devel@lists.sf.net,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:38508 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753587AbZFIRYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 13:24:09 -0400
In-reply-to: <4A2E8D62.6090004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:

>Jay Vosburgh wrote:
>> Patrick McHardy <kaber@trash.net> wrote:
>> 
>>> In any case, this is not the first time this has been broken and the
>>> fundamental reason is in my opinion that the bonding interface is
>>> broken to begin with. The module aliasing thing is complete crap
>>> and should have been phased out long ago. At this point its probably
>>> not worth anymore to migrate people to the sysfs interface though,
>>> the best thing would be to add an rtnl_link interface and phase out
>>> both.
>> 
>> 	The "load bonding multiple times" stuff is only there now for
>> backwards compatibility with old distro initscripts / sysconfig packages
>> that don't configure bonding through sysfs (a sysfs API was added to
>> bonding three or four years ago).
>> 
>> 	All of the current distro releases I'm aware of use sysfs to
>> configure bonding, and have done so for at least a year or two.  I
>> haven't done an exhaustive survey, but it seems unlikely that users are
>> running a current up to date kernel with a two or three year old
>> initscripts / sysconfig package.  Anybody have information to the
>> contrary?
>
>I'd expect its not the distros, but rather the applicances which might
>still be using this. I know a vendor I used to work for a couple of
>years ago just recently made the switch from 2.6.16 to a current kernel,
>and I'd expect that they are still using this (I can find out tommorrow
>if you want to know for sure). Vyatta likewise, I guess.

	Yes, I'd like to know for sure; thanks.

>> 	If nobody has any heartburn at dropping support for multiple
>> bonding instances on old distros, I'm as happy as anybody to remove all
>> of the multiple load logic from bonding.  There's been plenty of time
>> for transitioning from "multiple load" to sysfs.
>
>In my opinion it would need a feature-removal-schedule announcement.

	Yah, probably.  The multiple load stuff was working fine as of,
oh, a year or two ago, so I wasn't worried so much about getting rid of
it.  If it's causing problems, though, it's time for it to go (or be
scheduled to go in the not too distant future).  Can't keep driving that
Ford Pinto forever.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
