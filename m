From: Alan Ott <alan@signal11.us>
Subject: Re: [Linux-zigbee-devel] [PATCH 1/6] mac802154: Immediately retry
 sending failed packets
Date: Tue, 02 Apr 2013 22:57:59 -0400
Message-ID: <515B9AB7.50508@signal11.us>
References: <515B8D09.9050304@signal11.us> <20130402.220315.1782012687105065631.davem@davemloft.net> <515B9318.8090101@signal11.us> <20130402.223036.1483788180825619960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: werner@almesberger.net, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130402.223036.1483788180825619960.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/2013 10:30 PM, David Miller wrote:
> From: Alan Ott <alan@signal11.us>
> Date: Tue, 02 Apr 2013 22:25:28 -0400
>
>> The workqueue in mac802154 is only needed because the current mac802154
>> xmit() function is designed to be blocking and synchronous.
>>
>> Prior to my patch (#3/6), that very same workqueue would actually queue
>> up packets (without bound). That's what my patch fixes.
>>
>> The workqueue in mac802154 also serializes the access to the device for
>> other functions like setting the channel, ensuring that in the driver
>> code, one doesn't have to mutex everything. I'm not sure if that's the
>> "right" way to do it, but that's the way it was when I got here.
> This is entirely duplicating existing facilities.
>
> Your desire to allow blockability during xmit() on the basis of mutual
> exclusion is not well founded.

I'm not sure it's my desire, but rather a statement of the way it
currently is. To be clear, .ndo_start_xmit() does not block, but queues
a workqueue item which then calls ieee802154_ops->xmit() which does block.

This patch series centers around putting netif_stop_queue() and
netif_wake_queue() in the mac802154 layer. I've sent emails about this
before[1], and gotten no real suggestions about the issue, so I
proceeded with Solution #1 (as described at [1]). If you want to skip
this and go straight to solution #2, then let's talk about what that
might look like. I still think though, that there is benefit in getting
solution #1 in because it fixes some current usability problems
(including the buffer (workqueue) growing without bound).

All that said, I'm not sure I've answered your question or concern.
Please let me know if I'm still not getting it.

Alan.

[1] http://thread.gmane.org/gmane.linux.network/242495/focus=262869
