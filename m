From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Use firmware provided index to register a network
 interface
Date: Wed, 22 Sep 2010 15:16:45 -0700
Message-ID: <20100922151645.649d3d7a@nehalam>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>
	<4C9A7E39.2020304@buttersideup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Narendra K <Narendra_K@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	matt_domsch@dell.com, charles_rose@dell.com,
	jordan_hargrave@dell.com, vijay_nijhawan@dell.com
To: Tim Small <tim@buttersideup.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4C9A7E39.2020304@buttersideup.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2010 23:07:53 +0100
Tim Small <tim@buttersideup.com> wrote:

> Narendra K wrote:
> > Hello,
> >
> > Here is another approach to address the issue of "eth0 does not always
> > map to the Integrated NIC Port 1 as denoted on server chassis label".
> > For more details please refer to the thread -
> > http://marc.info/?l=linux-netdev&m=128163454631618&w=3.
> >   
> 
> 
> Hi,
> 
> Out of interest, that link says that doing it in usespace was rejected,
> but doesn't give any references... I'd be interested to know why this
> wasn't viable - since this seemed like the best fit at first glance -
> most people will never use this, so no need to grow their kernel size
> and complexity?
> 

This proposal was to ad changes into every application that
knows about network names (iproute, iptables, snmp, quagga, openswan, ...)
to do aliasing at the application layer.

I rejected it as an unmanageable since it would require changes to so
many packages (many of which are more BSD focused). Also doing aliasing
would lead to security and other issues. For example, if you write a
iptables rule based on the "Embedded NIC 1" rule would it work and know
when the packet name lookup returned eth0, or what about device names
in the Quagga RIB, ...
