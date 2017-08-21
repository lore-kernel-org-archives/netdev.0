From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 09:42:27 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A55C@ESESSMB107.ericsson.se>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
        <20170818152601.3760aaec@griffin>
        <20170821061109.GA72656@cran64.bj.intel.com>
        <20170821101925.3f9b36a1@griffin>
        <20170821083900.GA74649@cran64.bj.intel.com>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
 <20170821113514.6f0ec15e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Yang, Yi" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        "blp@ovn.org" <blp@ovn.org>, "e@erig.me" <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:46863 "EHLO
        sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751172AbdHUJma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 05:42:30 -0400
In-Reply-To: <20170821113514.6f0ec15e@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > struct nsh_hdr {
> >     ovs_be16 ver_flags_ttl_len;
> >     uint8_t mdtype;
> >     uint8_t np;
> >     ovs_16aligned_be32 path_hdr;
> >     union {
> >         struct nsh_md1_ctx md1;
> >         struct nsh_md2_tlv md2[];
> 
> I'm not that sure about this. With each member of md2 having a different
> size, you can't use md2 as an array. However, if it was declared as an
> array, it might encourage such (wrong) usage.
> 
> In particular, nsh_hdr->md2[1] is always wrong.
> 
> It seems better to not declare md2 as an array.

I understand your concern. But not declaring md2 as array is wrong as well, as there might not be an MD2 TLV context header. An MD2 NSH header is perfectly valid without any TLV. So in any case the user of the struct needs to be aware of the NSH semantics.

> >
> > I wonder about the possible 16-bit alignment of the 32-bit fields,
> > though. How is that handled in the kernel?
> 
> get_unaligned_*
> 
> > Also struct nsh_md1_ctx
> > has 32-bit members, which might not be 32-bit aligned in the packet.
> 
> I don't see that happening, it seems the header before md1 is 8 bytes and
> sizeof(md1) is 32 bytes? And for md2, the standard mandates that the md2
> size is a multiply of 4 bytes, too.

NSH can be carried over Ethernet with a 14 byte header. In that case the total NSH header would typically be 16-bit aligned, so that all 32-bit members would be misaligned.
