From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Fri, 28 Jun 2013 18:09:13 +0100
Message-ID: <1372439353.1937.21.camel@bwh-desktop.uk.level5networks.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
	  <51BF59D8.10806@gmail.com>
	  <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>
	  <1371656194.1956.25.camel@bwh-desktop.uk.level5networks.com>
	  <E31FB011129F30488D5861F383904915210BB9042A@BLRX7MCDC201.AMER.DELL.COM>
	 <1371670481.1956.105.camel@bwh-desktop.uk.level5networks.com>
	 <51C4892B.8000806@gmail.com>
	 <E31FB011129F30488D5861F383904915210BC0481A@BLRX7MCDC201.AMER.DELL.COM>
	 <51CDBAE9.1020807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <Narendra_K@Dell.com>, <netdev@vger.kernel.org>,
	<john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51993 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638Ab3F1RJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 13:09:18 -0400
In-Reply-To: <51CDBAE9.1020807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 09:33 -0700, John Fastabend wrote:
> [...]
> 
> >>
> >> Also, do you think this will be primarily useful for partitioning devices that
> >> expose multiple physical functions? Or do you see a use case for SR-IOV with
> >> virtual functions as well. The pyhs_port attribute provides a common
> >> interface for both cases which is good I suppose in the VF case however the
> >> host can already learn this. I gather from your original post here that you are
> >> aware of all this.
> >>
> >
> > John, I think it will be useful in the SRIOV scenario also when more
> than one VF from two NICs are assigned to the guest. phys_port would be
> helpful in choosing the correct slave interfaces when host details are
> not available.
> 
> OK. But I'm not sure why you would assign two VFs from the same NIC
> to a guest? This doesn't seem like a good configuration for failover
> because if one VF fails it seems likely both will fail. Maybe there
> are some benefits for load balancing? Or my assumption both VFs will
> fail is wrong.

I believe Narendra is trying to provide hints to the guest that would
allow it to avoid such broken bonding configurations.  But it is
certainly a good question why there would be two VFs assigned in the
first place.

I could imagine passing through two VFs for the same physical port that
have been assigned to different VLANs.  But then you wouldn't want to
bond two devices that are on different VLANs, whether or not they're
using the same port!

> Anyways it does seem useful in the partitioning case with multiple
> physical functions.

I was thinking it could also help to support the hybrid guest networking
mode.  In this mode, the guest gets a PV (e.g. virtio_net) device and a
VF bridged to the same physical port, and the VF can be removed before
the guest is migrated (and maybe reinserted if there's a VF available on
the new host) without a major disruption to the guest.  In that case the
guest *should* bond together the two net devices that have the same
physical port ID but different drivers.  This would require the physical
port ID to be propagated through macvtap/macvlan and virtio.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
