From: Ben Greear <greearb@candelatech.com>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 12:48:16 -0800
Message-ID: <41F6B090.6020602@candelatech.com>
References: <20050124234515.GA31837@postel.suug.ch> <20050125000759.GA15883@gondor.apana.org.au> <20050124164049.3b939791.davem@davemloft.net> <20050125014538.GB31837@postel.suug.ch> <20050125014838.GA16637@gondor.apana.org.au> <20050125020118.GC31837@postel.suug.ch> <20050124180354.63ae600d.davem@davemloft.net> <20050125022431.GD31837@postel.suug.ch> <20050124194328.20a106de.davem@davemloft.net> <20050125143319.GF31837@postel.suug.ch> <20050125203607.GG31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        david@davidcoulson.net, kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050125203607.GG31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Thomas Graf <20050125143319.GF31837@postel.suug.ch> 2005-01-25 15:33
> 
>>* David S. Miller <20050124194328.20a106de.davem@davemloft.net> 2005-01-24 19:43
>>
>>>On Tue, 25 Jan 2005 03:24:31 +0100
>>>Thomas Graf <tgraf@suug.ch> wrote:
>>>
>>>
>>>>This of course explains it, didn't think of that. I thought it would
>>>>inherit the checksumming features.
>>>
>>>It should, but only in very limited cases.
>>>
>>>Because it is very chip dependant whether this works or not in
>>>any case, we should probably create a special features flag for
>>>this.  Something like NETIF_F_VLAN_INHERIT_FEATURES.
>>
>>Can't we just use NETIF_F_HW_VLAN_TX for this and inherit
>>NETIF_F_HW_CSUM | NETIF_F_IP_CSUM if it is set? I don't have any
>>specs at hand though.
> 
> 
> Vlan devices don't inherit any features at the moment but it would make
> sense to do so.
> 
> NETIF_F_SG|NETIF_F_TSO:
>   The normal vlan code seems to handle pskbs correctly, we don't gain
>   that much though. The big gain would be in the driver specific accel
>   code. I assume that the driver specific accel code is aware of
>   pskbs if the card can handle it but I haven't checked this yet.
> 
> NETIF_F_NO_CSUM:
>   Avoid checksumming for vlan devices on loopback interfaces.
> 
> NETIF_F_HIGHDMA|NETIF_F_FRAGLIST:
>   Didn't find a reason why this would cause problems.
> 
> NETIF_F_LLTX:
>   vlan code accesses statistic counters so I think we can't
>   inherit. It might be worth to make it clean though.
> 
> NETIF_F_IP_CSUM|NETIF_F_HW_CSUM:
>   Assuming that the vlan accel code can always do the checksumming
>   if the card can do it.

I am leery of assuming these things for all drivers and all chipsets.

Maybe the driver itself could tell vlan code what sorts of flags it
can set?  That takes the guess-work out, and each driver can add
the features support as it is verified to work.  If any particular
hacks need to be used (ie, maybe chipset foo.rev-1a can't handle one
particular thing), then the VLAN code doesn't have to care.

	new_dev->features = real_dev->vlan_features;

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
