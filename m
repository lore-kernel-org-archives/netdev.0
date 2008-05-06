From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/5] IPv6 to Intel EtherExpress 16 fails - multicast problems
Date: Tue, 06 May 2008 12:23:11 -0400
Message-ID: <482085EF.1040005@garzik.org>
References: <200805022040.m42KesxY013686@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bns_robson@hotmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41404 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbYEFQXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:23:14 -0400
In-Reply-To: <200805022040.m42KesxY013686@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Bruce Robson <bns_robson@hotmail.com>
> 
> Taken from http://bugzilla.kernel.org/show_bug.cgi?id=10577
> 
> I was unable to access a computer containing an Intel EtherExpress 16 network
> card using IPv6.
> 
> I traced this to failure of neighbour discovery.  When I used an "ip -6 neigh
> add" command, on the computer attempting access, to insert a binding between
> the IPv6 address of the computer with the Intel EtherExpress 16 network card
> and the card's ethernet address, I was able to access that computer using
> IPv6.
> 
> Neighbour discovery requires working multicast.  The driver sources file
> eexpress.c contains an approximately 30 line function eexp_setup_filter used
> when loading multicast addresses.
> 
> I found 3 problems in this function
> 
> 1) It wrote the number of multicast addresses to the card instead of the
>     number of bytes in the multicast addresses.
> 
> 2) When loading multiple multicast addresses it loaded the first one
>     provided multiple times instead of loading each one once.
> 
> 3) The setting of pointer 'data' from 'dmi->dmi_addr' occured before the
>     test for the error situation of 'dmi' being NULL.
> 
> Correcting these problems allows the computer with the Intel EtherExpress 16
> network card to found by IPv6 neighbour discovery.
> 
> p.s. There is some information on the Intel EtherExpress 16 at
> http://www.intel.com/support/etherexpress/vintage/sb/cs-013500.htm
> Datasheet for the Intel 82586 ethernet controller used by the card
> http://www.datasheetcatalog.com/datasheets_pdf/8/2/5/8/82586.shtml
> 
> Signed-off-by: Bruce Robson <bns_robson@hotmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/eexpress.c |   11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)

applied


