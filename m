From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet
 Bridging: Enable Hardware Checksumming)
Date: Mon, 23 May 2005 12:40:17 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505231226160.20838@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
 <20050519214015.GA19961@us.ibm.com> <Pine.LNX.4.62.0505200858480.12681@webhosting.rdsbv.ro>
 <200505201354.46824.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200505201354.46824.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Let's use the full BR_FEAT_MASK of NETIF_F_HW_CSUM | NETIF_F_SG |
> | NETIF_F_FRAGLIST | NETIF_F_IP_CSUM | NETIF_F_HIGHDMA | NETIF_F_TSO).
> That is 0011 0000 0110 1011
>
> Now, let's assume that the NIC only has NETIF_F_TSO,
> NETIF_F_IP_CSUM, and NETIF_F_SG enabled.
> So, that is 0000 1000 0000 0011
>
> So, we have the following:
> For the first adapter added:
> br = 0001 1000 0110 1011
> br = 0001 1000 0110 1011 & 0000 1000 0000 0011 | ~0001 1000 0110 1011
> br = 0001 1000 0110 1011 & 0000 1000 0000 0011 | 1110 0111 1001 0100
> br = 0000 1000 0000 0011 | 1110 0111 1001 0100
> br = 1110 1111 1001 0111
> Note - this breaks down to the following being enabled:
> NETIF_F_SG
> NETIF_F_IP_CSUM
> NETIF_F_NO_CSUM
> UNDEFINED BIT
> NETIF_F_HW_VLAN_RX
> NETIF_F_HW_VLAN_FILTER
> NETIF_F_VLAN_CHALLENGED
> NETIF_F_TSO
> NETIF_F_LLTX
[...]
> Thanks,
> Jon

The code applies the ~ first, then the | and _then_ the &.
If we have:
a &= a | ~b;
it is equivalent with:
a = a & (a | ~b);

For your example:
br   = 0001 1000 0110 1011 = 0x186B
feat = 0001 1000 0110 1011 = 0x186B
nic  = 0000 1000 0000 0011 = 0x0803
br &= nic | ~feat
br = 0x803 - I say this is correct!

With the second nic:

br = 0x0803
feat = 0x186B
nic2 = 0x0803
br &= nic2 | ~feat;
br = 0x0803 - I say it's correct

Am I missing something?
---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
