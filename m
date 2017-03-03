From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [net 2/2] ixgbe: Limit use of 2K buffers on architectures with
 256B or larger cache lines
Date: Fri, 3 Mar 2017 15:55:20 +0000
Message-ID: <B1C1DF2ACD01FD4881736AA51731BAB2AC5DDB@ORSMSX107.amr.corp.intel.com>
References: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
 <20170303022448.79638-3-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE74145@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8146 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751593AbdCCPzX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 10:55:23 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE74145@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Friday, March 3, 2017 4:25 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.net
> Cc: Duyck, Alexander H <alexander.h.duyck@intel.com>;
> netdev@vger.kernel.org; nhorman@redhat.com; sassmann@redhat.com;
> jogreene@redhat.com
> Subject: RE: [net 2/2] ixgbe: Limit use of 2K buffers on architectures with 256B
> or larger cache lines
> 
> From: Jeff Kirsher
> > Sent: 03 March 2017 02:25
> > From: Alexander Duyck <alexander.h.duyck@intel.com>
> >
> > On architectures that have a cache line size larger than 64 Bytes we
> > start running into issues where the amount of headroom for the frame
> > starts shrinking.
> >
> > The size of skb_shared_info on a system with a 64B L1 cache line size
> > is 320.  This increases to 384 with a 128B cache line, and 512 with a
> > 256B cache line.
> 
> Perhaps some of the CACHE_LINE_ALIGNED markers don't actually need to
> force alignment with large line sizes?
> 
> I realise some things have hard requirements for cache alignment (eg non-
> coherent dma), but others are just there to limit the number of cache lines read
> and/or dirtied.
> 
> 	David

For our purposes I think this works well enough.  Basically we wanted to guarantee we have enough headroom for XDP.  In the case of the Mellanox drivers they are guaranteeing 256 if I recall correctly.

I have some follow-up patches for net-next that will make it so that we can just do a build-time test that will determine the padding size and allow us to always guaranteed at least NET_SKB_PAD + NET_IP_ALIGN.

- Alex
