From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: ipw2100: firmware problem
Date: Wed, 08 Jun 2005 16:46:01 -0500
Message-ID: <42A76719.2060700@linux.intel.com>
References: <20050608142310.GA2339@elf.ucw.cz> <42A723D3.3060001@linux.intel.com> <20050608212707.GA2535@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050608212707.GA2535@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:

>>We've been looking into whether the initrd can have the firmware affixed
>>to the end w/ some magic bytes to identify it.  If it works, enhancing
>>the request_firmware to support both hotplug and an initrd approach may
>>be reasonable.
>>    
>>
>
>That seems pretty ugly to me... imagine more than one driver does this
>:-(.
>  
>
Not ideal, but not *that bad* if there is a standard way to stick the
data on the initrd image.  Its annoying to have to do it, but it does
enable the most usage models and allows the network to be brought up as
early as possible--which other components in the system may be relying on.

>Having a parameter to control this seems a bit too complex to me.
>
>How is 
>
>insmod ipw2100 enable=1
>
>different from
>
>insmod ipw2100
>iwconfig eth1 start_scanning_or_whatever
>
>?
>  
>
It defaults to enabled, so you just need to do:

    insmod ipw2100

and it will auto associate with an open network.  For the use case where
users want the device to load but not initialize, they can use

    insmod ipw2100 disable=1

If hotplug and firmware loading worked early in the init sequence, no
one would have issue with the current model; it works as users expect it
to work.  It magically finds and associates to networks, and your
network scripts can then kick off DHCP, all with little to no special
crafting or utility interfacing. 

James
