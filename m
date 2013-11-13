From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] bonding: fix two race conditions in bond_store_updelay/downdelay
Date: Wed, 13 Nov 2013 17:34:16 +0100
Message-ID: <5283AA08.4040401@redhat.com>
References: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533Ab3KMQic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 11:38:32 -0500
In-Reply-To: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 05:07 PM, Nikolay Aleksandrov wrote:
> This patch fixes two race conditions between bond_store_updelay/downdelay
> and bond_store_miimon which could lead to division by zero as miimon can
> be set to 0 while either updelay/downdelay are being set and thus miss the
> zero check in the beginning, the zero div happens because updelay/downdelay
> are stored as new_value / bond->params.miimon. Use rtnl to synchronize with
> miimon setting.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---

A little addition: these can also race with anything that sets miimon to 0,
currently beside store_miimon only store_arp_interval does that. But that is
also fixed because store_arp_interval uses rtnl.

Cheers,
 Nik
