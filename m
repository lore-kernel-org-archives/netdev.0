From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Thu, 16 Feb 2012 03:58:48 +0000
Message-ID: <1329364728.3048.159.camel@deadeye>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	<roprabhu@cisco.com>, <netdev@vger.kernel.org>, <mst@redhat.com>,
	<chrisw@redhat.com>, <davem@davemloft.net>,
	<gregory.v.rose@intel.com>, <kvm@vger.kernel.org>,
	<sri@us.ibm.com>, Shradha Shah <sshah@solarflare.com>
To: <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8597 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750995Ab2BPD6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 22:58:45 -0500
In-Reply-To: <1328887111.2075.43.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I'm just catching up with this after getting my own driver changes into
shape.]

On Fri, 2012-02-10 at 10:18 -0500, jamal wrote:
> Hi John,
> 
> I went backwards to summarize at the top after going through your email.
> 
> TL;DR version 0.1: 
> you provide a good use case where it makes sense to do things in the
> kernel. IMO, you could make the same arguement if your embedded switch
> could do ACLs, IPv4 forwarding etc. And the kernel bloats.
> I am always bigoted to move all policy control to user space instead of
> bloating in the kernel.
[...]
> > Now here is the potential issue,
> > 
> > (G) The frame transmitted from ethx.y with the destination address of
> >     veth0 but the embedded switch is not a learning switch. If the FDB
> >     update is done in user space its possible (likely?) that the FDB
> >     entry for veth0 has not been added to the embedded switch yet. 
> 
> Ok, got it - so the catch here is the switch is not capable of learning.
> I think this depends on where learning is done. Your intent is to
> use the S/W bridge as something that does the learning for you i.e in
> the kernel. This makes the s/w bridge part of MUST-have-for-this-to-run.
> And that maybe the case for your use case.
[...]

Well, in addition, there are SR-IOV network adapters that don't have any
bridge.  For these, the software bridge is necessary to handle
multicast, broadcast and forwarding between local ports, not only to do
learning.

Solarflare's implementation of accelerated guest networking (which
Shradha and I are gradually sending upstream) builds on libvirt's
existing support for software bridges and assigns VFs to guests as a
means to offload some of the forwarding.

If and when we implement a hardware bridge, we would probably still want
to keep the software bridge as a fallback.  If a guest is dependent on a
VF that's connected to a hardware bridge, it becomes impossible or at
least very disruptive to migrate it to another host that doesn't have a
compatible VF available.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
