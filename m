From: Andi Kleen <andi@firstfloor.org>
Subject: openswan broken between 2.6.24rc8 and final
Date: Fri, 8 Feb 2008 14:53:25 +0100
Message-ID: <20080208135325.GA14434@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:61138 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755225AbYBHNx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 08:53:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Since I updated a system here from 2.6.24rc8 (+ some unrelated patches)
to 2.6.24 openswan in tunnel mode is rather unhappy now. It works 
initially for a few minutes, but then when it comes to renew a key (I think) 
the connection always hangs.  This means on 2.6.24-final the kernel
can now finally reboot again with active ipsec (previously
there were always leaked reference counts), but it cannot 
hold them up for a longer time.

I first thought it was caused by

commit d4782c323d10d3698b71b6a6b3c7bdad33824658
Author: Patrick McHardy <kaber@trash.net>
Date:   Sun Jan 20 17:24:29 2008 -0800

    [AF_KEY]: Fix skb leak on pfkey_send_migrate() error

but when I just revert just this patch it still doesn't work
(and obviously the reboot problem is back) 

Before I do a full bisect; is there already a fix for this? 

Thanks,

-Andi 

