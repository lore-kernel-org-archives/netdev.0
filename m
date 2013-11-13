From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix two race conditions in
 bond_store_updelay/downdelay
Date: Wed, 13 Nov 2013 09:03:34 -0800
Message-ID: <1384362214.28458.117.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59640 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435Ab3KMRDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 12:03:36 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so712204pab.14
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 09:03:35 -0800 (PST)
In-Reply-To: <1384358866-15157-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 17:07 +0100, Nikolay Aleksandrov wrote:
> This patch fixes two race conditions between bond_store_updelay/downdelay
> and bond_store_miimon which could lead to division by zero as miimon can
> be set to 0 while either updelay/downdelay are being set and thus miss the
> zero check in the beginning, the zero div happens because updelay/downdelay
> are stored as new_value / bond->params.miimon. Use rtnl to synchronize with
> miimon setting.

It seems a bit heavy duty to take rtnl for this.

Using ACCESS_ONCE() in bonding_store_updelay()/bonding_store_downdelay()
should be enough ?

int miimon = ACCESS_ONCE(bond->params.miimon);
