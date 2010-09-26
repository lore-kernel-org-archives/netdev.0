From: David Miller <davem@davemloft.net>
Subject: Re: de2104x: fix power management
Date: Sun, 26 Sep 2010 15:49:14 -0700 (PDT)
Message-ID: <20100926.154914.48490607.davem@davemloft.net>
References: <201009251157.07197.linux@rainbow-software.org>
	<4C9E2E88.3080101@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C9E2E88.3080101@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Sat, 25 Sep 2010 13:16:56 -0400

> On 09/25/2010 05:57 AM, Ondrej Zary wrote:
>> At least my 21041 cards come out of suspend with bus mastering
>> disabled so
>> they did not work after resume(no data transferred).
>> After adding pci_set_master(), the driver oopsed immediately on resume
>> -
>> because de_clean_rings() is called on suspend but de_init_rings() call
>> was missing in resume.
>>
>> Also disable link (reset SIA) before sleep (de4x5 does this too).
>>
>> Signed-off-by: Ondrej Zary<linux@rainbow-software.org>
 ...
> Acked-by: Jeff Garzik <jgarzik@redhat.com>

I'll apply this, thanks guys.

> IMO suspend/resume could use another look; if netif_running is false
> (interface is down), de2104x does not put the PCI device to sleep,
> which seems strange.

TG3 does the same.

The reason is that until we bringing the device up (and thus
netif_running becomes true) the device is left in the most appropriate
powered down state.

At least that is my understanding.

What is appropriate for any driver in this situation depends upon how
it programs the device before ->open() occurs.

> I also wonder if rtnl_lock() couldn't be eliminated, as other net
> drivers don't need it in suspend/resume.

I suspect the RTNL stuff here can be safely removed.

I think it's using it to guard the netif_running() check but that
isn't necessary.
