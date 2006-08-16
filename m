From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [E1000-devel] e1000: ethtool -p + cable pull = system wedges hard
Date: Wed, 16 Aug 2006 11:33:00 -0700
Message-ID: <200608161833.k7GIX0Zt014490@death.nxdomain.ibm.com>
References: <36D9DB17C6DE9E40B059440DB8D95F526B3588@orsmsx418.amr.corp.intel.com>
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:1513 "EHLO e36.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S932180AbWHPSdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 14:33:03 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7GIX3jE013666
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 14:33:03 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7GIX20u197626
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 12:33:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7GIX1mX016587
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 12:33:02 -0600
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-reply-to: <36D9DB17C6DE9E40B059440DB8D95F526B3588@orsmsx418.amr.corp.intel.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse <jesse.brandeburg@intel.com> wrote:

>Kok, Auke-jan H wrote:
>> Auke Kok wrote:
>>> Jay Vosburgh wrote:
>>>> 	Running both 2.6.17.6 plus the e1000 7.2.7 from sourceforge, or
>>>> the e1000 in netdev-2.6#upstream (7.1.9-k4).
>>>> 
>>>> 	Starting up "ethtool -p ethX" then unplugging the cable
>>>> connected to the identified port is causing my system to completely
>>>> freeze; even sysrq is unresponsive.  I'm running on a 2-way x86
>>>> box, with an 82545GM. 
[...]
>Has something to do with the RTNL lock being held and link notification,
>as I remember.
>We noticed it to be a global problem, happens with e100 too.
>
>http://www.mail-archive.com/netdev@vger.kernel.org/msg01654.html

	Well, I thought maybe I'd messed it up when I tested the other
cards, but I just went and tried it again.  Only the e1000 wedges the
system if I pull the cable with ethtool -p running.  The e100 and tg3
don't lock up.  Pulling the cable ends the ethtool for tg3, but for e100
the blinky blinky keeps going even after the cable is back in.

	Even so, as you mention, the operation is holding the RTNL, so
anything else that wants it has to wait.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
