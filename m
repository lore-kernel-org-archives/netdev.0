From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Fri, 01 Apr 2005 08:58:52 -0800
Message-ID: <424D7DCC.5030202@candelatech.com>
References: <424C6089.1080507@candelatech.com> <1112303627.1073.71.camel@jzny.localdomain> <424C6B10.6030200@candelatech.com> <1112306031.1073.109.camel@jzny.localdomain> <424C7813.4000101@candelatech.com> <20050331143531.30f4eb8f.davem@davemloft.net> <424C7F96.4070002@candelatech.com> <1112311618.1090.20.camel@jzny.localdomain> <424C8E2C.70302@candelatech.com> <20050401090116.GA21361@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20050401090116.GA21361@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> On Thu, Mar 31, 2005 at 03:56:28PM -0800, Ben Greear wrote:
> 
> 
>>>I think you are more comfortable with using netdevices and ioctls and
>>>/proc. 
>>
>>Definately.  Ever tried to sniff a socket with ethereal? :)
> 
> 
> On loopback, all the time. I'm probably dense but I don't understand what
> problem you've solved with this interface. Could you elaborate a bit?

It allows me to place a software bridge that can intercept all packets
from user-space via raw packet sockets, and kernel space via registering
an 'all' protocol on the device.  Please note that to bridge in this manner
I have to remove the IP protocol (set IP to 0.0.0.0), otherwise the IP stack
can interfere with the bridging behaviour.

By using a virtual pair of interfaces that are looped back, I can add an
IP to the second virtual network interface that does not interfere with
the two bridged interfaces (one physical, one redirect, both with 0.0.0.0 IP
addresses).

If there were an API to register handlers dynamically that act like the
netpoll hook (ie, with ability to consume frames), then I would not have to
remove the IP from the physical interface and I probably would not have had
to create these redirect devices.  But, when I was suggesting such a hook
in the past, it was shot down because it could allow someone to write their
own TCP stack, and the network guys did not want to allow this possibility.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
