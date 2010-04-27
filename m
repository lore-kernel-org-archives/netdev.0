From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Tue, 27 Apr 2010 14:35:25 +0200
Message-ID: <201004271435.25480.arnd@arndb.de>
References: <C7FB77DB.2BC42%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chrisw@redhat.com" <chrisw@redhat.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:57746 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393Ab0D0Mfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 08:35:32 -0400
In-Reply-To: <C7FB77DB.2BC42%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 April 2010, Scott Feldman wrote:
> > Yes, I believe that's there today:
> > 
> >     NLA_PUT_U32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent));
> > 
> > The number of VFs is returned in RTM_GETLINK.  But, it's only returned if:
> > 
> >     if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent)
> > 
> > For my proposal, I'll need to return IFLA_NUM_VF unconditionally so callers
> > can get num VFs.
> 
> Hmmm...seems IFLA_NUM_VF assumes a PCI device supporting SR-IOV when it uses
> dev_num_vf().  I think a better option would have been to query the device
> for the number of VFs, without assuming SR-IOV or even PCI.
> 
> I see a ndo_get_num_vf() coming...

Shouldn't the number of registered port profiles be totally independent of
the number of virtual functions?

Any of the VFs could multiplex multiple guests using macvlan, which means you
need to register each guest separately, not each VF.

Anything that ties port profiles to VFs seems fundamentally flawed AFAICT,
at least when we want to extend this to adapters that don't do it in firmware.

	Arnd
