From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Thu, 13 Feb 2014 22:55:23 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1402132252290.1967@localhost6.localdomain6>
References: <20140212205122.5783660e@nehalam.linuxnetplumber.net> <1392273125.2214.25.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:60377 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932AbaBMVz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 16:55:28 -0500
In-Reply-To: <1392273125.2214.25.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Feb 2014, Joe Perches wrote:

> On Wed, 2014-02-12 at 20:51 -0800, Stephen Hemminger wrote:
> > One of my pet coding style peeves is the practice of
> > adding extra return; at the end of function.
> > Kill several instances of this in network code.
> > I suppose some coccinelle wizardy could do this automatically.
> 
> Maybe, but grep version 2.5.4 will show most of them.
> 
> $ grep-2.5.4 -rP --include=*.[ch] "return;\n}" *
> [...]
> 
> Fixing them has to make sure that there's no
> label before the close brace.
> 
> gcc has to have a statement before the close brace
> of a void return after a label.
> 
> label:
> }
> 
> must be:
> 
> label:
> 	;
> }
> 
> to compile.

The patch below converts label: return; } to label: ; }.  I have only 
scanned through the patches, not patched the code and looked at the 
results, so I am not sure that it is completely correct.  On the other 
hand, I'm also not sure that label: ; } is better than label: return; }, 
either.  If people think it is, then I can cheack the results in more 
detail.

julia


diff -u -p a/arch/arm/mach-iop13xx/io.c b/arch/arm/mach-iop13xx/io.c
--- a/arch/arm/mach-iop13xx/io.c
+++ b/arch/arm/mach-iop13xx/io.c
@@ -80,7 +80,7 @@ static void __iop13xx_iounmap(volatile v
 	__iounmap(addr);
 
 skip:
-	return;
+	;
 }
 
 void __init iop13xx_init_early(void)
diff -u -p a/arch/arm/mach-pxa/balloon3.c b/arch/arm/mach-pxa/balloon3.c
--- a/arch/arm/mach-pxa/balloon3.c
+++ b/arch/arm/mach-pxa/balloon3.c
@@ -269,7 +269,7 @@ static void __init balloon3_lcd_init(voi
 err2:
 	gpio_free(BALLOON3_GPIO_RUN_BACKLIGHT);
 err:
-	return;
+	;
 }
 #else
 static inline void balloon3_lcd_init(void) {}
diff -u -p a/arch/arm/mach-pxa/vpac270.c b/arch/arm/mach-pxa/vpac270.c
--- a/arch/arm/mach-pxa/vpac270.c
+++ b/arch/arm/mach-pxa/vpac270.c
@@ -577,7 +577,7 @@ static void __init vpac270_lcd_init(void
 err2:
 	gpio_free(GPIO81_VPAC270_BKL_ON);
 err:
-	return;
+	;
 }
 #else
 static inline void vpac270_lcd_init(void) {}
diff -u -p a/arch/avr32/boards/atstk1000/atstk1002.c b/arch/avr32/boards/atstk1000/atstk1002.c
--- a/arch/avr32/boards/atstk1000/atstk1002.c
+++ b/arch/avr32/boards/atstk1000/atstk1002.c
@@ -236,7 +236,7 @@ err_set_clk:
 err_pll:
 	clk_put(gclk);
 err_gclk:
-	return;
+	;
 }
 #else
 static void __init atstk1002_setup_extdac(void)
diff -u -p a/arch/avr32/boards/atstk1000/atstk1003.c b/arch/avr32/boards/atstk1000/atstk1003.c
--- a/arch/avr32/boards/atstk1000/atstk1003.c
+++ b/arch/avr32/boards/atstk1000/atstk1003.c
@@ -103,7 +103,7 @@ err_set_clk:
 err_pll:
 	clk_put(gclk);
 err_gclk:
-	return;
+	;
 }
 #else
 static void __init atstk1003_setup_extdac(void)
diff -u -p a/arch/avr32/boards/atstk1000/atstk1004.c b/arch/avr32/boards/atstk1000/atstk1004.c
--- a/arch/avr32/boards/atstk1000/atstk1004.c
+++ b/arch/avr32/boards/atstk1000/atstk1004.c
@@ -108,7 +108,7 @@ err_set_clk:
 err_pll:
 	clk_put(gclk);
 err_gclk:
-	return;
+	;
 }
 #else
 static void __init atstk1004_setup_extdac(void)
diff -u -p a/arch/avr32/kernel/process.c b/arch/avr32/kernel/process.c
--- a/arch/avr32/kernel/process.c
+++ b/arch/avr32/kernel/process.c
@@ -105,7 +105,7 @@ static void dump_mem(const char *str, co
 	}
 
 out:
-	return;
+	;
 }
 
 static inline int valid_stack_ptr(struct thread_info *tinfo, unsigned long p)
diff -u -p a/arch/mips/kvm/kvm_mips.c b/arch/mips/kvm/kvm_mips.c
--- a/arch/mips/kvm/kvm_mips.c
+++ b/arch/mips/kvm/kvm_mips.c
@@ -260,7 +260,7 @@ void kvm_arch_commit_memory_region(struc
 		}
 	}
 out:
-	return;
+	;
 }
 
 void kvm_arch_flush_shadow_all(struct kvm *kvm)
diff -u -p a/arch/mips/lantiq/irq.c b/arch/mips/lantiq/irq.c
--- a/arch/mips/lantiq/irq.c
+++ b/arch/mips/lantiq/irq.c
@@ -328,7 +328,7 @@ asmlinkage void plat_irq_dispatch(void)
 	pr_alert("Spurious IRQ: CAUSE=0x%08x\n", read_c0_status());
 
 out:
-	return;
+	;
 }
 
 static int icu_map(struct irq_domain *d, unsigned int irq, irq_hw_number_t hw)
diff -u -p a/arch/powerpc/boot/wii.c b/arch/powerpc/boot/wii.c
--- a/arch/powerpc/boot/wii.c
+++ b/arch/powerpc/boot/wii.c
@@ -134,7 +134,7 @@ static void platform_fixups(void)
 	}
 
 out:
-	return;
+	;
 }
 
 void platform_init(unsigned long r3, unsigned long r4, unsigned long r5)
diff -u -p a/arch/s390/kernel/debug.c b/arch/s390/kernel/debug.c
--- a/arch/s390/kernel/debug.c
+++ b/arch/s390/kernel/debug.c
@@ -750,7 +750,7 @@ debug_unregister(debug_info_t * id)
 	mutex_unlock(&debug_mutex);
 
 out:
-	return;
+	;
 }
 EXPORT_SYMBOL(debug_unregister);
 
diff -u -p a/arch/um/os-Linux/irq.c b/arch/um/os-Linux/irq.c
--- a/arch/um/os-Linux/irq.c
+++ b/arch/um/os-Linux/irq.c
@@ -116,7 +116,7 @@ void os_free_irq_by_cb(int (*test)(struc
 		i++;
 	}
  out:
-	return;
+	;
 }
 
 int os_get_pollfd(int i)
diff -u -p a/arch/x86/lib/insn.c b/arch/x86/lib/insn.c
--- a/arch/x86/lib/insn.c
+++ b/arch/x86/lib/insn.c
@@ -173,7 +173,7 @@ vex_end:
 	prefixes->got = 1;
 
 err_out:
