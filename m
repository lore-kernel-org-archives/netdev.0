From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Fri, 17 Feb 2012 09:37:50 -0500
Message-ID: <1329489470.2272.28.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>  <1329364728.3048.159.camel@deadeye>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Shradha Shah <sshah@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1329364728.3048.159.camel@deadeye>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-16 at 03:58 +0000, Ben Hutchings wrote:

> 
> Well, in addition, there are SR-IOV network adapters that don't have any
> bridge.  For these, the software bridge is necessary to handle
> multicast, broadcast and forwarding between local ports, not only to do
> learning.

For the scenario where there is no h/w bridge - the s/ware bridge should
be usable. There's no way working around that.
My contention is only with the case where there is a h/w bridge and
there being two FDB tables; one in hardware and another in s/w.
And both the h/w and s/w bridges doing flooding and learning.
It is desirable to have options to use one or other or both with
some synchronization.

> Solarflare's implementation of accelerated guest networking (which
> Shradha and I are gradually sending upstream) builds on libvirt's
> existing support for software bridges and assigns VFs to guests as a
> means to offload some of the forwarding.
> If and when we implement a hardware bridge, we would probably still want
> to keep the software bridge as a fallback.  If a guest is dependent on a
> VF that's connected to a hardware bridge, it becomes impossible or at
> least very disruptive to migrate it to another host that doesn't have a
> compatible VF available.

In the scheme i described to John in last email, libvirt needs not be aware of 
existence of hardware offloading (and migration should be transparent of whether
h/w bridge exists or not)...

cheers,
jamal

