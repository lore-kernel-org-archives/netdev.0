From: "Kevin Curtis" <kevin.curtis@farsite.co.uk>
Subject: RE: Update FarSync WAN driver in 2.6
Date: Wed, 25 Feb 2004 17:19:34 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7C078C66B7752B438B88E11E5E20E72E25CC09@general.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-Class: urn:content-classes:message
To: "Kevin Curtis" <kevin.curtis@farsite.co.uk>,
        "Jeff Garzik" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
	any progress on the updating of the farsync driver in the 2.4
and 2.5 Kernels?

Regards

Kevin Curtis
Linux Development
FarSite Communications Ltd
http://www.farsite.co.uk
tel:  +44 1256 330461
fax:  +44 1256 854931

-----Original Message-----
From: Kevin Curtis 
Sent: 19 February 2004 11:03
To: Kevin Curtis; 'Jeff Garzik'
Cc: 'netdev@oss.sgi.com'; 'davem@redhat.com'
Subject: Update FarSync WAN driver in 2.6


Hi,
	Please find attached a patch file for the farsync drivers in 2.6
Kernel.  The patch was generated against 2.6.3, i.e. the latest release.
I have used tasklets instead of schedule_work and this seems to have
solved the performance problem I referred to last week.  I now wish to
use tasklets in the 2.4 Kernel.  Would you like me to resend the patch
again (updated), or a new patch to patch the patch you already have?


Kind Regards

Kevin Curtis
Linux Development
FarSite Communications Ltd
http://www.farsite.co.uk
tel:  +44 1256 330461
fax:  +44 1256 854931

-----Original Message-----
From: Kevin Curtis 
Sent: 12 February 2004 10:12
To: 'Jeff Garzik'; Kevin Curtis
Cc: 'netdev@oss.sgi.com'; 'davem@redhat.com'
Subject: RE: Update FarSync WAN driver in 2.4.25


Hi,
	Please find attached a revised patch file which I believe
addresses the comments that you and Francois Romieu made.

	I have changed the bottom half to use schedule_task, although I
can see a marked degradation in performance.  Can you tell me if it is
possible to still queue my tasks on the Immediate queue, so that they
run as soon as the interrupt is complete.  It seems to me that the
task_queue and tasklets are not as efficient.


Kind regards

Kevin



-----Original Message-----
From: Jeff Garzik [mailto:jgarzik@pobox.com] 
Sent: 04 February 2004 21:18
To: Kevin Curtis
Cc: 'netdev@oss.sgi.com'; 'davem@redhat.com'
Subject: Re: Update FarSync WAN driver in 2.4.25


Comments:

* please use standard indentation (one tab)

* please use constants per the include/linux/pci_ids.h standard, rather 
than defining your own.

* please use standard include/linux/pci.h constants, rather than 
defining your own (PCIILR, etc.)

* further, obtain interrupt from struct pci_dev::irq after calling 
pci_enable_device(); do not obtain directly via pci_read_config_xxx()

* fst_process_rx_status() could result in flooding the log

* use pci_set_master() to enable bus-mastering

* bottom halves are deprecated.  do not add new code using mark_bh() and

friends.  Use tasklets or schedule_task().

* use pci_set_dma_mask() rather than pci_dma_supported()

* use pci_request_regions() rather than request_region()