-	return;
+	;
 }
 
 /**
@@ -226,7 +226,7 @@ end:
 	opcode->got = 1;
 
 err_out:
-	return;
+	;
 }
 
 /**
@@ -264,7 +264,7 @@ void insn_get_modrm(struct insn *insn)
 	modrm->got = 1;
 
 err_out:
-	return;
+	;
 }
 
 
@@ -316,7 +316,7 @@ void insn_get_sib(struct insn *insn)
 	insn->sib.got = 1;
 
 err_out:
-	return;
+	;
 }
 
 
@@ -380,7 +380,7 @@ out:
 	insn->displacement.got = 1;
 
 err_out:
-	return;
+	;
 }
 
 /* Decode moffset16/32/64. Return 0 if failed */
@@ -559,7 +559,7 @@ done:
 	insn->immediate.got = 1;
 
 err_out:
-	return;
+	;
 }
 
 /**
diff -u -p a/crypto/tcrypt.c b/crypto/tcrypt.c
--- a/crypto/tcrypt.c
+++ b/crypto/tcrypt.c
@@ -401,7 +401,7 @@ out_nooutbuf:
 out_noaxbuf:
 	testmgr_free_buf(xbuf);
 out_noxbuf:
-	return;
+	;
 }
 
 static void test_cipher_speed(const char *algo, int enc, unsigned int sec,
diff -u -p a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -693,7 +693,7 @@ static void ia_tx_poll (IADEV *iadev) {
     }
     ia_que_tx(iadev);
 out:
-    return;
+    ;
 }
 #if 0
 static void ia_eeprom_put (IADEV *iadev, u32 addr, u_short val)
diff -u -p a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -1056,7 +1056,7 @@ static void push_rxbufs(ns_dev * card, s
 	}
 
 out:
-	return;
+	;
 }
 
 static irqreturn_t ns_irq_handler(int irq, void *dev_id)
diff -u -p a/drivers/block/cpqarray.c b/drivers/block/cpqarray.c
--- a/drivers/block/cpqarray.c
+++ b/drivers/block/cpqarray.c
@@ -1795,7 +1795,7 @@ err_2:
 err_1:
   	kfree(id_ldrive);
 err_0:
-	return;
+	;
 }
 
 static void __exit cpqarray_exit(void)
diff -u -p a/drivers/char/ipmi/ipmi_msghandler.c b/drivers/char/ipmi/ipmi_msghandler.c
--- a/drivers/char/ipmi/ipmi_msghandler.c
+++ b/drivers/char/ipmi/ipmi_msghandler.c
@@ -2789,7 +2789,7 @@ channel_handler(ipmi_smi_t intf, struct
 		}
 	}
  out:
-	return;
+	;
 }
 
 static void ipmi_poll(ipmi_smi_t intf)
@@ -3924,7 +3924,7 @@ void ipmi_smi_msg_received(ipmi_smi_t
 
 	tasklet_schedule(&intf->recv_tasklet);
  out:
-	return;
+	;
 }
 EXPORT_SYMBOL(ipmi_smi_msg_received);
 
diff -u -p a/drivers/char/ipmi/ipmi_poweroff.c b/drivers/char/ipmi/ipmi_poweroff.c
--- a/drivers/char/ipmi/ipmi_poweroff.c
+++ b/drivers/char/ipmi/ipmi_poweroff.c
@@ -310,7 +310,7 @@ static void ipmi_poweroff_atca(ipmi_user
 	if (atca_oem_poweroff_hook)
 		atca_oem_poweroff_hook(user);
  out:
-	return;
+	;
 }
 
 /*
@@ -434,7 +434,7 @@ static void ipmi_poweroff_cpi1(ipmi_user
 		goto out;
 
  out:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/char/ipmi/ipmi_watchdog.c b/drivers/char/ipmi/ipmi_watchdog.c
--- a/drivers/char/ipmi/ipmi_watchdog.c
+++ b/drivers/char/ipmi/ipmi_watchdog.c
@@ -1098,7 +1098,7 @@ static void ipmi_unregister_watchdog(int
 	watchdog_user = NULL;
 
  out:
-	return;
+	;
 }
 
 #ifdef HAVE_DIE_NMI
diff -u -p a/drivers/clk/clk.c b/drivers/clk/clk.c
--- a/drivers/clk/clk.c
+++ b/drivers/clk/clk.c
@@ -523,7 +523,7 @@ unlock_out:
 	clk_enable_unlock(flags);
 
 out:
-	return;
+	;
 }
 
 static bool clk_ignore_unused;
diff -u -p a/drivers/gpu/drm/gma500/oaktrail_hdmi.c b/drivers/gpu/drm/gma500/oaktrail_hdmi.c
--- a/drivers/gpu/drm/gma500/oaktrail_hdmi.c
+++ b/drivers/gpu/drm/gma500/oaktrail_hdmi.c
@@ -736,7 +736,7 @@ void oaktrail_hdmi_setup(struct drm_devi
 free:
 	kfree(hdmi_dev);
 out:
-	return;
+	;
 }
 
 void oaktrail_hdmi_teardown(struct drm_device *dev)
diff -u -p a/drivers/hid/hid-input.c b/drivers/hid/hid-input.c
--- a/drivers/hid/hid-input.c
+++ b/drivers/hid/hid-input.c
@@ -974,7 +974,7 @@ mapped:
 	}
 
 ignore:
-	return;
+	;
 
 }
 
diff -u -p a/drivers/hid/hid-wacom.c b/drivers/hid/hid-wacom.c
--- a/drivers/hid/hid-wacom.c
+++ b/drivers/hid/hid-wacom.c
@@ -154,7 +154,7 @@ static void wacom_set_image(struct hid_d
 				HID_FEATURE_REPORT);
 
 err:
-	return;
+	;
 }
 
 static void wacom_leds_set_brightness(struct led_classdev *led_dev,
diff -u -p a/drivers/ide/ide-park.c b/drivers/ide/ide-park.c
--- a/drivers/ide/ide-park.c
+++ b/drivers/ide/ide-park.c
@@ -55,7 +55,7 @@ static void issue_park_cmd(ide_drive_t *
 	elv_add_request(q, rq, ELEVATOR_INSERT_FRONT);
 
 out:
-	return;
+	;
 }
 
 ide_startstop_t ide_do_park_unpark(ide_drive_t *drive, struct request *rq)
diff -u -p a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -1552,7 +1552,7 @@ vendor_check:
 	}
 
 out:
-	return;
+	;
 }
 
 static struct ib_mad_agent_private *
diff -u -p a/drivers/infiniband/hw/cxgb4/ev.c b/drivers/infiniband/hw/cxgb4/ev.c
--- a/drivers/infiniband/hw/cxgb4/ev.c
+++ b/drivers/infiniband/hw/cxgb4/ev.c
@@ -172,7 +172,7 @@ done:
 		wake_up(&chp->wait);
 	c4iw_qp_rem_ref(&qhp->ibqp);
 out:
-	return;
+	;
 }
 
 int c4iw_ev_handler(struct c4iw_dev *dev, u32 qid)
diff -u -p a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -2613,5 +2613,5 @@ void ipath_user_remove(struct ipath_devd
 		atomic_set(&user_setup, 0);
 	}
 bail:
-	return;
+	;
 }
diff -u -p a/drivers/infiniband/hw/ipath/ipath_intr.c b/drivers/infiniband/hw/ipath/ipath_intr.c
--- a/drivers/infiniband/hw/ipath/ipath_intr.c
+++ b/drivers/infiniband/hw/ipath/ipath_intr.c
@@ -446,7 +446,7 @@ static void handle_e_ibstatuschanged(str
 skip_ibchange:
 	dd->ipath_lastibcstat = ibcs;
 done:
-	return;
+	;
 }
 
 static void handle_supp_msgs(struct ipath_devdata *dd,
diff -u -p a/drivers/infiniband/hw/ipath/ipath_rc.c b/drivers/infiniband/hw/ipath/ipath_rc.c
--- a/drivers/infiniband/hw/ipath/ipath_rc.c
+++ b/drivers/infiniband/hw/ipath/ipath_rc.c
@@ -709,7 +709,7 @@ queue_ack:
 	}
 	spin_unlock_irqrestore(&qp->s_lock, flags);
 done:
-	return;
+	;
 }
 
 /**
@@ -835,7 +835,7 @@ void ipath_restart_rc(struct ipath_qp *q
 	ipath_schedule_send(qp);
 
 bail:
-	return;
+	;
 }
 
 static inline void update_last_psn(struct ipath_qp *qp, u32 psn)
@@ -1312,7 +1312,7 @@ ack_err:
 ack_done:
 	spin_unlock_irqrestore(&qp->s_lock, flags);
 bail:
-	return;
+	;
 }
 
 /**
@@ -1965,5 +1965,5 @@ send_ack:
 unlock:
 	spin_unlock_irqrestore(&qp->s_lock, flags);
 done:
-	return;
+	;
 }
diff -u -p a/drivers/infiniband/hw/ipath/ipath_sdma.c b/drivers/infiniband/hw/ipath/ipath_sdma.c
--- a/drivers/infiniband/hw/ipath/ipath_sdma.c
+++ b/drivers/infiniband/hw/ipath/ipath_sdma.c
@@ -355,7 +355,7 @@ resched_noprint:
 unlock:
 	spin_unlock_irqrestore(&dd->ipath_sdma_lock, flags);
 done:
-	return;
+	;
 }
 
 /*
@@ -633,7 +633,7 @@ void ipath_restart_sdma(struct ipath_dev
 	ipath_ib_piobufavail(dd->verbs_dev);
 
 bail:
-	return;
+	;
 }
 
 static inline void make_sdma_desc(struct ipath_devdata *dd,
diff -u -p a/drivers/infiniband/hw/ipath/ipath_uc.c b/drivers/infiniband/hw/ipath/ipath_uc.c
--- a/drivers/infiniband/hw/ipath/ipath_uc.c
+++ b/drivers/infiniband/hw/ipath/ipath_uc.c
@@ -543,5 +543,5 @@ void ipath_uc_rcv(struct ipath_ibdev *de
 	qp->r_psn++;
 	qp->r_state = opcode;
 done:
-	return;
+	;
 }
diff -u -p a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
--- a/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
+++ b/drivers/infiniband/hw/ocrdma/ocrdma_verbs.c
@@ -2969,7 +2969,7 @@ static void build_kernel_pbes(struct ib_
 		}
 	}
 mr_tbl_done:
-	return;
+	;
 }
 
 struct ib_mr *ocrdma_reg_kernel_mr(struct ib_pd *ibpd,
diff -u -p a/drivers/infiniband/hw/qib/qib_iba6120.c b/drivers/infiniband/hw/qib/qib_iba6120.c
--- a/drivers/infiniband/hw/qib/qib_iba6120.c
+++ b/drivers/infiniband/hw/qib/qib_iba6120.c
@@ -1122,7 +1122,7 @@ static void handle_6120_errors(struct qi
 			qib_stats.sps_hdrfull++;
 	}
 done:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/infiniband/hw/qib/qib_iba7220.c b/drivers/infiniband/hw/qib/qib_iba7220.c
--- a/drivers/infiniband/hw/qib/qib_iba7220.c
+++ b/drivers/infiniband/hw/qib/qib_iba7220.c
@@ -1221,7 +1221,7 @@ static void handle_7220_errors(struct qi
 			qib_stats.sps_hdrfull++;
 	}
 done:
-	return;
+	;
 }
 
 /* enable/disable chip from delivering interrupts */
