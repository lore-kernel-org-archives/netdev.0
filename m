From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v3] bna: fix vlan tag stripping and implement its
 toggling
Date: Fri, 28 Feb 2014 14:37:08 +0100
Message-ID: <20140228133708.GD2823@minipsycho.orion>
References: <1393593243-10334-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, rmody@brocade.com,
	fw@strlen.de
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:58666 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbaB1NhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 08:37:16 -0500
Received: by mail-ee0-f41.google.com with SMTP id b15so2267726eek.14
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 05:37:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1393593243-10334-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 28, 2014 at 02:14:03PM CET, ivecera@redhat.com wrote:
>The recent commit "fe1624c bna: RX Filter Enhancements" disables
>VLAN tag stripping if the NIC is in promiscuous mode. This causes
>__vlan_hwaccel_put_tag() is called when the stripping is disabled.
>Because of this VLAN over bna does not work and causes BUGs in conjunction
>with openvswitch like this:
>
>---
>[18370.665074] kernel BUG at include/linux/skbuff.h:1497!
>...
>[18370.876769] Call Trace:
>[18370.879455]  <IRQ>
>[18370.881569]  [<ffffffffa063a3c6>] internal_dev_recv+0xb6/0x130 [openvswitch]
>[18370.889552]  [<ffffffffa06398ed>] ovs_vport_send+0x1d/0x80 [openvswitch]
>[18370.896922]  [<ffffffffa063016a>] do_output+0x2a/0x50 [openvswitch]
>[18370.903814]  [<ffffffffa06304cd>] do_execute_actions+0x19d/0xb20 [openvswitch]
>[18370.911757]  [<ffffffffa0630e7b>] ovs_execute_actions+0x2b/0x30 [openvswitch]
>[18370.919602]  [<ffffffffa0633722>] ovs_dp_process_received_packet+0x92/0x120 [openvswitch]
>[18370.928597]  [<ffffffff8109be83>] ? find_busiest_group+0x103/0x880
>[18370.935396]  [<ffffffffa063982a>] ovs_vport_receive+0x2a/0x30 [openvswitch]
>[18370.943053]  [<ffffffffa063a6b1>] netdev_frame_hook+0xc1/0x120 [openvswitch]
>[18370.950802]  [<ffffffff814b27c2>] __netif_receive_skb_core+0x262/0x840
>[18370.957982]  [<ffffffff81019a00>] ? flush_ptrace_hw_breakpoint+0x10/0x40
>[18370.965349]  [<ffffffff814b2db8>] __netif_receive_skb+0x18/0x60
>[18370.971855]  [<ffffffff814b2e33>] netif_receive_skb+0x33/0xb0
>[18370.978172]  [<ffffffff814b3736>] napi_gro_frags+0x116/0x170
>[18370.984407]  [<ffffffffa0c7aaa4>] bnad_napi_poll_rx+0x3f4/0x8f0 [bna]
>[18370.991488]  [<ffffffff814b31ba>] net_rx_action+0x15a/0x250
>...
>---
>
>The following patch makes the following changes so the driver:
>1. Implements .ndo_set_features so an user can toggle VLAN tag stripping
>   on/off
>2. Does not disable VLAN tag stripping in promiscuous mode so the driver
>   respect user's choice
>3. Calls __vlan_hwaccel_put_tag() only when the stripping is enabled
>
>v2:
>- make bnad_set_features static (thanks Florian Westphal)
>- enable/disable VLAN stripping during open WRT hw_features
>
>v3:
>- enable/disable VLAN stripping during open WRT features and not hw_features
>
>Signed-off-by: Ivan Vecera <ivecera@redhat.com>


Looks ok to me now.

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
