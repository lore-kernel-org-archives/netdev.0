From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v4] openvswitch: enable NSH support
Date: Tue, 22 Aug 2017 08:32:49 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274C9FB@ESESSMB107.ericsson.se>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
        <20170818152601.3760aaec@griffin>
        <20170821061109.GA72656@cran64.bj.intel.com>
        <20170821101925.3f9b36a1@griffin>
        <20170821083900.GA74649@cran64.bj.intel.com>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
        <20170821113514.6f0ec15e@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
        <20170821115106.70fa1e1d@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A5C7@ESESSMB107.ericsson.se>
 <20170821135019.5c65b888@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:61727 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932133AbdHVIcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 04:32:54 -0400
In-Reply-To: <20170821135019.5c65b888@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > If I understand correctly, this is a default definition that can be
> > overridden by drivers so that we still cannot rely on the Ethernet
> > payload always being 32-bit-aligned.
> 
> Not by drivers, by architectures. Only architectures that can efficiently
> handle unaligned access (or on which the cost of handling unaligned access
> is lower than the cost of unaligned DMA access) set NET_IP_ALIGN to 0.

Thanks, got it!

> 
> > Furthermore, there seem to be machine architectures that cannot handle
> > misaligned 32-bit access at all (not even with a performance penalty).
> 
> Those leave NET_IP_ALIGN to 2.

Dito

> 
> > Or why else does OVS user space code take so great pain to model
> > possible misalignment and provide/use safe access functions?
> 
> I don't know how the ovs user space deals with packet allocation. In the
> kernel, the network header is aligned in a way that it allows efficient 32bit
> access.

It seems that OVS has not had the same approach as Linux. There is no config parameter covering the alignment characteristics of the machine architecture. For packets buffers received from outside sources (e.g. DPDK interfaces) they make no assumptions on alignment and play safe. For packets allocated inside OVS, the Ethernet packet is typically stored so that the L3 header is 32-bit aligned, so that the misalignment precautions would be unnecessary. But I didn't check all code paths.
