From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 16:06:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D1F9C1.1040907@pobox.com>
References: <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com> <20040617185815.GB32216@bougret.hpl.hp.com> <40D1EAD9.6090403@pobox.com> <20040617191338.GD32216@bougret.hpl.hp.com> <40D1F23E.9090307@pobox.com> <20040617194448.GC31763@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Gertjan van Wingerde <gwingerde@home.nl>,
        sfeldma@pobox.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040617194448.GC31763@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> On Thu, Jun 17, 2004 at 03:34:22PM -0400, Jeff Garzik wrote:
> 
>>Your patch is half the job -- it allows development of a type-specific 
>>interface...
> 
> 
> 	Which is exactly what you want. Good.

The patch doesn't kill the type-opaque interface, so only 50% of what I 
want.


>>So while this patch may be useful in early development, it does not 
>>allow the direct exposure of core wireless code to the type-specific 
>>interfaces
> 
> 
> 	What is the core wireless code ?

At the moment, "the stuff that calls the driver-local iw_handlers", but 
hopefully more generic wireless core soon with the merge of HostAP.


>>and as such, it can paper over problems that would be 
>>immediately obviously if the type-specific interface were the only one 
>>to exist.
> 
> 
> 	Any new code in the kernel is free to use only the new
> API. That's a big enoug incentive to migrate drivers over to the new
> API.

With the type-opaque interface gone (key design goal), drivers not using 
the new API will not function...


>>>>Also there is a fourth -- WE doesn't work 100% when you have 
>>>>a 32-bit userland and a 64-bit kernel.
>>>
>>>
>>>	Since when ? What made you change your mind ?
>>>	Please check :
>>>http://marc.theaimsgroup.com/?l=linux-netdev&m=107894322418086&w=2
>>
>>The general API, yes.  But most driver-private interfaces will fail 
>>miserably through 32/64-bit translation.
> 
> 
> 	That's fixable, and easy to fix, if needed. You have all the
> data you need in the kernel.

Not really -- it's the same problem as SIOCDEVPRIVATE.  Driver-private 
interfaces by definition change for each driver.  Translation of the 
same ioctl differs on a per-driver basis.  Consider what happens when 
passing pointers from userland, for example...

It was for this reason that we created the MII ioctls, which were 
previously SIOCDEVPRIVATE.

	Jeff
