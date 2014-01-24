From: Michal Sojka <sojkam1@fel.cvut.cz>
Subject: Re: [PATCH v2 1/2] can: Decrease default size of CAN_RAW socket send queue
Date: Fri, 24 Jan 2014 13:14:09 +0100
Message-ID: <87mwilbmr2.fsf@steelpick.2x.cz>
References: <1390379257-9040-1-git-send-email-sojkam1@fel.cvut.cz> <20140123.124108.891860564230946746.davem@davemloft.net> <52E18331.6050607@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52E18331.6050607@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 23 2014, Marc Kleine-Budde wrote:
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

This problem can be solved with queuing disciplines. See
https://rtime.felk.cvut.cz/can/socketcan-qdisc-final.pdf.

This reminds me that I have another patch that makes qdisc work better
with CAN raw sockets. I'll send the patch to linux-can.

-Michal