diff -u -p a/drivers/infiniband/hw/qib/qib_iba7322.c b/drivers/infiniband/hw/qib/qib_iba7322.c
--- a/drivers/infiniband/hw/qib/qib_iba7322.c
+++ b/drivers/infiniband/hw/qib/qib_iba7322.c
@@ -1741,7 +1741,7 @@ static noinline void handle_7322_errors(
 	}
 
 done:
-	return;
+	;
 }
 
 static void qib_error_tasklet(unsigned long data)
@@ -2016,7 +2016,7 @@ static noinline void handle_7322_p_error
 	if (ppd->state_wanted & ppd->lflags)
 		wake_up_interruptible(&ppd->state_wait);
 done:
-	return;
+	;
 }
 
 /* enable/disable chip from delivering interrupts */
diff -u -p a/drivers/infiniband/hw/qib/qib_rc.c b/drivers/infiniband/hw/qib/qib_rc.c
--- a/drivers/infiniband/hw/qib/qib_rc.c
+++ b/drivers/infiniband/hw/qib/qib_rc.c
@@ -768,7 +768,7 @@ queue_ack:
 unlock:
 	spin_unlock_irqrestore(&qp->s_lock, flags);
 done:
-	return;
+	;
 }
 
 /**
@@ -1601,7 +1601,7 @@ ack_err:
 ack_done:
 	spin_unlock_irqrestore(&qp->s_lock, flags);
 bail:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/infiniband/hw/qib/qib_sd7220.c b/drivers/infiniband/hw/qib/qib_sd7220.c
--- a/drivers/infiniband/hw/qib/qib_sd7220.c
+++ b/drivers/infiniband/hw/qib/qib_sd7220.c
@@ -160,7 +160,7 @@ void qib_sd7220_clr_ibpar(struct qib_dev
 		QLOGIC_IB_HWE_IB_UC_MEMORYPARITYERR);
 	qib_read_kreg32(dd, kr_scratch);
 bail:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -1926,7 +1926,7 @@ static void srpt_handle_new_iu(struct sr
 
 	srpt_post_recv(ch->sport->sdev, recv_ioctx);
 out:
-	return;
+	;
 }
 
 static void srpt_process_rcv_completion(struct ib_cq *cq,
diff -u -p a/drivers/mfd/88pm860x-core.c b/drivers/mfd/88pm860x-core.c
--- a/drivers/mfd/88pm860x-core.c
+++ b/drivers/mfd/88pm860x-core.c
@@ -1037,7 +1037,7 @@ static void device_8607_init(struct pm86
 	device_power_init(chip, pdata);
 	device_codec_init(chip, pdata);
 out:
-	return;
+	;
 }
 
 static void device_8606_init(struct pm860x_chip *chip,
diff -u -p a/drivers/mfd/ab3100-core.c b/drivers/mfd/ab3100-core.c
--- a/drivers/mfd/ab3100-core.c
+++ b/drivers/mfd/ab3100-core.c
@@ -624,7 +624,7 @@ static void ab3100_setup_debugfs(struct
  exit_destroy_dir:
 	debugfs_remove(ab3100_dir);
  exit_no_debugfs:
-	return;
+	;
 }
 static inline void ab3100_remove_debugfs(void)
 {
diff -u -p a/drivers/mtd/maps/vmu-flash.c b/drivers/mtd/maps/vmu-flash.c
--- a/drivers/mtd/maps/vmu-flash.c
+++ b/drivers/mtd/maps/vmu-flash.c
@@ -592,7 +592,7 @@ fail_mpart:
 		MAPLE_FUNC_MEMCARD);
 	kfree(part_cur->name);
 fail_name:
-	return;
+	;
 }
 
 /* Handles very basic info about the flash, queries for details */
