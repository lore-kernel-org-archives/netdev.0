From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: BUG: bonding module can only be loaded once
Date: Tue, 09 Jun 2009 09:14:42 -0700
Message-ID: <4752.1244564082@death.nxdomain.ibm.com>
References: <20090608151127.70146505@nehalam> <200906091406.45463.arnd@arndb.de> <20090609080232.45f81833@nehalam> <4A2E80B3.6010600@trash.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	bonding-devel@lists.sf.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45356 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbZFIQPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 12:15:53 -0400
In-reply-to: <4A2E80B3.6010600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote:

>Stephen Hemminger wrote:
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -5203,7 +5203,7 @@ static int __init bonding_init(void)
>>>   	res = bond_create_sysfs();
>>>  	if (res)
>>> -		goto err;
>>> +		pr_info("Loading bonding module without sysfs interface\n");
>>>   	register_netdevice_notifier(&bond_netdev_notifier);
>>>  	register_inetaddr_notifier(&bond_inetaddr_notifier);
>>
>> That only makes it limp along, and there still are warnings.
>> The point is that who ever added the WARN() in proc and sysfs, effectively
>> broke a bonding usage model.
>
>It did already dump the stack before that change, didn't it?
>
>In any case, this is not the first time this has been broken and the
>fundamental reason is in my opinion that the bonding interface is
>broken to begin with. The module aliasing thing is complete crap
>and should have been phased out long ago. At this point its probably
>not worth anymore to migrate people to the sysfs interface though,
>the best thing would be to add an rtnl_link interface and phase out
>both.

	The "load bonding multiple times" stuff is only there now for
backwards compatibility with old distro initscripts / sysconfig packages
that don't configure bonding through sysfs (a sysfs API was added to
bonding three or four years ago).

	All of the current distro releases I'm aware of use sysfs to
configure bonding, and have done so for at least a year or two.  I
haven't done an exhaustive survey, but it seems unlikely that users are
running a current up to date kernel with a two or three year old
initscripts / sysconfig package.  Anybody have information to the
contrary?

	If nobody has any heartburn at dropping support for multiple
bonding instances on old distros, I'm as happy as anybody to remove all
of the multiple load logic from bonding.  There's been plenty of time
for transitioning from "multiple load" to sysfs.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
