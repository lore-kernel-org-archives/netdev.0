From: Thadeu Lima de Souza Cascardo <cascardo@cascardo.eti.br>
Subject: Re: [ovs-dev] [PATCH net-next v13 0/8] openvswitch: support for layer 3 encapsulated packets
Date: Tue, 15 Nov 2016 17:01:12 -0200
Message-ID: <7ABC8850-9773-4457-907E-7ACC3180A590@cascardo.eti.br>
References: <cover.1478791347.git.jbenc@redhat.com> <79BBBFE6CB6C9B488C1A45ACD284F5195F0EBFEA@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
        Simon Horman <simon.horman@netronome.com>, egarver@redhat.com
To: "Yang, Yi Y" <yi.y.yang@intel.com>, Jiri Benc <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trem.minaslivre.org ([148.251.208.85]:55264 "EHLO
        grilo.cascardo.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754344AbcKOTP1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 14:15:27 -0500
In-Reply-To: <79BBBFE6CB6C9B488C1A45ACD284F5195F0EBFEA@SHSMSX103.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On November 15, 2016 11:57:21 AM GMT-02:00, "Yang, Yi Y" <yi.y.yang@intel.com> wrote:
>Hi, Jiri
>
>I'm very glad to see you're continuing this work :-), I asked Simon
>about this twice, but nobody replies. I also remember Cascardo has a
>patch set to collaborate with this patch set, I asked Cascardo, but
>nobody responds, will you continue to do Cascardo's " create tunnel
>devices using rtnetlink interface" patch set? I test the old one v3,
>that can work with vxlan module in kernel, but if I build ovs with
>option " --with-linux=/lib/modules/`uname -r`/build", ovs vxlan module
>is built in vport_vxlan module, when I create vxlan-gpe port, kernel
>will automatically load vxlan module in the kernel instead of using the
>APIs in vport_vxlan module. 
>
>Cascardo, are you still working on this?
>
>-----Original Message-----
>From: netdev-owner@vger.kernel.org
>[mailto:netdev-owner@vger.kernel.org] On Behalf Of Jiri Benc
>Sent: Thursday, November 10, 2016 11:28 PM
>To: netdev@vger.kernel.org
>Cc: dev@openvswitch.org; Pravin Shelar <pshelar@ovn.org>; Lorand Jakab
><lojakab@cisco.com>; Simon Horman <simon.horman@netronome.com>
>Subject: [PATCH net-next v13 0/8] openvswitch: support for layer 3
>encapsulated packets
>
>At the core of this patch set is removing the assumption in Open
>vSwitch datapath that all packets have Ethernet header.
>
>The implementation relies on the presence of pop_eth and push_eth
>actions in datapath flows to facilitate adding and removing Ethernet
>headers as appropriate. The construction of such flows is left up to
>user-space.
>
>This series is based on work by Simon Horman, Lorand Jakab, Thomas
>Morin and others. I kept Lorand's and Simon's s-o-b in the patches that
>are derived from v11 to record their authorship of parts of the code.
>
>Changes from v12 to v13:
>
>* Addressed Pravin's feedback.
>* Removed the GRE vport conversion patch; L3 GRE ports should be
>created by
>  rtnetlink instead.
>
>Main changes from v11 to v12:
>
>* The patches were restructured and split differently for easier
>review.
>* They were rebased and adjusted to the current net-next. Especially
>MPLS
>handling is different (and easier) thanks to the recent MPLS GSO
>rework.
>* Several bugs were discovered and fixed. The most notable is fragment
>handling: header adjustment for ARPHRD_NONE devices on tx needs to be
>done
>after refragmentation, not before it. This required significant changes
>in
>the patchset. Another one is stricter checking of attributes (match on
>L2
>  vs. L3 packet) at the kernel level.
>* Instead of is_layer3 bool, a mac_proto field is used.
>
>Jiri Benc (8):
>  openvswitch: use hard_header_len instead of hardcoded ETH_HLEN
>  openvswitch: add mac_proto field to the flow key
>  openvswitch: pass mac_proto to ovs_vport_send
>  openvswitch: support MPLS push and pop for L3 packets
>  openvswitch: add processing of L3 packets
>  openvswitch: netlink: support L3 packets
>  openvswitch: add Ethernet push and pop actions
>  openvswitch: allow L3 netdev ports
>
> include/uapi/linux/openvswitch.h |  15 ++++
> net/openvswitch/actions.c        | 111 +++++++++++++++++-------
> net/openvswitch/datapath.c       |  13 +--
> net/openvswitch/flow.c           | 105 +++++++++++++++++------
> net/openvswitch/flow.h           |  22 +++++
>net/openvswitch/flow_netlink.c   | 179
>++++++++++++++++++++++++++-------------
> net/openvswitch/vport-netdev.c   |   9 +-
> net/openvswitch/vport.c          |  31 +++++--
> net/openvswitch/vport.h          |   2 +-
> 9 files changed, 353 insertions(+), 134 deletions(-)
>
>--
>1.8.3.1
>
>_______________________________________________
>dev mailing list
>dev@openvswitch.org
>https://mail.openvswitch.org/mailman/listinfo/ovs-dev

Hi.

I am still working on this. Just see my recent discussion with Pravin about the way to support out of tree drivers. If you have any opinion on that, please share on that thread, preferably with a patch. It's likely that Eric Garver will take this task as he was already working with me.

Cascardo.
