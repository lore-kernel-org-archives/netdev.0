From: Sam Ravnborg <sam@ravnborg.org>
Subject: Discourage duplicate symbols in the kernel? [Was: Intel I/O Acc...]
Date: Sun, 5 Mar 2006 10:02:52 +0100
Message-ID: <20060305090251.GA9116@mars.ravnborg.org>
References: <20060303214036.11908.10499.stgit@gitlost.site> <4408C2CA.5010909@garzik.org> <41b516cb0603031439n13e4df4cg8e5b21b606d2b4b8@mail.gmail.com> <20060305000933.2d799138.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chris.leech@gmail.com, christopher.leech@intel.com,
	jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752158AbWCEJDZ@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060305000933.2d799138.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 05, 2006 at 12:09:33AM -0800, Andrew Morton wrote:
> > +
> > +static inline u8 read_reg8(struct cb_device *device, unsigned int offset)
> > +{
> > +	return readb(device->reg_base + offset);
> > +}
> 
> These are fairly generic-sounding names.  In fact the as-yet-unmerged tiacx
> wireless driver is already using these, privately to
> drivers/net/wireless/tiacx/pci.c.

Do we in general discourage duplicate symbols even if they are static?

[ppc64, allmodconfig]

$> nm vmlinux | fgrep ' t ' | awk '{print $3}' | sort | uniq -dc
      2 .add_bridge
      2 .base_probe
      2 .c_next
      2 .c_start
      2 .c_stop
      3 .cpu_callback
      2 .default_open
      2 .default_read_file
      2 .default_write_file
      2 .dev_ifsioc
      2 .do_open
      4 .dst_output
      2 .dump_seek
      2 .dump_write
      2 .elf_core_dump
      2 .elf_map
      2 .exact_lock
      2 .exact_match
      2 .exit_elf_binfmt
      2 .fill_note
      2 .fill_prstatus
      2 .fillonedir
      2 .fini
      2 .fixup_one_level_bus_range
      5 .init
      8 .init_once
      3 .iommu_bus_setup_null
      3 .iommu_dev_setup_null
      2 .klist_devices_get
      2 .klist_devices_put
      2 .load_elf_binary
      2 .load_elf_interp
      2 .load_elf_library
      3 .m_next
      3 .m_start
      3 .m_stop
      2 .maydump
      3 .modalias_show
      2 .next_device
      3 .notesize
      2 .padzero
      2 .raw_ioctl
      2 .s_next
      2 .s_show
      2 .s_start
      2 .s_stop
      2 .seq_next
      2 .seq_show
      2 .seq_start
      2 .seq_stop
      2 .set_brk
      2 .setkey
      2 .state_show
      2 .state_store
      2 .store_uevent
      2 .u3_ht_cfg_access
      2 .u3_ht_read_config
      2 .u3_ht_write_config
      2 .writenote
      3 __initcall_init
      2 __setup_netdev_boot_setup
      2 __setup_str_netdev_boot_setup

If I did a make allyesconfig the result looks much more scary.

	Sam
