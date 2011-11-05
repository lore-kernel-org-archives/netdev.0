From: Rick Jones <rick.jones2@hp.com>
Subject: Re: what's in a bus_info
Date: Fri, 04 Nov 2011 18:17:08 -0700
Message-ID: <4EB48E94.7010804@hp.com>
References: <4EB466CB.2040506@hp.com> <1320447726.2753.30.camel@bwh-desktop> <4EB475CC.1000601@hp.com> <1320450167.2753.39.camel@bwh-desktop> <4EB47DB1.2000005@hp.com> <20111104170705.0553b8cf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, mst@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:38788 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752457Ab1KEBRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 21:17:10 -0400
In-Reply-To: <20111104170705.0553b8cf@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2011 05:07 PM, Stephen Hemminger wrote:
> My view of bus_info, is that it is an informational string for administrators.
> Tools shouldn't depend on the value.  If a tool wants to find out about
> the physical device, then it should readlink the value of /sys/class/net/ethX/device

Just a quick look under device for the virtio_net interface shows it 
isn't quite as "complete" as a bare iron tg3 interface (as an example)

The bare iron tg3 example:
raj@tardy:~$ ls /sys/class/net/eth0/device
broken_parity_status      enable         net        resource0
class                     firmware_node  numa_node  subsystem
config                    irq            power      subsystem_device
consistent_dma_mask_bits  local_cpulist  remove     subsystem_vendor
device                    local_cpus     rescan     uevent
dma_mask_bits             modalias       reset      vendor
driver                    msi_bus        resource   vpd

The virtio_net interface:

raj@raj-ubuntu-guest:~$ ls /sys/class/net/eth0/device
device  features  net    status     uevent
driver  modalias  power  subsystem  vendor


I have found that if I add a function to return a struct pci_dev * given 
a struct virtio_device, to virtio/virtio_pci.c and do a pci_name() 
against that, I do get a familiar looking bus address:

raj@raj-ubuntu-guest:~$ ethtool -i eth0
driver: virtio_net
version: I am versionless
firmware-version: I have no firmware
bus-info: 0000:00:03.0

and it even matches the lspci output for the guest:

00:03.0 Ethernet controller: Red Hat, Inc Virtio network device

(still my "playing around" version, hence the silly strings in version 
and firmware-version)

I suppose the question becomes whether it is worthwhile to clean it up 
and submit.    I'm also thinking it would be goodness to start 
displaying some sort of version number, and if there is anything the 
driver might query to fill-in as a firmware-version - perhaps something 
about the version of the driver on the other side?

rick jones
