From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: PCI memory reservation failure - 2.4/2.6
Date: Wed, 12 May 2004 23:07:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40A29211.2010707@colorfullife.com>
References: <BDD74A21E0B47FEAC3AB8A10@[192.168.0.100]>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dominik Brodowski <linux@brodo.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Alec H. Peterson" <ahp@hilander.com>
In-Reply-To: <BDD74A21E0B47FEAC3AB8A10@[192.168.0.100]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alec H. Peterson wrote:

> + #if 1
> +         if (!(type & IORESOURCE_IO) && (((end - start) < 
> BRIDGE_SIZE_MIN) ||
> +             (start & (end - start))))
> +       {
> +               printk(KERN_INFO "yenta %s: Preassigned resource start 
> %lx end %lx too small or not aligned.\n", socket->dev->slot_name, 
> start, end);
> +                 res->start = res->end = 0;
> +         } 

I'm not sure if this is the right approach - what if a bios 
intentionally assigns a small area? It's dangerous to override the BIOS 
setting.
I'd prefer a kernel command line parameter / module parameter / dmi 
based override instead of an unconditional override based on the minimum 
size.
I'll think about it.

--
    Manfred
