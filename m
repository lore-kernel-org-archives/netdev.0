From: Ben Greear <greearb@candelatech.com>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Wed, 22 Oct 2003 10:01:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F96B7FD.7080607@candelatech.com>
References: <Pine.LNX.4.44.0307091816280.1313-100000@hl.kauneta.net> <20030709152814.GC15293@gtf.org> <20031022140624.A9145@vip.cybercity.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031022140624.A9145@vip.cybercity.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:
> On Wed, Jul 09, 2003 at 11:28:15AM -0400, Jeff Garzik wrote:
> 
>>On Wed, Jul 09, 2003 at 06:19:51PM +0300, Andrius Kasparavicius wrote:
>>
>>>hello, as far as i know, currently there is no native vlan support in
>>>network device drivers. I mean, always need patching MTU.. add 4 bytes..
>>>
>>>is there any problems to include full vlans support?
>>
>>Native VLAN support has been in the kernel for a while.
>>
>>A few drivers still need patching, and unfortunately the VLAN driver
>>patches floating around all need cleaning up.
> 
> 
> What does a driver need to do to make sure it can handle vlan frames? Is it
> enought to be prepared to handle frames of size dev->mtu+4? How do I know 4
> bytes will be enough tomorrow when someone introduces VLAN2 with a 64-bit tag?
> Checking for CONFIG_VLAN is of no use, right?

It needs to be able to handle 1518 bytes (+crc), send and receive.  I'd
suggest using the Intel e100 or e1000, as they both support VLANs just fine.
Most other GigE nics work too.

Apply the patches in the VLAN howto if you need another NIC that needs
patching.  There seems to be zero motivation by 100bt driver authors to
add VLAN support to the drivers that still need it...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