diff -u -p a/drivers/mtd/nand/gpmi-nand/gpmi-lib.c b/drivers/mtd/nand/gpmi-nand/gpmi-lib.c
--- a/drivers/mtd/nand/gpmi-nand/gpmi-lib.c
+++ b/drivers/mtd/nand/gpmi-nand/gpmi-lib.c
@@ -1071,7 +1071,7 @@ void gpmi_begin(struct gpmi_nand_data *t
 	udelay(dll_wait_time_in_us);
 
 err_out:
-	return;
+	;
 }
 
 void gpmi_end(struct gpmi_nand_data *this)
diff -u -p a/drivers/mtd/sm_ftl.c b/drivers/mtd/sm_ftl.c
--- a/drivers/mtd/sm_ftl.c
+++ b/drivers/mtd/sm_ftl.c
@@ -1221,7 +1221,7 @@ error3:
 error2:
 	kfree(ftl);
 error1:
-	return;
+	;
 }
 
 /* main interface: device {surprise,} removal */
diff -u -p a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1396,7 +1396,7 @@ static inline void atl1e_rx_checksum(str
 	}
 
 hw_xsum :
-	return;
+	;
 }
 
 static struct atl1e_rx_page *atl1e_get_rx_page(struct atl1e_adapter *adapter,
diff -u -p a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9815,7 +9815,7 @@ static void bnx2x_period_task(struct wor
 
 	bnx2x_release_phy_lock(bp);
 period_task_exit:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -352,7 +352,7 @@ op_err:
 op_done:
 	bnx2x_vfop_end(bp, vf, vfop);
 op_pending:
-	return;
+	;
 }
 
 static int bnx2x_vfop_qctor_cmd(struct bnx2x *bp,
@@ -447,7 +447,7 @@ op_done:
 		bnx2x_vfop_default(state);
 	}
 op_pending:
-	return;
+	;
 }
 
 static int bnx2x_vfop_qdtor_cmd(struct bnx2x *bp,
@@ -670,7 +670,7 @@ op_done:
 	bnx2x_vfop_credit(bp, vfop, obj);
 	bnx2x_vfop_end(bp, vf, vfop);
 op_pending:
-	return;
+	;
 }
 
 struct bnx2x_vfop_vlan_mac_flags {
@@ -1083,7 +1083,7 @@ op_done:
 		bnx2x_vfop_default(state);
 	}
 op_pending:
-	return;
+	;
 }
 
 static int bnx2x_vfop_qflr_cmd(struct bnx2x *bp,
@@ -1159,7 +1159,7 @@ op_done:
 	kfree(args->mc);
 	bnx2x_vfop_end(bp, vf, vfop);
 op_pending:
-	return;
+	;
 }
 
 int bnx2x_vfop_mcast_cmd(struct bnx2x *bp,
@@ -1240,7 +1240,7 @@ op_done:
 		bnx2x_vfop_default(state);
 	}
 op_pending:
-	return;
+	;
 }
 
 static void bnx2x_vf_prep_rx_mode(struct bnx2x *bp, u8 qid,
@@ -2912,7 +2912,7 @@ op_done:
 	bnx2x_vfop_end(bp, vf, vfop);
 op_pending:
 	/* Not supported at the moment; Exists for macros only */
-	return;
+	;
 }
 
 int bnx2x_vfop_close_cmd(struct bnx2x *bp,
@@ -3014,7 +3014,7 @@ op_done:
 		bnx2x_vfop_default(state);
 	}
 op_pending:
-	return;
+	;
 }
 
 int bnx2x_vfop_release_cmd(struct bnx2x *bp,
diff -u -p a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -2013,7 +2013,7 @@ void bnx2x_vf_mbx(struct bnx2x *bp, stru
 mbx_error:
 	bnx2x_vf_release(bp, vf, false); /* non blocking */
 mbx_done:
-	return;
+	;
 }
 
 /* propagate local bulletin board to vf */
diff -u -p a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1216,7 +1216,7 @@ static void be_set_rx_mode(struct net_de
 		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
 	}
 done:
-	return;
+	;
 }
 
 static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
diff -u -p a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2820,7 +2820,7 @@ static void ehea_rereg_mrs(void)
 		}
 	pr_info("re-initializing driver complete\n");
 out:
-	return;
+	;
 }
 
 static void ehea_tx_watchdog(struct net_device *dev)
diff -u -p a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -487,7 +487,7 @@ static void e1000_power_down_phy(struct
 		msleep(1);
 	}
 out:
-	return;
+	;
 }
 
 static void e1000_down_and_stop(struct e1000_adapter *adapter)
@@ -3457,7 +3457,7 @@ rx_ring_summary:
 			readl(adapter->hw.hw_addr + i+8));
 	}
 exit:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -569,7 +569,7 @@ rx_ring_summary:
 	}
 
 exit:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -655,7 +655,7 @@ static void ixgbe_set_fiber_fixed_speed(
 		goto out;
 	}
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -705,7 +705,7 @@ rx_ring_summary:
 	}
 
 exit:
-	return;
+	;
 }
 
 static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
diff -u -p a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3187,7 +3187,7 @@ static void myri10ge_set_multicast_list(
 	return;
 
 abort:
-	return;
+	;
 }
 
 static int myri10ge_set_mac_address(struct net_device *dev, void *addr)
diff -u -p a/drivers/net/ethernet/neterion/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c
@@ -1126,7 +1126,7 @@ static void __vxge_hw_blockpool_destroy(
 	}
 	ret = 0;
 exit:
-	return;
+	;
 }
 
 /*
@@ -2311,7 +2311,7 @@ static void vxge_hw_blockpool_block_add(
 
 	req_out = blockpool->req_out;
 exit:
-	return;
+	;
 }
 
 static inline void
@@ -4651,7 +4651,7 @@ static void __vxge_hw_vp_terminate(struc
 	vpath->sw_stats = NULL;
 
 exit:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2265,7 +2265,7 @@ static void rtl_work_func_t(struct work_
 		_rtl8152_set_rx_mode(tp->netdev);
 
 out1:
-	return;
+	;
 }
 
 static int rtl8152_open(struct net_device *netdev)
diff -u -p a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -409,7 +409,7 @@ void i2400m_rx_ctl(struct i2400m *i2400m
 	} else		/* an ack to a CMD, GET or SET */
 		i2400m_rx_ctl_ack(i2400m, payload, size);
 error_check:
-	return;
+	;
 }
 
 
@@ -456,7 +456,7 @@ void i2400m_rx_trace(struct i2400m *i240
 		dev_err(dev, "error sending trace to userspace: %d\n",
 			result);
 error_check:
-	return;
+	;
 }
 
 
diff -u -p a/drivers/net/wireless/ath/ar5523/ar5523.c b/drivers/net/wireless/ath/ar5523/ar5523.c
--- a/drivers/net/wireless/ath/ar5523/ar5523.c
+++ b/drivers/net/wireless/ath/ar5523/ar5523.c
@@ -660,7 +660,7 @@ static void ar5523_rx_refill_work(struct
 
 	} while (true);
 done:
-	return;
+	;
 }
 
 static void ar5523_cancel_rx_bufs(struct ar5523 *ar)
diff -u -p a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -675,7 +675,7 @@ static void wcn36xx_bss_info_changed(str
 		}
 	}
 out:
