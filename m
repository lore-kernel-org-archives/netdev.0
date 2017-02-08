From: "Weiny, Ira" <ira.weiny@intel.com>
Subject: RE: [RFC v3 00/11] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 8 Feb 2017 07:01:22 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E3C644BF1@CRSMSX101.amr.corp.intel.com>
References: <1486498990-76562-1-git-send-email-niranjana.vishwanathapura@intel.com>
         <1486502926.2581.4.camel@sandisk.com>
         <1828884A29C6694DAF28B7E6B8A82373AB0E5B6C@ORSMSX109.amr.corp.intel.com>
         <1486504716.2581.8.camel@sandisk.com>
         <20170208005416.GA76793@knc-06.sc.intel.com>
 <1486516168.2581.21.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "Hefty, Sean" <sean.hefty@intel.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>,
        "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:11749 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752739AbdBHHCJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 02:02:09 -0500
In-Reply-To: <1486516168.2581.21.camel@sandisk.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> On Tue, 2017-02-07 at 16:54 -0800, Vishwanathapura, Niranjana wrote:
> > On Tue, Feb 07, 2017 at 09:58:50PM +0000, Bart Van Assche wrote:
> > > On Tue, 2017-02-07 at 21:44 +0000, Hefty, Sean wrote:
> > > > This is Ethernet - not IP - encapsulation over a non-InfiniBand
> device/protocol.
> > >
> > > That's more than clear from the cover letter. In my opinion the
> > > cover letter should explain why it is considered useful to have such
> > > a driver upstream and what the use cases are of encapsulating
> > > Ethernet frames inside RDMA packets.
> >
> > We believe on our HW, HFI VNIC design gives better hardware resource
> > usage which is also scalable and hence room for better performance.
> > Also as evident in the cover letter, it gives us better manageability
> > by defining virtual Ethernet switches overlaid on the fabric and use
> > standard Ethernet support provided by Linux.
> 
> That kind of language is appropriate for a marketing brochure but not for a
> technical forum.

Well.  That is not totally true.  Perhaps more detail on how we get better performance but we thought this has been covered already.

> Even reading your statement twice did not make me any wiser.
> You mentioned "better hardware resource usage". Compared to what? Is that
> perhaps compared to IPoIB?  Since Ethernet frames have an extra header and
> are larger than IPoIB frames, how can larger frames result in better hardware
> resource usage? 

Yes, as compared to IPoIB.  The problem with IPoIB is it introduces a significant amount of Verbs overhead which is not needed for Ethernet encapsulation.  Especially on hardware such as ours.  As Jason has mentioned having a more generic "skb_send" or "skb_qp" has been discussed in the past.

As we discussed at the plumbers conference not all send/receive paths are "Queue Pairs".  Yes we have a send queue (multiple send queues actually) and a recv queue (again multiple queues) but there is no pairing of the queues at all.  There are no completion semantics required either.  This reduced overhead results in better performance on our hardware.

> And what is a virtual Ethernet switch? Is this perhaps packet
> forwarding by software? If so, why are virtual Ethernet switches needed since
> the Linux networking stack already supports packet forwarding?

Virtual Ethernet switches provide packet switching through the native OPA switches via OPA Virtual Fabrics (a tuple of the path information including lid/pkey/sl/mtu).  This is not packet forwarding within the node.  A large advantage here is that the virtual switches are centrally managed by the EM in a very scalable way.  For example, the IPoIB configuration semantics such as multicast group join/create, Path Record queries, etc are all eliminated.  Further reducing overhead.

Ira
