From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 10:21:34 +0100
Message-ID: <1300699294.10934.63.camel@firesoul.comx.local>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:43461 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056Ab1CUJ3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 05:29:08 -0400
In-Reply-To: <4D8385CE.1060205@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 09:18 -0700, Alexander Duyck wrote:
> On 3/18/2011 4:12 AM, Jesper Dangaard Brouer wrote:
> > Hi
> >
> > I'm seeing the LRO disable warnings using kernel 2.6.38:
[...]
> >
> The error doesn't make any sense for igb to be triggering since it 
> doesn't support setting the NETIF_F_LRO flag in the 2.6.38 kernel.
> 
> By any chance are there any ixgbe or other interfaces in the system?  I 
> would suspect the error to come from a driver that at least contains the 
> NETIF_F_LRO flag.

The servers actually also have a four port semi-build in NIC (its a PCIe
slot with an extra connector, most likely for controlling the LEDs).  I
don't use that NIC as it (1) caused kernel panics on 2.6.35, (2) needs a
firmware blob, (3) reading through the driver code (at some point in
time) they didn't implement multiqueue support correctly.

So lets blame that driver ;-)

lspci-info:
 Ethernet controller: NetXen Incorporated NX3031 Multifunction 1/10-Gigabit Server Adapter (rev 42)

driver info via ethtool:
# ethtool -i eth01
 driver: netxen_nic
 version: 4.0.75
 firmware-version: 4.0.530
 bus-info: 0000:06:00.3

The strange part is that my pre-prod server also have a netxen_nic, but
it does not result in a WARN being tricked... 

The pre-prod server do have a different firmware version.
# ethtool -i eth01
 driver: netxen_nic
 version: 4.0.75
 firmware-version: 4.0.406
 bus-info: 0000:06:00.0

(I have pulled the NIC out of some of the prod server, due to the risk
of a kernel panic on the old kernel.  As operations have taken over the
deployment process, these NICs are still in.  Guess I'll ask them to
blacklist the driver, so they don't see the warn stacktrace, they get so
nervous when they see stuff like that ;-))

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


