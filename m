From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 09:04:30 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
 <20170818152601.3760aaec@griffin>
 <20170821061109.GA72656@cran64.bj.intel.com>
 <20170821101925.3f9b36a1@griffin>
 <20170821083900.GA74649@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>
To: "Yang, Yi" <yi.y.yang@intel.com>, Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:48510 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbdHUJEh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 05:04:37 -0400
In-Reply-To: <20170821083900.GA74649@cran64.bj.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> struct nsh_hdr {
>     ovs_be16 ver_flags_ttl_len;
>     uint8_t mdtype;
>     uint8_t np;
>     ovs_16aligned_be32 path_hdr;
>     union {
>         struct nsh_md1_ctx md1;
>         struct nsh_md2_tlv md2;
>     };
> };
> 

The second member of the union should be a variable length array [] of struct nsh_md2_tlv

struct nsh_hdr {
    ovs_be16 ver_flags_ttl_len;
    uint8_t mdtype;
    uint8_t np;
    ovs_16aligned_be32 path_hdr;
    union {
        struct nsh_md1_ctx md1;
        struct nsh_md2_tlv md2[];
    };
};

That was the original design before Ben removed it due to missing support in Microsoft compiler. 
For the Kernel datapath we should go back to that. 

I wonder about the possible 16-bit alignment of the 32-bit fields, though. How is that handled in the kernel? Also struct nsh_md1_ctx has 32-bit members, which might not be 32-bit aligned in the packet.

BR, Jan
