From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Update FarSync WAN driver in 2.4.25
Date: Wed, 04 Feb 2004 16:18:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4021618B.7070605@pobox.com>
References: <7C078C66B7752B438B88E11E5E20E72E25CBB5@general.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "'davem@redhat.com'" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
In-Reply-To: <7C078C66B7752B438B88E11E5E20E72E25CBB5@general.hq.farsitecommunications.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

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
