From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: fix panic with multiple vlan headers
Date: Fri, 22 Aug 2014 11:24:39 -0700 (PDT)
Message-ID: <20140822.112439.1786666004917748552.davem@davemloft.net>
References: <b490744c980813b54d54f628c719e03cdb143302.1408649593.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbaHVSYm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 14:24:42 -0400
In-Reply-To: <b490744c980813b54d54f628c719e03cdb143302.1408649593.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 21 Aug 2014 21:33:44 +0200

> When there are multiple vlan headers present in a received frame, the first
> one is put into vlan_tci and protocol is set to ETH_P_8021Q. Anything in the
> skb beyond the VLAN TPID may be still non-linear, including the inner TCI
> and ethertype. While ovs_flow_extract takes care of IP and IPv6 headers, it
> does nothing with ETH_P_8021Q. Later, if OVS_ACTION_ATTR_POP_VLAN is
> executed, __pop_vlan_tci pulls the next vlan header into vlan_tci.
> 
> This leads to two things:
> 
> 1. Part of the resulting ethernet header is in the non-linear part of the
>    skb. When eth_type_trans is called later as the result of
>    OVS_ACTION_ATTR_OUTPUT, kernel BUGs in __skb_pull. Also, __pop_vlan_tci
>    is in fact accessing random data when it reads past the TPID.
> 
> 2. network_header points into the ethernet header instead of behind it.
>    mac_len is set to a wrong value (10), too.
> 
> Reported-by: Yulong Pei <ypei@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied and queued up for -stable, thanks Jiri.
