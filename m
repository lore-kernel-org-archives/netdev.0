From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Tue, 20 Jan 2015 02:48:50 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EE6E76@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
	<1394712342-15778-119-Taiwan-albertk@realtek.com>
	<CAE4R7bAv26f-+DW-TmjspJxAb-3Add5sf563mnMUTGCyiqG3rQ@mail.gmail.com>
 <20150119.161333.1471925264489559119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150119.161333.1471925264489559119.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
> Sent: Tuesday, January 20, 2015 5:14 AM
[...]
> >> -               r8152_submit_rx(tp, agg, GFP_ATOMIC);
> >> +               if (!ret) {
> >> +                       ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
> >> +               } else {
> >> +                       urb->actual_length = 0;
> >> +                       list_add_tail(&agg->list, next);
> > 
> > Do you need a spin_lock_irqsave(&tp->rx_lock, flags) around this?
> 
> Indeed, and rtl_start_rx() seems to also access agg->list without
> proper locking.

It is unnecessary because I deal with them in a local list_head. My steps are
   1. Move the whole list from tp->rx_done to local rx_queue. (with spin lock)
   2. dequeue/enqueue the lists in rx_queue.
   3. Move the lists in rx_queue to tp->rx_done if it is necessary. (spin lock)
For step 2, it wouldn't have race, because the list_head is local and no other
function would change it. Therefore, I don't think it needs the spin lock.

The rtl_start_rx() also uses the similar way.
 
Best Regards,
Hayes
