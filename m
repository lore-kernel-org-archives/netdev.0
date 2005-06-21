From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 21 Jun 2005 13:38:39 -0700
Message-ID: <42B87ACF.3080800@hp.com>
References: <468F3FDA28AA87429AD807992E22D07E0450C00B@orsmsx408>	<Pine.CYG.4.58.0506061647340.128@mawilli1-desk2.amr.corp.intel.com>	<42A5284C.3060808@osdl.org> <20050621.132044.115910664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mitch.a.williams@intel.com, john.ronciak@intel.com,
        mchan@broadcom.com, hadi@cyberus.ca, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050621.132044.115910664.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Mon, 06 Jun 2005 21:53:32 -0700
> 
> 
>>I noticed that the tg3 driver copies packets less than a certain
>>threshold to a new buffer, but e1000 always passes the big buffer up
>>the stack. Could this be having an impact?
> 
> 
> I bet it does, this makes ACK processing a lot more expensive. 

Why would ACK processing care about the size of the buffer containing the ACK 
segment?

> And it
> is so much cheaper to just recycle the big buffer back to the chip
> if you copy to a small buffer, and it warms up the caches for the
> packet headers as a side effect as well.

I would think that the cache business would be a wash either way.  With 64 byte 
cache lines (128 in some cases) just accessing the link-level header has brought 
the IP header into the cache, and probably the TCP header as well.

Isn't the decision point between the sum of allocating a small buffer and doing 
the copy, versus allocating a new large buffer and (re)mapping it for DMA?  I 
guess that would come down to copy versus mapping overhead.

> Actually, it has a _HUGE_ _HUGE_ impact.  If you pass the big buffer
> up, the receiving socket gets charged for the size of the huge buffer,
> not for just the size of the packet contained within.  This makes
> sockets get overcharged for data reception, and it can cause all kinds
> of performance problems.

Then copy when the socket is about to fill with overhead bytes?

> I highly recommend that this gets fixed.

What is the cut-off point for the copy?

rick jones
