From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Thu, 24 Nov 2016 22:49:33 -0500
Message-ID: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
References: <0835B3720019904CB8F7AA43166CEEB201055ED8@RTITMBSV03.realtek.com.tw>
 <20161124.112152.692025478489876693.davem@davemloft.net>
 <23e0c132-8844-0a34-3e0b-e412f76493ba@pobox.com>
 <20161124.121140.2054576632424977475.davem@davemloft.net>
 <c3ca9e10-64de-2454-b99a-19e8302f5c12@pobox.com>
 <20161125002702.GA14085@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161125002702.GA14085@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-24 07:27 PM, Francois Romieu wrote:
>
> Through aliasing the URB was given a page that contains said (previously)
> received file. The ethernet chip/usb host does not write anything in it.

I don't see how that could be possible.  Please elaborate.

The URB buffers are statically allocated by the driver at probe time,
ten of them in all, allocated with usb_alloc_coherent() in the copy of
the driver I am testing with.

There is no possibility for them to be used for anything other than
USB receive buffers, for this driver only.  Nothing in the driver
or kernel ever writes to those buffers after initial allocation,
and only the driver and USB host controller ever have pointers to the buffers.
-- 
Mark Lord
