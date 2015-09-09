From: Palmer Dabbelt <palmer@dabbelt.com>
Subject: [PATCH 05/13] Hide some of "struct elf_prstatus" behind #ifdef __KERNEL__
Date: Wed,  9 Sep 2015 14:08:14 -0700
Message-ID: <1441832902-28993-6-git-send-email-palmer@dabbelt.com>
References: <2644177.lVCYzIBfPW@wuerfel>
 <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Cc: 3chas3@gmail.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: hpa@zytor.com
Cc: mingo@redhat.com
Cc: plagnioj@jcrosoft.com
Cc: jikos@kernel.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-atm-general@lists.sourceforge.net
Cc: linux-fbdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: tglx@linutronix.de
Cc: tomi.valkeinen@ti.com
Cc: x86@kernel.org
Cc: Palmer Dabbelt <palmer@dabbelt.com>
In-Reply-To: <1441832902-28993-1-git-send-email-palmer@dabbelt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This one scares me: while I can't find any system calls that directly
take this as an argument, a comment in <linux/ptrace.h>

  "
   Generic ptrace interface that exports the architecture specific
   regsets using the corresponding NT_* types (which are also used in
   the core dump).  Please note that the NT_PRSTATUS note type in a
   core dump contains a full 'struct elf_prstatus'. But the
   user_regset for NT_PRSTATUS contains just the elf_gregset_t that is
   the pr_reg field of 'struct elf_prstatus'. For all the other
   user_regset flavors, the user_regset layout and the ELF core dump
   note payload are exactly the same layout.
  "

seems to indicate that it's possible to see this sometimes.  Since
this would only be visible to userspace in a somewhat convoluted
manner, I'm going to try and keep it as it was.

Signed-off-by: Palmer Dabbelt <palmer@dabbelt.com>
Reviewed-by: Andrew Waterman <waterman@eecs.berkeley.edu>
Reviewed-by: Albert Ou <aou@eecs.berkeley.edu>
---
 include/uapi/linux/elfcore.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/elfcore.h b/include/uapi/linux/elfcore.h
index 569737cfb557..f9320b588937 100644
--- a/include/uapi/linux/elfcore.h
+++ b/include/uapi/linux/elfcore.h
@@ -60,7 +60,7 @@ struct elf_prstatus
 	long	pr_instr;		/* Current instruction */
 #endif
 	elf_gregset_t pr_reg;	/* GP registers */
-#ifdef CONFIG_BINFMT_ELF_FDPIC
+#if defined(__KERNEL__) && defined(CONFIG_BINFMT_ELF_FDPIC)
 	/* When using FDPIC, the loadmap addresses need to be communicated
 	 * to GDB in order for GDB to do the necessary relocations.  The
 	 * fields (below) used to communicate this information are placed
-- 
2.4.6
