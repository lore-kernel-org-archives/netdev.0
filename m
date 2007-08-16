From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: drivers/infiniband/mlx/mad.c misplaced ;
Date: Thu, 16 Aug 2007 13:22:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708161248050.22579@kivilampi-30.cs.helsinki.fi>
References: <20070815235825.GB17004@redhat.com> <1187224811.5906.55.camel@localhost>
 <20070816084635.GA15985@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, rolandd@cisco.com,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Paul Mundt <lethal@linux-sh.org>,
	isdn4linux@listserv.isdn4linux.de, mikep@linuxtr.net,
	Netdev <netdev@vger.kernel.org>, swen@vnet.ibm.com,
	linux390@de.ibm.com, linux-s390@vger.kernel.org, jdike@karaya.com,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	netfilter-devel@lists.netfilter.org, coreteam@netfilter.org,
	Satyam Sharma <satyam@infradead.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42167 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471AbXHPKWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 06:22:08 -0400
In-Reply-To: <20070816084635.GA15985@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


...I guess those guys hunting for broken busyloops in the other thread 
could also benefit from similar searching commands introduced in this 
thread... ...Ccing Satyam to caught their attention too.


> On Wed, Aug 15, 2007 at 05:40:11PM -0700, Joe Perches wrote:
> > 
> > There's more than a few of these (not inspected).
> > 
> > $ egrep -r --include=*.c "\bif[[:space:]]*\([^\)]*\)[[:space:]]*\;" * 

...Hmm, I plugged in "a preprocessor" too to manage with non compliant 
coding styles :-). Please understand that the line numbers are not an 
exact match due to preprocessor changes:

$ for i in `find . -name '*.[ch]'`; do echo $i; indent -npro -kr -i8 -ts8 
-sob -l8000 -ss -ncs -cp1 -nhnl -st $i | egrep -n "[[:space:]]if [(].*[)] ;$";
done | grep -B1 "^[^.]"

