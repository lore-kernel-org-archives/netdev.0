From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 26 Aug 2010 10:01:16 -0500
Message-ID: <20100826150116.GB21770@auslistsprd01.us.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com> <20100818144124.33a72453@nehalam> <20100819213314.GA26135@auslistsprd01.us.dell.com> <20100819145308.0fa08522@nehalam> <20100825220323.GA12671@auslistsprd01.us.dell.com> <20100825171646.3d40b721@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, linux-pci@vger.kernel.org,
	linux-hotplug@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:3075 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012Ab0HZPBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 11:01:38 -0400
Content-Disposition: inline
In-Reply-To: <20100825171646.3d40b721@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 25, 2010 at 05:16:46PM -0700, Stephen Hemminger wrote:
> On Wed, 25 Aug 2010 17:03:23 -0500
On Wed, Aug 25, 2010 at 05:16:46PM -0700, Stephen Hemminger wrote:
> Is it really a good idea to have to change every utility that could
> alter network devices?  There is iproute2, iputils, tcpdump, wireshark,
> quagga, snmp, ...  Many of the utilities come from a BSD world,
> and will be less likely to accept some Linux specific wart.

I agree, I don't want to have to change all those userspace apps
either.  We've started creating patches and are willing to do so if it
will yield the result we want though.
 
> I have lost faith in this library wrapper support everywhere method.
> Let's just keep the firmware stuff in udev. If the user wants to
> have a policy that renames device from eth0 to "Embedded BIOS LAN1" then
> do it in udev. Or if you want to keep the ethX naming convention
> and stuff the firmware label into ifAlias or other sysfs field
> so it can be displayed that will be not a big issue.

1) we remain constrained to IFNAMSIZ named arguments.  There is no
   such constraint on BIOS-provided names.  Dell BIOS presently uses
   'Embedded NIC 1' which (fortunately) is 14 chars. We're cutting it
   awfully close already.  I can't dictate to non-Dell BIOS vendors
   what to use as their strings, or how long to make them.

digression 1a) udev has a replace-spaces-with-underscores feature I used in
    the biosdevname udev rules.  That's a reasonable munging of the
    provided strings.  Much more than that and I'm not sure we could
    consistently get it right.

2) there are apps which use a regexp for device names.  We'd have to
   find and fix those too.  Arguably we'd have to do this when we
   patch them to use libnetdevname. [1]

3) it continues to force a single naming convention for NICs, where
   for other types of devices we can have several independent naming
   conventions.  I have end users who wish to name their interfaces by
   the BIOS label, others by the function (public, dmz,
   backup, storage, ...) that the network segment provides.  While we
   could have different policies, each system can have only one policy
   at a time.
  

David Miller had suggested [2] that we could add a method to get
alternate labels for devices by querying them.  We've got something
similar now by exporting the labels for devices in sysfs.  Yea -
progress!

But we can't _use_ those labels for more than display
(meaning a human is doing the mapping in their heads), or to rename
devices.  We can't use the labels in scripts without doing the label->kernel
name lookups, and then using the kernel name.

I'm open to revisiting the "have udev rename devices", but I tried
that with biosdevname 2 years ago, with little success.  Adding in the
hotplug dev team to the thread.


[1] http://marc.info/?l=linux-netdev&m=125522163322610&w=2 (Marco d'Itri)
[2] http://marc.info/?l=linux-hotplug&m=123793549323431&w=2

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
