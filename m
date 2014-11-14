From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Fri, 14 Nov 2014 05:14:36 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ED1624@RTITMBSV03.realtek.com.tw>
References: <20141112.144949.645590790916569141.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE8EF@RTITMBSV03.realtek.com.tw>
	<20141112.223146.2221136950144767962.davem@davemloft.net>
 <20141113.162240.1823683928052355016.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141113.162240.1823683928052355016.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem@davemloft.net] 
> Sent: Friday, November 14, 2014 5:23 AM
[...]
> What if even the first r8152_submit_rx() fails?  What ever will cause
> any of these retries to trigger at all?

According to the patch #1 "adjust r8152_submit_rx", the
r8152_submit_rx() would add the rx to the list and schedule
the tasklet, when the error occurs. Each time the tasklet is
called, the rx_bottom() would deal with all the rx in the
list. If the actual_length isn't vaild, the rx buffer would be
submitted directly. By this way, the retries would be done.
That is, the retries would be triggered when the tasklet
is called. Therefore, any tx, rx, and tasklet scheduling
would result in the retries.

> Second, why does your patch increment 'i' with 'i++;' in the error
> break path?  You should mark the first failed entry as unallocated
> with actual_length == 0 and place it on the rx_done queue.

Because the r8152_submit_rx() would add the failed rx to
the list, I only have to deal with the remaining ones. That
is why I increase the "i", otherwise the failed one would
be added twice.

I remember the usb_submit_urb() would set actual_length
to 0, so I skip the step. I would check it again.
 
Best Regards,
Hayes
