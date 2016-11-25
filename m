From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 06:11:18 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201056266@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-227-Taiwan-albertk@realtek.com>
 <0835B3720019904CB8F7AA43166CEEB20105013E@RTITMBSV03.realtek.com.tw>
 <d683c019-4e0f-6fe6-368c-c4fc86c72fe6@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201050B7E@RTITMBSV03.realtek.com.tw>
 <b9809516-d036-bfc3-b7a3-6563033ec957@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB2010517CE@RTITMBSV03.realtek.com.tw>
 <b61a0e10-c737-8912-3e4e-393f4eb32077@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201051D51@RTITMBSV03.realtek.com.tw>
 <95fa9f67-3af6-6749-0e2b-c95406486f7d@pobox.com>
 <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
 <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <cdb64b21-a590-8c4f-50b1-757302d7b528@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cdb64b21-a590-8c4f-50b1-757302d7b528@pobox.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord [mailto:mlord@pobox.com]
> Sent: Thursday, November 24, 2016 11:25 PM
[...]
> x86 has near fully-coherent memory, so it is the "easy" platform
> to get things working on.  But Linux supports a very diverse number
> of platforms, with varying degrees of cache/memory coherency,
> and it can be tricky for things to work correctly on all of them.

However, I have test iperf on raspberry pi v1 which you suggest
for more than one day. I still couldn't reproduce your issue.

> If you are testing with the driver as currently in 4.4.34,
> then you won't even notice when things are screwing up,
> because the driver just silently drops packets.
> Or it passes them on without noticing that they have bad data.

I only drop the packet silently when the rx descriptor outside
the urb buffer. Then, I check the rx descriptor before checking
the length of the packet.

> Here (attached) is the instrumented driver I am using here now.
> I suggest you use it or something similar when testing,
> and not the stock driver.

I would test it again with your driver.

[...]
> Also, unrelated, but inside r8152_submit_rx() there is this code:
> 
>          /* The rx would be stopped, so skip submitting */
>          if (test_bit(RTL8152_UNPLUG, &tp->flags) ||
>              !test_bit(WORK_ENABLE, &tp->flags)
> || !netif_carrier_ok(tp->netdev))
>                 return 0;
> 
> If that "return 0" statement is ever executed, doesn't it result
> in the loss/leak of a buffer?

They would be found back by calling rtl_start_rx(), when the rx
is restarted.

Best Regards,
Hayes
