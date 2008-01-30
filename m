From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [BUILD FAILURE] 2.6.24-git7 section type conflict at various drivers
 on powerpc
Date: Wed, 30 Jan 2008 21:49:59 +0530
Message-ID: <47A0A3AF.5050005@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Sam Ravnborg <sam@ravnborg.org>,
	Andy Whitcroft <apw@shadowen.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756471AbYA3Qf3@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Following are the different build failure with 2.6.24-git7 kernel on the powerpc

drivers/net/typhoon.c:181: error: typhoon_card_info causes a section type conflict
make[2]: *** [drivers/net/typhoon.o] Error 1

drivers/net/natsemi.c:259: error: natsemi_pci_info causes a section type conflict
make[2]: *** [drivers/net/natsemi.o] Error 1

drivers/net/bnx2.c:95: error: board_info causes a section type conflict
make[2]: *** [drivers/net/bnx2.o] Error 1

drivers/net/via-velocity.c:454: error: velocity_id_table causes a section type conflict
make[2]: *** [drivers/net/via-velocity.o] Error 1


Following are warning with section mismatch CONFIG_DEBUG_SECTION_MISMATCH enabled,

WARNING: kernel/built-in.o(.text+0x423f4): Section mismatch in reference from the function .enable_nonboot_cpus() to the function .cpuinit.text:._cpu_up()
The function  .enable_nonboot_cpus() references
the function __cpuinit ._cpu_up().
This is often because .enable_nonboot_cpus lacks a __cpuinit 
annotation or the annotation of ._cpu_up is wrong.

WARNING: drivers/net/ibm_newemac/ibm_newemac.o(.devinit.text+0x1bb4): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.tah_detach()
The function __devinit .emac_probe() references
a function __devexit .tah_detach().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.tah_detach() so it may be used outside an exit section.

WARNING: drivers/net/ibm_newemac/ibm_newemac.o(.devinit.text+0x1bd0): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.rgmii_detach()
The function __devinit .emac_probe() references
a function __devexit .rgmii_detach().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.rgmii_detach() so it may be used outside an exit section.

WARNING: drivers/net/ibm_newemac/ibm_newemac.o(.devinit.text+0x1bec): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.zmii_detach()
The function __devinit .emac_probe() references
a function __devexit .zmii_detach().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.zmii_detach() so it may be used outside an exit section.

WARNING: drivers/net/ibm_newemac/ibm_newemac.o(.devinit.text+0x1bfc): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.mal_unregister_commac()
The function __devinit .emac_probe() references
a function __devexit .mal_unregister_commac().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.mal_unregister_commac() so it may be used outside an exit section.

  LD      drivers/net/ibm_newemac/built-in.o
WARNING: drivers/net/ibm_newemac/built-in.o(.devinit.text+0x1bb4): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.tah_detach()
The function __devinit .emac_probe() references
a function __devexit .tah_detach().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.tah_detach() so it may be used outside an exit section.

WARNING: drivers/net/ibm_newemac/built-in.o(.devinit.text+0x1bd0): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.rgmii_detach()
The function __devinit .emac_probe() references
a function __devexit .rgmii_detach().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.rgmii_detach() so it may be used outside an exit section.

WARNING: drivers/net/ibm_newemac/built-in.o(.devinit.text+0x1bec): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.zmii_detach()
The function __devinit .emac_probe() references
a function __devexit .zmii_detach().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.zmii_detach() so it may be used outside an exit section.

WARNING: drivers/net/ibm_newemac/built-in.o(.devinit.text+0x1bfc): Section mismatch in reference from the function .emac_probe() to the function .devexit.text:.mal_unregister_commac()
The function __devinit .emac_probe() references
a function __devexit .mal_unregister_commac().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
.mal_unregister_commac() so it may be used outside an exit section.

WARNING: drivers/net/mlx4/mlx4_core.o(.text+0x6cf8): Section mismatch in reference from the function .mlx4_init_icm() to the function .devinit.text:.mlx4_init_cmpt_table()
The function  .mlx4_init_icm() references
the function __devinit .mlx4_init_cmpt_table().
This is often because .mlx4_init_icm lacks a __devinit 
annotation or the annotation of .mlx4_init_cmpt_table is wrong.

WARNING: drivers/net/mlx4/mlx4_core.o(.text+0x728c): Section mismatch in reference from the function .mlx4_init_hca() to the function .devinit.text:.mlx4_load_fw()
The function  .mlx4_init_hca() references
the function __devinit .mlx4_load_fw().
This is often because .mlx4_init_hca lacks a __devinit 
annotation or the annotation of .mlx4_load_fw is wrong.

WARNING: drivers/net/mlx4/mlx4_core.o(.text+0x7c98): Section mismatch in reference from the function .__mlx4_init_one() to the function .devinit.text:.mlx4_enable_msi_x()
The function  .__mlx4_init_one() references
the function __devinit .mlx4_enable_msi_x().
This is often because .__mlx4_init_one lacks a __devinit 
annotation or the annotation of .mlx4_enable_msi_x is wrong.

WARNING: drivers/net/mlx4/mlx4_core.o(.text+0x97ac): Section mismatch in reference from the function .mlx4_init_mr_table() to the function .devinit.text:.mlx4_buddy_init()
The function  .mlx4_init_mr_table() references
the function __devinit .mlx4_buddy_init().
This is often because .mlx4_init_mr_table lacks a __devinit 
annotation or the annotation of .mlx4_buddy_init is wrong.

  LD      drivers/net/mlx4/built-in.o
WARNING: drivers/net/mlx4/built-in.o(.text+0x6cf8): Section mismatch in reference from the function .mlx4_init_icm() to the function .devinit.text:.mlx4_init_cmpt_table()
The function  .mlx4_init_icm() references
the function __devinit .mlx4_init_cmpt_table().
This is often because .mlx4_init_icm lacks a __devinit 
annotation or the annotation of .mlx4_init_cmpt_table is wrong.

WARNING: drivers/net/mlx4/built-in.o(.text+0x728c): Section mismatch in reference from the function .mlx4_init_hca() to the function .devinit.text:.mlx4_load_fw()
The function  .mlx4_init_hca() references
the function __devinit .mlx4_load_fw().
This is often because .mlx4_init_hca lacks a __devinit 
annotation or the annotation of .mlx4_load_fw is wrong.

WARNING: drivers/net/mlx4/built-in.o(.text+0x7c98): Section mismatch in reference from the function .__mlx4_init_one() to the function .devinit.text:.mlx4_enable_msi_x()
The function  .__mlx4_init_one() references
the function __devinit .mlx4_enable_msi_x().
This is often because .__mlx4_init_one lacks a __devinit 
annotation or the annotation of .mlx4_enable_msi_x is wrong.

WARNING: drivers/net/mlx4/built-in.o(.text+0x97ac): Section mismatch in reference from the function .mlx4_init_mr_table() to the function .devinit.text:.mlx4_buddy_init()
The function  .mlx4_init_mr_table() references
the function __devinit .mlx4_buddy_init().
This is often because .mlx4_init_mr_table lacks a __devinit 
annotation or the annotation of .mlx4_buddy_init is wrong.

WARNING: drivers/net/tokenring/built-in.o(.text+0x4d64): Section mismatch in reference from the function .olympic_open() to the function .devinit.text:.olympic_init()
The function  .olympic_open() references
the function __devinit .olympic_init().
This is often because .olympic_open lacks a __devinit 
annotation or the annotation of .olympic_init is wrong.


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
