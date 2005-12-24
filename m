From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 16:06:02 -0500
Message-ID: <43ADB83A.4090005__7588.44575980238$1135458493$gmane$org@pobox.com>
References: <43AD4ADC.8050004@colorfullife.com> <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org> <43ADA7D0.9010908@colorfullife.com> <Pine.LNX.4.64.0512241241230.14098@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
        Ayaz Abdulla <AAbdulla@nvidia.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0512241241230.14098@g5.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> On Sat, 24 Dec 2005, Manfred Spraul wrote:
> 
> 
>>Linus Torvalds wrote:
>>
>>
>>>Of course, on the alloc path, it seems to add an additional
>>>"NV_RX_ALLOC_PAD" thing, so maybe the "end-data" thing makes sense.
>>
>>The problem is the pci_unmap_single() call that happens during nv_close() or
>>the rx interrupt handler. I think it makes more sense to rely on fields in the
>>individual skb instead of reading from np->rx_buf_sz. If np->rx_buf_sz changes
>>inbetween, then we have a memory leak.
> 
> 
> Fair enough. Patch applied.

Paranoia -- the situation above never occurs.  It is coded as are other 
drivers:  np->rx_buf_sz only changes in ->change_mtu(), which (a) is 
serialized against close and (b) always stops the engine and drains RX 
skbs before changing the size.

So can we please remove the subtraction code now added to the hot path? 
  If not now, for 2.6.16?

	Jeff
