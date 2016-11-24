From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 13:26:55 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <baf5246d-9d8a-4029-6823-350ed561fd33@pobox.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord [mailto:mlord@pobox.com]
> Sent: Thursday, November 24, 2016 8:31 PM
[...]
> Nope.  Guard zones did not fix it, so it's probably not a prefetch issue.
> Oddly, adding a couple of memory barriers to specific places in the driver
> does help, A LOT.  Still not 100%, but it did pass 1800 reboot tests over night
> with only three bad rx_desc's reported.
> 
> That's a new record here for the driver using kmalloc'd buffers,
> and put reliability on par with using non-cacheable buffers.
> 
> Any way we look at it though, the chip/driver are simply unreliable,
> and relying upon hardware checksums (which fail due to the driver
> looking at garbage rather than the checksum bits) leads to data corruption.

I don't think the garbage results from our driver or device.
If it is the issue about memory, I think the host driver ought
to deal with it, because it handles the DMA.

Besides, it doesn't seem to occur for all platforms. I have
tested the iperf more than 26 hours, and it still works fine.
I think I would get the same result on x86 or x86_64 platform.

Best Regards,
Hayes
