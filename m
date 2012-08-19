From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xfrm:Use rcu_dereference_bh to deference pointer
 protected by rcu_read_lock_bh
Date: Sun, 19 Aug 2012 11:58:46 +0200
Message-ID: <1345370326.5158.23.camel@edumazet-glaptop>
References: <1345184349-5849-1-git-send-email-fan.du@windriver.com>
	 <20120816.232414.545877018277576779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53503 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab2HSJ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Aug 2012 05:58:53 -0400
Received: by wgbdr13 with SMTP id dr13so4556614wgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 02:58:52 -0700 (PDT)
In-Reply-To: <20120816.232414.545877018277576779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-16 at 23:24 -0700, David Miller wrote:
> I already applied your patch, as I told you here:
> 
> http://marc.info/?l=linux-netdev&m=134517122805719&w=2
> 
> This means you are submitting a patch which doesn't not even apply
> to the net-next tree.
> 
> Instead of continuing to dig yourself deeper and deeper, take a
> break, take a deep breath, and work slowly and carefully.
> --

BTW, we (incorrectly ?) mix RCU and RCU_BH in this file, and since we
use synchronize_rcu() anyway, we should/could use rcu_read_lock()
everywhere we can, as this is less expensive (currently inlined at least
on x86) than rcu_read_lock_bh()

I'll send a cleanup patch on a separate thread
