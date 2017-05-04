From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Thu, 4 May 2017 02:34:52 +0200
Message-ID: <20170504003452.GO8029@lunn.ch>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-7-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503124722.GE8029@lunn.ch>
 <20170503.091823.747316360571887178.davem@davemloft.net>
 <20170504000534.GA11287@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50009 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752514AbdEDAe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 20:34:57 -0400
Content-Disposition: inline
In-Reply-To: <20170504000534.GA11287@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 04, 2017 at 10:05:34AM +1000, Gavin Shan wrote:
> On Wed, May 03, 2017 at 09:18:23AM -0400, David Miller wrote:
> >From: Andrew Lunn <andrew@lunn.ch>
> >Date: Wed, 3 May 2017 14:47:22 +0200
> >
> >> On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
> >>> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
> >>> NCSI hardware statistics.
> >> 
> >> Hi Gavin
> >> 
> >> I've not been following this patchset, so maybe i'm about to ask a
> >> question which has already been asked and answered.
> >> 
> >> Why cannot use just use ethtool -S for this?
> >
> >Indeed, when I said to use ethtool for these NCSI hw stats I meant
> >that the "ethtool -S" be used, not some new ethtool command.
> >
> 
> Thanks for the comments. Feel free to ask any questions which would
> make the code clear and better. There are couple of factors I thought
> separate command is better than ETHTOOL_GSTATS: The statistic items from
> ETHTOOL_GSTATS are variable, meaning the kernel needs provide the layout
> of the statistic items via ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS.
> NCSI HW statistics aren't following this and their layout is fixed.

That does not stop you from using it for a fixed layout. And what
happens when a new version of the standard is released with more
statistics?

> Besides, statistics for ETHTOOL_GSTATS are maintained in local MAC,
> but NCSI HW statistics are collected from NIC on far-end. So they're
> different from this point. 

You might want to take a look at what is happening with Ethernet
switches. Again, we have two sets of statistics for each port on the
switch. We have the statistics from the hardware, and statistics from
the software. Frames that come in one interface and the hardware
forwards out another interface are not seen by the software. But
frames which originate/terminate in the host, or the switch does not
know what to do with and so are passed to the host, are seen by the
software. Mellanox can tell you more. Your local and remote are not
that different.

> Lastly, the NCSI software statistics needs separate command. It'd
> better to have separate command for HW statistics as well, to make
> things consistent.

Are software statistics defined in DSP0222? Since they are software, i
kind of expect you want the flexibility to add more later. The
ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS gives you that flexibility,
without having to change ethtool.

	Andrew
