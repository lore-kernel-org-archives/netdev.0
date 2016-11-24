From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 12:11:40 -0500 (EST)
Message-ID: <20161124.121140.2054576632424977475.davem@davemloft.net>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
        <20161124.112152.692025478489876693.davem@davemloft.net>
        <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
        nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org
To: mlord@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Lord <mlord@pobox.com>
Date: Thu, 24 Nov 2016 11:43:53 -0500

> So even if this were a platform memory coherency issue, one should
> still never see ASCII data at the beginning of an rx buffer.

I'm not so convinced, since this is the kind of random corruption one
would expect to see when dealing with virtual caches that have
aliasing or similar issues.

Writes to address X that show up at address Y or not at all are
precisely the signature of virtual cache aliasing problems.

Is it a case of the chip writing to X but the cpu is still seeing
stale data from a previous CPU store?

For NFS the cpu is writing into the page cache, so we know that
cpu side stores are where the ASCII text is coming from.

Now is the r8152 buffer one that the USB host controller is DMA'ing
into directly, or is it one that SWIOMMU or similar bounce buffering
is copying into?  In the latter case we are doing cpu stores into
the area and the writes aren't coming from the device.
