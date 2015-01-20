From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Tue, 20 Jan 2015 03:24:52 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EE6E9F@RTITMBSV03.realtek.com.tw>
References: <CAE4R7bAv26f-+DW-TmjspJxAb-3Add5sf563mnMUTGCyiqG3rQ@mail.gmail.com>
	<20150119.161333.1471925264489559119.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2EE6E76@RTITMBSV03.realtek.com.tw>
 <20150119.215220.720365670558757349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150119.215220.720365670558757349.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
> Sent: Tuesday, January 20, 2015 10:52 AM
[...]
> agg->list is not local, you have to use a spinlock to protect
> modifications to it, some other sites which modify agg->list do take
> the lock properly.
> 
> You cannot modify a list like agg->list without proper locking.

Excuse me. I don't understand.

Before step1
   tp_rx_done->listA->listB->listC->listD->...
   rx_queue->
Because the other function would chage tp->rx_done,
I need move the lists with spin lock.

After step1
   tp_rx_done->
   rx_queue->listA->listB->listC->listD->...

Now I dequeue one of the lists from the list_head and
deal with it.
   tp_rx_done->
   rx_queue->listA->listC->listD->...
                    listB

Then, if I want to put it back to rx_queue, I have to
use spin lock. Why? No other function would chage
rx_queue and the items in it.
 
Best Regards,
Hayes
