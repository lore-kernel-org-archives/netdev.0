From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] can: Decrease default size of CAN_RAW socket
 send queue
Date: Thu, 23 Jan 2014 14:42:43 -0800 (PST)
Message-ID: <20140123.144243.998328685775607324.davem@davemloft.net>
References: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz>
	<20140123.124108.891860564230946746.davem@davemloft.net>
	<52E18331.6050607@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sojkam1@fel.cvut.cz, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52E18331.6050607@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 23 Jan 2014 22:01:37 +0100

> On 01/23/2014 09:41 PM, David Miller wrote:
>> From: Michal Sojka <sojkam1@fel.cvut.cz>
>> Date: Wed, 22 Jan 2014 09:27:36 +0100
>> 
>>> Since the length of the qdisc queue was set by default to 10
>>> packets, this is exactly what was happening.
>> 
>> This is your bug, set the qdisc limit to something more reasonable.
>> 
>> Something large enough to absorb the traffic wrt. the speed at which
>> the CAN device can sink the data.
> 
> Hmmm, the problem is on i686 I have to increase the txqueuelen to 366
> before the socket works as expected (writes are blocking). This means if
> there are two processes one sending a stream of bulk data and the other
> one occasionally more important data there will be a lot of frames in
> front of the important ones.
> 
> With Michal's patch we can limit the number of frames in flight to a
> reasonably low amount.

What do you think UDP applications have to do on slow interfaces?
If they care about overrunning the device queue and getting packet
drops, they themselves set a smaller socket send buffer size.

CAN is not special in this regard, please stop treating it as such.
