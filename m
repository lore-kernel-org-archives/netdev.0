From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v3 net] i40e: Look up MAC address in Open Firmware or
 IDPROM
Date: Fri, 30 Oct 2015 19:13:01 -0400
Message-ID: <20151030231301.GA14974@oracle.com>
References: <20151030150344.GG9312@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA14@fmsmsx115.amr.corp.intel.com>
 <20151030183645.GD32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACA8F@fmsmsx115.amr.corp.intel.com>
 <20151030192437.GE32759@oracle.com>
 <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"andy.shevchenko@gmail.com" <andy.shevchenko@gmail.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418AFACC2E@fmsmsx115.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (10/30/15 22:03), Nelson, Shannon wrote:
> The more common idiom in our driver would be
> 
> 	err = i40e_get_platform_mac_addr(..);
> 	if (err) {

Ok.

> Have you tested this beyond a compile?
> Do you have a DT model to try this against?

yes.

> In looking at a couple other drivers, I see the difference being that
> they typically are writing the primary mac filter on probe (and any
> other reset), whereas the i40e "knows" that the default mac address is
> already set up as the filter and doesn't bother with a redundant write.
> If you want to add this Open Filter code, you'll need to arrange for
> this write to happen.  You can't call i40e_set_mac() to do it, but you
> can see the i40e_aq_mac_address_write() code there that is involved in
> updating the mac address as an example.  You probably will want to look
> at section 4.2.1.5.3 of the XL710 data sheet in order to know how to
> use i40e_aq_mac_address_write() for your situation.

ok. I'll look into it (and also why this did not show up in my testing).

fwiw, the ixgbe patch is quite clearly missing in i40e, and hopefully
we wont be opportunistically fixing this one driver at a time in 
the future.

--Sowmini
