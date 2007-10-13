From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: Bonding support for eth1394?
Date: Sat, 13 Oct 2007 09:08:14 +0200
Message-ID: <47106EDE.1090601@s5r6.in-berlin.de>
References: <FFB081ED-646B-489D-8836-FBA619A57E3E@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: Karl Svec <karlsvec@gmail.com>
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
In-Reply-To: <FFB081ED-646B-489D-8836-FBA619A57E3E@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

(Adding Cc: netdev)

Karl Svec wrote to linux1394-devel:
> I'm trying to create a bonded network interface for an Xdmx setup out  
> of a regular ethernet device (sungem) and a firewire ethernet  
> (eth1394) device. However, ifenslave fails on the firewire device,  
> and gives me the following output:
> 
> Master 'bond0' : Error : SIOCBONDENSLAVE failed : Operation not  
> supported
> 
> I'm assuming that this error message means that bonding support is  
> not implemented in the eth1394 driver. If this is the case, I'd like  
> to request that bonding support be added to the eth1394 driver. Is  
> this a reasonable request (i.e. is this something that was left out  
> of the driver because it is difficult to do, or was it left out  
> because nobody anticipated anyone using this feature)?
> 
> I'm happy to do any testing.
> 
> Thanks for your time,

What criteria has a networking driver to fulfill to be interoperable
with the bonding driver?  From a brief look at the top of the files in
linux/drivers/net/bonding/, it appears that it is meant for Ethernet
drivers.

Unlike eth1394's name suggests, it is not Ethernet over FireWire but
IPv4 over FireWire, in a partial implementation of RFC 2734.
http://www.faqs.org/rfcs/rfc2734.html
What is missing to fully support RFC 2734 is multicast capability.
http://lxr.linux.no/source/drivers/ieee1394/eth1394.c#L25

The bonding sources have a few occurrences of EOPNOTSUPP.  Unless I
missed something, they are all related to setting the hardware address
of the interface.  AFAICS this is impossible with IP over FireWire.  If
it is crucial to bonding to be able to change the slaves' hardware
addresses, then you are out of luck.
-- 
Stefan Richter
-=====-=-=== =-=- -==-=
http://arcgraph.de/sr/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
