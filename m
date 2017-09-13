From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH v3 0/7] tc-flower based cloud filters in i40e
Date: Wed, 13 Sep 2017 12:12:12 +0200
Message-ID: <20170913101212.GA1981@nanopsycho>
References: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:37082 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdIMKMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 06:12:16 -0400
Received: by mail-wr0-f176.google.com with SMTP id k20so27690663wre.4
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 03:12:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 13, 2017 at 11:59:13AM CEST, amritha.nambiar@intel.com wrote:
>This patch series enables configuring cloud filters in i40e
>using the tc-flower classifier. The only tc-filter action
>supported is to redirect packets to a traffic class on the
>same device. The mirror/redirect action is extended to
>accept a traffic class to achieve this.
>
>The cloud filters are added for a VSI and are cleaned up when
>the VSI is deleted. The filters that match on L4 ports needs
>enhanced admin queue functions with big buffer support for
>extended fields in cloud filter commands.
>
>Example:
># tc qdisc add dev eth0 ingress
>
># ethtool -K eth0 hw-tc-offload on
>
># tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
>  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
>  skip_sw action mirred ingress redirect dev eth0 tclass 1
>
># tc filter show dev eth0 parent ffff:
>filter protocol ip pref 1 flower chain 0
>filter protocol ip pref 1 flower chain 0 handle 0x1
>  eth_type ipv4
>  ip_proto udp
>  dst_ip 192.168.1.1
>  dst_port 22
>  skip_sw
>  in_hw
>        action order 1: mirred (Ingress Redirect to device eth0) stolen tclass 1
>        index 7 ref 1 bind 1
>
>v3: Added an extra patch to clean up white-space noise. Cleaned up
>some lengthy function names. Used __be32 array for ipv6 address.
>Used macro for IP version. Minor formatting changes.
>
>---
>
>Amritha Nambiar (7):
>      tc_mirred: Clean up white-space noise
>      sched: act_mirred: Traffic class option for mirror/redirect action
>      i40e: Map TCs with the VSI seids
>      i40e: Cloud filter mode for set_switch_config command
>      i40e: Admin queue definitions for cloud filters
>      i40e: Clean up of cloud filters
>      i40e: Enable cloud filters via tc-flower

Would be good to use get_maintainers script and cc people if you want
comments.
