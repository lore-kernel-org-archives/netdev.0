From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 06/10] vxlan: use __dev_get_by_index instead of
 dev_get_by_index to find interface
Date: Tue, 14 Jan 2014 08:51:05 -0800
Message-ID: <20140114085105.706779c1@nehalam.linuxnetplumber.net>
References: <1389685269-18600-1-git-send-email-ying.xue@windriver.com>
	<1389685269-18600-7-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <vfalico@redhat.com>,
	<john.r.fastabend@intel.com>, <antonio@meshcoding.com>,
	<dmitry.tarnyagin@lockless.no>, <socketcan@hartkopp.net>,
	<johannes@sipsolutions.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:44037 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbaANQvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 11:51:08 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so8836663pbb.8
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 08:51:08 -0800 (PST)
In-Reply-To: <1389685269-18600-7-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Jan 2014 15:41:05 +0800
Ying Xue <ying.xue@windriver.com> wrote:

> The following call chains indicate that vxlan_fdb_parse() is
> under rtnl_lock protection. So if we use __dev_get_by_index()
> instead of dev_get_by_index() to find interface handler in it,
> this would help us avoid to change interface reference counter.
> 
> rtnetlink_rcv()
>   rtnl_lock()
>   netlink_rcv_skb()
>     rtnl_fdb_add()
>       vxlan_fdb_add()
>         vxlan_fdb_parse()
>   rtnl_unlock()
> 
> rtnetlink_rcv()
>   rtnl_lock()
>   netlink_rcv_skb()
>     rtnl_fdb_del()
>       vxlan_fdb_del()
>         vxlan_fdb_parse()
>   rtnl_unlock()
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
