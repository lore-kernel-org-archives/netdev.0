From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: ipw2100: firmware problem
Date: Thu, 09 Jun 2005 02:06:05 -0400
Message-ID: <42A7DC4D.7000008@pobox.com>
References: <20050608142310.GA2339@elf.ucw.cz>	<200506081744.20687.vda@ilport.com.ua>	<42A7268D.9020402@linux.intel.com> <20050608.124332.85408883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jketreno@linux.intel.com, vda@ilport.com.ua, pavel@ucw.cz,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
        ipw2100-admin@linux.intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050608.124332.85408883.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: James Ketrenos <jketreno@linux.intel.com>
> Date: Wed, 08 Jun 2005 12:10:37 -0500
> 
> 
>>My approach is to make the driver so it supports as many usage models as
>>possible, leaving policy to other components of the system.
> 
> 
> I don't see how this kind of firmware load setup handles something
> like an NFS root over such a device that requires firmware.
> 
> And let's not mention that I have to setup an initrd to make that
> work, that's rediculious.
> 
> This is the kind of crap that happens when drivers in the kernel
> are not self contained, and need "external stuff" to work properly.
> It means that simple things like NFS root over the device do not
> work in a straightforward, simple, and elegant manner.


Actually these questions has already been answered (though I know you 
will probably grumble a bit :))

"early userspace" is the long term answer.  usr/* in the current kernel 
tree is a placeholder for an image that is shipped with the kernel, 
which provides things (kernel modules, userspace programs, firmware) 
that are necessary to boot.

The key is that it is shipped with the kernel source tree, and built 
into the kernel image, and _dropped from memory_ after init.  The entire 
process should all be automatic.

Linus ack'd the current stuff (by merging it, after some discussion) and 
would have merged klibc too, had it any users.

  ...

As to $current_thread, initramfs exists but "early userspace" does not. 
    There isn't AFAIK any infrastructure to automatically add firmware 
to initrd in any standard distribution (corrections welcome!).  So 
today, initrd+firmware is just a big pain.

Therefore, the easiest way to make things work today is to poke Intel to 
fix their firmware license so that we can distribute it with the kernel :)

	Jeff
