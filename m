From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v5] i40e: Look up MAC address in Open Firmware or IDPROM
Date: Thu, 3 Dec 2015 10:48:23 -0500
Message-ID: <20151203154823.GA23433@oracle.com>
References: <20151104193956.GD14575@oracle.com>
 <CAHp75Vcrx+Rkz2mDSG+GEUW6LdO0w6On=6UoV4fhZK27Ayf1zQ@mail.gmail.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFAEA1A@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
To: netdev <netdev@vger.kernel.org>,
	"Nelson, Shannon" <shannon.nelson@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37566 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbLCPsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 10:48:38 -0500
Content-Disposition: inline
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFAEA1A@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The patch here: http://patchwork.ozlabs.org/patch/540218/
is marked "Awaiting Upstream", I think that means it has to first
show up in some other repo first (which one?)?

On addiitonal testing, we found a bug in the patch: if
we did not find the macaddr from Open Firmwre or IDPROM (i.e., defaults
were ok) then you dont want to be doing i40e_macaddr_init again, else
you will get a failure like this (truncated dump_stack shown
below)

[ 8127.050926] WARNING: CPU: 18 PID: 878 at kernel/irq/manage.c:1346 __free_irq+0x9f/0x230()
[ 8127.050927] Trying to free already-free IRQ 177
  :
[ 8127.051013]  [<ffffffffa043ddd0>] i40e_clear_interrupt_scheme+0xb0/0xc0 [i40e]
[ 8127.051018]  [<ffffffffa044b538>] i40e_probe.part.64+0x1018/0x1320 [i40e]
  :
[ 8127.051057]  [<ffffffffa044b862>] i40e_probe+0x22/0x30 [i40e]

I can think of a couple of ways to fix this- one (the ugly
way) is to ifdef the i40e_macaddr_init invocation for CONFIG_OF or CONFIG_SPARC
only. Another way to solve this is to track some bit in struct i40e_hw that 
indicates that the macaddr is not the default, thus i40e_macaddr_init() should
be called before register_netdev only if that bit is set. (Dont know
if there are cache-line considerations that exist in i40e_hw that
need to be taken into account for the second version)

In order to send a fix out for review, what should I clone? 
should I just apply the patch/540218 to net-next and send the update?

--Sowmini
