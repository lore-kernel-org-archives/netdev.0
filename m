From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge error; hangs w/ hardware memory hole
Date: Fri, 7 Jul 2006 14:18:43 -0700
Message-ID: <20060707141843.73fc6188@dxpl.pdx.osdl.net>
References: <20060703205238.GA10851@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	341801@bugs.debian.org, asd@suespammers.org, kevin@sysexperts.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60043 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932286AbWGGVTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 17:19:01 -0400
To: Martin Michlmayr <tbm@cyrius.com>, Andi Kleen <ak@suse.de>
In-Reply-To: <20060703205238.GA10851@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Jul 2006 22:52:38 +0200
Martin Michlmayr <tbm@cyrius.com> wrote:

> We received the following bug report at http://bugs.debian.org/341801
> 
> | I have a Asus A8V with 4GB of RAM. When I turn on the hardware memory
> | hole in the BIOS, the skge driver prints out this message:
> |       skge hardware error detected (status 0xc00)
> | and then does not work. Setting debug=16 doesn't really show anything.
> 
> Another users confirms this bug, saying:
> 
> | I'm running kernel 2.6.15-1-amd64-generic version 2.6.15-6, and see
> | the very same thing.
> | So I have to turn off the memory remapping feature that allows the
> | system to see all 4 gig of memory, and thus lose the use of about 200
> | megabytes of memory.
> | Hardware: ASUS A8V Deluxe, 4G RAM, Athlon 64 3200+ CPU.
> 
> This problem has probably been there forever and also happens with the
> sk98lin driver:
> 
> | With sk98lin under both 2.6.12 and 2.6.17 I get the following message,
> | repeated countless times, and finally a hang: [this is copied from
> | screen on to a sheet a paper and re-typed, beware typos]:
> 
> | eth0: Adapter failed
> | eth0: -- ERROR --
> | class: Hardware failure
> | Nr: 0x264
> | Msg: unexpected IRQ Status error
> 
> The bug is still present in 2.6.17 -mm6:
> 
> | -mm6 does not work with skge and the hardware memory hole. It gave
> | these messages:
> 
> | skge eth0: enabling interface
> | skge 0000:00:0a.0: PCI error cmd=0x117 status=0x22b0
> | skge unable to clear error (so ignoring them)
> | skge eth0: Link is up at 1000 Mbps, full duplex, flow control tx and rx
> 
> | DHCP never managed to get an IP address.
> 
> Any idea what to do about this?

I don't really have access to the hardware, or know the x86-64 details perhaps Andi Kleen 
would be of more help. But my suspicion is that the remapping doesn't work for i/o devices
because of hardware or BIOS.  One simple workaround is to force use of the I/O mmu on
the amd64 processor. This has a small performance impact (requires more setup).

See Documentation/x86_64/boot-options.txt iommu=force

-- 
Stephen Hemminger <shemminger@osdl.org>
Quis custodiet ipsos custodes?
