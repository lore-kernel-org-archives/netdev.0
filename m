From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: skb_pull_rcsum - Fatal exception in interrupt
Date: Mon, 20 Aug 2007 09:21:54 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52032A44D8@orsmsx418.amr.corp.intel.com>
References: <18115.5803.588114.372952@wylie.me.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>,
	"Linux Network Development list" <netdev@vger.kernel.org>
To: "Alan J. Wylie" <alan@wylie.me.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41102 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758087AbXHTQV5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 12:21:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <18115.5803.588114.372952@wylie.me.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan J. Wylie wrote:
> We have been shipping Linux based servers to customers for several
> years now, with few problems. Recently, however, a single customer has
> been seeing kernel panics. Unfortunately, the customer is about 200
> miles away, so physical access is limited. There are two ethernet
> interfaces, one should be plugged into a local RFC1918 network, the
> other is connected to the internet. If eth0 is plugged into the local
> network, a short time later the system panics.
> 
> Hardware: Intel S5000VSA server
> 
> Network cards: Intel e1000
>    Intel Corporation 80003ES2LAN Gigabit Ethernet Controller (Copper)

Hi Alan, I work on the team that supports e1000, I'd be interested in
seeing the dmesg output from the machine before it crashes, maybe you
can add that to your web collection of data below?

many of the 5000 series machines have BMC's its possible that you could
set up the remote management so you could reboot it remotely, but that
may not be worth the extra effort.  It could however give you the
ability to have a serial console over ethernet, which would get us the
full panic message, but see below.

> # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
can you try setting the CONFIG_E1000_DISABLE_PACKET_SPLIT=y

this will prevent the driver from splitting the header from the packet
data which could be exacerbating this problem.

Its not immediately obvious whether this is a kernel or driver problem,
I hope you don't mind I cc'd e1000-devel since this is possibly relevant
to other e1000 users and developers.
 
> We shipped a second system, and this displayed identical symptoms.  We
> have tested with several recent 2.6 kernels, including
> 
> 2.6.22
> 2.6.17.14
> 2.6.20.15
> 
> all of which crash.
> 
> We have a couple of photographs showing the tail end of the messages
> on the screen.
> 
> The last two lines are:
> 
> EIP: [<c02b6fb2>] skb_pull_rcsum+0x6d/0x71 SS:ESP 09068:c03e1ea4
> Kernel panic - not syncing: Fatal exception in interrupt

can you boot with vga=0x318 appended to kernel options? this might help
you get more on the screen.   you could also look into netconsole, but
because this is a networking crash I don't know if you'll get data out
of netconsole or not, and I don't know if you can use netconsole over
the 'net' as I've only used it for local logging.

Jesse
