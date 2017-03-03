From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net 2/2] ixgbe: Limit use of 2K buffers on architectures with
 256B or larger cache lines
Date: Fri, 3 Mar 2017 12:24:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE74145@AcuExch.aculab.com>
References: <20170303022448.79638-1-jeffrey.t.kirsher@intel.com>
 <20170303022448.79638-3-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.193]:53385 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdCCMk7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 07:40:59 -0500
In-Reply-To: <20170303022448.79638-3-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> Sent: 03 March 2017 02:25
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> On architectures that have a cache line size larger than 64 Bytes we start
> running into issues where the amount of headroom for the frame starts
> shrinking.
> 
> The size of skb_shared_info on a system with a 64B L1 cache line size is
> 320.  This increases to 384 with a 128B cache line, and 512 with a 256B
> cache line.

Perhaps some of the CACHE_LINE_ALIGNED markers don't actually need
to force alignment with large line sizes?

I realise some things have hard requirements for cache alignment
(eg non-coherent dma), but others are just there to limit the number
of cache lines read and/or dirtied.

	David
