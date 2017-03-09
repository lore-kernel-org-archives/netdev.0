From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Thu, 9 Mar 2017 07:34:43 -0500
Message-ID: <1447da4a-6a36-38fb-4298-fd7488697d11@timesys.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <2197294b-e6cf-6c56-1419-3a4f95c29db7@timesys.com>
 <6df4a9ae-eaba-6f3f-9c23-ae269548b005@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6df4a9ae-eaba-6f3f-9c23-ae269548b005-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 03/09/2017 04:59 AM, Wolfgang Grandegger wrote:
> Hello Akshay,
> 
> unfortunately there are not many CAN controllers for the SPI bus. I just
> know the MPC251x, which behaves badly (message losses) under Linux,
> especially at hight bit-rates due to insufficient RX buffering. What is
> your experience with that driver for the HI-311x?
> 

Hi Wolfgang,

Good question. I have not worked with MPC251x but the HI-311x performs
much better because HI-3110 features:
8 message FIFO (as opposed to 2 buffers on MPC2510)
20 MHz SPI interface (as opposed to 2.5 MHz on MPC2510)

As for the real world test results:

With RT patch applied to the kernel running on a i.MX6 Dual processor
(worst case interrupt latency of 50us as reported by cyclictest), there
are ZERO packet drops.
Tested with Kvaser Leaf sending 100 burst messages (back to back) every
40ms at a 1M CAN bit rate. 10 million messages were sent by the Kvaser
leaf and received successfully by the HI-311x driver.

Even without the RT patch, I was able to get the packet drop to zero but
this was by moving the CAN/SPI IRQ threads to CPU1 instead of CPU0.

Hence I feel the driver is a good candidate to be included in the Linux
kernel.

Below are detailed test results if you like:
https://goo.gl/VWgzp7

Ones of particular interest:
10M-msgs-1M-bitrate-100burst-40ms-interval-leaf.png
10M-msgs-1M-bitrate-100burst-40ms-interval-pwc.txt

Thanks,
Akshay

> 
> Am 07.03.2017 um 16:31 schrieb Akshay Bhat:
>>
>>
>> On 01/17/2017 02:22 PM, Akshay Bhat wrote:
>>> This patch adds support for the Holt HI-311x CAN controller. The HI311x
>>> CAN controller is capable of transmitting and receiving standard data
>>> frames, extended data frames and remote frames. The HI311x interfaces
>>> with the host over SPI.
>>>
>>> Datasheet: www.holtic.com/documents/371-hi-3110_v-rev-jpdf.do
>>>
>>> Signed-off-by: Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>> ---
>>>
>>
>>
>> Hi Marc,
>>
>> Wanted to check if this patch can be included in the next kernel release
>> (4.12).
>>
>> Thanks,
>> Akshay
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-can" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
