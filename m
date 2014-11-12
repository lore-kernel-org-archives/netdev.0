From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Tue, 11 Nov 2014 21:50:56 -0500 (EST)
Message-ID: <20141111.215056.2165761189796303933.davem@davemloft.net>
References: <1394712342-15778-90-Taiwan-albertk@realtek.com>
	<20141107.113522.837502028522211960.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE0A3@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ECE0A3@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 10 Nov 2014 03:29:27 +0000

> The behavior is different for PCI(e) and USB ethernet device.
> The PCI nic could know the ring buffer by certain way, so
> the device could fill the data into the buffer one by one
> automatically. However, for usb nic, the driver has to
> indicate (i.e. submit) each buffer for each data. The device
> doesn't know what is the next buffer by itself. That is,
> the driver determines the order by which the data would be
> filled.
> 
> Therefore, when I try to submit 10 rx buffers and some of
> them fail, I could get the data depending on the order of
> the successful ones. Besides, the driver has to submit the
> buffer for next data continually, so the previous unsuccessful
> ones could be tried again for the same time.

Ok, but if we are looping here in rtl_start_rx() and r8152_submit_rx()
fails due to a memory allocation failure, there is nothing which is
going to make such a memory allocation succeed in the next iteration
of the loop.

Unless you can prove that often it can succeed after an initial
failure, this is just wasted work and in fact making it take longer
for the system to reclaim memory when under pressure because these
extra iterations are completely wasted cpu work.
