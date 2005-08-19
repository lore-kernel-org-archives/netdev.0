From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Fw: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot
Date: Fri, 19 Aug 2005 04:04:55 -0400
Message-ID: <430592A7.30101@pobox.com>
References: <20050217134440.44f591e2.akpm@osdl.org> <E1D26BP-0005Lg-00@gondolin.me.apana.org.au> <20050305084537.GA12678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com, mangus@deprecated.it,
        webvenza@libero.it
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050305084537.GA12678@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi:
> 
> Here is the version that moves the necessary code above register_netdev
> instead of using init.  It's against netdev-2.6.
> 
> 
>>Feb 15 18:26:20 saturno kernel: Unable to handle kernel NULL pointer
>>dereference at virtual address 0000000e
>>Feb 15 18:26:20 saturno kernel:  printing eip:
>>Feb 15 18:26:20 saturno kernel: e1113417
>>Feb 15 18:26:20 saturno kernel: *pde = 00000000
>>Feb 15 18:26:20 saturno kernel: Oops: 0000 [#1]
>>Feb 15 18:26:20 saturno kernel: PREEMPT
>>Feb 15 18:26:20 saturno kernel: Modules linked in: sis900 nvidia 8250_pci 8250
>>serial_core psmouse
>>Feb 15 18:26:20 saturno kernel: CPU:    0
>>Feb 15 18:26:20 saturno kernel: EIP:    0060:[<e1113417>]    Tainted: P
>>VLI
>>Feb 15 18:26:20 saturno kernel: EFLAGS: 00010296   (2.6.10-M7)
>>Feb 15 18:26:20 saturno kernel: EIP is at sis900_check_mode+0x17/0xa0 [sis900]
> 
> 
> OK, this happened because we got preempted before sis900_mii_probe
> finished setting the sis_priv->mii.  Theoretically this can happen
> with SMP as well but I suppose the number of SMP machines with sis900
> is fairly small.
> 
> Anyway, the fix is to make sure that sis900_mii_probe is done before
> the device can be opened.  This patch does it by moving the setup
> before register_netdevice.
> 
> Since the netdev name is not available before register_netdev, I've
> changed the relevant printk's to use pci_name instead.  Note that
> one of those printk's may be called after register_netdev as well.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Is this patch still needed?

	Jeff
