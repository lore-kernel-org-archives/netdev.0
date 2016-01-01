From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] net-gianfar: Less function calls in
 gfar_ethflow_to_filer_table() after error detection
Date: Fri, 1 Jan 2016 15:45:15 +0100
Message-ID: <20160101144515.GA2273@electric-eye.fr.zoreil.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <56866F68.6070904@users.sourceforge.net>
 <alpine.DEB.2.02.1601011334200.2054@localhost6.localdomain6>
 <56867607.4090907@users.sourceforge.net>
 <alpine.DEB.2.02.1601011405000.2054@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1601011405000.2054@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia.lawall@lip6.fr> :
> On Fri, 1 Jan 2016, SF Markus Elfring wrote:
[...]
> > > Normally, one returns -ENOMEM for this case, but it looks like this 
> > > function is returning 0 on failure.
> > 
> > Should a symbol like "false" be used instead of such a special number?
> 
> Maybe it's better than 0 and 1...

Your suggestion about -ENOMEM is consistent with the callchain. Nothing
else is needed.

Btw:
1. kfree does not care about NULL parameter, especially in this hardly
   timing sensitive path.
2. kmalloc_array for small kernel controlled arrays of integers (see
   drivers/net/ethernet/freescale/gianfar.h), seriously ?

   I'd suggest the janitor to introduce a dedicated struct to embed both
   gfar_private.ftp_rqf{p, c}r then use a single, plain kmalloc in
   gfar_ethflow_to_filer_table.

Happy tasteful 2016 :o)

-- 
Ueimor
