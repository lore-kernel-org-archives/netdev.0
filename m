From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Fri, 02 Aug 2013 16:17:46 -0700
Message-ID: <1375485466.4457.4.camel@edumazet-glaptop>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com>
	 <20130802.153212.1340051334413929810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:33538 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab3HBXRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 19:17:51 -0400
Received: by mail-qc0-f173.google.com with SMTP id z10so654076qcx.4
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 16:17:50 -0700 (PDT)
In-Reply-To: <20130802.153212.1340051334413929810.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-02 at 15:32 -0700, David Miller wrote:

> Handling this specially in bonding isn't really ideal.
> 
> Please either hide this detail in dev_trans_start(), or (preferrably)
> have vlan_dev_hard_start_xmit() set the trans_start timestamp
> properly thus making this just work for everything.

vlan is LLTX, so setting the timestamp would incur false sharing on
multiqueue.

But it's true we need a helper, because many callers do

if (dev->priv_flags & IFF_802_1Q_VLAN)
       dev = vlan_dev_real_dev(dev);

or the slighly better

if (is_vlan_dev(dev))
   dev = vlan_dev_real_dev(dev);
