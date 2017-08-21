From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 10:10:38 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A5C7@ESESSMB107.ericsson.se>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
        <20170818152601.3760aaec@griffin>
        <20170821061109.GA72656@cran64.bj.intel.com>
        <20170821101925.3f9b36a1@griffin>
        <20170821083900.GA74649@cran64.bj.intel.com>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
        <20170821113514.6f0ec15e@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
 <20170821115106.70fa1e1d@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:59109 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753012AbdHUKKl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 06:10:41 -0400
In-Reply-To: <20170821115106.70fa1e1d@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > NSH can be carried over Ethernet with a 14 byte header. In that case
> > the total NSH header would typically be 16-bit aligned, so that all
> > 32-bit members would be misaligned.
> 
> See NET_IP_ALIGN in include/linux/skbuff.h.

If I understand correctly, this is a default definition that can be overridden by drivers so that we still cannot rely on the Ethernet payload always being 32-bit-aligned. 

Furthermore, there seem to be machine architectures that cannot handle misaligned 32-bit access at all (not even with a performance penalty).

Or why else does OVS user space code take so great pain to model possible misalignment and provide/use safe access functions?

Does Linux kernel code generally ignore this risk?

/Jan
