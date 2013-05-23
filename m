From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Generic interface to make physical port number used by a
 netdevice available to user space
Date: Thu, 23 May 2013 09:34:21 -0700
Message-ID: <20130523093421.3b20a0bd@nehalam.linuxnetplumber.net>
References: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:44707 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758563Ab3EWQe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 12:34:29 -0400
Received: by mail-pa0-f44.google.com with SMTP id wp1so588111pac.17
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 09:34:28 -0700 (PDT)
In-Reply-To: <20130522075331.GA1363@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 May 2013 13:24:15 +0530
<Narendra_K@Dell.com> wrote:

> Hello,
> 
> It is useful to know if network interfaces from NIC partitions 'map to/ use the'
> same physical port. For example,  when creating bonding in fault tolerance mode,
> if two network interfaces map to/use the same physical port, it might not have the
> desired result. This information is not available today in a standard format or
> it is not present.  If this information can be made available in a generic  way
> to user space, tools such as NetworkManager or Libteam  or Wicked can make smarter
> bonding decisions (such as warn users when setting up configurations which will
> not have desired effect).
> 
> The requirement is to have a generic interface using which kernel/drivers can
> provide information/hints to user space about the physical port number used by
> a network interface.
> 
> While looking for already existing generic facility, 'dev_id' sysfs attribute
> seemed relevant. Looking into the sources seemed to indicate that majority of 
> the drivers do not set it and it could be interpreted differently.
> 
> It would be great to know list's thoughts on  'dev_id' being used as the interface
> to make the physical port number information used by netdevice available to user
> space or do we need a new sysfs attribute for the same.
> 
> Note: I think in the scenario of SRIOV VF devices assigned to guest and being
> bonded, additional information would be needed to differentiate the network
> controller in the host.  But I suppose it is a different problem than this.
> 
> References to related discussions:
> 1. [PATCH net-next] bnx2x: Add Nic partitioning mode (57712)
> http://marc.info/?l=linux-netdev&m=129098288709528&w=2
> 2. [PATCH net-next] bonding: Support for multi function NIC devices
> http://marc.info/?l=linux-netdev&m=134240221118594&w=2
> 
> Thank you,
> 

One idea would be to reuse the mostly outdated if_port field.
As far as I can see only drivers using it are legacy drivers which support AUI vs. TP
back in the old bad days of BNC Ethernet.
