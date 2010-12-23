From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Export ACPI _DSM provided firmware instance number and string name to sysfs
Date: Thu, 23 Dec 2010 08:32:03 -0600
Message-ID: <20101223143203.GA12256@auslistsprd01.us.dell.com>
References: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@vger.kernel.org, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Charles_Rose@Dell.com, Vijay_Nijhawan@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101222170737.GA2428@fedora14-r610.oslab.blr.amer.dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2010 at 08:42:39AM -0800, Narendra_K@Dell.com wrote:
> Hello,
> 
> This patch exports ACPI _DSM provided firmware instance number and
> string name to sysfs.
> 
> Please review -

There are now two different meanings for the 'index' file:

1) SMBIOS-provided "type instance" value, which I've only seen in
   range [1..N] for N devices, monotonically stepwise increasing.

2) ACPI-provided "index" value, which per spec only needs to be a
   "sort key", not starting at 0 or 1, and while monotonically
   increasing, not necessarily stepwise.  It's perfectly valid for the
   values to be (12, 16, 27, 29) if that's convenient for BIOS to
   generate.

Therefore, a consumer of this value (such as biosdevname) must know
which of the two it's dealing with, and either accept the value as-is,
or sort the value list.  While I suppose it could sort the value list
in either case, I'd prefer the ACPI value to be exposed in its own
file, perhaps 'acpi_index', to make this explicit rather than
implicit.

'label' is fine for either case, with ACPI taking priority over
SMBIOS if both happen to be present.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
