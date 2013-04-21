From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 26/28] proc: Supply a function to remove a proc entry by PDE [RFC]
Date: Mon, 22 Apr 2013 00:01:56 +0200
Message-ID: <13676870.MCxoVzgcmR@vostro.rjw.lan>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk> <20130416182734.27773.47452.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-pci@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-acpi@vger.kernel.org, netfilter-devel@vger.kernel.org,
	viro@zeniv.linux.org.uk, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net
To: David Howells <dhowells@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20130416182734.27773.47452.stgit@warthog.procyon.org.uk>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, April 16, 2013 07:27:34 PM David Howells wrote:
> Supply a function (proc_remove()) to remove a proc entry (and any subtree
> rooted there) by proc_dir_entry pointer rather than by name and (optionally)
> root dir entry pointer.  This allows us to eliminate all remaining pde->name
> accesses outside of procfs.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: linux-acpi@vger.kernel.org
> cc: openipmi-developer@lists.sourceforge.net
> cc: devicetree-discuss@lists.ozlabs.org
> cc: linux-pci@vger.kernel.org
> cc: netdev@vger.kernel.org
> cc: netfilter-devel@vger.kernel.org
> cc: alsa-devel@alsa-project.org

The ACPI changes look good to me.

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

> ---
> 
>  drivers/acpi/sbs.c                  |   21 ++++-----------------
>  drivers/char/ipmi/ipmi_msghandler.c |    2 +-
>  drivers/misc/sgi-gru/gruprocfs.c    |    2 +-
>  drivers/of/base.c                   |   11 +----------
>  drivers/pci/proc.c                  |   12 +++---------
>  fs/proc/generic.c                   |    7 +++++++
>  fs/proc/vmcore.c                    |    2 +-
>  include/linux/proc_fs.h             |    2 ++
>  kernel/irq/proc.c                   |    6 +-----
>  net/8021q/vlanproc.c                |    9 ++-------
>  net/core/pktgen.c                   |    6 ++----
>  net/ipv4/netfilter/ipt_CLUSTERIP.c  |    4 ++--
>  net/ipv6/proc.c                     |    3 +--
>  net/netfilter/xt_hashlimit.c        |    4 ++--
>  sound/core/info.c                   |   19 +++++--------------
>  15 files changed, 35 insertions(+), 75 deletions(-)
> 
> diff --git a/drivers/acpi/sbs.c b/drivers/acpi/sbs.c
> index a296e08..b6241ee 100644
> --- a/drivers/acpi/sbs.c
> +++ b/drivers/acpi/sbs.c
> @@ -521,19 +521,6 @@ acpi_sbs_add_fs(struct proc_dir_entry **dir,
>  	return 0;
>  }
>  
> -static void
> -acpi_sbs_remove_fs(struct proc_dir_entry **dir,
> -			   struct proc_dir_entry *parent_dir)
> -{
> -	if (*dir) {
> -		remove_proc_entry(ACPI_SBS_FILE_INFO, *dir);
> -		remove_proc_entry(ACPI_SBS_FILE_STATE, *dir);
> -		remove_proc_entry(ACPI_SBS_FILE_ALARM, *dir);
> -		remove_proc_entry((*dir)->name, parent_dir);
> -		*dir = NULL;
> -	}
> -}
> -
>  /* Smart Battery Interface */
>  static struct proc_dir_entry *acpi_battery_dir = NULL;
>  
> @@ -836,8 +823,8 @@ static void acpi_battery_remove(struct acpi_sbs *sbs, int id)
>  		power_supply_unregister(&battery->bat);
>  	}
>  #ifdef CONFIG_ACPI_PROCFS_POWER
> -	if (battery->proc_entry)
> -		acpi_sbs_remove_fs(&battery->proc_entry, acpi_battery_dir);
> +	proc_remove(battery->proc_entry);
> +	battery->proc_entry = NULL;
>  #endif
>  }
>  
> @@ -873,8 +860,8 @@ static void acpi_charger_remove(struct acpi_sbs *sbs)
>  	if (sbs->charger.dev)
>  		power_supply_unregister(&sbs->charger);
>  #ifdef CONFIG_ACPI_PROCFS_POWER
> -	if (sbs->charger_entry)
> -		acpi_sbs_remove_fs(&sbs->charger_entry, acpi_ac_dir);
> +	proc_remove(sbs->charger_entry);
> +	sbs->charger_entry = NULL;
>  #endif
>  }
>  


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
