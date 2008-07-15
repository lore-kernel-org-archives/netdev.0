From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: po->mclist needs locker in reader side
Date: Tue, 15 Jul 2008 02:11:44 -0700 (PDT)
Message-ID: <20080715.021144.85711463.davem@davemloft.net>
References: <487C127D.9010908@cn.fujitsu.com>
	<20080714.205110.266962405.davem@davemloft.net>
	<487C573F.3020803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58537
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753704AbYGOJLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 05:11:43 -0400
In-Reply-To: <487C573F.3020803@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 15:52:31 +0800

> As my understanding, packet_dev_mclist() is the only reader who doesn't
> use same lock as writers(actually it doesn't use any lock).
> My proposal is that use RTNL to prevent synchronous access to po->mclist.
> Because packet_dev_mclist() is only called when device be unregistered,
> the lock will not affect speed too much. 
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

I took a look and it turns out that the RTNL lock is already held when
that notifier runs, so it seems everything is fine here already.

So I'll ignore this patch :)
