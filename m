From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: Interconnect virtual device?
Date: Mon, 14 Mar 2005 14:53:05 -0800
Message-ID: <423615D1.9030901@qualcomm.com>
References: <4222A8F2.6080004@candelatech.com>	 <1109592365.2188.914.camel@jzny.localdomain>	 <422353C9.6050001@candelatech.com>	 <1109800554.1091.213.camel@jzny.localdomain>	 <20050302225558.GS31837@postel.suug.ch> <1109810103.1090.247.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Ben Greear <greearb@candelatech.com>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1109810103.1090.247.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2005-03-02 at 17:55, Thomas Graf wrote:
> 
>>I think we talked about this once already and I do like the idea
>>but the reinjection is at least of the same importance to me. What
>>I'm thinking of basically gets down to two ring buffers both holding
>>mmaped buffers.
> 
> 
> The ring device already has the recv side direction ring,
> Whats needed is tx side.
> 
> 
>> The action enqueues skbs to the first ring buffer
>>and userspace dequeues it from there. The skb gets completely lost
>>at this point by having it shot or just cloned if mirroring is requested.
> 
> 
> This will happen by default i.e the mirred action will take care of
> buffer management and hopefully the ring device will worry about reusing
> those skbs.
> 
>>Userspace may reinject the skb again by putting it onto the second
>>ring buffer for a kernel thread to pick up and reinject it at
>>netif_receive_skb. Userspace may do whathever it likes as long as
>>the checksum gets corrected, it may also fragment packets and reinject
>>more than it originally received. Obviously for the redirect to
>>userspace the skb must fullfil quite a lot of requirements only
>>achievable on ingress but it would open up possibilities quite a lot.
> 
> 
> One thing the PF_RING device needs is some form of metadata that can be
> passed to user space. PF_PACKET with MMAP has a few, but we need to do a
> lot more such as exposing most if not all of the skb metadata.
> Similarly, the direction from user space will contain details of where
> this packet is going to go (ingress vs egress) - PF_PACKET assumes
> egress only at the moment.

btw I'm going to add mmap() interface for the TUN driver (I need it for other
stuff myself). In which case it seems that it should do pretty much the same
thing that you guys are talking about. i.e. mmap(/dev/net/tun), setup mirroring
to tunX, copy frames in/out of tunX.

Max
