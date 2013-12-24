From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Tue, 24 Dec 2013 15:58:06 +0200
Message-ID: <52B992EE.5030401@mellanox.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com> <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com> <52B6E568.4030400@mellanox.com> <20131223184845.GA4922@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, <netdev@vger.kernel.org>,
	<tomk@rgmadvisors.com>, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:49935 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751970Ab3LXN6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 08:58:18 -0500
In-Reply-To: <20131223184845.GA4922@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2013 8:48 PM, Richard Cochran wrote:
> On Sun, Dec 22, 2013 at 03:13:12PM +0200, Hadar Hen Zion wrote:
>
>> 2. Adding spin lock in the data path reduce performance by 15% when
>> HW timestamping is enabled. I did some testing and replacing
>> spin_lock_irqsave with read/write_lock_irqsave prevents the
>> performance decrease.
>
> Why do the spin locks cause such a bottleneck?
>
> Is there really that much lock contention in your test?
>
> Your figure of 15% seems awfully high. How did you arrive at that
> figure?
>
> Thanks,
> Richard
>

The spin locks case such a bottleneck since I'm using multiple streams 
in my performance test. RSS mechanism scattered the streams between 
multiple RX rings while each RX ring is bound to a different cup.
The describe scenario cause lock contention between the different RX rings.

Performance drops from 37.8 Gbits/sec to 32.1 Gbits/sec when spin locks 
are added and goes back to 37.8 Gbits/sec when using read/write locks.

Thanks,
Hadar
