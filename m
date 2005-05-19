From: jamal <hadi@cyberus.ca>
Subject: Re: igmp snooping?
Date: Wed, 18 May 2005 22:13:43 -0400
Message-ID: <1116468823.6240.34.camel@localhost.localdomain>
References: <OF6CAB3867.F641224F-ON88257006.00079FC5-88257006.00098A9E@us.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF6CAB3867.F641224F-ON88257006.00079FC5-88257006.00098A9E@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-18-05 at 18:44 -0700, David Stevens wrote:
> If you put the interface in multicast promiscuous mode (set flag 
> IFF_ALLMULTI),
> you can receive all hardware groups without joining.
> 
> For IGMP and MLD packets, one way to do that pat in an application is to 
> create
> a raw socket and specify the protocol there. So, to receive all reports
> for any version of IGMP sent to any group, you can create a socket like 
> this:
> 
>         s = socket(PF_INET, SOCK_RAW, IPPROTO_IGMP);
> 
> 
> For MLDv1 and MLDv2 (IPv6), they are part of ICMPv6, but you can use
> ICMPV6_FILTER with the MLD report types to receive only those.
> 
> You can get the receiving interface as ancillary data on a recvmsg()
> call with the IPV6_PKTINFO socket option on Linux systems
> (IPV6_RECVPKTINFO when RFC 3542 compliant) for IPv6 and
> similarly with IP_PKTINFO with IPv4, I believe. You also can get this
> information by restricting the socket to receiving on a particular
> interface, if you don't want one socket to handle multiple interfaces.
> Then, you know which interface by which socket you received on.
> 

Better approach than i proposed.

> So, you should be able to do most, possibly all, of what you want at
> application level without modification to the kernel, if you're looking
> to do this in an application and not a kernel module.

I think it belongs in user space. I would say its probably time that STP
also got moved out. The fact it's in the kernel has hurt addition of
interesting new features.

cheers,
jamal
