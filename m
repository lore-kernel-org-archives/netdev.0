From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 20:56:00 +0100
Message-ID: <43ADA7D0.9010908__452.26492588899$1135454268$gmane$org@colorfullife.com>
References: <43AD4ADC.8050004@colorfullife.com> <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Ayaz Abdulla <AAbdulla@nvidia.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:

>Of course, on the alloc path, it seems to add an additional 
>"NV_RX_ALLOC_PAD" thing, so maybe the "end-data" thing makes sense.
>
>  
>
The problem is the pci_unmap_single() call that happens during 
nv_close() or the rx interrupt handler. I think it makes more sense to 
rely on fields in the individual skb instead of reading from 
np->rx_buf_sz. If np->rx_buf_sz changes inbetween, then we have a memory 
leak.

--
    Manfred
