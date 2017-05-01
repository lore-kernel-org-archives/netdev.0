From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Mon, 01 May 2017 13:22:00 -0400
Message-ID: <f7ttw541ohz.fsf@redhat.com>
References: <20170430.120750.651845251226226775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36848 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751246AbdEARWE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 13:22:04 -0400
Received: by mail-qk0-f194.google.com with SMTP id y63so18058520qkd.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 10:22:03 -0700 (PDT)
In-Reply-To: <20170430.120750.651845251226226775.davem@davemloft.net> (David
        Miller's message of "Sun, 30 Apr 2017 12:07:50 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain

David Miller <davem@davemloft.net> writes:

> This is mainly a synchronization point, I still need to look
> more deeply into Alexei's -g issue.
>
> New in this version from v3:
>  - Remove tailcall from opcode table
>  - Rearrange relocations so that numbers match with LLVM ones
>  - Emit relocs properly so that dwarf2 debug info tests pass
>  - Handle negative load/store offsets properly, add tests
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Latest results from x86-64 and aarch64:

Both are little endian.  The only difference is for x86-64, I'm off of
commit 750eaa47f10f ("x86: Check plt_got before using .plt.got") and
for aarch64 I'm off of ee7e95efb981 ("merge_gnu_build_notes reloc
deletion").  I don't think that should matter.

I've also got a small incremental to fix some trailing whitespace, and
s/SPARC/BPF/ in one file, attached.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=0001-incremental.patch
Content-Description: incremental patch for git apply

diff --git a/bfd/elf64-bpf.c b/bfd/elf64-bpf.c
index a42f768..b04fdfb 100644
--- a/bfd/elf64-bpf.c
+++ b/bfd/elf64-bpf.c
@@ -39,7 +39,7 @@ _bfd_bpf_elf_reloc_type_lookup (bfd *abfd ATTRIBUTE_UNUSED,
     {
     case BFD_RELOC_NONE:
       return &_bfd_bpf_elf_howto_table[R_BPF_NONE];
-     
+
     case BFD_RELOC_BPF_WDISP16:
       return &_bfd_bpf_elf_howto_table[R_BPF_WDISP16];
 
diff --git a/gas/config/tc-bpf.c b/gas/config/tc-bpf.c
index 36393b7..d78f06f 100644
--- a/gas/config/tc-bpf.c
+++ b/gas/config/tc-bpf.c
@@ -1,4 +1,4 @@
-/* tc-bpf.c -- Assemble for the SPARC
+/* tc-bpf.c -- Assemble for BPF
    Copyright (C) 2017 Free Software Foundation, Inc.
    This file is part of GAS, the GNU Assembler.
 
@@ -153,7 +153,7 @@ output_insn (struct bpf_it *theinsn)
   valueT opc = theinsn->opcode;
   char *toP = frag_more (theinsn->imm64 ? 16 : 8);
   char code, regs;
-  
+
   code = opc >> (64 - 8);
   regs = opc >> (64 - (8 + 8));
 
@@ -317,7 +317,7 @@ md_assemble (char *str ATTRIBUTE_UNUSED)
 		      if (c != '0' || mask != 1)
 			goto error;
 		      mask = 10;
-		    }			  
+		    }
 		  the_insn.opcode |= (mask << 52);
 		  continue;
 		}
@@ -337,7 +337,7 @@ md_assemble (char *str ATTRIBUTE_UNUSED)
 		      if (c != '0' || mask != 1)
 			goto error;
 		      mask = 10;
-		    }			  
+		    }
 		  the_insn.opcode |= (mask << 48);
 		  continue;
 		}
diff --git a/gas/testsuite/gas/bpf/bpf.exp b/gas/testsuite/gas/bpf/bpf.exp
index 363fd2c..5a8d54c 100644
--- a/gas/testsuite/gas/bpf/bpf.exp
+++ b/gas/testsuite/gas/bpf/bpf.exp
@@ -4,15 +4,15 @@
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation; either version 3 of the License, or
 # (at your option) any later version.
-# 
+#
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
-# 
+#
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software
-# Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.  
+# Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.
 
 # BPF assembler testsuite
 
diff --git a/gdb/bpf-tdep.c b/gdb/bpf-tdep.c
index 6629f73..9cca3bc 100644
--- a/gdb/bpf-tdep.c
+++ b/gdb/bpf-tdep.c
@@ -192,7 +192,7 @@ bpf_gdbarch_init (struct gdbarch_info info, struct gdbarch_list *arches)
 
   tdep = XNEW (struct gdbarch_tdep);
   gdbarch = gdbarch_alloc (&info, tdep);
-  
+
   tdep->xxx = 0;
 
   set_gdbarch_num_regs (gdbarch, BPF_NUM_REGS);
diff --git a/opcodes/bpf-dis.c b/opcodes/bpf-dis.c
index 39656bf..e15acc1 100644
--- a/opcodes/bpf-dis.c
+++ b/opcodes/bpf-dis.c
@@ -79,7 +79,7 @@ print_insn_bpf (bfd_vma memaddr, disassemble_info *info)
     {
       getword = bfd_getl32;
       gethalf = bfd_getl16;
-    }  
+    }
 
   code = buffer[0];
   dest = (buffer[1] & 0xf0) >> 4;
-- 
2.9.3


--=-=-=
Content-Type: text/plain


x86-64:
  Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/bpf/bpf.exp ...
  FAIL: jump
  FAIL: call
  FAIL: imm64a
  Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/cfi/cfi.exp ...

aarch64 (pine64 board):
  Running /root/aarch64/git/binutils-gdb/gas/testsuite/gas/bpf/bpf.exp ...
  Running /root/aarch64/git/binutils-gdb/gas/testsuite/gas/cfi/cfi.exp ...


--=-=-=--
