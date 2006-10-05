From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Thu, 05 Oct 2006 16:56:46 +0200
Message-ID: <45251D2E.7050006@voltaire.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com> <4522605E.8000208@voltaire.com> <200610032310.k93NAGZt003069@death.nxdomain.ibm.com> <4523D254.9060006@voltaire.com> <200610041734.k94HYEZt013562@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:29732 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1751479AbWJEO5B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 10:57:01 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200610041734.k94HYEZt013562@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
>> My understanding is that changing ifenslave and the bonding kernel code to
>> allow for enslaving while master is not up is enough, so actually no
>> change is needed to the sysconfig tools, correct?
> 
> 	Incorrect.  The /sbin/ifup included with sysconfig (I'm looking
> at version 0.31-0-15.51) has logic to set the bonding master device up
> prior to adding any slaves.  E.g.,
> 
> 		# get up the bonding device before enslaving
> #		if ! is_iface_up $INTERFACE; then
> 			ip link set $INTERFACE up 2>&1
> #		fi
> 		# enslave available slave devices; if there is none -> hard break and log
> 		MESSAGE=`/sbin/ifenslave $BONDING_OPTIONS $INTERFACE $BSINTERFACES 2>&1`
> 
> 	For your purposes, this would cause it to register as an
> ethernet hardware type, not an IB type.  The /sbin/ifup included with
> initscripts operates a little differently, but also sets the bonding
> master up prior to adding any slaves.

OK, you are correct, i agree that the /sbin/ifup would attempt to first 
bring up the bonding device so it breaks my assumptions...

> 	Yes.  Part of the difficulty is that the changes to the
> initscripts and sysconfig packages won't be compatible with versions of
> bonding prior to the bonding kernel changes (because older versions of
> bonding will refuse to add slaves if the master is down).  It might
> require adding another API version to bonding, and modifying ifenslave
> to work both ways (i.e., with the current "enslave with master up" API,
> as well as the new "enslave with master down" API).

Gee, sounds bad

> 	An alternate approach would be to undertake the more substantial
> task of converting the initscripts and sysconfig code to use sysfs to
> configure bonding.  This would permit changing the logic (to add slaves
> while the bonding master is down, then set it up), as well as remove the
> current hacks (present only in sysconfig) to load the bonding module
> once per configured bonding interface.  The initscripts currently don't
> do this (as far as I know), so it's generally only possible to have one
> bonding interface under initscripts control.

This sounds like a good idea to get out of all these troubles...

So the direction to have sysconfig and initscripts tools configure 
bonding by sysfs and not by the enslave program is something you were 
considering regardless of the needs imposed by bonding support for non 
ARPHRD_ETHER netdevices? and you think the distro packages owners would 
like this?

I will look into the current methods used by sysconfig to configure 
bonding and see if i can come up with sketch of how to do it with sysfs.

Basically, i use now my own script working with sysfs in my IPoIB 
bonding testing where i have followed the directions in the bonding 
kernel doc.

Thanks again for all the coaching...

Or.


