From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: bonding module can only be loaded once
Date: Tue, 09 Jun 2009 18:27:14 +0200
Message-ID: <4A2E8D62.6090004@trash.net>
References: <20090608151127.70146505@nehalam> <200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam> <4A2E80B3.6010600@trash.net> <4752.1244564082@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757046AbZFIQ11@vger.kernel.org>
In-Reply-To: <4752.1244564082@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Patrick McHardy <kaber@trash.net> wrote:
> 
>> In any case, this is not the first time this has been broken and the
>> fundamental reason is in my opinion that the bonding interface is
>> broken to begin with. The module aliasing thing is complete crap
>> and should have been phased out long ago. At this point its probably
>> not worth anymore to migrate people to the sysfs interface though,
>> the best thing would be to add an rtnl_link interface and phase out
>> both.
> 
> 	The "load bonding multiple times" stuff is only there now for
> backwards compatibility with old distro initscripts / sysconfig packages
> that don't configure bonding through sysfs (a sysfs API was added to
> bonding three or four years ago).
> 
> 	All of the current distro releases I'm aware of use sysfs to
> configure bonding, and have done so for at least a year or two.  I
> haven't done an exhaustive survey, but it seems unlikely that users are
> running a current up to date kernel with a two or three year old
> initscripts / sysconfig package.  Anybody have information to the
> contrary?

I'd expect its not the distros, but rather the applicances which might
still be using this. I know a vendor I used to work for a couple of
years ago just recently made the switch from 2.6.16 to a current kernel,
and I'd expect that they are still using this (I can find out tommorrow
if you want to know for sure). Vyatta likewise, I guess.

> 	If nobody has any heartburn at dropping support for multiple
> bonding instances on old distros, I'm as happy as anybody to remove all
> of the multiple load logic from bonding.  There's been plenty of time
> for transitioning from "multiple load" to sysfs.

In my opinion it would need a feature-removal-schedule announcement.
