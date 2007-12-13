From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc5-mm1
Date: Thu, 13 Dec 2007 09:45:54 -0800 (PST)
Message-ID: <20071213.094554.136920553.davem@davemloft.net>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org>
	<47613F18.6080601@bull.net>
	<4761494E.1050704@bull.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pierre.peiffer@bull.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34483
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754817AbXLMRpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 12:45:55 -0500
In-Reply-To: <4761494E.1050704@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Thu, 13 Dec 2007 16:01:34 +0100

> The problem comes from the new macro UDPX_INC_STATS_BH introduced
> by Herbert, which was a nice addition to increment the correct 
> UDP MIB depending on the socket family, but unfortunately 
> the use of this macro from kernel code (I mean code not compiled 
> as module) requires that IPv6 is also compiled in kernel 
> (CONFIG_IPv6=y) in order to have udp_stats_in6 defined at link 
> time.

Herbert, please take a look at this, thanks!

> Benjamin
> 
> Pierre Peiffer wrote:
> > Hi,
> > 
> > 	My config does not link any more:
> > 
> > ...
> >   CHK     include/linux/compile.h
> >   UPD     include/linux/compile.h
> >   CC      init/version.o
> >   LD      init/built-in.o
> >   LD      .tmp_vmlinux1
> > net/built-in.o: In function `xs_udp_data_ready':
> > /home/peifferp/containers/kernel/linux-2.6.24-rc5-mm1/net/sunrpc/xprtsock.c:842:
> > undefined reference to `udp_stats_in6'
> > /home/peifferp/containers/kernel/linux-2.6.24-rc5-mm1/net/sunrpc/xprtsock.c:846:
> > undefined reference to `udp_stats_in6'
> > make[1]: *** [.tmp_vmlinux1] Error 1
> > make: *** [sub-make] Error 2
> > 
> > After a first look, udp_stats_in6 seems to be defined in ipv6 (file
> > net/ipv6/udp.c) but I have
> > 
> > CONFIG_IPV6=m
> > and
> > CONFIG_SUNRPC=y
> > 
> > So, SUNRPC uses something defined in a module in my case ?
> > 
> > ... looking more, this dependency seems to have been introduced by the patch
> > [UDP]: Restore missing inDatagrams increments
> > ( http://thread.gmane.org/gmane.linux.network/79716/focus=79831 )
> > 
> > (I cc netdev)
> > 
> > I don't know what is the right way to fix this ... ?
> > 
> > P.
> > Andrew Morton wrote:
> >> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc5/2.6.24-rc5-mm1/
> >>
> >> - If something goes wrong with a PCI device's probing or initialisation, try
> >>   reverting pci-disable-decoding-during-sizing-of-bars.patch.
> >>
> >> - git-sched was dropped due to breaking suspend-to-RAM.
> >>
> >> - git-block has been restored after having had a few problems
> >>
> >> - git-newsetup.patch was dropped due to conflicts with git-x86
> >>
> >> - git-perfmon.patch is still dropped for the same reason
> >>
> >> - git-kgdb.patch is still dropped for the same reason
> >>
> >> - Please do try to cc the correct developer and mailing list when
> >>   reporting problems - I'm just buried in bugs over here.
> >>
> >>
> >>
> >> Boilerplate:
> >>
> >> - See the `hot-fixes' directory for any important updates to this patchset.
> >>
> >> - To fetch an -mm tree using git, use (for example)
> >>
> >>   git-fetch git://git.kernel.org/pub/scm/linux/kernel/git/smurf/linux-trees.git tag v2.6.16-rc2-mm1
> >>   git-checkout -b local-v2.6.16-rc2-mm1 v2.6.16-rc2-mm1
> >>
> >> - -mm kernel commit activity can be reviewed by subscribing to the
> >>   mm-commits mailing list.
> >>
> >>         echo "subscribe mm-commits" | mail majordomo@vger.kernel.org
> >>
> >> - If you hit a bug in -mm and it is not obvious which patch caused it, it is
> >>   most valuable if you can perform a bisection search to identify which patch
> >>   introduced the bug.  Instructions for this process are at
> >>
> >>         http://www.zip.com.au/~akpm/linux/patches/stuff/bisecting-mm-trees.txt
> >>
> >>   But beware that this process takes some time (around ten rebuilds and
> >>   reboots), so consider reporting the bug first and if we cannot immediately
> >>   identify the faulty patch, then perform the bisection search.
> >>
> >> - When reporting bugs, please try to Cc: the relevant maintainer and mailing
> >>   list on any email.
> >>
> >> - When reporting bugs in this kernel via email, please also rewrite the
> >>   email Subject: in some manner to reflect the nature of the bug.  Some
> >>   developers filter by Subject: when looking for messages to read.
> >>
> >> - Occasional snapshots of the -mm lineup are uploaded to
> >>   ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/ and are announced on
> >>   the mm-commits list.  These probably are at least compilable.
> >>
> >> - More-than-daily -mm snapshots may be found at
> >>   http://userweb.kernel.org/~akpm/mmotm/.  These are almost certainly not
> >>   compileable.
> >>
> >>
> >>
> >> Changes since 2.6.24-rc4-mm1:
> >>
> >>
> >>  origin.patch
> >>  git-acpi.patch
> >>  git-alsa.patch
> >>  git-agpgart.patch
> >>  git-arm.patch
> >>  git-arm-master.patch
> >>  git-avr32.patch
> >>  git-cpufreq.patch
> >>  git-powerpc.patch
> >>  git-drm.patch
> >>  git-dvb.patch
> >>  git-hwmon.patch
> >>  git-gfs2-nmw.patch
> >>  git-hid.patch
> >>  git-hrt.patch
> >>  git-ieee1394.patch
> >>  git-infiniband.patch
> >>  git-input.patch
> >>  git-jfs.patch
> >>  git-kbuild.patch
> >>  git-kvm.patch
> >>  git-lblnet.patch
> >>  git-leds.patch
> >>  git-libata-all.patch
> >>  git-md-accel.patch
> >>  git-mips.patch
> >>  git-mmc.patch
> >>  git-mtd.patch
> >>  git-ubi.patch
> >>  git-net.patch
> >>  git-netdev-all.patch
> >>  git-battery.patch
> >>  git-nfs.patch
> >>  git-nfsd.patch
> >>  git-ocfs2.patch
> >>  git-s390.patch
> >>  git-sh.patch
> >>  git-scsi-misc.patch
> >>  git-scsi-rc-fixes.patch
> >>  git-block.patch
> >>  git-unionfs.patch
> >>  git-v9fs.patch
> >>  git-watchdog.patch
> >>  git-wireless.patch
> >>  git-ipwireless_cs.patch
> >>  git-x86.patch
> >>  git-xfs.patch
> >>  git-cryptodev.patch
> >>  git-xtensa.patch
> >>
> >>  git trees
> >>
> >> -aio-only-account-i-o-wait-time-in-read_events-if-there-are-active-requests.patch
> >> -fix-cloneclone_newpid.patch
> >> -rtc-assure-proper-memory-ordering-with-respect-to-rtc_dev_busy-flag.patch
> >> -ufs-fix-nexstep-dir-block-size.patch
> >> -ufs-fix-nexstep-dir-block-size-checkpatch-fixes.patch
> >> -aoe-properly-initialise-the-request_queues-backing_dev_info.patch
> >> -mm-backing-devc-fix-percpu_counter_destroy-call-bug-in-bdi_init.patch
> >> -add-export_symbolksize.patch
> >> -spi-use-mutex-not-semaphore.patch
> >> -spi-at25-driver-is-for-eeprom-not-flash.patch
> >> -spi-simplify-spi_sync-calling-convention.patch
> >> -spi-use-simplified-spi_sync-calling-convention.patch
> >> -spi-initial-bf54x-spi-support.patch
> >> -spi-bfin-spi-uses-portmux-calls.patch
> >> -spi-spi_bfin-cleanups-error-handling.patch
> >> -spi-spi_bfin-handles-spi_transfercs_change.patch
> >> -spi-spi_bfin-dont-bypass-spi-framework.patch
> >> -spi-spi_bfin-uses-platform-device-resources.patch
> >> -spi-spi_bfin-uses-portmux-for-additional-busses.patch
> >> -spi-spi_bfin-rearrange-portmux-calls.patch
> >> -spi-spi_bfin-change-handling-of-communication-parameters.patch
> >> -spi-spi_bfin-relocate-spin-waits.patch
> >> -spi-spi_bfin-handle-multiple-spi_masters.patch
> >> -spi-spi_bfin-bugfix-for-816-bit-word-sizes.patch
> >> -spi-spi_bfin-update-handling-of-delay-after-deselect.patch
> >> -spi-spi_bfin-resequence-dma-start-stop.patch
> >> -blackfin-spi-driver-use-cpu_relax-to-replace-continue-in-while-busywait.patch
> >> -blackfin-spi-driver-use-void-__iomem-for-regs_base.patch
> >> -blackfin-spi-driver-move-hard-coded-pin_req-to-board-file.patch
> >> -blackfin-spi-driver-reconfigure-speed_hz-and-bits_per_word-in-each-spi-transfer.patch
> >> -avoid-potential-null-dereference-in-unregister_sysctl_table.patch
> >> -gpio_cs5535-disable-aux-on-output.patch
> >> -mm-fix-xip-file-writes.patch
> >> -revert-dpt_i2o-convert-to-scsi-hotplug-model.patch
> >> -jbd-fix-assertion-failure-in-fs-jbd-checkpointc.patch
> >> -proc-fix-pde-refcounting.patch
> >> -powerpc-invalid-size-for-swapper_pg_dir-with-config_pte_64bit=y.patch
> >> -gregkh-driver-kset-add-kset_create_and_register-function.patch
> >> -gregkh-driver-kobject-add-kobject_create_and_register-function.patch
> >> -gregkh-driver-kset-convert-pci-hotplug-to-use-kset_create_and_register.patch
> >> -gregkh-driver-kset-convert-drivers-base-busc-kset_create_and_register.patch
> >> -gregkh-driver-kset-convert-drivers-base-classc-kset_create_and_register.patch
> >> -gregkh-driver-kset-convert-drivers-base-firmwarec-kset_create_and_register.patch
> >> -gregkh-driver-driver-core-remove-owner-field-from-struct-bus_type.patch
> >> -gregkh-driver-driver-core-add-way-to-get-to-bus-kset.patch
> >> -gregkh-driver-driver-core-add-way-to-get-to-bus-device-klist.patch
> >> -gregkh-driver-driver-core-remove-fields-from-struct-bus_type.patch
> >> -gregkh-driver-kobject-convert-hvc_console-to-use-kref-not-kobject.patch
> >> -gregkh-driver-kobject-convert-hvcs-to-use-kref-not-kobject.patch
> >> -gregkh-driver-kobject-fix-up-kobject_set_name-to-use-kvasprintf.patch
> >> -gregkh-driver-kobject-add-kobject_init_ng-kobject_add_ng-and-kobject_init_and_add-functions.patch
> >> -gregkh-driver-driver-core-move-the-driver-specific-module-code-into-the-driver-core-fix.patch
> >> -remove-saa7134-oss.patch
> >> -jdelvare-i2c-i2c-delete-old-documentation.patch
> >> -jdelvare-i2c-i2c-gpio-set-hwmon-class.patch
> >> -jdelvare-i2c-i2c-add-missing-space.patch
> >> -rename-_bss-to-__bss_start.patch
> >> -ia64-efi-make-full-use-of-macro-efi_md_size.patch
> >> -ads7846-stop-updating-dev-powerpower_state.patch
> >> -remove-trailing-nuls-from-network-bonding-sysfs-interface.patch
> >> -net-bonding-return-nothing-for-not-applicable-values.patch
> >> -net-bonding-purely-cosmetic-rename-a-local-variable.patch
> >> -git-watchdog-hpwdt-build-fix.patch
> >> -iwlwifi-3945-fix-race-conditional-panic.patch
> >> -iwlwifi-4965-fix-race-conditional-panic.patch
> >> -bcm43xx_debugfs-sscanf-fix.patch
> >> -arch-xtensa-remove-duplicate-includes.patch
> >> -xtensa-kernel-setupc-remove-dead-code.patch
> >> -ia64-increase-datapatch-offset.patch
> >> -ia64-dont-assume-that-unwcheckpy-is-executable.patch
> >> -ia64-export-copy_page-to-modules.patch
> >> -add-mike-christie-to-maintainers.patch
> >> -scsi-early-detection-of-medium-not-present-updated.patch
> >> -slubs-ksize-fails-for-size-2048.patch
> >> -vm-security-add-security-hook-to-do_brk.patch
> >> -mm-sparsec-check-the-return-value-of-sparse_index_alloc.patch
> >> -mm-sparsec-improve-the-error-handling-for-sparse_add_one_section.patch
> >> -pie-executable-randomization.patch
> >> -pie-executable-randomization-uninlining.patch
> >> -pie-executable-randomization-checkpatch-fixes.patch
> >>
> >>  Merged into mainline or a subsystem tree
> >>
> >> +revert-hibernation-use-temporary-page-tables-for-kernel-text-mapping-on-x86_64.patch
> >> +uml-stop-gdb-from-deleting-breakpoints-when-running-uml.patch
> >> +alpha-strncpy-strncat-fixes.patch
> >> +rtc-at32ap700x-fix-irq-init-oops.patch
> >> +parport-dev-timeslice-is-an-unsigned-long-not-an-int.patch
> >> +ecryptfs-initialize-new-auth_tokens-before-teardown.patch
> >> +knfsd-change-mailing-list-for-nfsd-in-maintainers.patch
> >> +fix-lguest-documentation.patch
> >> +sparsemem-make-sparsemem_vmemmap-selectable.patch
> >> +fs-kconfig-grammar-fix.patch
> >> +ext3-ext4-avoid-divide-by-zero.patch
> >> +alpha-build-fixes.patch
> >>
> >>  2.6.24 queue
> >>
> >> +timerfd-v3-new-timerfd-api-s390-fix.patch
> >> +timerfd-v3-new-timerfd-api-sparc64-fix.patch
> >>
> >>  Fix timerfd-v3-new-timerfd-api.patch a ridiculous number of times.
> >>
> >> +git-acpi-build-fix.patch
> >>
> >>  Fix git-acpi.patch more.
> >>
> >> +acpi-remove-duplicated-warning-message.patch
> >> +acpi_pci_irq_find_prt_entry-use-list_for_each_entry-instead-of-list_for_each.patch
> >>
> >>  ACPI things
> >>
> >> +alsa-nopage.patch
> >> +alsa-usx2y-nopage.patch
> >>
> >>  ALSA things
> >>
> >> -git-avr32-fixup.patch
> >>
> >>  Unneeded
> >>
> >> +agk-dm-dm-crypt-use-bio_add_page.patch
> >> +agk-dm-dm-convert-suspend_lock-semaphore-to-mutex.patch
> >> +agk-dm-dm-snapshot-combine-consecutive-exceptions-in-memory.patch
> >>
> >>  DM updates
> >>
> >> +powerpc-dont-cast-a-pointer-to-pointer-of-list_head.patch
> >> +arch-powerpc-add-missing-of_node_put.patch
> >> +arch-powerpc-platforms-cell-cbe_regsc-add-missing-of_node_put.patch
> >>
> >>  powerpc stuff
> >>
> >> +gregkh-driver-kobject-fix-the-documentation-of-how-kobject_set_name-works.patch
> >> +gregkh-driver-kobject-convert-ibmasm-to-use-kref-not-kobject.patch
> >> +gregkh-driver-kobject-convert-hvc_console-to-use-kref-not-kobject.patch
> >> +gregkh-driver-kobject-convert-hvcs-to-use-kref-not-kobject.patch
> >> +gregkh-driver-kobject-convert-icom-to-use-kref-not-kobject.patch
> >> +gregkh-driver-kobject-fix-up-kobject_set_name-to-use-kvasprintf.patch
> >> +gregkh-driver-kobject-make-kobject_cleanup-be-static.patch
> >> +gregkh-driver-kobject-add-kobject_init_ng-function.patch
> >> +gregkh-driver-kobject-add-kobject_add_ng-function.patch
> >> +gregkh-driver-kobject-add-kobject_init_and_add-function.patch
> >> +gregkh-driver-kset-add-kset_create_and_add-function.patch
> >> +gregkh-driver-kobject-add-kobject_create_and_add-function.patch
> >> +gregkh-driver-kset-convert-pci-hotplug-to-use-kset_create_and_add.patch
> >> +gregkh-driver-kset-convert-drivers-base-busc-to-use-kset_create.patch
> >> +gregkh-driver-kset-convert-drivers-base-classc-to-use-kset_create.patch
> >> +gregkh-driver-kset-convert-drivers-base-firmwarec-to-use-kset_create.patch
> >> +gregkh-driver-uio-fix-kobject-usage.patch
> >> +gregkh-driver-driver-core-remove-owner-field-from-struct-bus_type.patch
> >> +gregkh-driver-driver-core-add-way-to-get-to-bus-kset.patch
> >> +gregkh-driver-driver-core-add-way-to-get-to-bus-device-klist.patch
> >> +gregkh-driver-driver-core-remove-fields-from-struct-bus_type.patch
> >> +gregkh-driver-driver-core-introduce-default-attribute-groups.patch
> >> +gregkh-driver-netiucv-use-device_driver-default-attribute-groups.patch
> >> +gregkh-driver-zfcp-use-device_driver-default-attribute-groups.patch
> >> +gregkh-driver-infiniband-make-ipath-driver-use-default-driver-groups.patch
> >>
> >>  Driver tree updates
> >>
> >> +revert-gregkh-driver-pm-acquire-device-locks-prior-to-suspending.patch
> >>
> >>  Fix it.
> >>
> >> -driver-tree-broke-infiniband.patch
> >>
> >>  Unneeded
> >>
> >> +drm-dont-cast-a-pointer-to-pointer-of-list_head.patch
> >>
> >>  DRM cleanup
> >>
> >> +git-dvb-fix-build-in-drivers-media-dvb-frontends-tda18271h.patch
> >> +git-dvb-one-videobuf_read_start-is-enough.patch
> >> +git-dvb-drivers-media-dvb-frontends-zl10353c-avoid-64-bit-divide.patch
> >> +git-dvb-drivers-media-video-et61x251-et61x251_corec-fix-warnings.patch
> >>
> >>  Fix git-dvb
> >>
> >> +media-video-usbvision-add-mutex_unlock-to-error-paths.patch
> >> +media-video-usbvision-add-mutex_unlock-to-error-paths-fix.patch
> >> +media-video-usbvision-remove-ctrlurblock.patch
> >>
> >>  DVB things
> >>
> >> +jdelvare-i2c-i2c-deprecate-video-bus-drivers.patch
> >> +jdelvare-i2c-i2c-drop-redundant-client-usage-count.patch
> >> +jdelvare-i2c-i2c-change-refcounting-prototypes.patch
> >> +jdelvare-i2c-i2c-remove-redundant-i2c_adapter-list.patch
> >> +jdelvare-i2c-i2c-remove-redundant-i2c_driver-list.patch
> >> +jdelvare-i2c-i2c-core-rename-lock.patch
> >>
> >>  I2C tree updates
> >>
> >> +i2c-fix-drivers-media-video-bt866c.patch
> >>
> >>  Fix it.
> >>
> >> +applesmc-sensors-set-for-macbook2-try-2.patch
> >>
> >>  Update applesmc-sensors-set-for-macbook2.patch
> >>
> >> +gfs2-avoid-64-bit-divide.patch
> >>
> >>  Fix git-gfs2-nmw.patch
> >>
> >> +ia64-ia32-nopage.patch
> >>
> >>  ia64 cleanup
> >>
> >> +ieee1394-nopage.patch
> >>
> >>  firewire cleanup
> >>
> >> +ib-nopage.patch
> >>
> >>  Infiniband cleanup
> >>
> >> +fujitsu-application-panel-led-value.patch
> >>
> >>  apanel update
> >>
> >> +ads7846-stop-updating-dev-powerpower_state.patch
> >> +wistron_btns-add-support-for-x86_64-systems.patch
> >> +wistron_btns-add-support-for-fujitsu-siemens-amilo-pro-edition-v3505.patch
> >> +hp6xx-hp7xx-clean-up-drivers-input-keyboardtouchscreen-kconfigs.patch
> >>
> >>  input things
> >>
> >> +pata_legacy-restructure-and-revamp.patch
> >>
> >>  pata upate
> >>
> >> +ide-mm-ide-dma-reporting-and-validity-checking-fixes-take-3.patch
> >> +ide-mm-ide-cd-remove-dead-post_transform_command.patch
> >> +ide-mm-pdc202xx_new-fix-promise-tx4-support.patch
> >> +ide-mm-hpt366-fix-hpt37x-pio-mode-timings-take-2.patch
> >> +ide-mm-hpt366-change-timing-register-masks.patch
> >> +ide-mm-hpt366-kill-set_dma_mode-method-wrapper.patch
> >> +ide-mm-ide-remove-dead-code-from-__ide_dma_test_irq.patch
> >> +ide-mm-ide-remove-stale-changelog-from-ide-disk-c.patch
> >> +ide-mm-ide-remove-stale-changelog-from-ide-probe-c.patch
> >> +ide-mm-ide-add-ide_busy_sleep-helper.patch
> >> +ide-mm-ide-remove-broken-disk-byte-swapping-support.patch
> >> +ide-mm-cmd64x-remove-proc-ide-cmd64x.patch
> >>
> >>  IDE tree updates
> >>
> >> +md-balance-braces-in-raid5-debug-code.patch
> >>
> >>  Fix git-md-accel.patch
> >>
> >> +mips-fix-makefile-borkage.patch
> >>
> >>  MIPS fix
> >>
> >> +ipsec-fix-reversed-icmp6-policy-check.patch
> >> +ipsec-do-not-let-packets-pass-when-icmp-flag-is-off.patch
> >> +git-net-vs-git-lblnet.patch
> >> +git-net-fix-drivers-net-ns83820c-build.patch
> >> +updates-to-nfsroot-documentation-take-3.patch
> >> +net-use-mutex_is_locked-for-assert_rtnl.patch
> >> +tipc-fix-semaphore-handling.patch
> >> +ppp-synchronous-tty-convert-dead_sem-to-completion.patch
> >>
> >>  net things
> >>
> >> +e1000e-make-e1000e-default-to-the-same-kconfig-setting-as-e1000.patch
> >>
> >>  Make e1000e config sane
> >>
> >> +plip-driver-convert-killed_timer_sem-to-completion.patch
> >>
> >>  plip cleanup
> >>
> >> +backlight-omap1-backlight-driver.patch
> >> +backlight-omap1-backlight-driver-fix.patch
> >>
> >>  backlight driver
> >>
> >> +pcmcia-include-bad-cis-filename-in-error-message.patch
> >>
> >>  pcmcia niceness
> >>
> >> +pci-disable-decoding-during-sizing-of-bars.patch
> >>
> >>  PCI fix
> >>
> >> +pcie-aer-dont-check-_osc-when-acpi-is-disabled.patch
> >> +pci-dont-load-acpi_php-when-acpi-is-disabled.patch
> >> +pci-dont-load-acpi_php-when-acpi-is-disabled-fix.patch
> >>
> >>  PCIE and PCI fixes
> >>
> >> +kernel-time-make-tick_do_broadcast-static.patch
> >>
> >>  cleanup
> >>
> >> -git-scsi-misc-fixup.patch
> >>
> >>  Unneeded
> >>
> >> +git-scsi-misc-fix-build-in-drivers-scsi-scsi_tgt_libc.patch
> >>
> >>  Fix git-scsi-misc
> >>
> >> +sg-nopage.patch
> >> +3w-raid-drivers-memset-not-needed-in-probe.patch
> >> +hptiop-add-more-adapter-models-and-other-fixes.patch
> >> +hptiop-add-more-adapter-models-and-other-fixes-update.patch
> >> +hptiop-add-more-adapter-models-and-other-fixes-fix-2.patch
> >> +drivers-scsi-iprc-use-list_head-instead-of-list_head_init.patch
> >>
> >>  scsi things
> >>
> >> -bidi-support-sr-sd-remove-dead-code.patch
> >> -bidi-support-tgt-use-scsi_init_io-instead-of-scsi_alloc_sgtable.patch
> >> -bidi-support-scsi_data_buffer.patch
> >> -scsi-pending-arm-convert-to-accessors.patch
> >> -scsi-bidi-support.patch
> >>
> >>  scsi changes killed this
> >>
> >> +usb-mon-nopage.patch
> >>
> >>  USB cleanup
> >>
> >> +9p-util-fix-semaphore-handling.patch
> >>
> >>  9p fix
> >>
> >> +watchdog-use-sgi_has_indydog-for-indydog-depends.patch
> >>
> >>  watchdog cleanup
> >>
> >> +wireless-libertas-dont-cast-a-pointer-to-pointer-of-list_head.patch
> >>
> >>  wireless cleanup
> >>
> >> -revert-git-kvm-changes-in-arch-x86-kconfig.patch
> >> -revert-revert-git-kvm-changes-in-arch-x86-kconfig.patch
> >>
> >>  Unneeded
> >>
> >> +git-x86-fix-allnoconfig-build.patch
> >>
> >>  x86 fix
> >>
> >> +mcheck-mce_64-mce_read_sem-to-mutex.patch
> >>
> >>  x86 cleanup
> >>
> >> +x86_64-efi-runtime-service-support-efi-basic-runtime-service-support-calling-convention-fix.patch
> >>
> >>  Fix x86_64-efi-runtime-service-support-efi-basic-runtime-service-support-fixes.patch
> >>
> >> +x86-boot-use-e820-memory-map-on-efi-32-platform.patch
> >>
> >>  x86 fix
> >>
> >> +iommu-sg-add-iommu-helper-functions-for-the-free-area-management.patch
> >> +iommu-sg-powerpc-convert-iommu-to-use-the-iommu-helper.patch
> >> +iommu-sg-powerpc-remove-dma-4gb-boundary-protection.patch
> >> +iommu-sg-x86-convert-calgary-iommu-to-use-the-iommu-helper.patch
> >> +iommu-sg-x86-convert-gart-iommu-to-use-the-iommu-helper.patch
> >> +iommu-sg-kill-__clear_bit_string-and-find_next_zero_string.patch
> >>
> >>  More iommu work
> >>
> >> +drivers-cpufreq-cpufreq_statsc-section-fix.patch
> >> +bonding-locking-fix.patch
> >> +bridge-assign-random-address.patch
> >> +nfs-fix-an-oops-in-nfs-unmount.patch
> >> +acpi-sbs-reset-alarm-bit.patch
> >> +acpi-sbs-ignore-alarms-coming-from-unknown-devices.patch
> >> +acpi-sbs-return-rate-in-mw-if-capacity-in-mwh.patch
> >> +usb-use-irqf_disabled-for-hcd-interrupt-handlers.patch
> >> +usb-at91_udc-correct-hanging-while-disconnecting-usb-cable.patch
> >> +iwlwifi3945-4965-fix-rate-control-algo-reference-leak.patch
> >> +iwlwifi3945-4965-fix-rate-control-algo-reference-leak-fix.patch
> >> +mm-sparsec-check-the-return-value-of-sparse_index_alloc.patch
> >> +mm-sparsec-improve-the-error-handling-for-sparse_add_one_section.patch
> >> +mm-sparsec-improve-the-error-handling-for-sparse_add_one_section-fix.patch
> >> +pktcdvd-add-kobject_put-when-kobject-register-fails.patch
> >> +libertas-select-wireless_ext.patch
> >> +bcm43xx_debugfs-sscanf-fix.patch
> >> +apm_eventinfo_t-are-userspace-types.patch
> >> +drivers-macintosh-via-pmuc-added-a-missing-iounmap.patch
> >>
> >>  More 2.6.24 queue
> >>
> >> +slub-optimise-the-clearing-of-__gfp_zero.patch
> >>
> >>  Slub speedup
> >>
> >> +mm-special-mapping-nopage.patch
> >> +remove-unused-arguments-in-zone_init_free_lists.patch
> >>
> >>  MM things
> >>
> >> +smack-getpeercred_stream-fix-for-so_peersec-and-tcp.patch
> >>
> >>  smack update
> >>
> >> +agp-alpha-nopage.patch
> >> +alpha-fix-warning-by-fixing-flush_tlb_kernel_range.patch
> >>
> >>  alpha stuff
> >>
> >> +arch-cris-added-a-missing-iounmap.patch
> >>
> >>  cris fix
> >>
> >> +uml-remove-duplicate-config-symbol-and-unused-file-and-variables.patch
> >> +uml-fix-mconsole-stop.patch
> >> +uml-miscellaneous-code-cleanups.patch
> >> +uml-style-fixes-in-filec.patch
> >> +uml-64-bit-tlb-fixes.patch
> >> +uml-customize-tlbh.patch
> >> +uml-runtime-detection-of-host-vmsplit-on-i386.patch
> >> +uml-eliminate-setjmp_wrapper.patch
> >> +uml-install-panic-notifier-earlier.patch
> >> +uml-use-barrier-instead-of-mb.patch
> >> +uml-tidy-helper-code.patch
> >> +uml-dont-kill-pid-0.patch
> >> +uml-get-rid-of-syscall-counters.patch
> >> +uml-dont-allow-processes-to-call-into-stub.patch
> >> +uml-move-sig_handler_common_skas.patch
> >> +uml-clean-up-sig_handler_common_skas.patch
> >>
> >>  UML updates
> >>
> >> +get-rid-of-nr_open-and-introduce-a-sysctl_nr_open-fix.patch
> >>
> >>  Fix get-rid-of-nr_open-and-introduce-a-sysctl_nr_open.patch
> >>
> >> +dio-fix-kernel-doc-notation.patch
> >> +relay-nopage.patch
> >> +uio-nopage.patch
> >> +deprecate-smbfs-in-favour-of-cifs.patch
> >> +drivers-char-use-list_head-instead-of-list_head_init.patch
> >> +remove-one-useless-extern-declaration.patch
> >> +quota-improve-inode-list-scanning-in-add_dquot_ref.patch
> >> +quota-improve-inode-list-scanning-in-add_dquot_ref-fix.patch
> >> +rcu-move-three-variables-to-__read_mostly-to-save-space.patch
> >> +add-arch_ptrace_stop.patch
> >> +tty-enable-the-echoing-of-c-in-the-n_tty-discipline.patch
> >> +tty-enable-the-echoing-of-c-in-the-n_tty-discipline-checkpatch-fixes.patch
> >> +docs-kernel-locking-convert-semaphore-references.patch
> >> +virtio_net-remove-double-ether_setup.patch
> >> +drivers-char-ipmi-ipmi_msghandlerc-use-list_head-instead-of-list_head_init.patch
> >> +fs-reiserfs-xattrc-use-list_head-instead-of-list_head_init.patch
> >> +stopmachine-semaphore-to-mutex.patch
> >> +stopmachine-semaphore-to-mutex-fix.patch
> >> +amiga-serial-driver-port_write_mutex-fixup.patch
> >> +ext2-xip-check-fix.patch
> >> +parport-add-support-for-the-quatech-sppxp-100-parallel-port-pci-expresscard.patch
> >> +parport-add-support-for-the-quatech-sppxp-100-parallel-port-pci-expresscard-fix.patch
> >> +parport_serial-netmos-9855-fix.patch
> >> +partition-use-default_sgi_partition-for-sgi_partion-default.patch
> >>
> >>  Misc
> >>
> >> +atmel_spi-chain-dma-transfers-update.patch
> >>
> >>  Fix atmel_spi-chain-dma-transfers.patch
> >>
> >> +create-arch-kconfig.patch
> >> +add-have_oprofile.patch
> >> +add-have_kprobes.patch
> >> +move-kconfiginstrumentation-to-arch-kconfig-and-init-kconfig.patch
> >>
> >>  Fiddle with Kconfig
> >>
> >> -move-kprobes-examples-to-samples-resend.patch
> >> -move-kprobes-examples-to-samples-resend-checkpatch-fixes.patch
> >> -move-kprobes-examples-to-samples-resend-vs-git-x86.patch
> >>
> >>  These need updating
> >>
> >> +ecryptfs-make-show_options-reflect-actual-mount-options.patch
> >> +ecryptfs-make-show_options-reflect-actual-mount-options-fix.patch
> >>
> >>  ecryptfs cleanups/fixes
> >>
> >> +rtc-add-support-for-the-s-35390a-rtc-chip.patch
> >> +rtc-add-support-for-the-s-35390a-rtc-chip-fix.patch
> >>
> >>  RTC update
> >>
> >> +fb-defio-nopage.patch
> >> +atmel_lcdfb-validate-display-timings.patch
> >> +vgacon-fix-sparse-warning-about-shadowing-i-symbol.patch
> >> +fbcon-fix-sparse-warning-about-shadowing-p-symbol.patch
> >> +fbcon-fix-sparse-warning-about-shadowing-rotate-symbol.patch
> >> +logo-move-declarations-of-logos-to-linux_logoh.patch
> >> +logo-move-declarations-of-logos-to-linux_logoh-fix.patch
> >>
> >>  fbdev things
> >>
> >> +md-raid6-fix-mktablec.patch
> >> +md-raid6-clean-up-the-style-of-raid6test-testc.patch
> >> +md-update-md-bitmap-during-resync.patch
> >> +md-update-md-bitmap-during-resync-fix.patch
> >>
> >>  RAID updates
> >>
> >> +pnp-do-not-stop-start-devices-in-suspend-resume-path.patch
> >>
> >>  PNP fix
> >>
> >> -pnp-request-ioport-and-iomem-resources-used-by-active-devices.patch
> >>
> >>  Dropped for now.
> >>
> >> +ext-fix-comment-for-nonexistent-variable.patch
> >> +ext-use-ext_get_group_desc.patch
> >> +ext-remove-unused-argument-for-ext_find_goal.patch
> >> +ext-cleanup-ext_bg_num_gdb.patch
> >>
> >>  ext2/3/4 cleanups
> >>
> >> +per-zone-and-reclaim-enhancements-for-memory-controller-take-3-modifies-vmscanc-for-isolate-globa-cgroup-lru-activity-fix-accounting-in-vmscanc-for-memory-controller.patch
> >> +update-documentation-controller-memorytxt.patch
> >>
> >>  memory controller updates
> >>
> >> +drivers-dma-iop-admac-use-list_head-instead-of-list_head_init.patch
> >>
> >>  DMS driver cleanup
> >>
> >> +proc-seqfile-convert-proc_pid_status-to-properly-handle-pid-namespaces-fix-2.patch
> >> +proc-seqfile-convert-proc_pid_status-to-properly-handle-pid-namespaces-fix-3.patch
> >>
> >>  Fix
> >>  proc-seqfile-convert-proc_pid_status-to-properly-handle-pid-namespaces.patch
> >>  even more
> >>
> >> +fix-group-stop-with-exit-race.patch
> >> +sys_setsid-remove-now-unneeded-session-=-1-check.patch
> >> +move-the-related-code-from-exit_notify-to-exit_signals.patch
> >> +pid-sys_wait-fixes-v2.patch
> >> +pid-sys_wait-fixes-v2-checkpatch-fixes.patch
> >> +pid-extend-fix-pid_vnr.patch
> >> +sys_getsid-dont-use-nsproxy-directly.patch
> >> +pid-fix-mips-irix-emulation-pid-usage.patch
> >> +pid-fix-solaris_procids.patch
> >> +uglify-kill_pid_info-to-fix-kill-vs-exec-race.patch
> >> +uglify-while_each_pid_task-to-make-sure-we-dont-count-the-execing-pricess-twice.patch
> >> +itimer_real-convert-to-use-struct-pid.patch
> >>
> >>  Core kernel updates
> >>
> >> +rd-support-xip.patch
> >>
> >>  SUpport XIP in rd.c
> >>
> >> -cramfs-make-cramfs-little-endian-only.patch
> >> -cramfs-make-cramfs-little-endian-only-update.patch
> >> -cramfs-make-cramfs-little-endian-only-fix.patch
> >>
> >>  Dropped
> >>
> >>
> >> 5041 commits in 1616 patch files
> >>
> >> All patches:
> >>
> >> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24-rc5/2.6.24-rc5-mm1/patch-list
> >>
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> Please read the FAQ at  http://www.tux.org/lkml/
> >>
> > 
> 
> 
> -- 
> B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D
> 
>    http://www.bull.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