-	return;
+	;
 }
 
 /* this is required when using IEEE80211_HW_HAS_RATE_CONTROL */
diff -u -p a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -1397,7 +1397,7 @@ static void dma_rx(struct b43legacy_dmar
 
 	b43legacy_rx(ring->dev, skb, rxhdr);
 drop:
-	return;
+	;
 }
 
 void b43legacy_dma_rx(struct b43legacy_dmaring *ring)
diff -u -p a/drivers/net/wireless/cw1200/txrx.c b/drivers/net/wireless/cw1200/txrx.c
--- a/drivers/net/wireless/cw1200/txrx.c
+++ b/drivers/net/wireless/cw1200/txrx.c
@@ -1223,7 +1223,7 @@ void cw1200_rx_cb(struct cw1200_common *
 
 drop:
 	/* TODO: update failure counters */
-	return;
+	;
 }
 
 /* ******************************************************************** */
diff -u -p a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -1871,7 +1871,7 @@ il_set_ht_add_station(struct il_priv *il
 
 	il->stations[idx].sta.station_flags = sta_flags;
 done:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -796,7 +796,7 @@ void lbs_debugfs_init_one(struct lbs_pri
 	lbs_debug_init(priv);
 #endif
 exit:
-	return;
+	;
 }
 
 void lbs_debugfs_remove_one(struct lbs_private *priv)
diff -u -p a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -510,7 +510,7 @@ static void ezusb_req_queue_run(struct e
 	spin_unlock_irqrestore(&upriv->req_lock, flags);
 
  done:
-	return;
+	;
 }
 
 static void ezusb_req_enqueue_run(struct ezusb_priv *upriv,
@@ -532,7 +532,7 @@ static void ezusb_req_enqueue_run(struct
 	ezusb_req_queue_run(upriv);
 
  done:
-	return;
+	;
 }
 
 static void ezusb_request_out_callback(struct urb *urb)
diff -u -p a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -4103,7 +4103,7 @@ static void wl1271_bss_info_changed_ap(s
 	}
 
 out:
-	return;
+	;
 }
 
 static int wlcore_set_bssid(struct wl1271 *wl, struct wl12xx_vif *wlvif,
@@ -4418,7 +4418,7 @@ static void wl1271_bss_info_changed_sta(
 	}
 
 out:
-	return;
+	;
 }
 
 static void wl1271_op_bss_info_changed(struct ieee80211_hw *hw,
diff -u -p a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -806,7 +806,7 @@ static void wl3501_esbq_req_free(struct
 	if (this->esbq_req_tail >= this->esbq_req_end)
 		this->esbq_req_tail = this->esbq_req_start;
 out:
-	return;
+	;
 }
 
 static int wl3501_esbq_confirm(struct wl3501_card *this)
diff -u -p a/drivers/power/88pm860x_battery.c b/drivers/power/88pm860x_battery.c
--- a/drivers/power/88pm860x_battery.c
+++ b/drivers/power/88pm860x_battery.c
@@ -527,7 +527,7 @@ static void pm860x_init_battery(struct p
 	info->last_capacity = info->start_soc;
 	dev_dbg(info->dev, "init soc : %d\n", info->last_capacity);
 out:
-	return;
+	;
 }
 
 static void set_temp_threshold(struct pm860x_battery_info *info,
diff -u -p a/drivers/s390/net/ctcm_fsms.c b/drivers/s390/net/ctcm_fsms.c
--- a/drivers/s390/net/ctcm_fsms.c
+++ b/drivers/s390/net/ctcm_fsms.c
@@ -1054,7 +1054,7 @@ static void ctcm_chx_txretry(fsm_instanc
 		}
 	}
 done:
-	return;
+	;
 }
 
 /**
@@ -1590,7 +1590,7 @@ void ctcmpc_chx_rxidle(fsm_instance *fi,
 
 	fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
 done:
-	return;
+	;
 }
 
 /*
@@ -1734,7 +1734,7 @@ static void ctcmpc_chx_attnbusy(fsm_inst
 				CTCM_FUNTAIL, dev->name, ch->id);
 
 done:
-	return;
+	;
 }
 
 /*
@@ -1847,7 +1847,7 @@ static void ctcmpc_chx_send_sweep(fsm_in
 		ctcm_ccw_check_rc(wch, rc, "send sweep");
 
 done:
-	return;
+	;
 }
 
 
diff -u -p a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1177,7 +1177,7 @@ static void qeth_notify_skbs(struct qeth
 			skb = skb_queue_next(&buf->skb_list, skb);
 	}
 out:
-	return;
+	;
 }
 
 static void qeth_release_skbs(struct qeth_qdio_out_buffer *buf)
@@ -3576,7 +3576,7 @@ static void qeth_qdio_cq_handler(struct
 		card->perf_stats.cq_time += delta_t;
 	}
 out:
-	return;
+	;
 }
 
 void qeth_qdio_input_handler(struct ccw_device *ccwdev, unsigned int qdio_err,
@@ -4709,7 +4709,7 @@ out_offline:
 	if (ddev_offline == 1)
 		ccw_device_set_offline(ddev);
 out:
-	return;
+	;
 }
 
 static inline void qeth_qdio_establish_cq(struct qeth_card *card,
diff -u -p a/drivers/scsi/bfa/bfad_debugfs.c b/drivers/scsi/bfa/bfad_debugfs.c
--- a/drivers/scsi/bfa/bfad_debugfs.c
+++ b/drivers/scsi/bfa/bfad_debugfs.c
@@ -519,7 +519,7 @@ bfad_debugfs_init(struct bfad_port_s *po
 	}
 
 err:
-	return;
+	;
 }
 
 inline void
diff -u -p a/drivers/scsi/csiostor/csio_hw.c b/drivers/scsi/csiostor/csio_hw.c
--- a/drivers/scsi/csiostor/csio_hw.c
+++ b/drivers/scsi/csiostor/csio_hw.c
@@ -2148,7 +2148,7 @@ csio_hw_configure(struct csio_hw *hw)
 	} /* if not master */
 
 out:
-	return;
+	;
 }
 
 /*
@@ -2218,7 +2218,7 @@ csio_hw_initialize(struct csio_hw *hw)
 free_and_out:
 	mempool_free(mbp, hw->mb_mempool);
 out:
-	return;
+	;
 }
 
 #define PF_INTR_MASK (PFSW | PFCIM)
diff -u -p a/drivers/scsi/fnic/fnic_fcs.c b/drivers/scsi/fnic/fnic_fcs.c
--- a/drivers/scsi/fnic/fnic_fcs.c
+++ b/drivers/scsi/fnic/fnic_fcs.c
@@ -424,7 +424,7 @@ static void fnic_fcoe_process_vlan_resp(
 	sol_time = jiffies + msecs_to_jiffies(FCOE_CTLR_START_DELAY);
 	mod_timer(&fnic->fip_timer, round_jiffies(sol_time));
 out:
-	return;
+	;
 }
 
 static void fnic_fcoe_start_fcf_disc(struct fnic *fnic)
diff -u -p a/drivers/scsi/qla2xxx/qla_init.c b/drivers/scsi/qla2xxx/qla_init.c
--- a/drivers/scsi/qla2xxx/qla_init.c
+++ b/drivers/scsi/qla2xxx/qla_init.c
@@ -1179,7 +1179,7 @@ force:
 	qla25xx_write_risc_sema_reg(vha, RISC_SEMAPHORE_FORCE_SET);
 
 acquired:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/scsi/qla2xxx/qla_nx2.c b/drivers/scsi/qla2xxx/qla_nx2.c
--- a/drivers/scsi/qla2xxx/qla_nx2.c
+++ b/drivers/scsi/qla2xxx/qla_nx2.c
@@ -1497,7 +1497,7 @@ exit_read_template_error:
 	vfree(vha->reset_tmplt.buff);
 
 exit_read_reset_template:
-	return;
+	;
 }
 
 void
diff -u -p a/drivers/scsi/qla4xxx/ql4_83xx.c b/drivers/scsi/qla4xxx/ql4_83xx.c
--- a/drivers/scsi/qla4xxx/ql4_83xx.c
+++ b/drivers/scsi/qla4xxx/ql4_83xx.c
@@ -962,7 +962,7 @@ exit_read_template_error:
 	vfree(ha->reset_tmplt.buff);
 
 exit_read_reset_template:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/scsi/qla4xxx/ql4_os.c b/drivers/scsi/qla4xxx/ql4_os.c
--- a/drivers/scsi/qla4xxx/ql4_os.c
+++ b/drivers/scsi/qla4xxx/ql4_os.c
@@ -1819,7 +1819,7 @@ free_stats:
 	dma_free_coherent(&ha->pdev->dev, stats_size, ql_iscsi_stats,
 			  iscsi_stats_dma);
 exit_get_stats:
-	return;
+	;
 }
 
 static enum blk_eh_timer_return qla4xxx_eh_cmd_timed_out(struct scsi_cmnd *sc)
diff -u -p a/drivers/scsi/sym53c8xx_2/sym_hipd.c b/drivers/scsi/sym53c8xx_2/sym_hipd.c
--- a/drivers/scsi/sym53c8xx_2/sym_hipd.c
+++ b/drivers/scsi/sym53c8xx_2/sym_hipd.c
@@ -4637,7 +4637,7 @@ out_clrack:
 	OUTL_DSP(np, SCRIPTA_BA(np, clrack));
 	return;
 out_stuck:
-	return;
+	;
 }
 
 /*
@@ -5090,7 +5090,7 @@ static void sym_alloc_lcb_tags (struct s
 
 	return;
 fail:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/scsi/ufs/ufshcd.c b/drivers/scsi/ufs/ufshcd.c
--- a/drivers/scsi/ufs/ufshcd.c
+++ b/drivers/scsi/ufs/ufshcd.c
@@ -2740,7 +2740,7 @@ static void ufshcd_async_scan(void *data
 	scsi_scan_host(hba->host);
 	pm_runtime_put_sync(hba->dev);
 out:
-	return;
+	;
 }
 
 static struct scsi_host_template ufshcd_driver_template = {
diff -u -p a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -355,7 +355,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu
 	}
 
 out:
-	return;
+	;
 }
 
 void
diff -u -p a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -201,7 +201,7 @@ void ll_ioepoch_close(struct inode *inod
 	ll_done_writing_attr(inode, op_data);
 
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -201,7 +201,7 @@ void ll_ioepoch_close(struct inode *inod
 	ll_done_writing_attr(inode, op_data);
 
 out:
-	return;
+	;
 }
 
 /**
(sfw_test_unit_t *tsu
 	}
 
 out:
-	return;
+	;
 }
 
 void
diff -u -p a/drivers/staging/octeon-usb/octeon-hcd.c b/drivers/staging/octeon-usb/octeon-hcd.c
--- a/drivers/staging/octeon-usb/octeon-hcd.c
+++ b/drivers/staging/octeon-usb/octeon-hcd.c
@@ -2041,7 +2041,7 @@ static void __cvmx_usb_perform_complete(
 					 transaction->urb);
 	kfree(transaction);
 done:
-	return;
+	;
 }
 
 
diff -u -p a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -7700,7 +7700,7 @@ void survey_timer_hdl(struct adapter *pa
 
 
 exit_survey_timer_hdl:
-	return;
+	;
 }
 
 void link_timer_hdl(struct adapter *padapter)
diff -u -p a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_dm.c
@@ -199,7 +199,7 @@ void rtl8188e_HalDmWatchDog(struct adapt
 skip_dm:
 	/*  Check GPIO to determine current RF on/off and Pbc status. */
 	/*  Check Hardware Radio ON/OFF or not */
