From: "junk" <junk@toutatis.be>
Subject: Re: ipt_ROUTE and destination MAC address
Date: Fri, 11 Feb 2005 15:17:12 +0100
Message-ID: <20050211140611.M58411@toutatis.be>
References: <S262133AbVBJPBt/20050210150149Z+8411@vger.kernel.org> <20050210141334.M57687@toutatis.be> <Pine.LNX.4.61.0502110100240.13349@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.61.0502110100240.13349@filer.marasystems.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 11 Feb 2005 01:07:55 +0100 (CET), Henrik Nordstrom wrote
> On Thu, 10 Feb 2005, junk wrote:
> 
> > i'm coding a virtual interface. That virtual interface has to receive packets
> > coming on eth0. For that purpose, i'm using ipt_ROUTE. That works great, i can
> > see my packets arriving on red0 (my virtual interface).
> >
> > The problem is that the destination MAC is the one of eth0, so, it seems the
> > kernel doesn't really deliver the packet to my driver. I can see it in tcpdump
> > but my driver receive function is never called.
> 
> It is not due to the destination MAC, but to what ipt_ROUTE does.
> 
> ipt_ROUTE reoutes the packet as if it came in on the other interface,
>  all done at the IP layer in the kernel, it does not resubmit the 
> packet to the driver level.
> 
> The MAC is not modified as this is not relevant to the IP layer, and 
> there really isn't any reason why it should be modified either. The 
> MAC used in received skbufs is the MAC the sending station was 
> addressing the packet to, not the MAC of the receiving interface. 
> Usually they are the same, but not always.
> 
> Can you give an more detailed example of what it is you are trying 
> to accomplish or why you need a custom virtual interface driver? It 
> is possible (or even likely) there is other better tools for the job.
> 
> Also I am a little confused on your virtual interface driver. 
> Normally virtual interface drivers does not have a receive function, 
> only a transmit function called when packets are routed to be 
> transmitted on the interface.. How you make packets arrive at the 
> interface driver is up to you (emulated hardware or whatever).
> 
> Regards 
> Henrik
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" 
> in the body of a message to majordomo@vger.kernel.org More majordomo 
> info at  http://vger.kernel.org/majordomo-info.html


The purpose is to run a redundant network.

My virtual interface has to duplicate packets it receive from software, and
send each copy of it on eth0 and eth1 respectively.

>From the application, there is only one interface: red0.

red0 has to:
- duplicate packets having red0 as outgoing interface (real output iface are
eth0/eth1)
- receive packets from eth0/eth1, discarding the copy (as eth0 and eth1
receive the same data), pass the packet to application
- alert userland if eth0 or eth1 comes down

The problem is that I want my driver to know about incoming packets, not only
the software.
