From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 15:34:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D1F23E.9090307@pobox.com>
References: <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com> <40D1E24C.8090802@pobox.com> <20040617185815.GB32216@bougret.hpl.hp.com> <40D1EAD9.6090403@pobox.com> <20040617191338.GD32216@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Gertjan van Wingerde <gwingerde@home.nl>,
        sfeldma@pobox.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040617191338.GD32216@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> On Thu, Jun 17, 2004 at 03:02:49PM -0400, Jeff Garzik wrote:
> 
>>Jean Tourrilhes wrote:
>>
>>>On Thu, Jun 17, 2004 at 02:26:20PM -0400, Jeff Garzik wrote:
>>>
>>>
>>>>Note that the above is only a first step.  Through the standard Linux 
>>>>development process -- evolution -- each hook can be pared down to 
>>>>precisely what each call needs.  The above allows for a quick transition 
>>>>of drivers, while keeping them working.
>>>>
>>>>	Jeff
>>>
>>>
>>>	Have you looked at the patch I sent you ? In which way does it
>>>fails to meet your need ?
>>
>>
>>The three major problems I listed in a previous email are still 
>>present...
> 
> 
> 	Are we talking of the same patch ? I'm talking of this patch :
> http://marc.theaimsgroup.com/?l=linux-netdev&m=108749580004668&w=2
> 	I reattached the patch below. It's short enough.

Your patch is half the job -- it allows development of a type-specific 
interface...  but it does nothing to address the problems with the 
underlying type-opaque interface.

The creation of the type-specific interface replaces the type-opaque 
interface, not layers on top of it.

So while this patch may be useful in early development, it does not 
allow the direct exposure of core wireless code to the type-specific 
interfaces, and as such, it can paper over problems that would be 
immediately obviously if the type-specific interface were the only one 
to exist.


>> Also there is a fourth -- WE doesn't work 100% when you have 
>>a 32-bit userland and a 64-bit kernel.
> 
> 
> 	Since when ? What made you change your mind ?
> 	Please check :
> http://marc.theaimsgroup.com/?l=linux-netdev&m=107894322418086&w=2

The general API, yes.  But most driver-private interfaces will fail 
miserably through 32/64-bit translation.

	Jeff