-	return;
+	;
 }
 
 void rtl8188e_init_dm_priv(struct adapter *Adapter)
diff -u -p a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_hal_init.c
@@ -955,7 +955,7 @@ static void ReadEFuseByIC(struct adapter
 	Hal_EfuseReadEFuse88E(Adapter, _offset, _size_byte, pbuf, bPseudoTest);
 
 exit:
-	return;
+	;
 }
 
 static void ReadEFuse_Pseudo(struct adapter *Adapter, u8 efuseType, u16 _offset, u16 _size_byte, u8 *pbuf, bool bPseudoTest)
diff -u -p a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -249,7 +249,7 @@ void rtw_free_netdev(struct net_device *
 	free_netdev(netdev);
 
 RETURN:
-	return;
+	;
 }
 
 int rtw_change_ifname(struct adapter *padapter, const char *ifname)
diff -u -p a/drivers/staging/rtl8712/rtl8712_cmd.c b/drivers/staging/rtl8712/rtl8712_cmd.c
--- a/drivers/staging/rtl8712/rtl8712_cmd.c
+++ b/drivers/staging/rtl8712/rtl8712_cmd.c
@@ -475,5 +475,5 @@ void r8712_event_handle(struct _adapter
 		event_callback(padapter, (u8 *)peventbuf);
 	pevt_priv->evt_done_cnt++;
 _abort_event_:
-	return;
+	;
 }
diff -u -p a/drivers/staging/rts5139/rts51x_transport.c b/drivers/staging/rts5139/rts51x_transport.c
--- a/drivers/staging/rts5139/rts51x_transport.c
+++ b/drivers/staging/rts5139/rts51x_transport.c
@@ -732,5 +732,5 @@ void rts51x_invoke_transport(struct scsi
 	 * by issuing a port reset.  If that fails, try a class-specific
 	 * device reset. */
 Handle_Errors:
-	return;
+	;
 }
diff -u -p a/drivers/staging/tidspbridge/core/io_sm.c b/drivers/staging/tidspbridge/core/io_sm.c
--- a/drivers/staging/tidspbridge/core/io_sm.c
+++ b/drivers/staging/tidspbridge/core/io_sm.c
@@ -788,7 +788,7 @@ void io_cancel_chnl(struct io_mgr *hio_m
 
 	sm_interrupt_dsp(pio_mgr->bridge_context, MBX_PCPY_CLASS);
 func_end:
-	return;
+	;
 }
 
 
@@ -899,7 +899,7 @@ void io_dpc(unsigned long ref_data)
 	} while (serviced != requested);
 	pio_mgr->dpc_sched = requested;
 func_end:
-	return;
+	;
 }
 
 /*
@@ -964,7 +964,7 @@ void io_request_chnl(struct io_mgr *io_m
 	} else {
 	}
 func_end:
-	return;
+	;
 }
 
 /*
@@ -1136,7 +1136,7 @@ static void input_chnl(struct io_mgr *pi
 		notify_chnl_complete(pchnl, chnl_packet_obj);
 	}
 func_end:
-	return;
+	;
 }
 
 /*
@@ -1271,7 +1271,7 @@ static void notify_chnl_complete(struct
 	/* Notify that IO is complete */
 	ntfy_notify(pchnl->ntfy_obj, DSP_STREAMIOCOMPLETION);
 func_end:
