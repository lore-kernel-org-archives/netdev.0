From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH] net: limit maximum number of packets to mark with
 xmit_more
Date: Tue, 29 Aug 2017 13:35:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00684AC@AcuExch.aculab.com>
References: <20170825152449.29790-1-jacob.e.keller@intel.com>
 <20170825153418.53864810@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jakub Kicinski' <kubakici@wp.pl>,
        Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:57021 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751368AbdH2Nf6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 09:35:58 -0400
In-Reply-To: <20170825153418.53864810@cakuba>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski
> Sent: 25 August 2017 20:34
>
> On Fri, 25 Aug 2017 08:24:49 -0700, Jacob Keller wrote:
> > Under some circumstances, such as with many stacked devices, it is
> > possible that dev_hard_start_xmit will bundle many packets together, and
> > mark them all with xmit_more.
> 
> Excuse my ignorance but what are those stacked devices?  Could they
> perhaps be fixed somehow?  My intuition was that long xmit_more
> sequences can only happen if NIC and/or BQL are back pressuring, and
> therefore we shouldn't be seeing a long xmit_more "train" arriving at
> an empty device ring...

I also suspect that the packets could be coming from multiple sources.
So getting the sources to limit the number of packets with XMIT_MORE
set won't really solve any problem.

At some point the driver for the physical device will have to give it
a kick to start the transmits.

On the systems I've got (desktop x86) PCIe writes aren't really very
expensive.
Reads are a different matter entirely (2us into our fpga target).

	David.
