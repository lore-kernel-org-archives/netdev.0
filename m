From: Martin Michlmayr <tbm@cyrius.com>
Subject: skge error; hangs w/ hardware memory hole
Date: Mon, 3 Jul 2006 22:52:38 +0200
Message-ID: <20060703205238.GA10851@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, 341801@bugs.debian.org,
	asd@suespammers.org, kevin@sysexperts.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.19.161.204] ([65.19.161.204]:39950 "EHLO sorrow.cyrius.com")
	by vger.kernel.org with ESMTP id S932106AbWGCUxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 16:53:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We received the following bug report at http://bugs.debian.org/341801

| I have a Asus A8V with 4GB of RAM. When I turn on the hardware memory
| hole in the BIOS, the skge driver prints out this message:
|       skge hardware error detected (status 0xc00)
| and then does not work. Setting debug=16 doesn't really show anything.

Another users confirms this bug, saying:

| I'm running kernel 2.6.15-1-amd64-generic version 2.6.15-6, and see
| the very same thing.
| So I have to turn off the memory remapping feature that allows the
| system to see all 4 gig of memory, and thus lose the use of about 200
| megabytes of memory.
| Hardware: ASUS A8V Deluxe, 4G RAM, Athlon 64 3200+ CPU.

This problem has probably been there forever and also happens with the
sk98lin driver:

| With sk98lin under both 2.6.12 and 2.6.17 I get the following message,
| repeated countless times, and finally a hang: [this is copied from
| screen on to a sheet a paper and re-typed, beware typos]:

| eth0: Adapter failed
| eth0: -- ERROR --
| class: Hardware failure
| Nr: 0x264
| Msg: unexpected IRQ Status error

The bug is still present in 2.6.17 -mm6:

| -mm6 does not work with skge and the hardware memory hole. It gave
| these messages:

| skge eth0: enabling interface
| skge 0000:00:0a.0: PCI error cmd=0x117 status=0x22b0
| skge unable to clear error (so ignoring them)
| skge eth0: Link is up at 1000 Mbps, full duplex, flow control tx and rx

| DHCP never managed to get an IP address.

Any idea what to do about this?
-- 
Martin Michlmayr
http://www.cyrius.com/
