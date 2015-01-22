From: Dean Gehnert <deang@tpi.com>
Subject: Re: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO
 path
Date: Thu, 22 Jan 2015 13:27:31 -0800
Message-ID: <54C16B43.5040504@tpi.com>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com> <20150121150159.GS26493@n2100.arm.linux.org.uk> <54C1443C.80909@tpi.com> <20150122210951.GC26493@n2100.arm.linux.org.uk>
Reply-To: deang@tpi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpi.com ([74.45.170.26]:35374 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754227AbbAVV1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 16:27:32 -0500
In-Reply-To: <20150122210951.GC26493@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 01:09 PM, Russell King - ARM Linux wrote:
> On Thu, Jan 22, 2015 at 10:41:00AM -0800, Dean Gehnert wrote:
>> FYI, I found a way to reproduce the mv643xx_eth transmit corruption without
>> using a network filesystem by using SOCAT (should also be able to use NETCAT
>> or NC) and I have a bit more information about the corruption that looks
>> like it is somehow related to the cache line size.
> That's not quite what I'm seeing.  What I'm seeing with NFS is that the
> machine is basically unusable.  I have the etna_viv source in a NFS
> share (it's shared amongst not only the Dove box but also my collection
> of iMX6 based hardware.)
>
> I'm fairly fully IPv6 enabled here, which includes NFS.
>
> On the Dove, if I try to build this without any fixes, and then try to
> build the etna_viv sources, it will take the machine out to the extent
> that I have to reboot it - either the machine will freeze solidly, or
> the kernel will oops in the DMA API functions, in a path which was
> called from an interrupt handler.  That takes out the entire machine
> because we miss acknowleding the interrupt.
I am wondering if there is a possibility of the root cause of this being 
in the arch DMA layer... From my testing with SOCAT and different cache 
line alignments, I am seeing Ethernet 4 byte transmit corruptions. My 
fear is this may not be restricted to the Ethernet transmit and maybe 
the root cause is a DMA / cache issue... I have no way to prove that 
theory. Your DMA API oops is a bit concerning that maybe there is some 
corruption going on during DMA operation.
>
> Either way, it's effectively a power cycle as there's no reset button on
> the machine.
>
> I have yet to see any sign of data corruption.
>
Can you can try the SOCAT test on your Dove platform and see if that 
passes the non-cache line aligned test case? I think what the SOCAT test 
does is take the NFS "variable" out of the equation. My theory is that 
if there is a DMA corruption, then hard telling what kinds of problems 
will occur. It might be the payload of a file is corrupted, or if the 
NFS structures are corrupted, it could manifest itself as a problem in 
the NFS code.
