From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] mv643xx enet update + ethtool support
Date: Thu, 24 Feb 2005 00:02:11 -0500
Message-ID: <421D5FD3.9020107@pobox.com>
References: <20050217224239.GA16609@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Ralf Baechle <ralf@linux-mips.org>,
        Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Dale Farnsworth <dale@farnsworth.org>
In-Reply-To: <20050217224239.GA16609@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> Here is an update to mv643xx ethernet support.  
> There are several small bugfixes.  The two larger issues are
> the beginning of ethtool support and the fact that I've disabled
> hardware tcp/udp checksum generation.  It now looks like there's
> a hardware bug with the checksums, but I'm still characterizing it.
> 
> ChangeSets before 1.2065 are already in -netdev.
> I've included a cumulative patch of the new changesets below.
> 
> Thanks,
> -Dale Farnsworth
> 
> Please do a
> 
> 	bk pull bk://dfarnsworth.bkbits.net/linux-2.5-mv643xx-enet

Pulled.  Two comments:

1) Your descriptions MUST follow the "one line summary" format found in 
other changesets.

When Linus, myself and others use automated tools to summarize a large 
number of changesets, the first line from each changeset description is 
used.  You should include an identifier indicating which area of the 
kernel tree you are modifying ("mv643xx" in this case), and a one-line 
summary of the changeset.  For example, when I check in net driver 
changesets, they look like

	[netdrvr 8139too] fix bugs, whitespace change

	* fix RX error overflow case
	* Update PCI initialization code to better use PCI API
	* trim trailing whitespace (chomp)

For now, I have (with great patience) hand-edited all 30+ changesets to 
fix this up.

See rule #1 of http://linux.yyz.us/patch-format.html.  Even though that 
URL applies to patches, not BitKeeper, the one-line-summary and 
$subsystem portions are applicable to you.


> +void mv643xx_set_ethtool_ops(struct net_device *netdev)
> +{
> +	SET_ETHTOOL_OPS(netdev, &mv643xx_ethtool_ops);
> +}
> +

2) This function should not exist.

	Jeff
