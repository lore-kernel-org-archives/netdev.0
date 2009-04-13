From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 14:32:11 -0700 (PDT)
Message-ID: <20090413.143211.214694858.davem@davemloft.net>
References: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	mcarlson@broadcom.com, mchan@broadcom.com
To: James.Bottomley@HansenPartnership.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 13 Apr 2009 15:29:54 +0000

> We noticed on parisc that our broadcoms all swapped MAC addresses going
> from 2.6.29 to 2.6.30-rc1:
> 
> Apr 11 07:48:24 ion kernel: eth0: Tigon3 [partno(BCM95700A6) rev 0105] (PCI:66MHz:64-bit) MAC address 00:30:6e:4b:15:59
> Apr 13 07:34:34 ion kernel: eth0: Tigon3 [partno(BCM95700A6) rev 0105] (PCI:66MHz:64-bit) MAC address 00:00:59:15:4b:6e
> 
> The problem patch is:
> 
> commit 6d348f2c1e0bb1cf7a494b51fc921095ead3f6ae
> Author: Matt Carlson <mcarlson@broadcom.com>
> Date:   Wed Feb 25 14:25:52 2009 +0000
> 
>     tg3: Eliminate tg3_nvram_read_swab()
> 
> With the root cause being the use of memcpy to set the mac address:
> 
>    memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
>    memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));
> 
> This might work on little endian machines, but it can't on big endian
> ones.  You have to use the original setting mechanism to be correct on
> all architectures.
> 
> The attached patch fixes parisc.
> 
> Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>

I'm applying this, thanks a lot James!
