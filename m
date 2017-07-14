From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: fix dest lookup when vlan proto
 doesn't match
Date: Fri, 14 Jul 2017 08:19:42 -0700 (PDT)
Message-ID: <20170714.081942.1796952600877192514.davem@davemloft.net>
References: <1499951350-2087-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, makita.toshiaki@lab.ntt.co.jp,
        roopa@cumulusnetworks.com, anitha@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754178AbdGNPTn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:19:43 -0400
In-Reply-To: <1499951350-2087-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 13 Jul 2017 16:09:10 +0300

> With 802.1ad support the vlan_ingress code started checking for vlan
> protocol mismatch which causes the current tag to be inserted and the
> bridge vlan protocol & pvid to be set. The vlan tag insertion changes
> the skb mac_header and thus the lookup mac dest pointer which was loaded
> prior to calling br_allowed_ingress in br_handle_frame_finish is VLAN_HLEN
> bytes off now, pointing to the last two bytes of the destination mac and
> the first four of the source mac causing lookups to always fail and
> broadcasting all such packets to all ports. Same thing happens for locally
> originated packets when passing via br_dev_xmit. So load the dest pointer
> after the vlan checks and possible skb change.
> 
> Fixes: 8580e2117c06 ("bridge: Prepare for 802.1ad vlan filtering support")
> Reported-by: Anitha Narasimha Murthy <anitha@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied.
