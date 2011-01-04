From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 25062] New: Bonding packet deduplication
 doesn't work properly anymore
Date: Tue, 4 Jan 2011 13:39:36 -0800
Message-ID: <20110104133936.60d389e2.akpm@linux-foundation.org>
References: <bug-25062-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-new@lists.osdl.org,
	bugme-daemon@bugzilla.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	kevin.lapagna@bigtag.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36655 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab1ADVkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 16:40:46 -0500
In-Reply-To: <bug-25062-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 17 Dec 2010 11:45:18 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=25062
> 
>            Summary: Bonding packet deduplication doesn't work properly
>                     anymore
>            Product: Networking
>            Version: 2.5
>     Kernel Version: > 2.6.33
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: kevin.lapagna@bigtag.ch
>         Regression: No
> 
> 
> Here's the setup:
> 
> switch: ordinary cisco switch
> eth0: NIC with kernel module tg3
> eth1: NIC with kernel module e1000e
> bond0: bond with slaves eth0,eth1 in mode 1 (or 5)
> bond0.100: vlan device created with vconfig
> bridge100: bridge created with brctl
> tap1: tap device created with tunctl
> vguest: qemu-kvm vguest whit emulated e1000 NIC
> 
> 
> |________________|-- eth0 \                                               |________________|
> | switch |          -- bond0 -- bond0.100 -- bridge100 -- tap1 -- | vguest |
> |________|-- eth1 /                                               |________|
> 
> When the vguest emits an ethernet broadcast (DHCP-request), it's forwarded all
> the way up to the switch, through eth0. The switch forwards the broadcast -
> also to eth1. The packet travels then all the way back to bridge100. So the
> last status known for bridge100, regarding the mac address of the vgeust is,
> that it is behind bond0.110 (instead of tap1). If a DHCP-server responds to the
> request, the packet travels to bridge100, which has now a faulty
> MAC-address-table and the packet will be rejected and never reaches tap1 and
> therefor not the vguest.
> 
> I witnessed this wrong behavior in kernel 2.6.37-rc5 (debian package), 2.6.36.2
> and 2.6.35.9 (self compiled -  vanilla). The setup has worked with kernels <=
> 2.6.33.7. I've never tried 2.6.34.
> 
> I assume the setup above is a common way for the separation of virtual guests
> on a network level. So this could become a major issue for a lot of people when
> upgrading their kernels.
> 

