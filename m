From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: spidernet: dynamic phy setup code
Date: Sat, 27 Jan 2007 07:21:42 +1100
Message-ID: <1169842902.24996.108.camel@localhost.localdomain>
References: <200701261409.29537.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Linas Vepstas <linas@austin.ibm.com>, jgarzik@pobox.com,
	James K Lewis <jim@jklewis.com>
To: Jens Osterkamp <jens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58460 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbXAZUXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 15:23:23 -0500
In-Reply-To: <200701261409.29537.jens@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-01-26 at 14:09 +0100, Jens Osterkamp wrote:
> This patch modifies the patch submitted by Kou Ishizaki to make it work on the
> blade (http://marc.theaimsgroup.com/?l=linux-netdev&m=116593424505539&w=2).
> Unfortunately I dont have access to a Celleb so I cannot test it there.
> 
> The basic logic behind this is simple : when the interface first comes up
> it tries to detect the phy. When the phy is detected, it is initially set up
> to use copper. A timer is set to check the link status in spidernet_link_phy
> using poll_link. If link check fails more than SPIDER_NET_ANEG_TIMEOUT
> times, it switches to fiber link with autonegotiation. If that fails more
> than SPIDER_NET_ANEG_TIMEOUT times, it switches to fiber link with no
> autonegotiation. If that also fails, it goes back to copper, and so forth.
> If the link comes up, it prints the link abilites and we are done.
> 
> The name of the phy found attached to the spider chip is reported to the
> user. Hardcoded values for the timeout are moved to #defines. I put in a
> few comments to make the code more readable.

Can't we have a device-tree property indicating wether to use fiber or
copper ?

Ben.


