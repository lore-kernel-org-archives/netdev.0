From: Chris Lightfoot <chris@ex-parrot.com>
Subject: Re: sky2 problems on Intel Mac Mini
Date: Wed, 31 Jan 2007 00:09:37 +0000
Message-ID: <9vX5bgSdy97f.I2iK+nv0AUYsJOXCRbPMsQ@sphinx.mythic-beasts.com>
References: <DJgDe2E/Cvnb.CrmE6+LDxkzqNQTYvzH+WQ@sphinx.mythic-beasts.com> <20070130111520.47e07a79@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wumpus2.mythic-beasts.com ([212.69.38.51]:56120 "EHLO
	wumpus2.mythic-beasts.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbXAaAJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 19:09:41 -0500
Content-Disposition: inline
In-Reply-To: <20070130111520.47e07a79@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 30, 2007 at 11:15:20AM -0800, Stephen Hemminger wrote:
> a) hardware flow control problems
>    look at ethtool -S eth0 statistics, are there flow control packets
>    showing up?

on yeti (machine from which i quoted the first log
output),

[root@yeti /root]# /root/ethtool -S eth0 | grep mac_pause
     tx_mac_pause: 0
     rx_mac_pause: 8649

and on t1 both 0.

But presumably you want to know this at the point of the
failure -- I'll add it to the things the watchdog records
before rebooting.

> b) GMAC or ram buffer issues
>    looking at 'ethtool -d eth0' output can help, but it is a needle in
>    haystack finding these setup errors.
>  
>    The sky2 driver copies most of the stuff from vendor version of sk98lin,
>    but if sk98lin works and sky2 doesn't then comparing register settings
>    can give hints.

ok. I'll try to get one of these machines running the
vendor driver to see whether the problems still occur.

> c) DMA problems
>    For some problems, I have had luck adding a /proc interface and dumping
>    the transmit ring after a hang.  Looking at the last control block that
>    hung can help.  This found the case where IPV6 TSO was leaking through.
> 
> d) checksum problems
>    Turning off tx scatter/gather forces non fragmented skb's. This hurts
>    performance, but can tell if the problem is with fragment code.
>    Turning off tx checksum turns off scatter/gather, checksumming and
>    TSO.

also seems worth trying, though without a test case it'll
take a while to be sure what was causing the problem.

> e) possible alignment and flow control interaction
>    Because the receive DMA engine has hardware bugs and requires alignment
>    or it doesn't work with flow control. I still wonder if there are alignment
>    bugs on Tx with flow control.
> 
> f) other driver bug
> 
> To save time, I'll go get a new Mac Mini and try and clone this setup.
> Could you send me a full kernel config (and other setup information
> like filesystem type, distro etc).

we've seen this on lots of different machines; yeti is
NFS-root, originally ancient Redhat plus lots of
locally-built packages with some bits of the filesystem on
ext3. t1 is Ubuntu (`edgy' I think) on ext3. The same
problems occur on Debian `sarge' and CentOS, though.

What I haven't yet managed to do is to reproduce the
problem -- the test machine on my desk (also NFS-root)
has never exhibited it. But it's mostly idle.

    [...]
> The vendor driver does some slightly different setup, but it also
> does a hardware reset when inactive (every 10ms).

!!!

-- 
``I have a sneaking sympathy for Belgium, as a land where, by accident of
  geography, too often other people have chosen to hold their wars.''
  (Alan Follett)
