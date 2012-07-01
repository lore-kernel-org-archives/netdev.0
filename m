From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] e1000e: remove use of IP payload checksum
Date: Sat, 30 Jun 2012 17:37:52 -0700 (PDT)
Message-ID: <20120630.173752.1993136000245136259.davem@davemloft.net>
References: <1341052528-2444-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1341092196.4852.43.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2GAAhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 20:37:53 -0400
In-Reply-To: <1341092196.4852.43.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 30 Jun 2012 22:36:36 +0100

> On Sat, 2012-06-30 at 03:35 -0700, Jeff Kirsher wrote:
>> From: Bruce Allan <bruce.w.allan@intel.com>
>> 
>> Currently only used when packet split mode is enabled with jumbo frames,
>> IP payload checksum (for fragmented UDP packets) is mutually exclusive with
>> receive hashing offload since the hardware uses the same space in the
>> receive descriptor for the hardware-provided packet checksum and the RSS
>> hash, respectively.  Users currently must disable jumbos when receive
>> hashing offload is enabled, or vice versa, because of this incompatibility.
>> Since testing has shown that IP payload checksum does not provide any real
>> benefit, just remove it so that there is no longer a choice between jumbos
>> or receive hashing offload but not both as done in other Intel GbE drivers
>> (e.g. e1000, igb).
>> 
>> Also, add a missing check for IP checksum error reported by the hardware;
>> let the stack verify the checksum when this happens.
> [...]
> 
> The change to enable RX hashing in 3.4, with this odd restriction seems
> to have broken most existing systems using jumbo MTU on e1000e.  None of
> the distro scripts or network management daemons will automatically
> change offload configuration before MTU; how could they know?
> 
> Therefore this needs to be fixed in 3.5 and 3.4.y, not net-next.

Agreed.
