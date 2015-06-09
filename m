From: Kirill Tkhai <ktkhai@odin.com>
Subject: net: Missed commit aff09ce303f83bd370772349238482ae422a2341  in
 stable trees
Date: Tue, 9 Jun 2015 18:38:51 +0300
Message-ID: <1433864331.23588.117.camel@odin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:33433 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933175AbbFIPi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 11:38:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

it looks like the bellow commit is missed in stable kernel versions.
In our local 2.6.32 tree without this commit we observed a bridge
dropping big packets. The fix is in mainstream kernel now.

Please, look if it's need for stable 3.10 kernel etc.

commit aff09ce303f83bd370772349238482ae422a2341
Author: Vasily Averin <vvs@parallels.com>
Date:   Mon May 5 00:17:48 2014 +0400

    bridge: superfluous skb->nfct check in br_nf_dev_queue_xmit

    Currently bridge can silently drop ipv4 fragments.
    If node have loaded nf_defrag_ipv4 module but have no nf_conntrack_ipv4,
    br_nf_pre_routing defragments incoming ipv4 fragments
    but nfct check in br_nf_dev_queue_xmit does not allow re-fragment combined
    packet back, and therefore it is dropped in br_dev_queue_push_xmit without
    incrementing of any failcounters
    
    It seems the only way to hit the ip_fragment code in the bridge xmit
    path is to have a fragment list whose reassembled fragments go over
    the mtu. This only happens if nf_defrag is enabled. Thanks to
    Florian Westphal for providing feedback to clarify this.
    
    Defragmentation ipv4 is required not only in conntracks but at least in
    TPROXY target and socket match, therefore #ifdef is changed from
    NF_CONNTRACK_IPV4 to NF_DEFRAG_IPV4
    
    Signed-off-by: Vasily Averin <vvs@openvz.org>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Kirill
