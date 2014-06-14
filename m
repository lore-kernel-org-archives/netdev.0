From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: No GSOs to i40e with VXLAN
Date: Fri, 13 Jun 2014 21:38:55 -0700 (PDT)
Message-ID: <alpine.LFD.2.11.1406132119570.5273@fvl-a0.jf.intel.com>
References: <alpine.LFD.2.11.1406131657240.4926@fvl-a0.jf.intel.com> <CA+mtBx_6BWhHm4eK2qqR737jwQHi_dyrv-Md_-_f5AEghWNAKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18322 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbaFNEfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2014 00:35:52 -0400
In-Reply-To: <CA+mtBx_6BWhHm4eK2qqR737jwQHi_dyrv-Md_-_f5AEghWNAKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 13 Jun 2014, Tom Herbert wrote:

> On Fri, Jun 13, 2014 at 5:15 PM, Joseph Gasparakis
> <joseph.gasparakis@intel.com> wrote:
> > Hi all,
> >
> > I quickly tested VXLAN on i40e with net-next with commit id
> > f9da455b93f6ba076935b4ef4589f61e529ae046 and the i40e driver has stopped
> > receiving GSOs even when advertising tx-udp_tnl-segmentation which means
> > our VXLAN segmentation offload. I am guessing this has something to do
> > with Tom's recent UDP work but this is just a guess as unfortunatly I
> > do not have the time to debug this, but I am signing up to review and test
> > patches fixing this issue.
> >
> I verified tunnel offload works properly with bnx2x (I'm using simple
> vxlan interfaces not OVS).
> 

Ok, I will try to have a quick look at bnx2x and i40e and see the 
differences in what the two drivers advertise in terms of netdev features and 
hw_enc_features.

> One possibility I can think of is that UDP checksums are somehow
> enabled. If you're using IPv6 this probably the case (but I assume
> you're seeing this with IPv4). If checksums are inadvertently enabled
> somehow in IPv4 this should should up in tcpdump on the Ethernet
> interface.

Let me explain a bit my setup:

I am using two linux boxes back to back, on my DUT I have an i40e and I 
am bringing a vxlan interface in both machines. No bridge, no VMs, no OVS.

I am using some simple perl scripts using TCP sockets to send a number of 
bytes from DUT to my link partner and even if I send 50k in one message I 
don't see any GSOs. Instead I get many non-GSO skbs leading me to the 
conclusion that the stack must have segmented the skb before passing it on 
to the driver. I am also using netperf with TCP_STREAM and I don't see any 
GSOs either. All the above done using IPv4 only. And if I do the same on 
the i40e interface instead of vxlan I do see GSOs again.

Both these tests would result to the stack sending GSOs last time I did a 
smoke test on vxlan and i40e (about 3 weeks ago or so...).  

The checksum offloads seem to be working as before however.

Thanks

Joseph
 
> 
> Thanks,
> Tom
> 
> > The driver still gets GSOs with non VXLAN traffic (tested with TCP).
> >
> > Thanks
> >
> > Joseph
> 
