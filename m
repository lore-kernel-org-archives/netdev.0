From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH] ehea: Add kdump support
Date: Mon, 26 Nov 2007 12:11:49 -0600
Message-ID: <20071126181148.GF4551@austin.ibm.com>
References: <200711091433.51259.osstklei@de.ibm.com> <1196064988.19855.15.camel@concordia> <1196091697.7513.30.camel@luke-laptop.br.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: michael@ellerman.id.au, Michael Neuling <mikey@neuling.org>,
	Jeff Garzik <jeff@garzik.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Marcus Eder <meder@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	ahuja@austin.ibm.com
To: Luke Browning <lukebr@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55979 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbXKZSMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 13:12:09 -0500
Content-Disposition: inline
In-Reply-To: <1196091697.7513.30.camel@luke-laptop.br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

On Mon, Nov 26, 2007 at 01:41:37PM -0200, Luke Browning wrote:
> On Mon, 2007-11-26 at 19:16 +1100, Michael Ellerman wrote:
> 
> > For kdump we have to assume that the kernel is fundamentally broken,

If I may so humbly suggest: since ehea is a power6 thing only,
we should refocus our energies on "hypervisor assisted dump",
which solves all of these problems. 

In short, upon crash, the hypervisor will reset the 
pci devices into working order, and will then boot
a new fresh kernel into a tiny corner of ram. The rest
of ram is not cleared, and can be dumped. After the 
dump, the mem is returned to general use.

The key point here, for ehea, is "the hypervisor
will reset he device state to something rational".

Preliminary patches are at
http://patchwork.ozlabs.org/linuxppc/patch?id=14884
and following.

--linas