./arch/arm/mach-omap1/leds-innovator.c
97:	if (led_state & LED_STATE_ENABLED) ;
--
./arch/mips/sibyte/cfe/console.c
23:				if (written < 0) ;
32:			if (written < 0) ;
--
./arch/powerpc/kernel/legacy_serial.c
524:	if (0) ;
--
./arch/powerpc/xmon/ppc-opc.c
938:	else if (value == 0) ;
--
./arch/sh/boards/se/7343/io.c
137:	if (0) ;
--
./arch/um/kernel/tt/tracer.c
254:		if (WIFEXITED(status)) ;
--
./arch/x86_64/ia32/ptrace32.c
363:			if (__copy_from_user(&child->thread.i387.fxsave, u, sizeof(*u))) ;
--
./arch/x86_64/kernel/traps.c
801:	if (eregs == (struct pt_regs *)eregs->rsp) ;
--
./drivers/atm/iphase.c
159:		if (!desc1) ;
--
./drivers/isdn/capi/capiutil.c
456:	else if (c <= 0x0f) ;
--
./drivers/isdn/hisax/hfc_pci.c
125:	if (Read_hfc(cs, HFCPCI_INT_S1)) ;
155:	if (Read_hfc(cs, HFCPCI_INT_S1)) ;
1483:					if (Read_hfc(cs, HFCPCI_INT_S1)) ;
--
./drivers/isdn/hisax/hfc_sx.c
377:	if (Read_hfc(cs, HFCSX_INT_S1)) ;
407:	if (Read_hfc(cs, HFCSX_INT_S2)) ;
1246:					if (Read_hfc(cs, HFCSX_INT_S1)) ;
--
./drivers/media/video/video-buf.c
1141:			if (q->bufs[i]) ;
--
./drivers/net/lp486e.c
777:	if (lp->scb.command && i596_timeout(dev, "i596_cleanup_cmd", 100)) ;
785:	if (lp->scb.command && i596_timeout(dev, "i596_reset", 100)) ;
794:	if (lp->scb.command && i596_timeout(dev, "i596_reset(2)", 400)) ;
820:		if (lp->scb.command && i596_timeout(dev, "i596_add_cmd", 100)) ;
1146:	if (lp->scb.command && i596_timeout(dev, "interrupt", 40)) ;
1192:	if (lp->scb.command && i596_timeout(dev, "i596 interrupt", 100)) ;
1217:	if (lp->scb.command && i596_timeout(dev, "i596_close", 200)) ;
--
./drivers/net/ni5010.c
273:	if (dev->irq == 0xff) ;
--
./drivers/net/ni52.c
648:		if (result & TDR_LNK_OK) ;
--
./drivers/net/sun3_82586.c
498:		if (result & TDR_LNK_OK) ;
--
./drivers/pci/hotplug/ibmphp_core.c
418:					else if (mode == BUS_MODE_PCI) ;
636:		else if (mode == BUS_MODE_PCI) ;
--
./drivers/usb/gadget/file_storage.c
2480:	if (protocol_is_scsi()) ;
--
./drivers/usb/host/uhci-debug.c
416:		if (i <= SKEL_ISO) ;
419:		else if (!uhci->fsbr_is_on) ;
--
./drivers/usb/host/uhci-q.c
541:	if (qh->skel == SKEL_ISO) ;
--
./drivers/usb/misc/usbtest.c
1401:	if (status != 0) ;
--
./drivers/video/intelfb/intelfbdrv.c
337:		if (get_opt_bool(this_opt, "accel", &accel)) ;
338:		else if (get_opt_int(this_opt, "vram", &vram)) ;
339:		else if (get_opt_bool(this_opt, "hwcursor", &hwcursor)) ;
340:		else if (get_opt_bool(this_opt, "mtrr", &mtrr)) ;
341:		else if (get_opt_bool(this_opt, "fixed", &fixed)) ;
--
./drivers/video/matrox/matroxfb_DAC1064.c
46:	if (fvco <= 100000) ;
--
./drivers/video/matrox/matroxfb_maven.c
298:	if (fvco <= 100000000) ;
316:	if (fvco <= 100000) ;
--
./fs/hfs/inode.c
72:		if (!node) ;
--
./fs/hfsplus/inode.c
67:		if (!node) ;
--
./fs/hostfs/hostfs_user.c
300:	if (attrs->ia_valid & HOSTFS_ATTR_CTIME) ;
--
./fs/xfs/xfs_bmap.c
2287:	if (nullfb || XFS_FSB_TO_AGNO(mp, ap->rval) == fb_agno) ;
--
./fs/xfs/xfs_dir2.c
281:	else if ((rval = xfs_dir2_isblock(tp, dp, &v))) ;
--
./fs/xfs/xfs_iomap.c
248:	if (io->io_flags & XFS_IOCORE_RT) ;
--
./include/asm-cris/uaccess.h
255:	if (n == 0) ;
303:	if (n == 0) ;
351:	if (n == 0) ;
--
./mm/swapfile.c
791:				if (swcount <= 1) ;
--
./net/core/pktgen.c
2256:		if (pkt_dev->min_in6_daddr.s6_addr32[0] == 0 && pkt_dev->min_in6_daddr.s6_addr32[1] == 0 && pkt_dev->min_in6_daddr.s6_addr32[2] == 0 && pkt_dev->min_in6_daddr.s6_addr32[3] == 0) ;
--
./net/irda/af_irda.c
1357:			if (ret) ;
1358:			else if (sk->sk_shutdown & RCV_SHUTDOWN) ;
--
./net/irda/irnetlink.c
105:	if (nla_put_string(msg, IRDA_NL_ATTR_IFNAME, dev->name)) ;
--
./net/netfilter/xt_u32.c
38:		if (skb->len < 4 || pos > skb->len - 4) ;
--
./sound/pci/au88x0/au88x0_core.c
2076:				if (vortex_adbdma_bufshift(vortex, i)) ;
2085:				if (vortex_wtdma_bufshift(vortex, i)) ;
--
./sound/pci/au88x0/au88x0_synth.c
352:				if (eax == 0) ;
--
./sound/pci/ice1712/ice1724.c
596:	if (!ptr) ;
636:	if (!ptr) ;
--
./sound/usb/usbmixer.c
1296:		if (check_mapped_name(state, unitid, cval->control, kctl->id.name, sizeof(kctl->id.name))) ;
1500:	if (len) ;


...some of these are false positives due to constructs like this (not 
sure if there's some better alternative):

if (!ptr)
	;
else if (ptr->something)
	do_it();
else
	do_other();

...plus there might be some #ifdefs in that construct too.


-- 
 i.
