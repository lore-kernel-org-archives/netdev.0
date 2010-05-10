From: Stefan Berger <stefanb@us.ibm.com>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Mon, 10 May 2010 23:51:57 +0000 (UTC)
Message-ID: <loom.20100511T015142-35@post.gmane.org>
References: <C80DA4F7.2FBCF%scofeldm@cisco.com> <201005102346.38229.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:57938 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932127Ab0EJXwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 19:52:09 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OBclZ-00068G-TL
	for netdev@vger.kernel.org; Tue, 11 May 2010 01:52:05 +0200
Received: from pool-74-101-125-124.nycmny.fios.verizon.net ([74.101.125.124])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 01:52:05 +0200
Received: from stefanb by pool-74-101-125-124.nycmny.fios.verizon.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 May 2010 01:52:05 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> wrote on 05/10/2010 05:46:37 PM:


> The other question is which protocol we're using. There are as far as I
> can tell five options:
> 
> 1. enic device driver
> 2. VDP
> 3. CDCP
> 4. CDCP + VDP
> 5. enic + VDP
> 
> The first two ones are the most interesting for now, since Linux cannot do
> S-VLANs yet, and they are required for CDCP. However, each of these options
> could theoreticall be done in the kernel (plus firmware) or in user space.
> 
> If it's done in user space, the VF number is meaningless, because the setup
> of the software device is also done from software, but instead you need to
> take care of creating the software device with the correct parameters, e.g.
> a macvtap device connected to a VLAN interface using the numbers you pass
> in the VDP protocol.
> 
> Right now, we're not planning to do the protocol that enic uses in LLDPAD,
> because it's not publically released. Similarly, there are no adapters that
> do VDP in firmware, but both these cases should be covered by the protocol
> and it would be good if libvirt could handle them.
> 
> Stefan, can you just define the XML in a way that matches the netlink
> definition? What you need is something like
> 
> 1. VF number (optional, signifies that 2/3 are done in firmware) 

Shouldn't we be able to query that number via netlink starting with the 
macvtap device and the following the trail to the root and trying to find 
a VF number on the way? 

> 2. Lower-level protocol
>   2.1. CDCP
>      2.1.1 SVID
>      2.1.2 SCID 

Will the later on be qeueryable via netlink as well but not today??? 
Vivek tells me svid is vlan, so that could be found out from the kernel. 

So if we want to only support 1 and 2 for now, I'd rather skip them for now. 

>   2.2. enic
>      2.2.1 port profile name 

as proposed on libvirt mailing list 

>      2.2.2 ...
> 3. VDP
>   3.1 VSI type/version/provider 

as proposed on libvirt mailing list 

>   3.2 UUID 

we have a couple of UUIDs, which one? 


>   3.3 MAC/VLAN 

MAC: available from libvirt 
VLAN: can be found out by querying for every interface for VLAN ID while
following the path towards the root device. 


    Stefan 

