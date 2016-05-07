From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
Date: Sat, 07 May 2016 13:40:48 -0400 (EDT)
Message-ID: <20160507.134048.139772599380708393.davem@davemloft.net>
References: <1462381017-568-1-git-send-email-decui@microsoft.com>
	<20160506.130353.2082047339292515860.davem@davemloft.net>
	<BLUPR03MB1410F30AED34632F8F1268DEBF7E0@BLUPR03MB1410.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	cavery@redhat.com, kys@microsoft.com, haiyangz@microsoft.com,
	joe@perches.com, vkuznets@redhat.com
To: decui@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbcEGRky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 13:40:54 -0400
In-Reply-To: <BLUPR03MB1410F30AED34632F8F1268DEBF7E0@BLUPR03MB1410.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dexuan Cui <decui@microsoft.com>
Date: Sat, 7 May 2016 10:49:25 +0000

> I should be able to make 'send', 'recv' here to pointers and use vmalloc()
> to allocate the memory for them.  I will do this.

That's still unswappable kernel memory.

People can open N sockets, where N is something on the order of the FD
limit the process has, per process.  This allows someone to quickly
eat up a lot of memory and hold onto it nearly indefinitely.
