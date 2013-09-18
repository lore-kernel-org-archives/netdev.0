From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 005/007] WAN Drivers: Update farsync driver and
 introduce fsflex driver
Date: Wed, 18 Sep 2013 16:44:52 +0100
Message-ID: <1379519092.1522.27.camel@bwh-desktop.uk.level5networks.com>
References: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA4@SOLO.hq.farsitecommunications.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	"Dermot Smith" <dermot.smith@farsite.com>
To: Kevin Curtis <Kevin.Curtis@farsite.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E603DC592C92B54A89CEF6B0919A0B1CAAAA787DA4@SOLO.hq.farsitecommunications.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-18 at 11:12 +0100, Kevin Curtis wrote:
> Farsite Communications FarSync driver update
> 
> Patch 5 of 7
> Note that this patch must be applied with patch 4 (farsync_include_patch)
> 
> Update the current farsync driver to support all of the PCI and PCI X
> cards manufactured by Farsite Communications.
> 
> Add a tty interface so that the ports can also be used by the ppp daemon.
> 
> Add support for big endian systems (the FarSite cards have a little endian
> processor on board).
[...]

Should all be separate patches.  This is just doing way too much in one
go.

And there are regressions in here like:

>  static struct pci_driver fst_driver = {
> -        .name          = FST_NAME,
> -        .id_table      = fst_pci_dev_id,
> -        .probe         = fst_add_one,
> -        .remove        = fst_remove_one,
> -        .suspend       = NULL,
> -        .resume        = NULL,
> +name: FST_NAME,
> +id_table : fst_pci_dev_id,
> +probe : fst_add_one,
> +remove : fst_remove_one,
> +suspend : NULL,
> +resume : NULL,
> +};

And the addition of a file in procfs (at the top level, even!) as if
it's still 2001 and sysfs doesn't exist:

> +static int farsync_proc_open(struct inode *inode, struct file *file)
> +{
> +       return single_open(file, fst_proc_info, NULL);
> +}
> +
> +static const struct file_operations farsync_proc_fops = {
> +       .open = farsync_proc_open,
> +       .read = seq_read,
> +       .llseek = seq_lseek,
> +       .release = single_release,
>  };

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
