From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Tue, 14 Oct 2014 21:15:03 -0700
Message-ID: <1413346503.17109.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jkosina@suse.cz, netdev@vger.kernel.org,
	LeoLi@freescale.com, linux-doc@vger.kernel.org
To: Pan Jiafei <Jiafei.Pan@freescale.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-10-15 at 11:26 +0800, Pan Jiafei wrote:
> In some platform, there are some hardware block provided
> to manage buffers to improve performance. So in some case,
> it is expected that the packets received by some generic
> NIC should be put into such hardware managed buffers
> directly, so that such buffer can be released by hardware
> or by driver.

You repeat 'some' four times.

> 
> This patch provide such general APIs for generic NIC to
> use hardware block managed buffers without any modification
> for generic NIC drivers.

...

> In this patch, the following fields are added to "net_device":
>     void *hw_skb_priv;
>     struct sk_buff *(*alloc_hw_skb)(void *hw_skb_priv, unsigned int length);
>     void (*free_hw_skb)(struct sk_buff *skb);
> so in order to let generic NIC driver to use hardware managed
> buffers, the function "alloc_hw_skb" and "free_hw_skb"
> provide implementation for allocate and free hardware managed
> buffers. "hw_skb_priv" is provided to pass some private data for
> these two functions.
> 
> When the socket buffer is allocated by these APIs, "hw_skb_state"
> is provided in struct "sk_buff". this argument can indicate
> that the buffer is hardware managed buffer, this buffer
> should freed by software or by hardware.
> 
> Documentation on how to use this featue can be found at
> <file:Documentation/networking/hw_skb.txt>.
> 
> Signed-off-by: Pan Jiafei <Jiafei.Pan@freescale.com>


I am giving a strong NACK, of course.

We are not going to grow sk_buff and add yet another conditional in fast
path for a very obscure feature like that.

Memory management is not going to be done by drivers.

The way it should work is that if your hardware has specific needs, rx
and tx paths (of the driver) need to make the needed adaptation.
Not the other way.

We already have complex skb layouts, we do not need a new one. 

Take a look at how drivers can 'lock' pages already, and build skb sith
page frags. It is already there.


