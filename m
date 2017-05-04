From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 06/10] net/ncsi: Ethtool operation to get
 NCSI hw statistics
Date: Wed, 03 May 2017 20:16:43 -0400 (EDT)
Message-ID: <20170503.201643.358209122385716637.davem@davemloft.net>
References: <20170503124722.GE8029@lunn.ch>
        <20170503.091823.747316360571887178.davem@davemloft.net>
        <20170504000534.GA11287@gwshan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org, joe@perches.com,
        kubakici@wp.pl, f.fainelli@gmail.com
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbdEDAQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 20:16:49 -0400
In-Reply-To: <20170504000534.GA11287@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Thu, 4 May 2017 10:05:34 +1000

> On Wed, May 03, 2017 at 09:18:23AM -0400, David Miller wrote:
>>From: Andrew Lunn <andrew@lunn.ch>
>>Date: Wed, 3 May 2017 14:47:22 +0200
>>
>>> On Wed, May 03, 2017 at 02:44:37PM +1000, Gavin Shan wrote:
>>>> This adds ethtool command (ETHTOOL_GNCSISTATS) to retrieve the
>>>> NCSI hardware statistics.
>>> 
>>> Hi Gavin
>>> 
>>> I've not been following this patchset, so maybe i'm about to ask a
>>> question which has already been asked and answered.
>>> 
>>> Why cannot use just use ethtool -S for this?
>>
>>Indeed, when I said to use ethtool for these NCSI hw stats I meant
>>that the "ethtool -S" be used, not some new ethtool command.
>>
> 
> Thanks for the comments. Feel free to ask any questions which would
> make the code clear and better. There are couple of factors I thought
> separate command is better than ETHTOOL_GSTATS: The statistic items from
> ETHTOOL_GSTATS are variable, meaning the kernel needs provide the layout
> of the statistic items via ETHTOOL_GSSET_INFO and ETHTOOL_GSTRINGS.
> NCSI HW statistics aren't following this and their layout is fixed.
> Besides, statistics for ETHTOOL_GSTATS are maintained in local MAC,
> but NCSI HW statistics are collected from NIC on far-end. So they're
> different from this point. Lastly, the NCSI software statistics needs
> separate command. It'd better to have separate command for HW statistics
> as well, to make things consistent.

ETHTOOL_GSTATS are for device specific statistics.  Whether they are
fixed in your implementation or not.
