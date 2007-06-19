From: David Gundersen <gundy@iinet.net.au>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Tue, 19 Jun 2007 20:45:44 +1000
Message-ID: <4677B3D8.1000102@iinet.net.au>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com> <46715FBA.3070302@iinet.net.au> <20070618151430.GE10418@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihug-mail.icp-qv1-irony5.iinet.net.au ([203.59.1.199]:18642
	"EHLO mail-ihug.icp-qv1-irony5.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751939AbXFSKpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 06:45:19 -0400
In-Reply-To: <20070618151430.GE10418@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Out of curiousity, does it work if you just do a single read (ie 
> RTL_R8(TxPoll);) of the register before writing to it?  That would clear 
> things up if it is a PCI posting problem.

Hi Ben,

I tried your suggestion but it didn't seem to make any difference :(

I tried the following combinations:

  - realtek original                          [broken]
  - realtek original with the RTL_R8(TxPoll)
    before RTL_W8(TxPoll, NPQ);               [broken]
  - my patched version without the ndelay
    loop but including the RTL_R8(TxPoll)
    (to see if my messing with the frag logic
     was having any impact)                   [broken]
  - my patched version including the
    ndelay loop                               [full speed transfers]


Also, I'm not sure if I made it clear in my first post, but I'm testing 
these changes on a 8168B (it's built in to my GA-945G-S3 motherboard).

I'm not sure if we can assume that the same change applied to the 8169 
driver would have the same effect on the 8169 too?   (is the 8168 just a 
PCI express version of the [pci] 8169?)


Dave.
