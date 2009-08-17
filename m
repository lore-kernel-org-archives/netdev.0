From: Roland Dreier <rdreier@cisco.com>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Mon, 17 Aug 2009 15:04:03 -0700
Message-ID: <ada7hx22j3g.fsf@cisco.com>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:12971 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbZHQWED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 18:04:03 -0400
In-Reply-To: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> (Christoph
	Lameter's message of "Mon, 17 Aug 2009 15:26:02 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > mlx4 fails to initialize here:
 > 
 > 
 > [    9.973940] mlx4_core 0000:04:00.0: irq 93 for MSI/MSI-X
 > [    9.983108] sr 1:0:0:0: Attached scsi CD-ROM sr0
 > [    9.988209] ses 0:0:32:0: Attached scsi generic sg0 type 13
 > [    9.999376] sd 0:2:0:0: Attached scsi generic sg1 type 0
 > [   10.010024] sr 1:0:0:0: Attached scsi generic sg2 type 5
 > [   10.256371] mlx4_core 0000:04:00.0: SW2HW_EQ failed (-5)
 > [   10.270103] mlx4_core 0000:04:00.0: Failed to initialize event queue
 > table, aborting.
 > [   10.288768] mlx4_core 0000:04:00.0: PCI INT A disabled
 > [   10.299057] mlx4_core: probe of 0000:04:00.0 failed with error -5

Thanks for the report... could you try loading mlx4_core with
debug_level=1 to see if anything interesting comes out?  The kernel log
here indicates that the device FW is giving us "internal error" when we
try to initialize event queues.

Also what kernel is this with?  Anything unusual about the system (arch
!= x86, lots of CPUs or RAM, etc)?

One stab in the dark would be to try a423b8a0 ("mlx4_core: Allocate and
map sufficient ICM memory for EQ context") from the for-next branch of
my infiniband.git kernel.org tree.  I would only think that matters if
you have 32 or more CPUs, but maybe you do...

 - R.
