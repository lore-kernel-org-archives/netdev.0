From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Thu, 14 Oct 2004 17:21:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410150021.i9F0LJ39024214@guinness.s2io.com>
References: <200410150002.i9F02d39021336@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Jeff Garzik'" <jgarzik@pobox.com>, <ravinandan.arakali@s2io.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>, <netdev@oss.sgi.com>,
        <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Raghavendra Koushik'" <raghavendra.koushik@s2io.com>,
        "'Chris Leech'" <chris.leech@gmail.com>
In-Reply-To: <200410150002.i9F02d39021336@guinness.s2io.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 "fragmented SKB on Rx" is an old problem - we tried to deploy 2 and 5
buffer Xframe modes before and it did not work in Linux. 
Is anyone aware of any network driver that successfully uses fragmented
SKBs?

Thanks, Leonid

> -----Original Message-----
> From: Raghavendra Koushik [mailto:raghavendra.koushik@s2io.com] 
> Sent: Thursday, October 14, 2004 5:03 PM
> To: 'Chris Leech'
> Cc: 'Jeff Garzik'; ravinandan.arakali@s2io.com; 'Francois 
> Romieu'; netdev@oss.sgi.com; leonid.grossman@s2io.com; 
> rapuru.sriram@s2io.com
> Subject: RE: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
> 
> Hi Chris,
> 
> 	I think you have a point. As an alternative I can 
> allocate some extra buffer space for buffer 2 (Ethernet 
> payload) to begin with and in Rx path copy the buffer 
> 1(Ethernet header) to the start of buffer 2(skb_push).
> This can then be passed to the upper layer (after 
> eth_type_trans call).
> I did try fragmented SKB on Rx but it didn't seem to work. If 
> any one can give me some pointers on how to get this working, 
> I would implement 2Buff mode using this method and avoid a 
> copy in fast path.
> 
> Koushik
> 
> 
> > -----Original Message-----
> > From: Chris Leech [mailto:chris.leech@gmail.com]
> > Sent: Thursday, October 14, 2004 1:49 PM
> > To: Raghavendra Koushik
> > Cc: Jeff Garzik; ravinandan.arakali@s2io.com; Francois Romieu; 
> > netdev@oss.sgi.com; leonid.grossman@s2io.com; rapuru.sriram@s2io.com
> > Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
> > 
> > On Thu, 14 Oct 2004 11:33:13 -0700, Raghavendra Koushik 
> > <raghavendra.koushik@s2io.com> wrote:
> > 
> > > > 1) can this not be done with SKB fragments?
> > > >
> > > To acheve what is required, the H/W still has to split the Rx'ed 
> > > frame
> > into
> > > 2 parts. By implementing this through the SKB fragments 
> method, the 
> > > only thing we avoid is usage of ba_0 and ba_1 fields, but 
> note that 
> > > none of
> > these
> > > are allocated or freed in fast path. They are all pre-allocated 
> > > buffers (along with the Rx descriptors) and hence won't 
> hit the Rx 
> > > side
> > performance.
> > > Also by pulling down the eth_type_trans implementation partially 
> > > into
> > the
> > > driver any kind of copy during Rx is also avoided.
> > 
> > This change would pass skbs from the driver without the MAC header?
> > What happens in a bridging configuration?  And 
> dev->hard_header_parse 
> > is set to eth_header_parse, which expects skb->mac.ethernet to be 
> > valid, so I think any use of packet sockets will result in a NULL 
> > dereference.
> > 
> > - Chris
> 
