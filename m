From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: order:1 failure in ipoib_cm_alloc_rx_skb
Date: Fri, 22 Aug 2014 09:00:50 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1747EEE3@AcuExch.aculab.com>
References: <b2996322-2711-466b-8c41-7f4c13c7c0dc@default>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Venkat Venkatsubra' <venkat.x.venkatsubra@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33476 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752042AbaHVJCP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 05:02:15 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20251-06 for <netdev@vger.kernel.org>;
 Fri, 22 Aug 2014 10:02:06 +0100 (BST)
In-Reply-To: <b2996322-2711-466b-8c41-7f4c13c7c0dc@default>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Venkatsubra
> Hello All,
> 
> Many of our customers have hit this order:1 failure in ipoib_cm_alloc_rx_skb causing softlockup:
> ....
>         skb = dev_alloc_skb(IPOIB_CM_HEAD_SIZE + 12);
> ....

Notwithstanding any other problems, that allocation could fail even if the size were
small enough that the entire skb would fit in one page.
So the driver needs changing so that the allocation failure doesn't cause a deadlock.

OTOH if you can't allocate 8k of contiguous address space and memory the system
is unlikely to be working very well at all.

	David