-	return;
+	;
 }
 
 /*
@@ -1355,7 +1355,7 @@ static void output_chnl(struct io_mgr *p
 		ntfy_notify(pchnl->ntfy_obj, DSP_STREAMDONE);
 
 func_end:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/staging/tidspbridge/rmgr/node.c b/drivers/staging/tidspbridge/rmgr/node.c
--- a/drivers/staging/tidspbridge/rmgr/node.c
+++ b/drivers/staging/tidspbridge/rmgr/node.c
@@ -2473,7 +2473,7 @@ static void delete_node(struct node_obje
 	kfree(hnode);
 	hnode = NULL;
 func_end:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/staging/wlan-ng/hfa384x_usb.c b/drivers/staging/wlan-ng/hfa384x_usb.c
--- a/drivers/staging/wlan-ng/hfa384x_usb.c
+++ b/drivers/staging/wlan-ng/hfa384x_usb.c
@@ -3541,7 +3541,7 @@ static void hfa384x_usbin_rx(wlandevice_
 	}
 
 done:
-	return;
+	;
 }
 
 /*----------------------------------------------------------------
diff -u -p a/drivers/tty/amiserial.c b/drivers/tty/amiserial.c
--- a/drivers/tty/amiserial.c
+++ b/drivers/tty/amiserial.c
@@ -332,7 +332,7 @@ static void receive_chars(struct serial_
 		tty_insert_flip_char(&info->tport, 0, TTY_OVERRUN);
 	tty_flip_buffer_push(&info->tport);
 out:
-	return;
+	;
 }
 
 static void transmit_chars(struct serial_state *info)
diff -u -p a/drivers/tty/nozomi.c b/drivers/tty/nozomi.c
--- a/drivers/tty/nozomi.c
+++ b/drivers/tty/nozomi.c
@@ -470,7 +470,7 @@ static void read_mem32(u32 *buf, const v
 		ptr++;
 	}
 out:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/tty/serial/68328serial.c b/drivers/tty/serial/68328serial.c
--- a/drivers/tty/serial/68328serial.c
+++ b/drivers/tty/serial/68328serial.c
@@ -338,7 +338,7 @@ static void transmit_chars(struct m68k_s
 
 clear_and_return:
 	/* Clear interrupt (should be auto)*/
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/usb/gadget/mv_udc_core.c b/drivers/usb/gadget/mv_udc_core.c
--- a/drivers/usb/gadget/mv_udc_core.c
+++ b/drivers/usb/gadget/mv_udc_core.c
@@ -1589,7 +1589,7 @@ static void ch9clearfeature(struct mv_ud
 	if (udc_prime_status(udc, EP_DIR_IN, 0, true))
 		ep0_stall(udc);
 out:
-	return;
+	;
 }
 
 static void ch9setfeature(struct mv_udc *udc, struct usb_ctrlrequest *setup)
@@ -1641,7 +1641,7 @@ static void ch9setfeature(struct mv_udc
 	if (udc_prime_status(udc, EP_DIR_IN, 0, true))
 		ep0_stall(udc);
 out:
-	return;
+	;
 }
 
 static void handle_setup_packet(struct mv_udc *udc, u8 ep_num,
diff -u -p a/drivers/usb/mon/mon_main.c b/drivers/usb/mon/mon_main.c
--- a/drivers/usb/mon/mon_main.c
+++ b/drivers/usb/mon/mon_main.c
@@ -302,7 +302,7 @@ static void mon_bus_init(struct usb_bus
 	return;
 
 err_alloc:
-	return;
+	;
 }
 
 static void mon_bus0_init(void)
diff -u -p a/drivers/usb/wusbcore/wa-nep.c b/drivers/usb/wusbcore/wa-nep.c
--- a/drivers/usb/wusbcore/wa-nep.c
+++ b/drivers/usb/wusbcore/wa-nep.c
@@ -251,7 +251,7 @@ static void wa_nep_cb(struct urb *urb)
 		wa_reset_all(wa);
 	}
 out:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/usb/wusbcore/wa-xfer.c b/drivers/usb/wusbcore/wa-xfer.c
--- a/drivers/usb/wusbcore/wa-xfer.c
+++ b/drivers/usb/wusbcore/wa-xfer.c
@@ -2610,7 +2610,7 @@ static void wa_dti_cb(struct urb *urb)
 		}
 	}
 out:
-	return;
+	;
 }
 
 /*
diff -u -p a/drivers/video/aty/aty128fb.c b/drivers/video/aty/aty128fb.c
--- a/drivers/video/aty/aty128fb.c
+++ b/drivers/video/aty/aty128fb.c
@@ -1863,7 +1863,7 @@ static void aty128_bl_init(struct aty128
 	return;
 
 error:
-	return;
+	;
 }
 
 static void aty128_bl_exit(struct backlight_device *bd)
diff -u -p a/drivers/video/aty/atyfb_base.c b/drivers/video/aty/atyfb_base.c
--- a/drivers/video/aty/atyfb_base.c
+++ b/drivers/video/aty/atyfb_base.c
@@ -2260,7 +2260,7 @@ static void aty_bl_init(struct atyfb_par
 	return;
 
 error:
-	return;
+	;
 }
 
 #ifdef CONFIG_PCI
diff -u -p a/drivers/video/nvidia/nv_backlight.c b/drivers/video/nvidia/nv_backlight.c
--- a/drivers/video/nvidia/nv_backlight.c
+++ b/drivers/video/nvidia/nv_backlight.c
@@ -135,7 +135,7 @@ void nvidia_bl_init(struct nvidia_par *p
 	return;
 
 error:
-	return;
+	;
 }
 
 void nvidia_bl_exit(struct nvidia_par *par)
diff -u -p a/drivers/video/riva/fbdev.c b/drivers/video/riva/fbdev.c
--- a/drivers/video/riva/fbdev.c
+++ b/drivers/video/riva/fbdev.c
@@ -379,7 +379,7 @@ static void riva_bl_init(struct riva_par
 	return;
 
 error:
-	return;
+	;
 }
 
 static void riva_bl_exit(struct fb_info *info)
diff -u -p a/fs/buffer.c b/fs/buffer.c
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1557,7 +1557,7 @@ void block_invalidatepage(struct page *p
 	if (offset == 0)
 		try_to_release_page(page, 0);
 out:
-	return;
+	;
 }
 EXPORT_SYMBOL(block_invalidatepage);
 
diff -u -p a/fs/coredump.c b/fs/coredump.c
--- a/fs/coredump.c
+++ b/fs/coredump.c
@@ -676,7 +676,7 @@ fail_unlock:
 fail_creds:
 	put_cred(cred);
 fail:
-	return;
+	;
 }
 
 /*
diff -u -p a/fs/dlm/recover.c b/fs/dlm/recover.c
--- a/fs/dlm/recover.c
+++ b/fs/dlm/recover.c
@@ -808,7 +808,7 @@ static void recover_lvb(struct dlm_rsb *
 		memset(r->res_lvbptr, 0, lvblen);
 	}
  out:
-	return;
+	;
 }
 
 /* All master rsb's flagged RECOVER_CONVERT need to be looked at.  The locks
diff -u -p a/fs/ecryptfs/crypto.c b/fs/ecryptfs/crypto.c
--- a/fs/ecryptfs/crypto.c
+++ b/fs/ecryptfs/crypto.c
@@ -1860,7 +1860,7 @@ static void ecryptfs_encode_for_filename
 		block_num++;
 	}
 out:
-	return;
+	;
 }
 
 static size_t ecryptfs_max_decoded_size(size_t encoded_size)
@@ -1925,7 +1925,7 @@ ecryptfs_decode_from_filename(unsigned c
 	}
 	(*dst_size) = dst_byte_offset;
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/fs/ext3/inode.c b/fs/ext3/inode.c
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -3525,7 +3525,7 @@ void ext3_dirty_inode(struct inode *inod
 	}
 	ext3_journal_stop(handle);
 out:
-	return;
+	;
 }
 
 #if 0
diff -u -p a/fs/ext4/inode.c b/fs/ext4/inode.c
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4959,7 +4959,7 @@ void ext4_dirty_inode(struct inode *inod
 
 	ext4_journal_stop(handle);
 out:
-	return;
+	;
 }
 
 #if 0
diff -u -p a/fs/hpfs/dnode.c b/fs/hpfs/dnode.c
--- a/fs/hpfs/dnode.c
+++ b/fs/hpfs/dnode.c
@@ -64,7 +64,7 @@ void hpfs_del_pos(struct inode *inode, l
 	return;
 	not_f:
 	/*printk("HPFS: warning: position pointer %p->%08x not found\n", pos, (int)*pos);*/
