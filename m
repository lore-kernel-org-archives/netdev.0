From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding] Add basic support for dynamic configuration of bond
 interfaces
Date: Sun, 11 Jan 2004 16:59:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4001C72E.8030108@pobox.com>
References: <E6F7D288B394A64585E67497E5126BA601F991D1@hasmsx403.iil.intel.com> <200401111628.07930.amir.noam@intel.com> <4001A667.2020904@pobox.com> <4001C158.6040103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Noam <amir.noam@intel.com>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4001C158.6040103@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I would also be open to moving the VLAN ioctls over into the
> ethtool ioctl space, but that just exchanges one magic ioctl for
> another...


The key question is what is the best interface for userland to configure 
in-kernel information -that is unrelated to a specific interface-. 
ethtool ioctl space doesn't apply, because that's a per-interface API.

Opening a socket and just ioctl'ing away isn't terribly scalable in the 
long run, either.  Consider all the applications that could legitimately 
claim they need a SIOCxxx ioctl assignment, just for their little slice 
of the networking world.  Further, consider that all an ioctl is is a 
message sent to the kernel driver, perhaps sending and/or receiving some 
data.  :)

ioctls are a pain for 32/64-bit emulation layers too.  It seems much 
easier to define a netlink protocol family of some sort and communicate 
that way.

I'll poke around and see what I can come up with.

	Jeff
