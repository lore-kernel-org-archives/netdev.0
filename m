From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/11] bonding: Call dev_kfree_skby_any instead of
 kfree_skb.
Date: Mon, 10 Mar 2014 22:02:38 -0700
Message-ID: <1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <871ty9qvaf.fsf_-_@xmission.com>
	 <87vbvlpgnk.fsf_-_@xmission.com>
	 <1394509467.21721.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311.004217.1616529960369263682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:44849 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416AbaCKFCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 01:02:41 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so8276184pad.31
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 22:02:41 -0700 (PDT)
In-Reply-To: <20140311.004217.1616529960369263682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 00:42 -0400, David Miller wrote:

> These changes eminate from a recent discussion about netpoll, which can
> call into the driver from hardware interrupts, particularly when netconsole
> services a printk from hardware interrupt context.
> 
> bnx2x already makes similar ammends.
> 
> I hope that Eric B. here audited to make sure he's only doing this
> transformation in situations that actually need this treatment for
> the above mentioned issue.

I totally understand the TX path, not the RX.

It seems netpoll should not drain rx queues.
