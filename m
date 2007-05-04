From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH v2] gianfar: Add I/O barriers when touching buffer descriptor ownership.
Date: Fri, 4 May 2007 17:13:09 -0500
Message-ID: <20070504221309.GR6193@austin.ibm.com>
References: <20070502195712.GA16541@ld0162-tx32.am.freescale.net> <F1B250DD-A472-470F-B3D0-EBB2F042E454@kernel.crashing.org> <4638F0C4.2000406@freescale.com> <FA9554A4-5A7D-4E03-BE28-C4B6B80D9DB9@kernel.crashing.org> <4638F734.2040809@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48819 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031524AbXEDWNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 18:13:10 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l44MDAh6001433
	for <netdev@vger.kernel.org>; Fri, 4 May 2007 18:13:10 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l44MDACS174760
	for <netdev@vger.kernel.org>; Fri, 4 May 2007 16:13:10 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l44MD9VJ013339
	for <netdev@vger.kernel.org>; Fri, 4 May 2007 16:13:10 -0600
Content-Disposition: inline
In-Reply-To: <4638F734.2040809@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2007 at 03:40:20PM -0500, Scott Wood wrote:
> 
> Well, Segher doesn't want me to use iobarrier (because it's not I/O). 
> Andy doesn't want me to use wmb() (because it's sync).  I don't think 
> something like gfar_wmb() would be appropriate.  So the remaining 
> options are either eieio(), 

? Just curious... the original intent of eieio was to order I/O, 
such as MMIO; it has no effect on memory that isn't marked 
cache-inhibited or write-trhough or guarded. Has this changed?
I guess I haven't kept up with the times ... is eieio now
being used to provide some other kind of barrier?
Is eieio providing some sort of SMP synchronization side-effect?

Point being: if Segher doesn't let you "use iobarrier (because 
it's not I/O)", then I don't understand why eieio would work (since
that's for io only).  

--linas
