From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: 07 Sep 2004 17:53:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094593729.1079.32.camel@jzny.localdomain>
References: <20040907120532.GB25051@wotan.suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040907120532.GB25051@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-07 at 08:05, Andi Kleen wrote:
> New version of the NETIF_F_LLTX for network devices patch. 
> 
> This allows network drivers to set the NETIF_F_LLTX flag

> The drivers can use try lock if they want and return -1
> when the lock wasn't grabbed. In this case the packet
> will be requeued. For better compatibility this is only
> done for drivers with LLTX set, others don't give a special
> meaning to -1.

Are you reinventing the rules or changing them?

hard_start_xmit() return codes are intepreted as follows:

0: typically means the packet was put in the ring. 
It is being abused by a few drivers to mean a retry depending on the
device state (which while may work results in a longer code path). 
1: means packet was not put on the ring. i.e if you return
1, the toplayer will retry later with the same skb. 
[of course If you stash it on the ring, the danger is tx complete will
try to free it later while the toplayer code is still referencing it. A
good oops].


cheers,
jamal
