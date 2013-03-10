From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: hitting lockdep warning as of too early VF probe with 3.9-rc1
Date: Sun, 10 Mar 2013 09:37:38 -0700
Message-ID: <20130310163738.GC4392@kroah.com>
References: <51360D7C.3060209@mellanox.com>
 <CAJZOPZ+_N53n59cJv00=GXETNhZJUEvgcLEB+D-ujBdSsyvM9g@mail.gmail.com>
 <CACVXFVMcgMzwHrvimn2awQZCPP2m=_npTGap-m7Ru+jdCoqcyA@mail.gmail.com>
 <201303101728.50883.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ming Lei <ming.lei@canonical.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Liran Liss <liranl@mellanox.com>
To: Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:50371 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab3CJQgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 12:36:55 -0400
Received: by mail-da0-f44.google.com with SMTP id z20so562421dae.17
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 09:36:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <201303101728.50883.jackm@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 10, 2013 at 05:28:50PM +0200, Jack Morgenstein wrote:
> Hello, Ming, Greg, Roland, Dave, all...
> 
> From a quick scan of ethernet drivers in Dave Miller's net-next git, I
> notice that the following drivers (apart from the Mellanox mlx4 driver)
> enable SRIOV during the PF probe:
>   cisco enic (function "enic_probe")
>   neterion vxge driver(function "vxge_probe")
>   Solarflare efx driver (function "efx_pci_probe", which invokes "efx_sriov_init")
>   emulex driver (function "be_probe" --> be_setup --> be_vf_setup)
> 
> It would seem that these drivers are susceptible to the nested probe/deadlock
> race condition as well.
> 
> I believe that it is healthiest for everyone if the probe code in the kernel itself
> would avoid such nested probe calls (rather than forcing vendors to deal
> with this issue).  The kernel code is certainly aware
> (or could easily track) that it is invoking the a driver's probe function
> while that same probe function has already been invoked and has not yet returned!

Patches to handle this are always gladly accepted.

thanks,

greg k-h
