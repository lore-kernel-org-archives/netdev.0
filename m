From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Tue, 14 Feb 2012 08:18:46 -0500
Message-ID: <1329225526.2806.34.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>
	 <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com>
	 <1328887111.2075.43.camel@mojatatu>  <4F39287F.6030204@intel.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50443 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611Ab2BNNSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 08:18:54 -0500
In-Reply-To: <4F39287F.6030204@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-13 at 07:13 -0800, John Fastabend wrote:

> The use case here is multiple VFs but the same solution should work with
> multiple PFs as well. FDB controls should be independent of how the ports
> are exposed VFs, PFs, VMDQ/queue pairs, macvlan, etc.

Makes sense.

> With events and ADD/DEL/GET FDB controls we can solve both cases. This also
> solves Roopa's case with macvlan where he wants to add additional addresses
> to macvlan ports.

Not familiar with that issue - I'll prowl the list.

> Yes it should flood here, unless its acting as a 802.1Qbg VEB or VEPA.

Ok. So there is a toggle somewhere which controls how flooding should
happen.

> 
> Maybe not. But the kernel already has the needed signals with one extra
> hook we can save running a daemon in user space. Maybe that's not a great
> argument to add kernel code though.

You make a reasonable arguement to have it in the kernel but i think we
win more if we separate the control. So while i empathize, I am hoping
that youd go with the path that is hard to travel ;->

> The PF_BRIDGE:RTM_GETNEIGH,RTM_NEWNEIGH,RTM_DELNEIGH are registered in the
> br_netlink_init() path. 

Hrm - hadnt paid attention to that before. Nasty.
The bridge seems to be hard-coding policy on station movement, no? 
This is a good example of the qualms i have on adding things to the
kernel;->
I may not want to auto update a MAC address moving ports as part of
some policy i have. I can go and add YAK (Yet Another Knob) - but where
is the line drawn?

cheers,
jamal
