From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] forcedeth: fix random memory scribbling bug
Date: Sat, 24 Dec 2005 14:58:26 -0500
Message-ID: <43ADA862.6010906__15352.6237154894$1135454426$gmane$org@pobox.com>
References: <43AD4ADC.8050004@colorfullife.com> <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
        Ayaz Abdulla <AAbdulla@nvidia.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0512241145520.14098@g5.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> However, that
> 
> 	"skb->end - skb->data"
> 
> calculation is a bit strange. It correctly maps the whole skb, but 

nod


> wouldn't it make more sense to use the length we actually tell the card to 
> use? 
> 
> In other words, wouldn't it be a whole lot more sensible and logical to 
> use
> 
> 	np->rx_buf_sz
> 
> instead? That's the value we use for allocation and that's the size we 
> tell the card we have.

That's the sort of thing I prefer.


> Of course, on the alloc path, it seems to add an additional 
> "NV_RX_ALLOC_PAD" thing, so maybe the "end-data" thing makes sense.

None of the other ethernet drivers do 'end - data', which is why I 
hesitated quite a bit on this change.

	Jeff
