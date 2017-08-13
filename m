From: Jan Scheurich <jan.scheurich@ericsson.com>
Subject: RE: [PATCH net-next v2] openvswitch: enable NSH support
Date: Sun, 13 Aug 2017 21:13:57 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D72736EAE@ESESSMB107.ericsson.se>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
        <20170811102418.6b1be4f7@griffin>
        <20170811084722.GA19968@cran64.bj.intel.com>
        <20170811111055.482bd42b@griffin>
        <79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
        <20170811114449.745c49c5@griffin>
        <CFF8EF42F1132E4CBE2BF0AB6C21C58D7273679A@ESESSMB107.ericsson.se>
 <20170811122256.2cec123e@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Yang, Yi Y" <yi.y.yang@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:51631 "EHLO
        sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750915AbdHMVN7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 17:13:59 -0400
In-Reply-To: <20170811122256.2cec123e@griffin>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jiri Benc [mailto:jbenc@redhat.com]
> Sent: Friday, 11 August, 2017 12:23
> 
> On Fri, 11 Aug 2017 10:09:36 +0000, Jan Scheurich wrote:
> > Unless someone can explain to me why the datapath should understand the
> > internal structure/format of metadata in push_nsh, I would strongly
> > vote to keep the metadata as variable length octet sequence in the
> > non-structured OVS_ACTION_ATTR_PUSH_NSH
> 
> Could be but it still needs to be in a different attribute and not in
> the ovs_action_push_nsh structure.
> 
> Separate attributes for MD1/MD2 has the advantage of easier validation:
> with a separate MD1 type attribute, the size check is easier. With an
> unstructured MD attribute, we'd need to look into the
> OVS_ACTION_ATTR_NSH_BASE_HEADER attribute for mdtype and then validate
> the unstructured MD attribute size manually. Not a big deal, though.
> I don't have strong opinion here.
> 
> But I do have strong opinion that MD needs to go into a separate
> attribute, whether there are separate attributes for MD1/2 or not.

Jiri, I am not too familiar with conventions on the OVS netlink interface regarding the handling of variable length fields. What is the benefit of structuring the push_nsh action into

OVS_ACTION_ATTR_PUSH_NSH
+-- OVS_ACTION_ATTR_NSH_BASE_HEADER
+-- OVS_ACTION_ATTR_NSH_MD

instead of grouping the base header fields and the variable length MD into a single monolithic attribute OVS_ACTION_ATTR_PUSH_NSH? Is the main concern a potential future need to add additional parameters to the push_nsh datapath action? Are there examples for such structured actions other than OVS_ACTION_ATTR_CT where the need is obvious because it is very polymorphic?

BR, Jan

BTW:  The name OVS_ACTION_ATTR_NSH_BASE_HEADER is misleading because in the NSH draft the term base header is used for the first 32-bit word, whereas here it includes also the 32-bit Service Path header.