-	return;
+	;
 }
 
 static void for_all_poss(struct inode *inode, void (*f)(loff_t *, loff_t, loff_t),
diff -u -p a/fs/jbd/transaction.c b/fs/jbd/transaction.c
--- a/fs/jbd/transaction.c
+++ b/fs/jbd/transaction.c
@@ -1682,7 +1682,7 @@ __journal_try_to_free_buffer(journal_t *
 	}
 	spin_unlock(&journal->j_list_lock);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -1830,7 +1830,7 @@ __journal_try_to_free_buffer(journal_t *
 	}
 	spin_unlock(&journal->j_list_lock);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/fs/ocfs2/dlm/dlmthread.c b/fs/ocfs2/dlm/dlmthread.c
--- a/fs/ocfs2/dlm/dlmthread.c
+++ b/fs/ocfs2/dlm/dlmthread.c
@@ -435,7 +435,7 @@ blocked:
 	}
 
 leave:
-	return;
+	;
 }
 
 /* must have NO locks when calling this with res !=NULL * */
diff -u -p a/fs/ocfs2/dlmglue.c b/fs/ocfs2/dlmglue.c
--- a/fs/ocfs2/dlmglue.c
+++ b/fs/ocfs2/dlmglue.c
@@ -1766,7 +1766,7 @@ void ocfs2_open_unlock(struct inode *ino
 				     DLM_LOCK_EX);
 
 out:
-	return;
+	;
 }
 
 static int ocfs2_flock_handle_signal(struct ocfs2_lock_res *lockres,
diff -u -p a/fs/ocfs2/inode.c b/fs/ocfs2/inode.c
--- a/fs/ocfs2/inode.c
+++ b/fs/ocfs2/inode.c
@@ -1050,7 +1050,7 @@ bail_unlock_nfs_sync:
 bail_unblock:
 	ocfs2_unblock_signals(&oldset);
 bail:
-	return;
+	;
 }
 
 static void ocfs2_clear_inode(struct inode *inode)
diff -u -p a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2734,7 +2734,7 @@ static void proc_flush_task_mnt(struct v
 out_put_leader:
 	dput(leader);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/fs/reiserfs/inode.c b/fs/reiserfs/inode.c
--- a/fs/reiserfs/inode.c
+++ b/fs/reiserfs/inode.c
@@ -3029,7 +3029,7 @@ static void reiserfs_invalidatepage(stru
 		/* maybe should BUG_ON(!ret); - neilb */
 	}
       out:
-	return;
+	;
 }
 
 static int reiserfs_set_page_dirty(struct page *page)
diff -u -p a/kernel/audit.c b/kernel/audit.c
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1424,7 +1424,7 @@ static void audit_log_vformat(struct aud
 out_va_end:
 	va_end(args2);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/mm/highmem.c b/mm/highmem.c
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -408,7 +408,7 @@ void set_page_address(struct page *page,
 		spin_unlock_irqrestore(&pas->lock, flags);
 	}
 done:
-	return;
+	;
 }
 
 void __init page_address_init(void)
diff -u -p a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -135,7 +135,7 @@ static void hugetlb_cgroup_move_parent(i
 
 	set_hugetlb_cgroup(page, parent);
 out:
-	return;
+	;
 }
 
 /*
diff -u -p a/net/batman-adv/network-coding.c b/net/batman-adv/network-coding.c
--- a/net/batman-adv/network-coding.c
+++ b/net/batman-adv/network-coding.c
@@ -1572,7 +1572,7 @@ free_skb:
 free_nc_path:
 	batadv_nc_path_free_ref(nc_path);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -423,7 +423,7 @@ void batadv_interface_rx(struct net_devi
 dropped:
 	kfree_skb(skb);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1216,7 +1216,7 @@ void fib_select_default(struct fib_resul
 		fib_result_assign(res, last_resort);
 	tb->tb_default = last_idx;
 out:
-	return;
+	;
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
diff -u -p a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1346,7 +1346,7 @@ void ip_mc_inc_group(struct in_device *i
 	if (!in_dev->dead)
 		ip_rt_multicast_event(in_dev);
 out:
-	return;
+	;
 }
 EXPORT_SYMBOL(ip_mc_inc_group);
 
diff -u -p a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -1172,5 +1172,5 @@ cleanup_subsys:
 	unregister_pernet_subsys(&tcp_net_metrics_ops);
 
 cleanup:
-	return;
+	;
 }
diff -u -p a/net/ipv6/ah6.c b/net/ipv6/ah6.c
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -207,7 +207,7 @@ static void ipv6_rearrange_destopt(struc
 	}
 	/* Note: ok if len == 0 */
 bad:
-	return;
+	;
 }
 #else
 static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *destopt) {}
diff -u -p a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1007,7 +1007,7 @@ static void ndisc_recv_rs(struct sk_buff
 		neigh_release(neigh);
 	}
 out:
-	return;
+	;
 }
 
 static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *opt)
diff -u -p a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -125,7 +125,7 @@ static void ipx_remove_socket(struct soc
 	spin_unlock_bh(&intrfc->if_sklist_lock);
 	ipxitf_put(intrfc);
 out:
-	return;
+	;
 }
 
 static void ipx_destroy_socket(struct sock *sk)
diff -u -p a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1347,7 +1347,7 @@ static void l2tp_tunnel_destruct(struct
 	if (sk->sk_destruct)
 		(*sk->sk_destruct)(sk);
 end:
-	return;
+	;
 }
 
 /* When the tunnel is closed, all the attached sessions need to go too.
diff -u -p a/security/tomoyo/audit.c b/security/tomoyo/audit.c
--- a/security/tomoyo/audit.c
+++ b/security/tomoyo/audit.c
@@ -399,7 +399,7 @@ void tomoyo_write_log2(struct tomoyo_req
 	}
 	wake_up(&tomoyo_log_wait);
 out:
-	return;
+	;
 }
 
 /**
diff -u -p a/sound/oss/vidc.c b/sound/oss/vidc.c
--- a/sound/oss/vidc.c
+++ b/sound/oss/vidc.c
@@ -502,7 +502,7 @@ mem_failed:
 mixer_failed:
 	sound_unload_audiodev(adev);
 audio_failed:
-	return;
+	;
 }
 
 static int __init probe_vidc(struct address_info *hw_config)
