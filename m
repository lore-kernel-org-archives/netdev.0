From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: net/usb/ax88179_178a driver broken in linux-3.12
Date: Tue, 19 Nov 2013 08:10:00 -0800
Message-ID: <1384877400.8604.107.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52890C7E.6000607@pobox.com> <52891178.2080509@pobox.com>
	 <52891341.4020403@pobox.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B742B@saturn3.aculab.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com>
	 <528A9A36.50903@pobox.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
	 <528B6F73.7040801@pobox.com>
	 <1384870550.8604.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7434@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <mlord@pobox.com>, Ming Lei <ming.lei@canonical.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	stable@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7434@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-19 at 14:43 +0000, David Laight wrote:

> It isn't directly a TSO problem.
> There has always been a bug in the xhci driver for fragmented buffers.
> TSO just means it is given a lot of fragmented buffers.
> 
> As well as user-supplied fragmented buffers, the bug affects
> internal fragmentation that happens whenever a buffer crosses a 64k
> byte boundary (please hw engineers - stop doing this!)

TCP stack uses order-3 allocations.

This means 32KB for x86 (PAGE_SIZE=4096)

What is PAGE_SIZE for your arches ?

If there is a 6KB limit, we might adapt TCP to make sure we do not cross
a 64KB boundary.

Other strategy would be to detect this case in the driver and split a
problematic segment into two parts.

> 
> I'm not sure whether usbnet would ever pass buffers that cross 64k
> boundaries. I've not seen one - even with TSO. But the rx buffers
> are 20k (doesn't seem ideal!) and could also be problematical.
> 
> USB mass storage has used SG for ages, the buffers must all be
> adequately aligned for the hardware - they won't meet the constraint
> for USB3 itself, but the documented restriction may be more severe
> than the actual one.
