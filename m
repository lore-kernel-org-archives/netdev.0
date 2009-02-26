From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
 module
Date: Thu, 26 Feb 2009 11:44:29 -0500
Message-ID: <49A6C6ED.3070801@hp.com>
References: <49A5ADB3.2010709@hp.com>	<28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, arvidjaar@mail.ru, vladislav.yasevich@hp.com,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:6637 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265AbZBZQoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 11:44:34 -0500
In-Reply-To: <20090225.141430.166906161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Wed, 25 Feb 2009 14:10:58 -0800
> 
>> 	I've been fooling with the disable_ipv6 sysctl, and one issue is
>> that, at least on the distro I'm testing on (SLES), it's not picked up
>> from /etc/sysctl.conf at boot time (presumably because ipv6 isn't loaded
>> yet, although I haven't really checked).
> 
> Correct, that's the problem.
> 
> We could create a blocker bitmap.  Two sysctls, "block_af" and
> "unblock_af".  You write the AF_foo value for the protocol there and
> it sets or clears the assosciated bit in the internal blocker bitmap.
> 
> Things like sys_socket() et al. key off of this.

I'm open to suggestions at this point in time, I just don't see how this will 
solve the bonding problem since it still wouldn't load, right?

Dave - do you feel I need to fix this regression?  If not I can try to work on 
this AF blocker thing.  My only other thought if we want to fix this is to have 
the IPv6 module register these five functions into an ops structure that bonding 
can call.  It doesn't fix SCTP, qeth, etc, but it gets these "blacklist ipv6" 
configs working again, and gets me out of the crosshairs :)

-Brian
