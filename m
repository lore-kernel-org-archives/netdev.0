From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 09/12] net: mediatek: increase watchdog_timeo
Date: Mon, 6 Jun 2016 08:24:08 +0200
Message-ID: <0da64a49-d100-f83d-e6d3-91b706710660@phrozen.org>
References: <1465108385-38286-1-git-send-email-john@phrozen.org>
 <1465108385-38286-10-git-send-email-john@phrozen.org>
 <20160605145632.GI12165@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sean Wang <keyhaede@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>,
	Felix Fietkau <nbd@nbd.name>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160605145632.GI12165@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 05/06/2016 16:56, Andrew Lunn wrote:
> On Sun, Jun 05, 2016 at 08:33:02AM +0200, John Crispin wrote:
>> During stress testing, after reducing the threshold value, we have seen
>> TX timeouts that were caused by the watchdog_timeo value being too low.
>> Increase the value to 5 * HZ which is a value commonly used by many other
>> drivers.
> 
> I've never studied what watchdog_timeo actually means. Does it mean a
> transmit has not completed in that amount of time? Would this imply
> you have 5 seconds worth of packets in your transmit queue? Do you
> know what the driver is doing during this 5 seconds?

Hi Andrew,

it is waiting for the watchdog to trigger :-) TBH the 1s seems to be too
short to for the dma ring length to be flushed and i had to pick some
value and 5 is used most places.

it really depends on the amount of packets in the queue, their length
and the mac setting. the timeout needs to be large enough that it would
not trigger incorrectly even if the mac is on 10mbit half duplex and all
frames in the queue were maximum size.

	John
