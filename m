From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Wed, 25 Aug 2010 17:16:46 -0700
Message-ID: <20100825171646.3d40b721@nehalam>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
	<20100812141240.417949e2@s6510>
	<EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
	<20100818144124.33a72453@nehalam>
	<20100819213314.GA26135@auslistsprd01.us.dell.com>
	<20100819145308.0fa08522@nehalam>
	<20100825220323.GA12671@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com, linux-pci@vger.kernel.org
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20100825220323.GA12671@auslistsprd01.us.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Aug 2010 17:03:23 -0500
Matt Domsch <Matt_Domsch@Dell.com> wrote:

> On Thu, Aug 19, 2010 at 02:53:08PM -0700, Stephen Hemminger wrote:
> > On Thu, 19 Aug 2010 16:33:14 -0500
> > Matt Domsch <Matt_Domsch@Dell.com> wrote:
> > 
> > > On Wed, Aug 18, 2010 at 02:41:24PM -0700, Stephen Hemminger wrote:
> > > > The netdev_alias_to_kernelname should only happen after normal lookup failed.
> > > 
> > > Stephen, can you enlighten me as to the "right" way to do interface
> > > name lookups?  While I can still find examples of parsing
> > > /proc/net/dev, or globbing /sys/class/net/*, I expect these aren't the
> > > preferred method anymore.  Your own iproute2 suite uses RTM_GETLINK
> > > netlink calls, though for the seeming simple case of "give me a list of all
> > > interfaces", your path through there is far more capable (and
> > > complex) than I would hope to need.
> > 
> > There is no magic right way. We have to support multiple interfaces.
> > I am really concerned that all this alias stuff will turn into a
> > disaster when there are 10,000 interfaces (Vlans).  The kernel has
> > lots of tables and hashes to handle this but if the utilities
> > are doing a dumb scan of all names it will not work.
> 

Is it really a good idea to have to change every utility that could
alter network devices?  There is iproute2, iputils, tcpdump, wireshark,
quagga, snmp, ...  Many of the utilities come from a BSD world,
and will be less likely to accept some Linux specific wart.

I have lost faith in this library wrapper support everywhere method.
Let's just keep the firmware stuff in udev. If the user wants to
have a policy that renames device from eth0 to "Embedded BIOS LAN1" then
do it in udev. Or if you want to keep the ethX naming convention
and stuff the firmware label into ifAlias or other sysfs field
so it can be displayed that will be not a big issue.
