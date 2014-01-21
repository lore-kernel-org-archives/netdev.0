From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: issues with vxlan RX checksum offload under OVS datapath
Date: Tue, 21 Jan 2014 14:35:40 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1401211410560.16080@intel.com>
References: <52DC4C1B.5000309@mellanox.com> <CALnjE+rUTejbU_d39G7WSn=k0aY2xELCE3UxjDr_Zdq3iwHbNA@mail.gmail.com> <CAJZOPZJ6xj=fOAY9rkXZZs99ONkHwcW8RMXb+H2FjJzV3eoAPg@mail.gmail.com> <alpine.LFD.2.03.1401211336550.16080@intel.com>
 <CAJZOPZKdSmuEQv6dcuLb8E8CqBuTvpywQXZypFTp+j3Xnw2E0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11272 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669AbaAUWRE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jan 2014 17:17:04 -0500
In-Reply-To: <CAJZOPZKdSmuEQv6dcuLb8E8CqBuTvpywQXZypFTp+j3Xnw2E0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 21 Jan 2014, Or Gerlitz wrote:

> On Tue, Jan 21, 2014, Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:
> > On Tue, 21 Jan 2014, Or Gerlitz wrote:
> 
> >> To be a bit more precise/concrete here, do we agree that the both paths must >>    skb->encapsulation = 0;
> >> which is done now only by the non-ovs path
> 
> > Originally skb->encapsulation had (and still has) the meaning of "does
> > this skb have outer *and* (valid) inner headers? If so, it is an
> > encapsulated packet".
> > So based on this skb->encapsulation should be set as soon an (inner)
> > packet gets encapsulated and unset when decapsulation takes place, and
> > ideally this should happen in the ovs path too.
> 
> I would say critically not ideally... e.g when the packet is
> destinat-ed to a VM and goes through tap netdevice plugged to OVS --
> without this de-assignment weird things happen after the point in time
> where the ovs TX path calls dev_queue_xmit() in
> net/openvswitch/vport-netdev.c
> 
> > Together with skb->encapsulation the inner headers should be correctly set.
> 
> That's interesting point, what might break if this isn't done?

Well, the inner headers, same as the generic (outer) headers are pointers 
or offsets that are going to be added to the packet data pointer. If for 
any reason we try to access these pointers when they are invalid anything 
can go wrong... The way to indicate if they are valid or not should be 
skb->encapsulation.

> 
