From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net, USB, Option, hso: Do not dereference NULL pointer
Date: Sun, 13 Feb 2011 16:56:08 -0800 (PST)
Message-ID: <20110213.165608.149817059.davem@davemloft.net>
References: <alpine.LNX.2.00.1102132206390.18930@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@suse.de, j.dumon@option.com,
	f.aben@option.com, d.barow@option.com, ajb@spheresystems.co.uk
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1102132206390.18930@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 13 Feb 2011 22:15:35 +0100 (CET)

> In drivers/net/usb/hso.c::hso_create_bulk_serial_device() we have this 
> code:
> ...
> 	serial = kzalloc(sizeof(*serial), GFP_KERNEL);
> 	if (!serial)
> 		goto exit;
> ...
> exit:
> 	hso_free_tiomget(serial);
> ...
> hso_free_tiomget() directly dereferences its argument, which in the 
> example above is a NULL pointer, ouch.
> I could just add a 'if (serial)' test at the 'exit' label, but since most 
> freeing functions in the kernel accept NULL pointers (and it seems like 
> this was also assumed here) I opted to instead change 'hso_free_tiomget()' 
> so that it is safe to call it with a NULL argument. I also modified the 
> function to get rid of a pointles conditional before the call to 
> 'usb_free_urb()' since that function already tests for NULL itself - 
> besides fixing the NULL deref this change also buys us a few bytes in 
> size.
> Before:
> $ size drivers/net/usb/hso.o
>    text    data     bss     dec     hex filename
>   32200     592    9960   42752    a700 drivers/net/usb/hso.o
> After:
> $ size drivers/net/usb/hso.o
>    text    data     bss     dec     hex filename
>   32196     592    9960   42748    a6fc drivers/net/usb/hso.o
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied.
