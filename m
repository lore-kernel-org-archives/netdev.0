From: <Narendra_K@Dell.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Tue, 2 Jul 2013 07:40:40 -0700
Message-ID: <20130702144018.GA11970@fedora18-dev.oslab.blr.amer.dell.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
 <51BF59D8.10806@gmail.com>
 <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>
 <1371656194.1956.25.camel@bwh-desktop.uk.level5networks.com>
 <E31FB011129F30488D5861F383904915210BB9042A@BLRX7MCDC201.AMER.DELL.COM>
 <1371670481.1956.105.camel@bwh-desktop.uk.level5networks.com>
 <51C4892B.8000806@gmail.com>
 <E31FB011129F30488D5861F383904915210BC0481A@BLRX7MCDC201.AMER.DELL.COM>
 <51CDBAE9.1020807@gmail.com>
 <1372439353.1937.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <john.fastabend@gmail.com>, <netdev@vger.kernel.org>,
	<john.r.fastabend@intel.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:36449 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3GBOo5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 10:44:57 -0400
In-Reply-To: <1372439353.1937.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 10:39:13PM +0530, Ben Hutchings wrote:
> 
> On Fri, 2013-06-28 at 09:33 -0700, John Fastabend wrote:
[...]
> > > John, I think it will be useful in the SRIOV scenario also when more
> > than one VF from two NICs are assigned to the guest. phys_port would be
> > helpful in choosing the correct slave interfaces when host details are
> > not available.
> >
> > OK. But I'm not sure why you would assign two VFs from the same NIC
> > to a guest? This doesn't seem like a good configuration for failover
> > because if one VF fails it seems likely both will fail. Maybe there
> > are some benefits for load balancing? Or my assumption both VFs will
> > fail is wrong.
> 
> I believe Narendra is trying to provide hints to the guest that would
> allow it to avoid such broken bonding configurations.  But it is
> certainly a good question why there would be two VFs assigned in the
> first place.
> 
> I could imagine passing through two VFs for the same physical port that
> have been assigned to different VLANs.  But then you wouldn't want to
> bond two devices that are on different VLANs, whether or not they're
> using the same port!

I was thinking of the following scenario in the guest. 

bond0 = NIC1 VF0 + NIC2 VF0
bond1 = NIC1 VF1 + NIC2 VF1

bond0 and bond1 are on different VLANs. The phys_port identifier hint
would be helpful to the guest in selecting the correct slaves for the
above configuration. Sorry if I missed any detail here.

> 
> > Anyways it does seem useful in the partitioning case with multiple
> > physical functions.

Yes, I agree. 

> 
> I was thinking it could also help to support the hybrid guest networking
> mode.  In this mode, the guest gets a PV (e.g. virtio_net) device and a
> VF bridged to the same physical port, and the VF can be removed before
> the guest is migrated (and maybe reinserted if there's a VF available on
> the new host) without a major disruption to the guest.  In that case the
> guest *should* bond together the two net devices that have the same
> physical port ID but different drivers.  This would require the physical
> port ID to be propagated through macvtap/macvlan and virtio.
> 
> Ben.
> 
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
