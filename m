From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Thu, 9 Mar 2017 15:45:15 +0100
Message-ID: <a9cb37d9-a71e-ce59-c379-d9bde5d8afb9@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <2197294b-e6cf-6c56-1419-3a4f95c29db7@timesys.com>
 <6df4a9ae-eaba-6f3f-9c23-ae269548b005@grandegger.com>
 <1447da4a-6a36-38fb-4298-fd7488697d11@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        Akshay Bhat <nodeax@gmail.com>
To: Akshay Bhat <akshay.bhat@timesys.com>, mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1447da4a-6a36-38fb-4298-fd7488697d11@timesys.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Akshay,

Am 09.03.2017 um 13:34 schrieb Akshay Bhat:
>
>
> On 03/09/2017 04:59 AM, Wolfgang Grandegger wrote:
>> Hello Akshay,
>>
>> unfortunately there are not many CAN controllers for the SPI bus. I just
>> know the MPC251x, which behaves badly (message losses) under Linux,
>> especially at hight bit-rates due to insufficient RX buffering. What is
>> your experience with that driver for the HI-311x?
>>
>
> Hi Wolfgang,
>
> Good question. I have not worked with MPC251x but the HI-311x performs
> much better because HI-3110 features:
> 8 message FIFO (as opposed to 2 buffers on MPC2510)
> 20 MHz SPI interface (as opposed to 2.5 MHz on MPC2510)
>
> As for the real world test results:
>
> With RT patch applied to the kernel running on a i.MX6 Dual processor
> (worst case interrupt latency of 50us as reported by cyclictest), there
> are ZERO packet drops.
> Tested with Kvaser Leaf sending 100 burst messages (back to back) every
> 40ms at a 1M CAN bit rate. 10 million messages were sent by the Kvaser
> leaf and received successfully by the HI-311x driver.

This corresponds to a bus load of approx. 50%, I think?

> Even without the RT patch, I was able to get the packet drop to zero but
> this was by moving the CAN/SPI IRQ threads to CPU1 instead of CPU0.

Vanilla Linux is more critical here due to higher latencies. With 2500 
Messages per sec the RX FIFO (8 Messages) fills up within 3.2 ms... and 
in a burst even quicker. That's already heavy load.

Wolfgang.
