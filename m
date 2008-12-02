From: Yu Zhao <yu.zhao@intel.com>
Subject: [SR-IOV driver example 3/3 resend] VF driver: an independent PCI
	NIC driver
Date: Tue, 2 Dec 2008 17:57:57 +0800
Message-ID: <20081202095757.GC1974@yzhao12-linux.sh.intel.com>
References: <20081121183605.GA7810@yzhao12-linux.sh.intel.com>
	<20081202092741.GA1859@yzhao12-linux.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
        "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
        "matthew@wil.cx" <matthew@wil.cx>, "greg@kroah.com" <greg@kroah.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
        "Rose,
	Gregory V" <gregory.v.rose@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20081202092741.GA1859@yzhao12-linux.sh.intel.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch is the VF driver for Intel 82576 NIC. Since the VF appears
as the normal PCI device driver, this VF driver has no difference from
other PCI NIC drivers. It handles interrupt, DMA operations, etc. to
perform packet receiving and transmission.

How the design of the VF internals is up to the hardware vendor. So the
VF may have totally different register set from the PF, which means the
VF driver may have its own logics (rather than derive from PF driver)
to handle the hardware specific stuff.

This driver is a totally new driver, currently there is no logical-split
patches available. The attached single diff file includes code.

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="igbvf-0.5.2.diff"

From: Intel Corporation, LAN Access Division <e1000-devel@lists.sourceforge.net>
Signed-off-by: Yu Zhao <yu.zhao@intel.com>

diff -Npur igbvf-0.5.2/COPYING igbvf-0.5.2.orig/COPYING
--- igbvf-0.5.2/COPYING	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/COPYING	2008-11-26 02:08:29.000000000 +0800
@@ -0,0 +1,339 @@
+
+"This software program is licensed subject to the GNU General Public License 
+(GPL). Version 2, June 1991, available at 
+<http://www.fsf.org/copyleft/gpl.html>"
+
+GNU General Public License 
+
+Version 2, June 1991
+
+Copyright (C) 1989, 1991 Free Software Foundation, Inc.  
+59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
+
+Everyone is permitted to copy and distribute verbatim copies of this license
+document, but changing it is not allowed.
+
+Preamble
+
+The licenses for most software are designed to take away your freedom to 
+share and change it. By contrast, the GNU General Public License is intended
+to guarantee your freedom to share and change free software--to make sure 
+the software is free for all its users. This General Public License applies 
+to most of the Free Software Foundation's software and to any other program 
+whose authors commit to using it. (Some other Free Software Foundation 
+software is covered by the GNU Library General Public License instead.) You 
+can apply it to your programs, too.
+
+When we speak of free software, we are referring to freedom, not price. Our
+General Public Licenses are designed to make sure that you have the freedom 
+to distribute copies of free software (and charge for this service if you 
+wish), that you receive source code or can get it if you want it, that you 
+can change the software or use pieces of it in new free programs; and that 
+you know you can do these things.
+
+To protect your rights, we need to make restrictions that forbid anyone to 
+deny you these rights or to ask you to surrender the rights. These 
+restrictions translate to certain responsibilities for you if you distribute
+copies of the software, or if you modify it.
+
+For example, if you distribute copies of such a program, whether gratis or 
+for a fee, you must give the recipients all the rights that you have. You 
+must make sure that they, too, receive or can get the source code. And you 
+must show them these terms so they know their rights.
+ 
+We protect your rights with two steps: (1) copyright the software, and (2) 
+offer you this license which gives you legal permission to copy, distribute 
+and/or modify the software. 
+
+Also, for each author's protection and ours, we want to make certain that 
+everyone understands that there is no warranty for this free software. If 
+the software is modified by someone else and passed on, we want its 
+recipients to know that what they have is not the original, so that any 
+problems introduced by others will not reflect on the original authors' 
+reputations. 
+
+Finally, any free program is threatened constantly by software patents. We 
+wish to avoid the danger that redistributors of a free program will 
+individually obtain patent licenses, in effect making the program 
+proprietary. To prevent this, we have made it clear that any patent must be 
+licensed for everyone's free use or not licensed at all. 
+
+The precise terms and conditions for copying, distribution and modification 
+follow. 
+
+TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
+
+0. This License applies to any program or other work which contains a notice
+   placed by the copyright holder saying it may be distributed under the 
+   terms of this General Public License. The "Program", below, refers to any
+   such program or work, and a "work based on the Program" means either the 
+   Program or any derivative work under copyright law: that is to say, a 
+   work containing the Program or a portion of it, either verbatim or with 
+   modifications and/or translated into another language. (Hereinafter, 
+   translation is included without limitation in the term "modification".) 
+   Each licensee is addressed as "you". 
+
+   Activities other than copying, distribution and modification are not 
+   covered by this License; they are outside its scope. The act of running 
+   the Program is not restricted, and the output from the Program is covered 
+   only if its contents constitute a work based on the Program (independent 
+   of having been made by running the Program). Whether that is true depends
+   on what the Program does. 
+
+1. You may copy and distribute verbatim copies of the Program's source code 
+   as you receive it, in any medium, provided that you conspicuously and 
+   appropriately publish on each copy an appropriate copyright notice and 
+   disclaimer of warranty; keep intact all the notices that refer to this 
+   License and to the absence of any warranty; and give any other recipients 
+   of the Program a copy of this License along with the Program. 
+
+   You may charge a fee for the physical act of transferring a copy, and you 
+   may at your option offer warranty protection in exchange for a fee. 
+
+2. You may modify your copy or copies of the Program or any portion of it, 
+   thus forming a work based on the Program, and copy and distribute such 
+   modifications or work under the terms of Section 1 above, provided that 
+   you also meet all of these conditions: 
+
+   * a) You must cause the modified files to carry prominent notices stating 
+        that you changed the files and the date of any change. 
+
+   * b) You must cause any work that you distribute or publish, that in 
+        whole or in part contains or is derived from the Program or any part 
+        thereof, to be licensed as a whole at no charge to all third parties
+        under the terms of this License. 
+
+   * c) If the modified program normally reads commands interactively when 
+        run, you must cause it, when started running for such interactive 
+        use in the most ordinary way, to print or display an announcement 
+        including an appropriate copyright notice and a notice that there is
+        no warranty (or else, saying that you provide a warranty) and that 
+        users may redistribute the program under these conditions, and 
+        telling the user how to view a copy of this License. (Exception: if 
+        the Program itself is interactive but does not normally print such 
+        an announcement, your work based on the Program is not required to 
+        print an announcement.) 
+
+   These requirements apply to the modified work as a whole. If identifiable 
+   sections of that work are not derived from the Program, and can be 
+   reasonably considered independent and separate works in themselves, then 
+   this License, and its terms, do not apply to those sections when you 
+   distribute them as separate works. But when you distribute the same 
+   sections as part of a whole which is a work based on the Program, the 
+   distribution of the whole must be on the terms of this License, whose 
+   permissions for other licensees extend to the entire whole, and thus to 
+   each and every part regardless of who wrote it. 
+
+   Thus, it is not the intent of this section to claim rights or contest 
+   your rights to work written entirely by you; rather, the intent is to 
+   exercise the right to control the distribution of derivative or 
+   collective works based on the Program. 
+
+   In addition, mere aggregation of another work not based on the Program 
+   with the Program (or with a work based on the Program) on a volume of a 
+   storage or distribution medium does not bring the other work under the 
+   scope of this License. 
+
+3. You may copy and distribute the Program (or a work based on it, under 
+   Section 2) in object code or executable form under the terms of Sections 
+   1 and 2 above provided that you also do one of the following: 
+
+   * a) Accompany it with the complete corresponding machine-readable source 
+        code, which must be distributed under the terms of Sections 1 and 2 
+        above on a medium customarily used for software interchange; or, 
+
+   * b) Accompany it with a written offer, valid for at least three years, 
+        to give any third party, for a charge no more than your cost of 
+        physically performing source distribution, a complete machine-
+        readable copy of the corresponding source code, to be distributed 
+        under the terms of Sections 1 and 2 above on a medium customarily 
+        used for software interchange; or, 
+
+   * c) Accompany it with the information you received as to the offer to 
+        distribute corresponding source code. (This alternative is allowed 
+        only for noncommercial distribution and only if you received the 
+        program in object code or executable form with such an offer, in 
+        accord with Subsection b above.) 
+
+   The source code for a work means the preferred form of the work for 
+   making modifications to it. For an executable work, complete source code 
+   means all the source code for all modules it contains, plus any 
+   associated interface definition files, plus the scripts used to control 
+   compilation and installation of the executable. However, as a special 
+   exception, the source code distributed need not include anything that is 
+   normally distributed (in either source or binary form) with the major 
+   components (compiler, kernel, and so on) of the operating system on which
+   the executable runs, unless that component itself accompanies the 
+   executable. 
+
+   If distribution of executable or object code is made by offering access 
+   to copy from a designated place, then offering equivalent access to copy 
+   the source code from the same place counts as distribution of the source 
+   code, even though third parties are not compelled to copy the source 
+   along with the object code. 
+
+4. You may not copy, modify, sublicense, or distribute the Program except as
+   expressly provided under this License. Any attempt otherwise to copy, 
+   modify, sublicense or distribute the Program is void, and will 
+   automatically terminate your rights under this License. However, parties 
+   who have received copies, or rights, from you under this License will not
+   have their licenses terminated so long as such parties remain in full 
+   compliance. 
+
+5. You are not required to accept this License, since you have not signed 
+   it. However, nothing else grants you permission to modify or distribute 
+   the Program or its derivative works. These actions are prohibited by law 
+   if you do not accept this License. Therefore, by modifying or 
+   distributing the Program (or any work based on the Program), you 
+   indicate your acceptance of this License to do so, and all its terms and
+   conditions for copying, distributing or modifying the Program or works 
+   based on it. 
+
+6. Each time you redistribute the Program (or any work based on the 
+   Program), the recipient automatically receives a license from the 
+   original licensor to copy, distribute or modify the Program subject to 
+   these terms and conditions. You may not impose any further restrictions 
+   on the recipients' exercise of the rights granted herein. You are not 
+   responsible for enforcing compliance by third parties to this License. 
+
+7. If, as a consequence of a court judgment or allegation of patent 
+   infringement or for any other reason (not limited to patent issues), 
+   conditions are imposed on you (whether by court order, agreement or 
+   otherwise) that contradict the conditions of this License, they do not 
+   excuse you from the conditions of this License. If you cannot distribute 
+   so as to satisfy simultaneously your obligations under this License and 
+   any other pertinent obligations, then as a consequence you may not 
+   distribute the Program at all. For example, if a patent license would 
+   not permit royalty-free redistribution of the Program by all those who 
+   receive copies directly or indirectly through you, then the only way you 
+   could satisfy both it and this License would be to refrain entirely from 
+   distribution of the Program. 
+
+   If any portion of this section is held invalid or unenforceable under any
+   particular circumstance, the balance of the section is intended to apply
+   and the section as a whole is intended to apply in other circumstances. 
+
+   It is not the purpose of this section to induce you to infringe any 
+   patents or other property right claims or to contest validity of any 
+   such claims; this section has the sole purpose of protecting the 
+   integrity of the free software distribution system, which is implemented 
+   by public license practices. Many people have made generous contributions
+   to the wide range of software distributed through that system in 
+   reliance on consistent application of that system; it is up to the 
+   author/donor to decide if he or she is willing to distribute software 
+   through any other system and a licensee cannot impose that choice. 
+
+   This section is intended to make thoroughly clear what is believed to be 
+   a consequence of the rest of this License. 
+
+8. If the distribution and/or use of the Program is restricted in certain 
+   countries either by patents or by copyrighted interfaces, the original 
+   copyright holder who places the Program under this License may add an 
+   explicit geographical distribution limitation excluding those countries, 
+   so that distribution is permitted only in or among countries not thus 
+   excluded. In such case, this License incorporates the limitation as if 
+   written in the body of this License. 
+
+9. The Free Software Foundation may publish revised and/or new versions of 
+   the General Public License from time to time. Such new versions will be 
+   similar in spirit to the present version, but may differ in detail to 
+   address new problems or concerns. 
+
+   Each version is given a distinguishing version number. If the Program 
+   specifies a version number of this License which applies to it and "any 
+   later version", you have the option of following the terms and 
+   conditions either of that version or of any later version published by 
+   the Free Software Foundation. If the Program does not specify a version 
+   number of this License, you may choose any version ever published by the 
+   Free Software Foundation. 
+
+10. If you wish to incorporate parts of the Program into other free programs
+    whose distribution conditions are different, write to the author to ask 
+    for permission. For software which is copyrighted by the Free Software 
+    Foundation, write to the Free Software Foundation; we sometimes make 
+    exceptions for this. Our decision will be guided by the two goals of 
+    preserving the free status of all derivatives of our free software and 
+    of promoting the sharing and reuse of software generally. 
+
+   NO WARRANTY
+
+11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY 
+    FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN 
+    OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES 
+    PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER 
+    EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
+    WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
+    ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH 
+    YOU. SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL 
+    NECESSARY SERVICING, REPAIR OR CORRECTION. 
+
+12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING 
+    WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR 
+    REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR 
+    DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL 
+    DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM 
+    (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED 
+    INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF 
+    THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR 
+    OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
+
+END OF TERMS AND CONDITIONS
+
+How to Apply These Terms to Your New Programs
+
+If you develop a new program, and you want it to be of the greatest 
+possible use to the public, the best way to achieve this is to make it free 
+software which everyone can redistribute and change under these terms. 
+
+To do so, attach the following notices to the program. It is safest to 
+attach them to the start of each source file to most effectively convey the
+exclusion of warranty; and each file should have at least the "copyright" 
+line and a pointer to where the full notice is found. 
+
+one line to give the program's name and an idea of what it does.
+Copyright (C) yyyy  name of author
+
+This program is free software; you can redistribute it and/or modify it 
+under the terms of the GNU General Public License as published by the Free 
+Software Foundation; either version 2 of the License, or (at your option) 
+any later version.
+
+This program is distributed in the hope that it will be useful, but WITHOUT 
+ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+more details.
+
+You should have received a copy of the GNU General Public License along with
+this program; if not, write to the Free Software Foundation, Inc., 59 
+Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+Also add information on how to contact you by electronic and paper mail. 
+
+If the program is interactive, make it output a short notice like this when 
+it starts in an interactive mode: 
+
+Gnomovision version 69, Copyright (C) year name of author Gnomovision comes 
+with ABSOLUTELY NO WARRANTY; for details type 'show w'.  This is free 
+software, and you are welcome to redistribute it under certain conditions; 
+type 'show c' for details.
+
+The hypothetical commands 'show w' and 'show c' should show the appropriate 
+parts of the General Public License. Of course, the commands you use may be 
+called something other than 'show w' and 'show c'; they could even be 
+mouse-clicks or menu items--whatever suits your program. 
+
+You should also get your employer (if you work as a programmer) or your 
+school, if any, to sign a "copyright disclaimer" for the program, if 
+necessary. Here is a sample; alter the names: 
+
+Yoyodyne, Inc., hereby disclaims all copyright interest in the program 
+'Gnomovision' (which makes passes at compilers) written by James Hacker.
+
+signature of Ty Coon, 1 April 1989
+Ty Coon, President of Vice
+
+This General Public License does not permit incorporating your program into 
+proprietary programs. If your program is a subroutine library, you may 
+consider it more useful to permit linking proprietary applications with the 
+library. If this is what you want to do, use the GNU Library General Public 
+License instead of this License.
diff -Npur igbvf-0.5.2/README igbvf-0.5.2.orig/README
--- igbvf-0.5.2/README	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/README	2008-11-26 02:08:29.000000000 +0800
@@ -0,0 +1,10 @@
+Linux* Base Driver README for the Intel(R) PRO/1000 Family of Adapters
+===============================================================
+
+This is a placeholder file, if you're reading this you got a pre-pre-alpha 
+copy of a driver tarball.
+
+This program is distributed in the hope that it will be useful, but WITHOUT 
+ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
+FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+more details.
diff -Npur igbvf-0.5.2/SUMS igbvf-0.5.2.orig/SUMS
--- igbvf-0.5.2/SUMS	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/SUMS	2008-11-26 02:08:29.000000000 +0800
@@ -0,0 +1,27 @@
+37528    24 src/e1000_vf.c
+40974    11 src/Makefile
+05583    48 src/kcompat.h
+43811    88 src/netdev.c
+16366    73 src/e1000_defines.h
+05472    11 src/kcompat.c
+43671    59 src/e1000_phy.c
+52675    61 src/e1000_mac.c
+64115     3 src/e1000_nvm.h
+54788    17 src/ethtool.c
+31462    31 src/e1000_regs.h
+29628    17 src/e1000_nvm.c
+35406    15 src/e1000_hw.h
+08899     5 src/e1000_mac.h
+64697     4 src/e1000_osdep.h
+41156     8 src/e1000_phy.h
+61263    10 src/igbvf.h
+44123    11 src/e1000_manage.c
+09481    21 src/e1000_82575.h
+56017    29 src/kcompat_ethtool.c
+27223     4 src/e1000_manage.h
+61211    10 src/param.c
+12485     1 igbvf.7
+40802     1 README
+21679     1 pci.updates
+50366    12 igbvf.spec
+39773    19 COPYING
diff -Npur igbvf-0.5.2/igbvf.7 igbvf-0.5.2.orig/igbvf.7
--- igbvf-0.5.2/igbvf.7	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/igbvf.7	2008-11-26 02:08:29.000000000 +0800
@@ -0,0 +1,11 @@
+.\" LICENSE
+.\"
+.\" This software program is released under the terms of a license agreement between you ('Licensee') and Intel. Do not use or load this software or any associated materials (collectively, the 'Software') until you have carefully read the full terms and conditions of the LICENSE located in this software package. By loading or using the Software, you agree to the terms of this Agreement. If you do not agree with the terms of this Agreement, do not install or use the Software.
+.\"
+.\" * Other names and brands may be claimed as the property of others.
+.\"
+.TH e1000e 1 "August 9999"
+
+
+.SH NAME
+e1000e \-This is a placeholder file, if you're reading this you got a pre-pre-alpha copy of a driver tarball.
diff -Npur igbvf-0.5.2/igbvf.spec igbvf-0.5.2.orig/igbvf.spec
--- igbvf-0.5.2/igbvf.spec	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/igbvf.spec	2008-11-26 02:08:29.000000000 +0800
@@ -0,0 +1,471 @@
+Name: igbvf
+Summary: Intel(R) 82576 Virtual Function
+Version: 0.5.2
+Release: 1
+Source: %{name}-%{version}.tar.gz
+Vendor: Intel Corporation
+License: GPL
+ExclusiveOS: linux
+Group: System Environment/Kernel
+Provides: %{name}
+URL: http://support.intel.com/support/go/linux/igbvf.htm
+BuildRoot: %{_tmppath}/%{name}-%{version}-root
+# do not generate debugging packages by default - newer versions of rpmbuild
+# may instead need:
+#%define debug_package %{nil}
+%debug_package %{nil}
+# macros for finding system files to update at install time (pci.ids, pcitable)
+%define find() %(for f in %*; do if [ -e $f ]; then echo $f; break; fi; done)
+%define _pciids   /usr/share/pci.ids        /usr/share/hwdata/pci.ids
+%define _pcitable /usr/share/kudzu/pcitable /usr/share/hwdata/pcitable /dev/null
+%define pciids    %find %{_pciids}
+%define pcitable  %find %{_pcitable}
+Requires: kernel, fileutils, findutils, gawk, bash
+
+%description
+This package contains the Linux driver for the Intel(R) 82576 Virtual Function.
+
+%prep
+%setup
+
+%build
+mkdir -p %{buildroot}
+
+KV=$(uname -r)
+KA=%{_arch}
+KV_BASE=$(echo $KV | sed '{ s/hugemem//g; s/smp//g; s/enterprise//g; }' )
+
+if [ -e /usr/src/kernels ] && [ $(echo $KV_BASE | grep "^2.6") ]; then
+	if [ -e /etc/redhat-release ]; then
+		KSP=$(ls /lib/modules | grep $KV_BASE)
+		for K in $KSP ; do
+			if [ $KA == "x86_64" ] && \
+			   [ $(echo $K | grep hugemem) ]; then
+				# Include path for x86_64 hugemem is broken
+				# on RHEL4
+				continue
+			fi
+			make -C src clean
+			make -C src KSP=/lib/modules/$K/build \
+				INSTALL_MOD_PATH=%{buildroot} \
+				KVERSION=$k \
+				MANDIR=%{_mandir} \
+				CFLAGS_EXTRA="$CFLAGS_EXTRA" install
+		done
+	else
+		make -C src clean
+		make -C src INSTALL_MOD_PATH=%{buildroot} \
+			MANDIR=%{_mandir} install
+	fi
+else
+	SwitchRHKernel () {
+		CFLAGS_EXTRA=""
+		for K in $2 ; do
+			if [ $K == $1 ] ; then
+				CFLAGS_EXTRA="$CFLAGS_EXTRA -D__BOOT_KERNEL_$K=1"
+			else
+				CFLAGS_EXTRA="$CFLAGS_EXTRA -D__BOOT_KERNEL_$K=0"
+			fi
+		done
+	}
+
+	KSP="/lib/modules/$KV/build
+	     /usr/src/linux-$KV
+	     /usr/src/linux-$(echo $KV | sed 's/-.*//')
+	     /usr/src/kernel-headers-$KV
+	     /usr/src/kernel-source-$KV
+	     /usr/src/linux-$(echo $KV | sed 's/\([0-9]*\.[0-9]*\)\..*/\1/')
+	     /usr/src/linux"
+
+	KSRC=$(for d in $KSP ; do [ -e $d/include/linux ] && echo $d; echo;  done)
+	KSRC=$(echo $KSRC | awk '{ print $1 }')
+
+	if [ -e $KSRC/include/linux/rhconfig.h ] ; then
+		RHKL=$(grep 'BOOT_KERNEL_.* [01]' /boot/kernel.h |
+		       sed 's/.*BOOT_KERNEL_\(.*\) [01]/\1/')
+		if echo $RHKL | grep BIGMEM
+		then
+			RHKL=$(echo $RHKL | sed 's/ENTERPRISE//')
+		fi
+		if echo $RHKL | grep HUGEMEM
+		then
+			RHKL=$(echo $RHKL | sed 's/BIGMEM//')
+		fi
+		for K in $RHKL ; do
+			SwitchRHKernel $K "$RHKL"
+			make -C src clean
+			if [ $KA == "x86_64" ] ; then
+				CFLAGS_EXTRA="$CFLAGS_EXTRA -D__MODULE_KERNEL_x86_64=0 -D__MODULE_KERNEL_ia32e=1"
+			fi
+			make -C src INSTALL_MOD_PATH=%{buildroot} \
+				MANDIR=%{_mandir} CFLAGS_EXTRA="$CFLAGS_EXTRA" install
+		done
+	else
+		make -C src clean
+		make -C src INSTALL_MOD_PATH=%{buildroot} MANDIR=%{_mandir} install
+	fi
+fi
+
+%install
+# Append .new to driver name to avoid conflict with kernel RPM
+cd %{buildroot}
+find lib -name "igbvf.*o" -exec mv {} {}.new \; \
+         -fprintf %{_builddir}/%{name}-%{version}/file.list "/%p.new\n"
+
+
+%clean
+rm -rf %{buildroot}
+
+%files -f %{_builddir}/%{name}-%{version}/file.list
+%defattr(-,root,root)
+%{_mandir}/man7/igbvf.7.gz
+%doc COPYING
+%doc README
+%doc file.list
+%doc pci.updates
+
+%post
+FL="%{_docdir}/%{name}-%{version}/file.list
+    %{_docdir}/%{name}/file.list"
+FL=$(for d in $FL ; do if [ -e $d ]; then echo $d; break; fi;  done)
+
+if [ -d /usr/local/lib/%{name} ]; then
+	rm -rf /usr/local/lib/%{name}
+fi
+if [ -d /usr/local/share/%{name} ]; then
+	rm -rf /usr/local/share/%{name}
+fi
+
+# Save old drivers (aka .o and .o.gz)
+echo "original pci.ids saved in /usr/local/share/%{name}";
+if [ "%{pcitable}" != "/dev/null" ]; then
+	echo "original pcitable saved in /usr/local/share/%{name}";
+fi
+for k in $(sed 's/\/lib\/modules\/\([0-9a-zA-Z_\.\-]*\).*/\1/' $FL) ; 
+do
+	d_drivers=/lib/modules/$k
+	d_usr=/usr/local/share/%{name}/$k
+	mkdir -p $d_usr
+	cd $d_drivers; find . -name %{name}.*o -exec cp --parents {} $d_usr \; -exec rm -f {} \;
+	cd $d_drivers; find . -name %{name}_*.*o -exec cp --parents {} $d_usr \; -exec rm -f {} \;
+	cd $d_drivers; find . -name %{name}.*o.gz -exec cp --parents {} $d_usr \; -exec rm -f {} \;
+	cd $d_drivers; find . -name %{name}_*.*o.gz -exec cp --parents {} $d_usr \; -exec rm -f {} \;
+	cp --parents %{pciids} /usr/local/share/%{name}/
+	if [ "%{pcitable}" != "/dev/null" ]; then
+		cp --parents %{pcitable} /usr/local/share/%{name}/
+	fi
+done
+
+# Add driver link
+for f in $(sed 's/\.new$//' $FL) ; do
+	ln -f $f.new $f 
+done
+
+# Check if kernel version rpm was built on IS the same as running kernel
+BK_LIST=$(sed 's/\/lib\/modules\/\([0-9a-zA-Z_\.\-]*\).*/\1/' $FL)
+MATCH=no
+for i in $BK_LIST
+do
+	if [ $(uname -r) == $i ] ; then
+		MATCH=yes
+		break
+	fi
+done
+if [ $MATCH == no ] ; then
+	echo -n "WARNING: Running kernel is $(uname -r).  "
+	echo -n "RPM supports kernels (  "
+	for i in $BK_LIST
+	do
+		echo -n "$i  "
+	done
+	echo ")"
+fi
+
+LD="%{_docdir}/%{name}";
+if [ -d %{_docdir}/%{name}-%{version} ]; then
+	LD="%{_docdir}/%{name}-%{version}";
+fi
+
+#Yes, this really needs bash
+bash -s %{pciids} \
+	%{pcitable} \
+	$LD/pci.updates \
+	$LD/pci.ids.new \
+	$LD/pcitable.new \
+	%{name} \
+<<"END"
+#! /bin/bash
+# $1 = system pci.ids file to update
+# $2 = system pcitable file to update
+# $3 = file with new entries in pci.ids file format
+# $4 = pci.ids output file
+# $5 = pcitable output file
+# $6 = driver name for use in pcitable file
+
+exec 3<$1
+exec 4<$2
+exec 5<$3
+exec 6>$4
+exec 7>$5
+driver=$6
+IFS=
+
+# pattern matching strings
+ID="[[:xdigit:]][[:xdigit:]][[:xdigit:]][[:xdigit:]]"
+VEN="${ID}*"
+DEV="	${ID}*"
+SUB="		${ID}*"
+TABLE_DEV="0x${ID}	0x${ID}	\"*"
+TABLE_SUB="0x${ID}	0x${ID}	0x${ID}	0x${ID}	\"*"
+
+line=
+table_line=
+ids_in=
+table_in=
+vendor=
+device=
+ids_device=
+table_device=
+subven=
+ids_subven=
+table_subven=
+subdev=
+ids_subdev=
+table_subdev=
+ven_str=
+dev_str=
+sub_str=
+
+# force a sub-shell to fork with a new stdin
+# this is needed if the shell is reading these instructions from stdin
+while true
+do
+	# get the first line of each data file to jump start things
+	exec 0<&3
+	read -r ids_in
+	if [ "$2" != "/dev/null" ];then
+	exec 0<&4
+	read -r table_in
+	fi
+
+	# outer loop reads lines from the updates file
+	exec 0<&5
+	while read -r line
+	do
+		# vendor entry
+		if [[ $line == $VEN ]]
+		then
+			vendor=0x${line:0:4}
+			ven_str=${line#${line:0:6}}
+			# add entry to pci.ids
+			exec 0<&3
+			exec 1>&6
+			while [[ $ids_in != $VEN ||
+				 0x${ids_in:0:4} < $vendor ]]
+			do
+				echo "$ids_in"
+				read -r ids_in
+			done
+			echo "$line"
+			if [[ 0x${ids_in:0:4} == $vendor ]]
+			then
+				read -r ids_in
+			fi
+
+		# device entry
+		elif [[ $line == $DEV ]]
+		then
+			device=`echo ${line:1:4} | tr [:upper:] [:lower:]`
+			table_device=0x${line:1:4}
+			dev_str=${line#${line:0:7}}
+			ids_device=`echo ${ids_in:1:4} | tr [:upper:] [:lower:]`
+			table_line="$vendor	$table_device	\"$driver\"	\"$ven_str|$dev_str\""
+			# add entry to pci.ids
+			exec 0<&3
+			exec 1>&6
+			while [[ $ids_in != $DEV ||
+				 $ids_device < $device ]]
+			do
+				if [[ $ids_in == $VEN ]]
+				then
+					break
+				fi
+				if [[ $ids_device != ${ids_in:1:4} ]]
+				then
+					echo "${ids_in:0:1}$ids_device${ids_in#${ids_in:0:5}}"
+				else
+					echo "$ids_in"
+				fi
+				read -r ids_in
+				ids_device=`echo ${ids_in:1:4} | tr [:upper:] [:lower:]`
+			done
+			if [[ $device != ${line:1:4} ]]
+			then
+				echo "${line:0:1}$device${line#${line:0:5}}"
+			else
+				echo "$line"
+			fi
+			if [[ $ids_device == $device ]]
+			then
+				read -r ids_in
+			fi
+			# add entry to pcitable
+			if [ "$2" != "/dev/null" ];then
+			exec 0<&4
+			exec 1>&7
+			while [[ $table_in != $TABLE_DEV ||
+				 ${table_in:0:6} < $vendor ||
+				 ( ${table_in:0:6} == $vendor &&
+				   ${table_in:7:6} < $table_device ) ]]
+			do
+				echo "$table_in"
+				read -r table_in
+			done
+			echo "$table_line"
+			if [[ ${table_in:0:6} == $vendor &&
+			      ${table_in:7:6} == $table_device ]]
+			then
+				read -r table_in
+			fi
+			fi
+		# subsystem entry
+		elif [[ $line == $SUB ]]
+		then
+			subven=`echo ${line:2:4} | tr [:upper:] [:lower:]`
+			subdev=`echo ${line:7:4} | tr [:upper:] [:lower:]`
+			table_subven=0x${line:2:4}
+			table_subdev=0x${line:7:4}
+			sub_str=${line#${line:0:13}}
+			ids_subven=`echo ${ids_in:2:4} | tr [:upper:] [:lower:]`
+			ids_subdev=`echo ${ids_in:7:4} | tr [:upper:] [:lower:]`
+			table_line="$vendor	$table_device	$table_subven	$table_subdev	\"$driver\"	\"$ven_str|$sub_str\""
+			# add entry to pci.ids
+			exec 0<&3
+			exec 1>&6
+			while [[ $ids_in != $SUB ||
+				 $ids_subven < $subven ||
+				 ( $ids_subven == $subven && 
+				   $ids_subdev < $subdev ) ]]
+			do
+				if [[ $ids_in == $VEN ||
+				      $ids_in == $DEV ]]
+				then
+					break
+				fi
+				if [[ ! (${ids_in:2:4} == "1014" &&
+					 ${ids_in:7:4} == "052C") ]]
+				then
+					if [[ $ids_subven != ${ids_in:2:4} || $ids_subdev != ${ids_in:7:4} ]]
+					then
+						echo "${ids_in:0:2}$ids_subven $ids_subdev${ids_in#${ids_in:0:11}}"
+					else
+						echo "$ids_in"
+					fi
+				fi
+				read -r ids_in
+				ids_subven=`echo ${ids_in:2:4} | tr [:upper:] [:lower:]`
+				ids_subdev=`echo ${ids_in:7:4} | tr [:upper:] [:lower:]`
+			done
+			if [[ $subven != ${line:2:4} || $subdev != ${line:7:4} ]]
+			then
+				echo "${line:0:2}$subven $subdev${line#${line:0:11}}"
+			else
+				echo "$line"
+			fi
+			if [[ $ids_subven == $subven  &&
+			      $ids_subdev == $subdev ]]
+			then
+				read -r ids_in
+			fi
+			# add entry to pcitable
+			if [ "$2" != "/dev/null" ];then
+			exec 0<&4
+			exec 1>&7
+			while [[ $table_in != $TABLE_SUB ||
+				 ${table_in:14:6} < $table_subven ||
+				 ( ${table_in:14:6} == $table_subven &&
+				   ${table_in:21:6} < $table_subdev ) ]]
+			do
+				if [[ $table_in == $TABLE_DEV ]]
+				then
+					break
+				fi
+				if [[ ! (${table_in:14:6} == "0x1014" &&
+					 ${table_in:21:6} == "0x052C") ]]
+				then
+					echo "$table_in"
+				fi
+				read -r table_in
+			done
+			echo "$table_line"
+			if [[ ${table_in:14:6} == $table_subven &&
+			      ${table_in:21:6} == $table_subdev ]]
+			then
+				read -r table_in
+			fi
+			fi
+		fi
+
+		exec 0<&5
+	done
+
+	# print the remainder of the original files
+	exec 0<&3
+	exec 1>&6
+	echo "$ids_in"
+	while read -r ids_in
+	do
+		echo "$ids_in"
+	done
+
+	if [ "$2" != "/dev/null" ];then
+	exec 0>&4
+	exec 1>&7
+	echo "$table_in"
+	while read -r table_in
+	do
+		echo "$table_in"
+	done
+	fi
+
+	break
+done <&5
+
+exec 3<&-
+exec 4<&-
+exec 5<&-
+exec 6>&-
+exec 7>&-
+
+END
+
+mv -f $LD/pci.ids.new  %{pciids}
+if [ "%{pcitable}" != "/dev/null" ]; then
+mv -f $LD/pcitable.new %{pcitable}
+fi
+
+uname -r | grep BOOT || /sbin/depmod -a > /dev/null 2>&1 || true
+
+%preun
+# If doing RPM un-install
+if [ $1 -eq 0 ] ; then
+	FL="%{_docdir}/%{name}-%{version}/file.list
+    		%{_docdir}/%{name}/file.list"
+	FL=$(for d in $FL ; do if [ -e $d ]; then echo $d; break; fi;  done)
+
+	# Remove driver link
+	for f in $(sed 's/\.new$//' $FL) ; do
+		rm -f $f
+	done
+
+	# Restore old drivers
+	if [ -d /usr/local/share/%{name} ]; then
+		cd /usr/local/share/%{name}; find . -name '%{name}.*o*' -exec cp --parents {} /lib/modules/ \;
+		cd /usr/local/share/%{name}; find . -name '%{name}_*.*o*' -exec cp --parents {} /lib/modules/ \;
+		rm -rf /usr/local/share/%{name}
+	fi
+fi
+
+%postun
+uname -r | grep BOOT || /sbin/depmod -a > /dev/null 2>&1 || true
+
diff -Npur igbvf-0.5.2/pci.updates igbvf-0.5.2.orig/pci.updates
--- igbvf-0.5.2/pci.updates	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/pci.updates	2008-11-26 02:08:29.000000000 +0800
@@ -0,0 +1,9 @@
+# updates for the system pci.ids file
+#
+# IMPORTANT!  Entries in this list must be sorted as they
+#             would appear in the system pci.ids file.  Entries
+#             are sorted by ven, dev, subven, subdev
+#             (numerical order).
+#
+8086  Intel Corporation
+	10ca  82576 Virtual Function Network Connection
diff -Npur igbvf-0.5.2/src/Makefile igbvf-0.5.2.orig/src/Makefile
--- igbvf-0.5.2/src/Makefile	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/Makefile	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,345 @@
+################################################################################
+#
+# Intel(R) 82576 Virtual Function Linux driver
+# Copyright(c) 1999 - 2008 Intel Corporation.
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# You should have received a copy of the GNU General Public License along with
+# this program; if not, write to the Free Software Foundation, Inc.,
+# 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+# Contact Information:
+# Linux NICS <linux.nics@intel.com>
+# e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+# Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+#
+################################################################################
+
+###########################################################################
+# Driver files
+FAMILYC = e1000_vf.c
+FAMILYH = e1000_82575.h
+
+# core driver files
+CFILES = netdev.c ethtool.c param.c $(FAMILYC) \
+         e1000_mac.c e1000_nvm.c e1000_phy.c e1000_manage.c kcompat.c
+HFILES = igbvf.h e1000_osdep.h e1000_hw.h e1000_regs.h e1000_defines.h \
+         e1000_mac.h e1000_nvm.h e1000_phy.h e1000_manage.h $(FAMILYH) kcompat.h
+ifeq (,$(BUILD_KERNEL))
+BUILD_KERNEL=$(shell uname -r)
+endif
+
+DRIVER_NAME = igbvf
+
+###########################################################################
+# Environment tests
+
+# Kernel Search Path
+# All the places we look for kernel source
+KSP :=  /lib/modules/$(BUILD_KERNEL)/build \
+        /lib/modules/$(BUILD_KERNEL)/source \
+        /usr/src/linux-$(BUILD_KERNEL) \
+        /usr/src/linux-$($(BUILD_KERNEL) | sed 's/-.*//') \
+        /usr/src/kernel-headers-$(BUILD_KERNEL) \
+        /usr/src/kernel-source-$(BUILD_KERNEL) \
+        /usr/src/linux-$($(BUILD_KERNEL) | sed 's/\([0-9]*\.[0-9]*\)\..*/\1/') \
+        /usr/src/linux
+
+# prune the list down to only values that exist
+# and have an include/linux sub-directory
+test_dir = $(shell [ -e $(dir)/include/linux ] && echo $(dir))
+KSP := $(foreach dir, $(KSP), $(test_dir))
+
+# we will use this first valid entry in the search path
+ifeq (,$(KSRC))
+  KSRC := $(firstword $(KSP))
+endif
+
+ifeq (,$(KSRC))
+  $(warning *** Linux kernel source not found in any of these locations:)
+  $(warning $(KSP))
+  $(warning *** Install the appropriate kernel development package, e.g.)
+  $(error kernel-devel, for building kernel modules and try again)
+else
+ifeq (/lib/modules/$(shell uname -r)/source, $(KSRC))
+  KOBJ :=  /lib/modules/$(shell uname -r)/build
+else
+  KOBJ :=  $(KSRC)
+endif
+endif
+
+# check for version.h and autoconf.h for running kernel in /boot (SUSE)
+ifneq (,$(wildcard /boot/vmlinuz.version.h))
+  VERSION_FILE := /boot/vmlinuz.version.h
+  CONFIG_FILE  := /boot/vmlinuz.autoconf.h
+  KVER := $(shell $(CC) $(EXTRA_CFLAGS) -E -dM $(VERSION_FILE) | \
+          grep UTS_RELEASE | awk '{ print $$3 }' | sed 's/\"//g')
+  ifeq ($(KVER),$(shell uname -r))
+    # set up include path to override headers from kernel source
+    x:=$(shell rm -rf include)
+    x:=$(shell mkdir -p include/linux)
+    x:=$(shell cp /boot/vmlinuz.version.h include/linux/version.h)
+    x:=$(shell cp /boot/vmlinuz.autoconf.h include/linux/autoconf.h)
+    EXTRA_CFLAGS += -I./include
+  else
+    ifneq (,$(wildcard $(KOBJ)/include/linux/utsrelease.h))
+      VERSION_FILE := $(KOBJ)/include/linux/utsrelease.h
+    else
+      VERSION_FILE := $(KOBJ)/include/linux/version.h
+    endif
+    CONFIG_FILE  := $(KSRC)/include/linux/autoconf.h
+  endif
+else
+  ifneq (,$(wildcard $(KOBJ)/include/linux/utsrelease.h))
+    VERSION_FILE := $(KOBJ)/include/linux/utsrelease.h
+  else
+    VERSION_FILE := $(KOBJ)/include/linux/version.h
+  endif
+  CONFIG_FILE  := $(KSRC)/include/linux/autoconf.h
+endif
+
+ifeq (,$(wildcard $(VERSION_FILE)))
+  $(error Linux kernel source not configured - missing version.h)
+endif
+
+ifeq (,$(wildcard $(CONFIG_FILE)))
+  $(error Linux kernel source not configured - missing autoconf.h)
+endif
+
+# pick a compiler
+ifneq (,$(findstring egcs-2.91.66, $(shell cat /proc/version)))
+  CC := kgcc gcc cc
+else
+  CC := gcc cc
+endif
+test_cc = $(shell $(cc) --version > /dev/null 2>&1 && echo $(cc))
+CC := $(foreach cc, $(CC), $(test_cc))
+CC := $(firstword $(CC))
+ifeq (,$(CC))
+  $(error Compiler not found)
+endif
+
+# we need to know what platform the driver is being built on
+# some additional features are only built on Intel platforms
+ARCH := $(shell uname -m | sed 's/i.86/i386/')
+ifeq ($(ARCH),alpha)
+  EXTRA_CFLAGS += -ffixed-8 -mno-fp-regs
+endif
+ifeq ($(ARCH),x86_64)
+  EXTRA_CFLAGS += -mcmodel=kernel -mno-red-zone
+endif
+ifeq ($(ARCH),ppc)
+  EXTRA_CFLAGS += -msoft-float
+endif
+ifeq ($(ARCH),ppc64)
+  EXTRA_CFLAGS += -m64 -msoft-float
+  LDFLAGS += -melf64ppc
+endif
+ifneq (,$(findstring NO_82542_SUPPORT, $(CFLAGS_EXTRA)))
+  CFILES := $(filter-out e1000_82542.c, $(CFILES))
+endif
+
+# extra flags for module builds
+EXTRA_CFLAGS += -DDRIVER_$(shell echo $(DRIVER_NAME) | tr '[a-z]' '[A-Z]')
+EXTRA_CFLAGS += -DDRIVER_NAME=$(DRIVER_NAME)
+EXTRA_CFLAGS += -DDRIVER_NAME_CAPS=$(shell echo $(DRIVER_NAME) | tr '[a-z]' '[A-Z]')
+# standard flags for module builds
+EXTRA_CFLAGS += -DLINUX -D__KERNEL__ -DMODULE -O2 -pipe -Wall
+EXTRA_CFLAGS += -I$(KSRC)/include -I.
+EXTRA_CFLAGS += $(shell [ -f $(KSRC)/include/linux/modversions.h ] && \
+            echo "-DMODVERSIONS -DEXPORT_SYMTAB \
+                  -include $(KSRC)/include/linux/modversions.h")
+
+EXTRA_CFLAGS += $(CFLAGS_EXTRA)
+
+RHC := $(KSRC)/include/linux/rhconfig.h
+ifneq (,$(wildcard $(RHC)))
+  # 7.3 typo in rhconfig.h
+  ifneq (,$(shell $(CC) $(EXTRA_CFLAGS) -E -dM $(RHC) | grep __module__bigmem))
+	EXTRA_CFLAGS += -D__module_bigmem
+  endif
+endif
+
+# get the kernel version - we use this to find the correct install path
+KVER := $(shell $(CC) $(EXTRA_CFLAGS) -E -dM $(VERSION_FILE) | grep UTS_RELEASE | \
+        awk '{ print $$3 }' | sed 's/\"//g')
+
+# assume source symlink is the same as build, otherwise adjust KOBJ
+ifneq (,$(wildcard /lib/modules/$(KVER)/build))
+ifneq ($(KSRC),$(shell cd /lib/modules/$(KVER)/build ; pwd -P))
+  KOBJ=/lib/modules/$(KVER)/build
+endif
+endif
+
+KKVER := $(shell echo $(KVER) | \
+         awk '{ if ($$0 ~ /2\.[4-9]\./) print "1"; else print "0"}')
+ifeq ($(KKVER), 0)
+  $(error *** Aborting the build. \
+          *** This driver is not supported on kernel versions older than 2.4.0)
+endif
+
+# set the install path
+INSTDIR := /lib/modules/$(KVER)/kernel/drivers/net/$(DRIVER_NAME)
+
+# look for SMP in config.h
+SMP := $(shell $(CC) $(EXTRA_CFLAGS) -E -dM $(CONFIG_FILE) | \
+         grep -w CONFIG_SMP | awk '{ print $$3 }')
+ifneq ($(SMP),1)
+  SMP := 0
+endif
+
+ifneq ($(SMP),$(shell uname -a | grep SMP > /dev/null 2>&1 && echo 1 || echo 0))
+  $(warning ***)
+  ifeq ($(SMP),1)
+    $(warning *** Warning: kernel source configuration (SMP))
+    $(warning *** does not match running kernel (UP))
+  else
+    $(warning *** Warning: kernel source configuration (UP))
+    $(warning *** does not match running kernel (SMP))
+  endif
+  $(warning *** Continuing with build,)
+  $(warning *** resulting driver may not be what you want)
+  $(warning ***)
+endif
+
+ifeq ($(SMP),1)
+  EXTRA_CFLAGS += -D__SMP__
+endif
+
+###########################################################################
+# 2.4.x & 2.6.x Specific rules
+
+K_VERSION:=$(shell uname -r | cut -c1-3 | sed 's/2\.[56]/2\.6/')
+
+ifeq ($(K_VERSION), 2.6)
+
+# Makefile for 2.6.x kernel
+TARGET = $(DRIVER_NAME).ko
+
+# man page
+MANSECTION = 7
+MANFILE = $(TARGET:.ko=.$(MANSECTION))
+
+ifneq ($(PATCHLEVEL),)
+EXTRA_CFLAGS += $(CFLAGS_EXTRA)
+obj-m += $(DRIVER_NAME).o
+$(DRIVER_NAME)-objs := $(CFILES:.c=.o)
+else
+default:
+ifeq ($(KOBJ),$(KSRC))
+	$(MAKE) -C $(KSRC) SUBDIRS=$(shell pwd) modules
+else
+	$(MAKE) -C $(KSRC) O=$(KOBJ) SUBDIRS=$(shell pwd) modules
+endif
+endif
+
+else # ifeq ($(K_VERSION),2.6)
+
+# Makefile for 2.4.x kernel
+TARGET = $(DRIVER_NAME).o
+
+# man page
+MANSECTION = 7
+MANFILE = $(TARGET:.o=.$(MANSECTION))
+
+# Get rid of compile warnings in kernel header files from SuSE
+ifneq (,$(wildcard /etc/SuSE-release))
+  EXTRA_CFLAGS += -Wno-sign-compare -fno-strict-aliasing
+endif
+
+# Get rid of compile warnings in kernel header files from fedora
+ifneq (,$(wildcard /etc/fedora-release))
+  EXTRA_CFLAGS += -fno-strict-aliasing
+endif
+CFLAGS += $(EXTRA_CFLAGS)
+
+.SILENT: $(TARGET)
+$(TARGET): $(filter-out $(TARGET), $(CFILES:.c=.o))
+	$(LD) $(LDFLAGS) -r $^ -o $@
+	echo; echo
+	echo "**************************************************"
+	echo "** $(TARGET) built for $(KVER)"
+	echo -n "** SMP               "
+	if [ "$(SMP)" = "1" ]; \
+		then echo "Enabled"; else echo "Disabled"; fi
+	echo "**************************************************"
+	echo
+
+$(CFILES:.c=.o): $(HFILES) Makefile
+default:
+	$(MAKE)
+
+endif # ifeq ($(K_VERSION),2.6)
+
+ifeq (,$(MANDIR))
+  # find the best place to install the man page
+  MANPATH := $(shell (manpath 2>/dev/null || echo $MANPATH) | sed 's/:/ /g')
+  ifneq (,$(MANPATH))
+    # test based on inclusion in MANPATH
+    test_dir = $(findstring $(dir), $(MANPATH))
+  else
+    # no MANPATH, test based on directory existence
+    test_dir = $(shell [ -e $(dir) ] && echo $(dir))
+  endif
+  # our preferred install path
+  # should /usr/local/man be in here ?
+  MANDIR := /usr/share/man /usr/man
+  MANDIR := $(foreach dir, $(MANDIR), $(test_dir))
+  MANDIR := $(firstword $(MANDIR))
+endif
+ifeq (,$(MANDIR))
+  # fallback to /usr/man
+  MANDIR := /usr/man
+endif
+
+# depmod version for rpm builds
+DEPVER := $(shell /sbin/depmod -V 2>/dev/null | \
+          awk 'BEGIN {FS="."} NR==1 {print $$2}')
+
+###########################################################################
+# Build rules
+
+$(MANFILE).gz: ../$(MANFILE)
+	gzip -c $< > $@
+
+install: default $(MANFILE).gz
+	# remove all old versions of the driver
+	find $(INSTALL_MOD_PATH)/lib/modules/$(KVER) -name $(TARGET) -exec rm -f {} \; || true
+	find $(INSTALL_MOD_PATH)/lib/modules/$(KVER) -name $(TARGET).gz -exec rm -f {} \; || true
+	install -D -m 644 $(TARGET) $(INSTALL_MOD_PATH)$(INSTDIR)/$(TARGET)
+ifeq (,$(INSTALL_MOD_PATH))
+	/sbin/depmod -a || true
+else
+  ifeq ($(DEPVER),1 )
+	/sbin/depmod -r $(INSTALL_MOD_PATH) -a || true
+  else
+	/sbin/depmod -b $(INSTALL_MOD_PATH) -a -n $(KVERSION) > /dev/null || true
+  endif
+endif
+	install -D -m 644 $(MANFILE).gz $(INSTALL_MOD_PATH)$(MANDIR)/man$(MANSECTION)/$(MANFILE).gz
+	man -c -P'cat > /dev/null' $(MANFILE:.$(MANSECTION)=) || true
+
+uninstall:
+	if [ -e $(INSTDIR)/$(TARGET) ] ; then \
+	    rm -f $(INSTDIR)/$(TARGET) ; \
+	fi
+	/sbin/depmod -a
+	if [ -e $(MANDIR)/man$(MANSECTION)/$(MANFILE).gz ] ; then \
+		rm -f $(MANDIR)/man$(MANSECTION)/$(MANFILE).gz ; \
+	fi
+
+.PHONY: clean install
+
+clean:
+	rm -rf $(TARGET) $(TARGET:.ko=.o) $(TARGET:.ko=.mod.c) $(TARGET:.ko=.mod.o) $(CFILES:.c=.o) $(MANFILE).gz .*cmd .tmp_versions
diff -Npur igbvf-0.5.2/src/e1000_82575.h igbvf-0.5.2.orig/src/e1000_82575.h
--- igbvf-0.5.2/src/e1000_82575.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_82575.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,478 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_82575_H_
+#define _E1000_82575_H_
+
+#define ID_LED_DEFAULT_82575_SERDES ((ID_LED_DEF1_DEF2 << 12) | \
+                                     (ID_LED_DEF1_DEF2 <<  8) | \
+                                     (ID_LED_DEF1_DEF2 <<  4) | \
+                                     (ID_LED_OFF1_ON2))
+/*
+ * Receive Address Register Count
+ * Number of high/low register pairs in the RAR.  The RAR (Receive Address
+ * Registers) holds the directed and multicast addresses that we monitor.
+ * These entries are also used for MAC-based filtering.
+ */
+/*
+ * For 82576, there are an additional set of RARs that begin at an offset
+ * separate from the first set of RARs.
+ */
+#define E1000_RAR_ENTRIES_82575   16
+#define E1000_RAR_ENTRIES_82576   24
+
+#ifdef E1000_BIT_FIELDS
+struct e1000_adv_data_desc {
+	u64 buffer_addr;    /* Address of the descriptor's data buffer */
+	union {
+		u32 data;
+		struct {
+			u32 datalen :16; /* Data buffer length */
+			u32 rsvd    :4;
+			u32 dtyp    :4;  /* Descriptor type */
+			u32 dcmd    :8;  /* Descriptor command */
+		} config;
+	} lower;
+	union {
+		u32 data;
+		struct {
+			u32 status  :4;  /* Descriptor status */
+			u32 idx     :4;
+			u32 popts   :6;  /* Packet Options */
+			u32 paylen  :18; /* Payload length */
+		} options;
+	} upper;
+};
+
+#define E1000_TXD_DTYP_ADV_C    0x2  /* Advanced Context Descriptor */
+#define E1000_TXD_DTYP_ADV_D    0x3  /* Advanced Data Descriptor */
+#define E1000_ADV_TXD_CMD_DEXT  0x20 /* Descriptor extension (0 = legacy) */
+#define E1000_ADV_TUCMD_IPV4    0x2  /* IP Packet Type: 1=IPv4 */
+#define E1000_ADV_TUCMD_IPV6    0x0  /* IP Packet Type: 0=IPv6 */
+#define E1000_ADV_TUCMD_L4T_UDP 0x0  /* L4 Packet TYPE of UDP */
+#define E1000_ADV_TUCMD_L4T_TCP 0x4  /* L4 Packet TYPE of TCP */
+#define E1000_ADV_TUCMD_MKRREQ  0x10 /* Indicates markers are required */
+#define E1000_ADV_DCMD_EOP      0x1  /* End of Packet */
+#define E1000_ADV_DCMD_IFCS     0x2  /* Insert FCS (Ethernet CRC) */
+#define E1000_ADV_DCMD_RS       0x8  /* Report Status */
+#define E1000_ADV_DCMD_VLE      0x40 /* Add VLAN tag */
+#define E1000_ADV_DCMD_TSE      0x80 /* TCP Seg enable */
+/* Extended Device Control */
+#define E1000_CTRL_EXT_NSICR    0x00000001 /* Disable Intr Clear all on read */
+
+struct e1000_adv_context_desc {
+	union {
+		u32 ip_config;
+		struct {
+			u32 iplen    :9;
+			u32 maclen   :7;
+			u32 vlan_tag :16;
+		} fields;
+	} ip_setup;
+	u32 seq_num;
+	union {
+		u64 l4_config;
+		struct {
+			u32 mkrloc :9;
+			u32 tucmd  :11;
+			u32 dtyp   :4;
+			u32 adv    :8;
+			u32 rsvd   :4;
+			u32 idx    :4;
+			u32 l4len  :8;
+			u32 mss    :16;
+		} fields;
+	} l4_setup;
+};
+#endif
+
+/* SRRCTL bit definitions */
+#define E1000_SRRCTL_BSIZEPKT_SHIFT                     10 /* Shift _right_ */
+#define E1000_SRRCTL_BSIZEHDRSIZE_MASK                  0x00000F00
+#define E1000_SRRCTL_BSIZEHDRSIZE_SHIFT                 2  /* Shift _left_ */
+#define E1000_SRRCTL_DESCTYPE_LEGACY                    0x00000000
+#define E1000_SRRCTL_DESCTYPE_ADV_ONEBUF                0x02000000
+#define E1000_SRRCTL_DESCTYPE_HDR_SPLIT                 0x04000000
+#define E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS          0x0A000000
+#define E1000_SRRCTL_DESCTYPE_HDR_REPLICATION           0x06000000
+#define E1000_SRRCTL_DESCTYPE_HDR_REPLICATION_LARGE_PKT 0x08000000
+#define E1000_SRRCTL_DESCTYPE_MASK                      0x0E000000
+#define E1000_SRRCTL_DROP_EN                            0x80000000
+
+#define E1000_SRRCTL_BSIZEPKT_MASK      0x0000007F
+#define E1000_SRRCTL_BSIZEHDR_MASK      0x00003F00
+
+#define E1000_TX_HEAD_WB_ENABLE   0x1
+#define E1000_TX_SEQNUM_WB_ENABLE 0x2
+
+#define E1000_MRQC_ENABLE_RSS_4Q            0x00000002
+#define E1000_MRQC_ENABLE_VMDQ              0x00000003
+#define E1000_MRQC_RSS_FIELD_IPV4_UDP       0x00400000
+#define E1000_MRQC_RSS_FIELD_IPV6_UDP       0x00800000
+#define E1000_MRQC_RSS_FIELD_IPV6_UDP_EX    0x01000000
+
+#define E1000_VMRCTL_MIRROR_PORT_SHIFT      8
+#define E1000_VMRCTL_MIRROR_DSTPORT_MASK    (7 << E1000_VMRCTL_MIRROR_PORT_SHIFT)
+#define E1000_VMRCTL_POOL_MIRROR_ENABLE     (1 << 0)
+#define E1000_VMRCTL_UPLINK_MIRROR_ENABLE   (1 << 1)
+#define E1000_VMRCTL_DOWNLINK_MIRROR_ENABLE (1 << 2)
+
+#define E1000_EICR_TX_QUEUE ( \
+    E1000_EICR_TX_QUEUE0 |    \
+    E1000_EICR_TX_QUEUE1 |    \
+    E1000_EICR_TX_QUEUE2 |    \
+    E1000_EICR_TX_QUEUE3)
+
+#define E1000_EICR_RX_QUEUE ( \
+    E1000_EICR_RX_QUEUE0 |    \
+    E1000_EICR_RX_QUEUE1 |    \
+    E1000_EICR_RX_QUEUE2 |    \
+    E1000_EICR_RX_QUEUE3)
+
+#define E1000_EIMS_RX_QUEUE E1000_EICR_RX_QUEUE
+#define E1000_EIMS_TX_QUEUE E1000_EICR_TX_QUEUE
+
+#define EIMS_ENABLE_MASK ( \
+    E1000_EIMS_RX_QUEUE  | \
+    E1000_EIMS_TX_QUEUE  | \
+    E1000_EIMS_TCP_TIMER | \
+    E1000_EIMS_OTHER)
+
+/* Immediate Interrupt Rx (A.K.A. Low Latency Interrupt) */
+#define E1000_IMIR_PORT_IM_EN     0x00010000  /* TCP port enable */
+#define E1000_IMIR_PORT_BP        0x00020000  /* TCP port check bypass */
+#define E1000_IMIREXT_SIZE_BP     0x00001000  /* Packet size bypass */
+#define E1000_IMIREXT_CTRL_URG    0x00002000  /* Check URG bit in header */
+#define E1000_IMIREXT_CTRL_ACK    0x00004000  /* Check ACK bit in header */
+#define E1000_IMIREXT_CTRL_PSH    0x00008000  /* Check PSH bit in header */
+#define E1000_IMIREXT_CTRL_RST    0x00010000  /* Check RST bit in header */
+#define E1000_IMIREXT_CTRL_SYN    0x00020000  /* Check SYN bit in header */
+#define E1000_IMIREXT_CTRL_FIN    0x00040000  /* Check FIN bit in header */
+#define E1000_IMIREXT_CTRL_BP     0x00080000  /* Bypass check of ctrl bits */
+
+/* Receive Descriptor - Advanced */
+union e1000_adv_rx_desc {
+	struct {
+		u64 pkt_addr;             /* Packet buffer address */
+		u64 hdr_addr;             /* Header buffer address */
+	} read;
+	struct {
+		struct {
+			union {
+				u32 data;
+				struct {
+					u16 pkt_info; /* RSS type, Packet type */
+					u16 hdr_info; /* Split Header,
+				        	       * header buffer length */
+				} hs_rss;
+			} lo_dword;
+			union {
+				u32 rss;          /* RSS Hash */
+				struct {
+					u16 ip_id;    /* IP id */
+					u16 csum;     /* Packet Checksum */
+				} csum_ip;
+			} hi_dword;
+		} lower;
+		struct {
+			u32 status_error;     /* ext status/error */
+			u16 length;           /* Packet length */
+			u16 vlan;             /* VLAN tag */
+		} upper;
+	} wb;  /* writeback */
+};
+
+#define E1000_RXDADV_RSSTYPE_MASK        0x0000F000
+#define E1000_RXDADV_RSSTYPE_SHIFT       12
+#define E1000_RXDADV_HDRBUFLEN_MASK      0x7FE0
+#define E1000_RXDADV_HDRBUFLEN_SHIFT     5
+#define E1000_RXDADV_SPLITHEADER_EN      0x00001000
+#define E1000_RXDADV_SPH                 0x8000
+#define E1000_RXDADV_ERR_HBO             0x00800000
+
+/* RSS Hash results */
+#define E1000_RXDADV_RSSTYPE_NONE        0x00000000
+#define E1000_RXDADV_RSSTYPE_IPV4_TCP    0x00000001
+#define E1000_RXDADV_RSSTYPE_IPV4        0x00000002
+#define E1000_RXDADV_RSSTYPE_IPV6_TCP    0x00000003
+#define E1000_RXDADV_RSSTYPE_IPV6_EX     0x00000004
+#define E1000_RXDADV_RSSTYPE_IPV6        0x00000005
+#define E1000_RXDADV_RSSTYPE_IPV6_TCP_EX 0x00000006
+#define E1000_RXDADV_RSSTYPE_IPV4_UDP    0x00000007
+#define E1000_RXDADV_RSSTYPE_IPV6_UDP    0x00000008
+#define E1000_RXDADV_RSSTYPE_IPV6_UDP_EX 0x00000009
+
+/* RSS Packet Types as indicated in the receive descriptor */
+#define E1000_RXDADV_PKTTYPE_NONE        0x00000000
+#define E1000_RXDADV_PKTTYPE_IPV4        0x00000010 /* IPV4 hdr present */
+#define E1000_RXDADV_PKTTYPE_IPV4_EX     0x00000020 /* IPV4 hdr + extensions */
+#define E1000_RXDADV_PKTTYPE_IPV6        0x00000040 /* IPV6 hdr present */
+#define E1000_RXDADV_PKTTYPE_IPV6_EX     0x00000080 /* IPV6 hdr + extensions */
+#define E1000_RXDADV_PKTTYPE_TCP         0x00000100 /* TCP hdr present */
+#define E1000_RXDADV_PKTTYPE_UDP         0x00000200 /* UDP hdr present */
+#define E1000_RXDADV_PKTTYPE_SCTP        0x00000400 /* SCTP hdr present */
+#define E1000_RXDADV_PKTTYPE_NFS         0x00000800 /* NFS hdr present */
+
+#define E1000_RXDADV_PKTTYPE_IPSEC_ESP   0x00001000 /* IPSec ESP */
+#define E1000_RXDADV_PKTTYPE_IPSEC_AH    0x00002000 /* IPSec AH */
+#define E1000_RXDADV_PKTTYPE_LINKSEC     0x00004000 /* LinkSec Encap */
+#define E1000_RXDADV_PKTTYPE_ETQF        0x00008000 /* PKTTYPE is ETQF index */
+#define E1000_RXDADV_PKTTYPE_ETQF_MASK   0x00000070 /* ETQF has 8 indices */
+#define E1000_RXDADV_PKTTYPE_ETQF_SHIFT  4          /* Right-shift 4 bits */
+
+/* LinkSec results */
+/* Security Processing bit Indication */
+#define E1000_RXDADV_LNKSEC_STATUS_SECP         0x00020000
+#define E1000_RXDADV_LNKSEC_ERROR_BIT_MASK      0x18000000
+#define E1000_RXDADV_LNKSEC_ERROR_NO_SA_MATCH   0x08000000
+#define E1000_RXDADV_LNKSEC_ERROR_REPLAY_ERROR  0x10000000
+#define E1000_RXDADV_LNKSEC_ERROR_BAD_SIG       0x18000000
+
+#define E1000_RXDADV_IPSEC_STATUS_SECP          0x00020000
+#define E1000_RXDADV_IPSEC_ERROR_BIT_MASK       0x18000000
+#define E1000_RXDADV_IPSEC_ERROR_INVALID_PROTOCOL       0x08000000
+#define E1000_RXDADV_IPSEC_ERROR_INVALID_LENGTH         0x10000000
+#define E1000_RXDADV_IPSEC_ERROR_AUTHENTICATION_FAILED  0x18000000
+
+/* Transmit Descriptor - Advanced */
+union e1000_adv_tx_desc {
+	struct {
+		u64 buffer_addr;    /* Address of descriptor's data buf */
+		u32 cmd_type_len;
+		u32 olinfo_status;
+	} read;
+	struct {
+		u64 rsvd;       /* Reserved */
+		u32 nxtseq_seed;
+		u32 status;
+	} wb;
+};
+
+/* Adv Transmit Descriptor Config Masks */
+#define E1000_ADVTXD_DTYP_CTXT    0x00200000 /* Advanced Context Descriptor */
+#define E1000_ADVTXD_DTYP_DATA    0x00300000 /* Advanced Data Descriptor */
+#define E1000_ADVTXD_DCMD_EOP     0x01000000 /* End of Packet */
+#define E1000_ADVTXD_DCMD_IFCS    0x02000000 /* Insert FCS (Ethernet CRC) */
+#define E1000_ADVTXD_DCMD_RS      0x08000000 /* Report Status */
+#define E1000_ADVTXD_DCMD_DDTYP_ISCSI  0x10000000 /* DDP hdr type or iSCSI */
+#define E1000_ADVTXD_DCMD_DEXT    0x20000000 /* Descriptor extension (1=Adv) */
+#define E1000_ADVTXD_DCMD_VLE     0x40000000 /* VLAN pkt enable */
+#define E1000_ADVTXD_DCMD_TSE     0x80000000 /* TCP Seg enable */
+#define E1000_ADVTXD_MAC_LINKSEC  0x00040000 /* Apply LinkSec on packet */
+#define E1000_ADVTXD_MAC_TSTAMP   0x00080000 /* IEEE1588 Timestamp packet */
+#define E1000_ADVTXD_STAT_SN_CRC  0x00000002 /* NXTSEQ/SEED present in WB */
+#define E1000_ADVTXD_IDX_SHIFT    4  /* Adv desc Index shift */
+#define E1000_ADVTXD_POPTS_ISCO_1ST  0x00000000 /* 1st TSO of iSCSI PDU */
+#define E1000_ADVTXD_POPTS_ISCO_MDL  0x00000800 /* Middle TSO of iSCSI PDU */
+#define E1000_ADVTXD_POPTS_ISCO_LAST 0x00001000 /* Last TSO of iSCSI PDU */
+#define E1000_ADVTXD_POPTS_ISCO_FULL 0x00001800 /* 1st&Last TSO-full iSCSI PDU*/
+#define E1000_ADVTXD_POPTS_IPSEC     0x00000400 /* IPSec offload request */
+#define E1000_ADVTXD_PAYLEN_SHIFT    14 /* Adv desc PAYLEN shift */
+
+/* Context descriptors */
+struct e1000_adv_tx_context_desc {
+	u32 vlan_macip_lens;
+	u32 seqnum_seed;
+	u32 type_tucmd_mlhl;
+	u32 mss_l4len_idx;
+};
+
+#define E1000_ADVTXD_MACLEN_SHIFT    9  /* Adv ctxt desc mac len shift */
+#define E1000_ADVTXD_VLAN_SHIFT     16  /* Adv ctxt vlan tag shift */
+#define E1000_ADVTXD_TUCMD_IPV4    0x00000400  /* IP Packet Type: 1=IPv4 */
+#define E1000_ADVTXD_TUCMD_IPV6    0x00000000  /* IP Packet Type: 0=IPv6 */
+#define E1000_ADVTXD_TUCMD_L4T_UDP 0x00000000  /* L4 Packet TYPE of UDP */
+#define E1000_ADVTXD_TUCMD_L4T_TCP 0x00000800  /* L4 Packet TYPE of TCP */
+#define E1000_ADVTXD_TUCMD_IPSEC_TYPE_ESP    0x00002000 /* IPSec Type ESP */
+/* IPSec Encrypt Enable for ESP */
+#define E1000_ADVTXD_TUCMD_IPSEC_ENCRYPT_EN  0x00004000
+#define E1000_ADVTXD_TUCMD_MKRREQ  0x00002000 /* Req requires Markers and CRC */
+#define E1000_ADVTXD_L4LEN_SHIFT     8  /* Adv ctxt L4LEN shift */
+#define E1000_ADVTXD_MSS_SHIFT      16  /* Adv ctxt MSS shift */
+/* Adv ctxt IPSec SA IDX mask */
+#define E1000_ADVTXD_IPSEC_SA_INDEX_MASK     0x000000FF
+/* Adv ctxt IPSec ESP len mask */
+#define E1000_ADVTXD_IPSEC_ESP_LEN_MASK      0x000000FF
+
+/* Additional Transmit Descriptor Control definitions */
+#define E1000_TXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Tx Queue */
+#define E1000_TXDCTL_SWFLSH        0x04000000 /* Tx Desc. write-back flushing */
+/* Tx Queue Arbitration Priority 0=low, 1=high */
+#define E1000_TXDCTL_PRIORITY      0x08000000
+
+/* Additional Receive Descriptor Control definitions */
+#define E1000_RXDCTL_QUEUE_ENABLE  0x02000000 /* Enable specific Rx Queue */
+#define E1000_RXDCTL_SWFLSH        0x04000000 /* Rx Desc. write-back flushing */
+
+/* Direct Cache Access (DCA) definitions */
+#define E1000_DCA_CTRL_DCA_ENABLE  0x00000000 /* DCA Enable */
+#define E1000_DCA_CTRL_DCA_DISABLE 0x00000001 /* DCA Disable */
+
+#define E1000_DCA_CTRL_DCA_MODE_CB1 0x00 /* DCA Mode CB1 */
+#define E1000_DCA_CTRL_DCA_MODE_CB2 0x02 /* DCA Mode CB2 */
+
+#define E1000_DCA_RXCTRL_CPUID_MASK 0x0000001F /* Rx CPUID Mask */
+#define E1000_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
+#define E1000_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
+#define E1000_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
+
+#define E1000_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
+#define E1000_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */
+#define E1000_DCA_TXCTRL_TX_WB_RO_EN (1 << 11) /* Tx Desc writeback RO bit */
+
+#define E1000_DCA_TXCTRL_CPUID_MASK_82576 0xFF000000 /* Tx CPUID Mask */
+#define E1000_DCA_RXCTRL_CPUID_MASK_82576 0xFF000000 /* Rx CPUID Mask */
+#define E1000_DCA_TXCTRL_CPUID_SHIFT_82576 24 /* Tx CPUID */
+#define E1000_DCA_RXCTRL_CPUID_SHIFT_82576 24 /* Rx CPUID */
+
+/* Additional interrupt register bit definitions */
+#define E1000_ICR_LSECPNS       0x00000020          /* PN threshold - server */
+#define E1000_IMS_LSECPNS       E1000_ICR_LSECPNS   /* PN threshold - server */
+#define E1000_ICS_LSECPNS       E1000_ICR_LSECPNS   /* PN threshold - server */
+
+/* ETQF register bit definitions */
+#define E1000_ETQF_FILTER_ENABLE   (1 << 26)
+#define E1000_ETQF_IMM_INT         (1 << 29)
+#define E1000_ETQF_1588            (1 << 30)
+#define E1000_ETQF_QUEUE_ENABLE    (1 << 31)
+/*
+ * ETQF filter list: one static filter per filter consumer. This is
+ *                   to avoid filter collisions later. Add new filters
+ *                   here!!
+ *
+ * Current filters:
+ *    EAPOL 802.1x (0x888e): Filter 0
+ */
+#define E1000_ETQF_FILTER_EAPOL          0
+
+#define E1000_NVM_APME_82575          0x0400
+#define MAX_NUM_VFS                   8
+
+#define E1000_DTXSWC_MAC_SPOOF_MASK   0x000000FF /* Per VF MAC spoof control */
+#define E1000_DTXSWC_VLAN_SPOOF_MASK  0x0000FF00 /* Per VF VLAN spoof control */
+#define E1000_DTXSWC_LLE_MASK         0x00FF0000 /* Per VF Local LB enables */
+#define E1000_DTXSWC_VMDQ_LOOPBACK_EN (1 << 31)  /* global VF LB enable */
+
+/* Easy defines for setting default pool, would normally be left a zero */
+#define E1000_VT_CTL_DEFAULT_POOL_SHIFT 7
+#define E1000_VT_CTL_DEFAULT_POOL_MASK  (0x7 << E1000_VT_CTL_DEFAULT_POOL_SHIFT)
+
+/* Other useful VMD_CTL register defines */
+#define E1000_VT_CTL_IGNORE_MAC         (1 << 28)
+#define E1000_VT_CTL_DISABLE_DEF_POOL   (1 << 29)
+#define E1000_VT_CTL_VM_REPL_EN         (1 << 30)
+
+/* Per VM Offload register setup */
+#define E1000_VMOLR_LPE        0x00010000 /* Accept Long packet */
+#define E1000_VMOLR_AUPE       0x01000000 /* Accept untagged packets */
+#define E1000_VMOLR_BAM        0x08000000 /* Accept Broadcast packets */
+#define E1000_VMOLR_MPME       0x10000000 /* Multicast promiscuous mode */
+#define E1000_VMOLR_STRVLAN    0x40000000 /* Vlan stripping enable */
+
+#define E1000_V2PMAILBOX_REQ   0x00000001 /* Request for PF Ready bit */
+#define E1000_V2PMAILBOX_ACK   0x00000002 /* Ack PF message received */
+#define E1000_V2PMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
+#define E1000_V2PMAILBOX_PFU   0x00000008 /* PF owns the mailbox buffer */
+#define E1000_V2PMAILBOX_PFSTS 0x00000010 /* PF wrote a message in the MB */
+#define E1000_V2PMAILBOX_PFACK 0x00000020 /* PF ack the previous VF msg */
+#define E1000_V2PMAILBOX_RSTI  0x00000040 /* PF has reset indication */
+#define E1000_V2PMAILBOX_RSTD  0x00000080 /* PF has indicated reset done */
+
+#define E1000_P2VMAILBOX_STS   0x00000001 /* Initiate message send to VF */
+#define E1000_P2VMAILBOX_ACK   0x00000002 /* Ack message recv'd from VF */
+#define E1000_P2VMAILBOX_VFU   0x00000004 /* VF owns the mailbox buffer */
+#define E1000_P2VMAILBOX_PFU   0x00000008 /* PF owns the mailbox buffer */
+#define E1000_P2VMAILBOX_RVFU  0x00000010 /* Reset VFU - used when VF stuck */
+
+#define E1000_VLVF_ARRAY_SIZE     32
+#define E1000_VLVF_VLANID_MASK    0x00000FFF
+#define E1000_VLVF_POOLSEL_SHIFT  12
+#define E1000_VLVF_POOLSEL_MASK   (0xFF << E1000_VLVF_POOLSEL_SHIFT)
+#define E1000_VLVF_LVLAN          0x00100000
+#define E1000_VLVF_VLANID_ENABLE  0x80000000
+
+#define E1000_VFMAILBOX_SIZE   16 /* 16 32 bit words - 64 bytes */
+
+/* If it's a E1000_VF_* msg then it originates in the VF and is sent to the
+ * PF.  The reverse is true if it is E1000_PF_*.
+ * Message ACK's are the value or'd with 0xF0000000
+ */
+#define E1000_VT_MSGTYPE_ACK      0xF0000000  /* Messages below or'd with
+                                               * this are the ACK */
+#define E1000_VT_MSGTYPE_NACK     0xFF000000  /* Messages below or'd with
+                                               * this are the NACK */
+#define E1000_VT_MSGINFO_SHIFT    16
+/* bits 23:16 are used for exra info for certain messages */
+#define E1000_VT_MSGINFO_MASK     (0xFF << E1000_VT_MSGINFO_SHIFT)
+
+#define E1000_VF_MSGTYPE_REQ_MAC  1 /* VF needs to know its MAC */
+#define E1000_VF_MSGTYPE_VFLR     2 /* VF notifies VFLR to PF */
+#define E1000_VF_SET_MULTICAST    3 /* VF requests PF to set MC addr */
+#define E1000_VF_SET_VLAN         4 /* VF requests PF to set VLAN */
+#define E1000_VF_SET_LPE          5 /* VF requests PF to set VMOLR.LPE */
+
+/* Add 100h to all PF msgs, leaves room for up to 255 discrete message types
+ * from VF to PF - way more than we'll ever need */
+#define E1000_PF_MSGTYPE_RESET    (1 + 0x100) /* PF notifies global reset
+                                               * imminent to VF */
+#define E1000_PF_MSGTYPE_LSC      (2 + 0x100) /* PF notifies VF of LSC... VF
+                                               * will see extra msg info for
+                                               * status */
+
+#define E1000_PF_MSG_LSCDOWN      (1 << E1000_VT_MSGINFO_SHIFT)
+#define E1000_PF_MSG_LSCUP        (2 << E1000_VT_MSGINFO_SHIFT)
+
+#define ALL_QUEUES   0xFFFF
+
+s32  e1000_send_mail_to_pf_vf(struct e1000_hw *hw, u32 *msg,
+                              s16 size);
+s32  e1000_receive_mail_from_pf_vf(struct e1000_hw *hw,
+                                   u32 *msg, s16 size);
+s32  e1000_send_mail_to_vf(struct e1000_hw *hw, u32 *msg,
+                           u32 vf_number, s16 size);
+s32  e1000_receive_mail_from_vf(struct e1000_hw *hw, u32 *msg,
+                                u32 vf_number, s16 size);
+void e1000_vmdq_loopback_enable_vf(struct e1000_hw *hw);
+void e1000_vmdq_loopback_disable_vf(struct e1000_hw *hw);
+void e1000_vmdq_replication_enable_vf(struct e1000_hw *hw, u32 enables);
+void e1000_vmdq_replication_disable_vf(struct e1000_hw *hw);
+void e1000_vmdq_enable_replication_mode_vf(struct e1000_hw *hw);
+void e1000_vmdq_broadcast_replication_enable_vf(struct e1000_hw *hw,
+						u32 enables);
+void e1000_vmdq_multicast_replication_enable_vf(struct e1000_hw *hw,
+						u32 enables);
+void e1000_vmdq_broadcast_replication_disable_vf(struct e1000_hw *hw,
+						u32 disables);
+void e1000_vmdq_multicast_replication_disable_vf(struct e1000_hw *hw,
+						u32 disables);
+bool e1000_check_for_pf_ack_vf(struct e1000_hw *hw);
+
+bool e1000_check_for_pf_mail_vf(struct e1000_hw *hw, u32*);
+
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_defines.h igbvf-0.5.2.orig/src/e1000_defines.h
--- igbvf-0.5.2/src/e1000_defines.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_defines.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,1460 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_DEFINES_H_
+#define _E1000_DEFINES_H_
+
+/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
+#define REQ_TX_DESCRIPTOR_MULTIPLE  8
+#define REQ_RX_DESCRIPTOR_MULTIPLE  8
+
+/* Definitions for power management and wakeup registers */
+/* Wake Up Control */
+#define E1000_WUC_APME       0x00000001 /* APM Enable */
+#define E1000_WUC_PME_EN     0x00000002 /* PME Enable */
+#define E1000_WUC_PME_STATUS 0x00000004 /* PME Status */
+#define E1000_WUC_APMPME     0x00000008 /* Assert PME on APM Wakeup */
+#define E1000_WUC_LSCWE      0x00000010 /* Link Status wake up enable */
+#define E1000_WUC_LSCWO      0x00000020 /* Link Status wake up override */
+#define E1000_WUC_SPM        0x80000000 /* Enable SPM */
+#define E1000_WUC_PHY_WAKE   0x00000100 /* if PHY supports wakeup */
+
+/* Wake Up Filter Control */
+#define E1000_WUFC_LNKC 0x00000001 /* Link Status Change Wakeup Enable */
+#define E1000_WUFC_MAG  0x00000002 /* Magic Packet Wakeup Enable */
+#define E1000_WUFC_EX   0x00000004 /* Directed Exact Wakeup Enable */
+#define E1000_WUFC_MC   0x00000008 /* Directed Multicast Wakeup Enable */
+#define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
+#define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
+#define E1000_WUFC_IPV4 0x00000040 /* Directed IPv4 Packet Wakeup Enable */
+#define E1000_WUFC_IPV6 0x00000080 /* Directed IPv6 Packet Wakeup Enable */
+#define E1000_WUFC_IGNORE_TCO   0x00008000 /* Ignore WakeOn TCO packets */
+#define E1000_WUFC_FLX0 0x00010000 /* Flexible Filter 0 Enable */
+#define E1000_WUFC_FLX1 0x00020000 /* Flexible Filter 1 Enable */
+#define E1000_WUFC_FLX2 0x00040000 /* Flexible Filter 2 Enable */
+#define E1000_WUFC_FLX3 0x00080000 /* Flexible Filter 3 Enable */
+#define E1000_WUFC_FLX4 0x00100000 /* Flexible Filter 4 Enable */
+#define E1000_WUFC_FLX5 0x00200000 /* Flexible Filter 5 Enable */
+#define E1000_WUFC_ALL_FILTERS  0x000F00FF /* Mask for all wakeup filters */
+#define E1000_WUFC_FLX_OFFSET   16 /* Offset to the Flexible Filters bits */
+#define E1000_WUFC_FLX_FILTERS  0x000F0000 /*Mask for the 4 flexible filters */
+/*
+ * For 82576 to utilize Extended filter masks in addition to
+ * existing (filter) masks
+ */
+#define E1000_WUFC_EXT_FLX_FILTERS      0x00300000 /* Ext. FLX filter mask */
+
+/* Wake Up Status */
+#define E1000_WUS_LNKC         E1000_WUFC_LNKC
+#define E1000_WUS_MAG          E1000_WUFC_MAG
+#define E1000_WUS_EX           E1000_WUFC_EX
+#define E1000_WUS_MC           E1000_WUFC_MC
+#define E1000_WUS_BC           E1000_WUFC_BC
+#define E1000_WUS_ARP          E1000_WUFC_ARP
+#define E1000_WUS_IPV4         E1000_WUFC_IPV4
+#define E1000_WUS_IPV6         E1000_WUFC_IPV6
+#define E1000_WUS_FLX0         E1000_WUFC_FLX0
+#define E1000_WUS_FLX1         E1000_WUFC_FLX1
+#define E1000_WUS_FLX2         E1000_WUFC_FLX2
+#define E1000_WUS_FLX3         E1000_WUFC_FLX3
+#define E1000_WUS_FLX_FILTERS  E1000_WUFC_FLX_FILTERS
+
+/* Wake Up Packet Length */
+#define E1000_WUPL_LENGTH_MASK 0x0FFF   /* Only the lower 12 bits are valid */
+
+/* Four Flexible Filters are supported */
+#define E1000_FLEXIBLE_FILTER_COUNT_MAX 4
+/* Two Extended Flexible Filters are supported (82576) */
+#define E1000_EXT_FLEXIBLE_FILTER_COUNT_MAX     2
+#define E1000_FHFT_LENGTH_OFFSET        0xFC /* Length byte in FHFT */
+#define E1000_FHFT_LENGTH_MASK          0x0FF /* Length in lower byte */
+
+/* Each Flexible Filter is at most 128 (0x80) bytes in length */
+#define E1000_FLEXIBLE_FILTER_SIZE_MAX  128
+
+#define E1000_FFLT_SIZE E1000_FLEXIBLE_FILTER_COUNT_MAX
+#define E1000_FFMT_SIZE E1000_FLEXIBLE_FILTER_SIZE_MAX
+#define E1000_FFVT_SIZE E1000_FLEXIBLE_FILTER_SIZE_MAX
+
+/* Extended Device Control */
+#define E1000_CTRL_EXT_GPI0_EN   0x00000001 /* Maps SDP4 to GPI0 */
+#define E1000_CTRL_EXT_GPI1_EN   0x00000002 /* Maps SDP5 to GPI1 */
+#define E1000_CTRL_EXT_PHYINT_EN E1000_CTRL_EXT_GPI1_EN
+#define E1000_CTRL_EXT_GPI2_EN   0x00000004 /* Maps SDP6 to GPI2 */
+#define E1000_CTRL_EXT_GPI3_EN   0x00000008 /* Maps SDP7 to GPI3 */
+/* Reserved (bits 4,5) in >= 82575 */
+#define E1000_CTRL_EXT_SDP4_DATA 0x00000010 /* Value of SW Definable Pin 4 */
+#define E1000_CTRL_EXT_SDP5_DATA 0x00000020 /* Value of SW Definable Pin 5 */
+#define E1000_CTRL_EXT_PHY_INT   E1000_CTRL_EXT_SDP5_DATA
+#define E1000_CTRL_EXT_SDP6_DATA 0x00000040 /* Value of SW Definable Pin 6 */
+#define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Definable Pin 7 */
+/* SDP 4/5 (bits 8,9) are reserved in >= 82575 */
+#define E1000_CTRL_EXT_SDP4_DIR  0x00000100 /* Direction of SDP4 0=in 1=out */
+#define E1000_CTRL_EXT_SDP5_DIR  0x00000200 /* Direction of SDP5 0=in 1=out */
+#define E1000_CTRL_EXT_SDP6_DIR  0x00000400 /* Direction of SDP6 0=in 1=out */
+#define E1000_CTRL_EXT_SDP7_DIR  0x00000800 /* Direction of SDP7 0=in 1=out */
+#define E1000_CTRL_EXT_ASDCHK    0x00001000 /* Initiate an ASD sequence */
+#define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
+#define E1000_CTRL_EXT_IPS       0x00004000 /* Invert Power State */
+/* Physical Func Reset Done Indication */
+#define E1000_CTRL_EXT_PFRSTD    0x00004000
+#define E1000_CTRL_EXT_SPD_BYPS  0x00008000 /* Speed Select Bypass */
+#define E1000_CTRL_EXT_RO_DIS    0x00020000 /* Relaxed Ordering disable */
+#define E1000_CTRL_EXT_LINK_MODE_MASK 0x00C00000
+#define E1000_CTRL_EXT_LINK_MODE_GMII 0x00000000
+#define E1000_CTRL_EXT_LINK_MODE_TBI  0x00C00000
+#define E1000_CTRL_EXT_LINK_MODE_KMRN    0x00000000
+#define E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
+#define E1000_CTRL_EXT_LINK_MODE_PCIX_SERDES  0x00800000
+#define E1000_CTRL_EXT_LINK_MODE_SGMII   0x00800000
+#define E1000_CTRL_EXT_EIAME          0x01000000
+#define E1000_CTRL_EXT_IRCA           0x00000001
+#define E1000_CTRL_EXT_WR_WMARK_MASK  0x03000000
+#define E1000_CTRL_EXT_WR_WMARK_256   0x00000000
+#define E1000_CTRL_EXT_WR_WMARK_320   0x01000000
+#define E1000_CTRL_EXT_WR_WMARK_384   0x02000000
+#define E1000_CTRL_EXT_WR_WMARK_448   0x03000000
+#define E1000_CTRL_EXT_CANC           0x04000000 /* Int delay cancellation */
+#define E1000_CTRL_EXT_DRV_LOAD       0x10000000 /* Driver loaded bit for FW */
+/* IAME enable bit (27) was removed in >= 82575 */
+#define E1000_CTRL_EXT_IAME           0x08000000 /* Int acknowledge Auto-mask */
+#define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers
+                                                  * after IMS clear */
+#define E1000_CRTL_EXT_PB_PAREN       0x01000000 /* packet buffer parity error
+                                                  * detection enabled */
+#define E1000_CTRL_EXT_DF_PAREN       0x02000000 /* descriptor FIFO parity
+                                                  * error detection enable */
+#define E1000_CTRL_EXT_GHOST_PAREN    0x40000000
+#define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
+#define E1000_I2CCMD_REG_ADDR_SHIFT   16
+#define E1000_I2CCMD_REG_ADDR         0x00FF0000
+#define E1000_I2CCMD_PHY_ADDR_SHIFT   24
+#define E1000_I2CCMD_PHY_ADDR         0x07000000
+#define E1000_I2CCMD_OPCODE_READ      0x08000000
+#define E1000_I2CCMD_OPCODE_WRITE     0x00000000
+#define E1000_I2CCMD_RESET            0x10000000
+#define E1000_I2CCMD_READY            0x20000000
+#define E1000_I2CCMD_INTERRUPT_ENA    0x40000000
+#define E1000_I2CCMD_ERROR            0x80000000
+#define E1000_MAX_SGMII_PHY_REG_ADDR  255
+#define E1000_I2CCMD_PHY_TIMEOUT      200
+#define E1000_IVAR_VALID        0x80
+#define E1000_GPIE_NSICR        0x00000001
+#define E1000_GPIE_MSIX_MODE    0x00000010
+#define E1000_GPIE_EIAME        0x40000000
+#define E1000_GPIE_PBA          0x80000000
+
+/* Receive Descriptor bit definitions */
+#define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
+#define E1000_RXD_STAT_EOP      0x02    /* End of Packet */
+#define E1000_RXD_STAT_IXSM     0x04    /* Ignore checksum */
+#define E1000_RXD_STAT_VP       0x08    /* IEEE VLAN Packet */
+#define E1000_RXD_STAT_UDPCS    0x10    /* UDP xsum calculated */
+#define E1000_RXD_STAT_TCPCS    0x20    /* TCP xsum calculated */
+#define E1000_RXD_STAT_IPCS     0x40    /* IP xsum calculated */
+#define E1000_RXD_STAT_PIF      0x80    /* passed in-exact filter */
+#define E1000_RXD_STAT_CRCV     0x100   /* Speculative CRC Valid */
+#define E1000_RXD_STAT_IPIDV    0x200   /* IP identification valid */
+#define E1000_RXD_STAT_UDPV     0x400   /* Valid UDP checksum */
+#define E1000_RXD_STAT_DYNINT   0x800   /* Pkt caused INT via DYNINT */
+#define E1000_RXD_STAT_ACK      0x8000  /* ACK Packet indication */
+#define E1000_RXD_ERR_CE        0x01    /* CRC Error */
+#define E1000_RXD_ERR_SE        0x02    /* Symbol Error */
+#define E1000_RXD_ERR_SEQ       0x04    /* Sequence Error */
+#define E1000_RXD_ERR_CXE       0x10    /* Carrier Extension Error */
+#define E1000_RXD_ERR_TCPE      0x20    /* TCP/UDP Checksum Error */
+#define E1000_RXD_ERR_IPE       0x40    /* IP Checksum Error */
+#define E1000_RXD_ERR_RXE       0x80    /* Rx Data Error */
+#define E1000_RXD_SPC_VLAN_MASK 0x0FFF  /* VLAN ID is in lower 12 bits */
+#define E1000_RXD_SPC_PRI_MASK  0xE000  /* Priority is in upper 3 bits */
+#define E1000_RXD_SPC_PRI_SHIFT 13
+#define E1000_RXD_SPC_CFI_MASK  0x1000  /* CFI is bit 12 */
+#define E1000_RXD_SPC_CFI_SHIFT 12
+
+#define E1000_RXDEXT_STATERR_CE    0x01000000
+#define E1000_RXDEXT_STATERR_SE    0x02000000
+#define E1000_RXDEXT_STATERR_SEQ   0x04000000
+#define E1000_RXDEXT_STATERR_CXE   0x10000000
+#define E1000_RXDEXT_STATERR_TCPE  0x20000000
+#define E1000_RXDEXT_STATERR_IPE   0x40000000
+#define E1000_RXDEXT_STATERR_RXE   0x80000000
+
+/* mask to determine if packets should be dropped due to frame errors */
+#define E1000_RXD_ERR_FRAME_ERR_MASK ( \
+    E1000_RXD_ERR_CE  |                \
+    E1000_RXD_ERR_SE  |                \
+    E1000_RXD_ERR_SEQ |                \
+    E1000_RXD_ERR_CXE |                \
+    E1000_RXD_ERR_RXE)
+
+/* Same mask, but for extended and packet split descriptors */
+#define E1000_RXDEXT_ERR_FRAME_ERR_MASK ( \
+    E1000_RXDEXT_STATERR_CE  |            \
+    E1000_RXDEXT_STATERR_SE  |            \
+    E1000_RXDEXT_STATERR_SEQ |            \
+    E1000_RXDEXT_STATERR_CXE |            \
+    E1000_RXDEXT_STATERR_RXE)
+
+#define E1000_MRQC_ENABLE_MASK                 0x00000007
+#define E1000_MRQC_ENABLE_RSS_2Q               0x00000001
+#define E1000_MRQC_ENABLE_RSS_INT              0x00000004
+#define E1000_MRQC_RSS_FIELD_MASK              0xFFFF0000
+#define E1000_MRQC_RSS_FIELD_IPV4_TCP          0x00010000
+#define E1000_MRQC_RSS_FIELD_IPV4              0x00020000
+#define E1000_MRQC_RSS_FIELD_IPV6_TCP_EX       0x00040000
+#define E1000_MRQC_RSS_FIELD_IPV6_EX           0x00080000
+#define E1000_MRQC_RSS_FIELD_IPV6              0x00100000
+#define E1000_MRQC_RSS_FIELD_IPV6_TCP          0x00200000
+
+#define E1000_RXDPS_HDRSTAT_HDRSP              0x00008000
+#define E1000_RXDPS_HDRSTAT_HDRLEN_MASK        0x000003FF
+
+/* Management Control */
+#define E1000_MANC_SMBUS_EN      0x00000001 /* SMBus Enabled - RO */
+#define E1000_MANC_ASF_EN        0x00000002 /* ASF Enabled - RO */
+#define E1000_MANC_R_ON_FORCE    0x00000004 /* Reset on Force TCO - RO */
+#define E1000_MANC_RMCP_EN       0x00000100 /* Enable RCMP 026Fh Filtering */
+#define E1000_MANC_0298_EN       0x00000200 /* Enable RCMP 0298h Filtering */
+#define E1000_MANC_IPV4_EN       0x00000400 /* Enable IPv4 */
+#define E1000_MANC_IPV6_EN       0x00000800 /* Enable IPv6 */
+#define E1000_MANC_SNAP_EN       0x00001000 /* Accept LLC/SNAP */
+#define E1000_MANC_ARP_EN        0x00002000 /* Enable ARP Request Filtering */
+/* Enable Neighbor Discovery Filtering */
+#define E1000_MANC_NEIGHBOR_EN   0x00004000
+#define E1000_MANC_ARP_RES_EN    0x00008000 /* Enable ARP response Filtering */
+#define E1000_MANC_TCO_RESET     0x00010000 /* TCO Reset Occurred */
+#define E1000_MANC_RCV_TCO_EN    0x00020000 /* Receive TCO Packets Enabled */
+#define E1000_MANC_REPORT_STATUS 0x00040000 /* Status Reporting Enabled */
+#define E1000_MANC_RCV_ALL       0x00080000 /* Receive All Enabled */
+#define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000 /* Block phy resets */
+/* Enable MAC address filtering */
+#define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000
+/* Enable MNG packets to host memory */
+#define E1000_MANC_EN_MNG2HOST   0x00200000
+/* Enable IP address filtering */
+#define E1000_MANC_EN_IP_ADDR_FILTER    0x00400000
+#define E1000_MANC_EN_XSUM_FILTER   0x00800000 /* Enable checksum filtering */
+#define E1000_MANC_BR_EN            0x01000000 /* Enable broadcast filtering */
+#define E1000_MANC_SMB_REQ       0x01000000 /* SMBus Request */
+#define E1000_MANC_SMB_GNT       0x02000000 /* SMBus Grant */
+#define E1000_MANC_SMB_CLK_IN    0x04000000 /* SMBus Clock In */
+#define E1000_MANC_SMB_DATA_IN   0x08000000 /* SMBus Data In */
+#define E1000_MANC_SMB_DATA_OUT  0x10000000 /* SMBus Data Out */
+#define E1000_MANC_SMB_CLK_OUT   0x20000000 /* SMBus Clock Out */
+
+#define E1000_MANC_SMB_DATA_OUT_SHIFT  28 /* SMBus Data Out Shift */
+#define E1000_MANC_SMB_CLK_OUT_SHIFT   29 /* SMBus Clock Out Shift */
+
+/* Receive Control */
+#define E1000_RCTL_RST            0x00000001    /* Software reset */
+#define E1000_RCTL_EN             0x00000002    /* enable */
+#define E1000_RCTL_SBP            0x00000004    /* store bad packet */
+#define E1000_RCTL_UPE            0x00000008    /* unicast promiscuous enable */
+#define E1000_RCTL_MPE            0x00000010    /* multicast promiscuous enab */
+#define E1000_RCTL_LPE            0x00000020    /* long packet enable */
+#define E1000_RCTL_LBM_NO         0x00000000    /* no loopback mode */
+#define E1000_RCTL_LBM_MAC        0x00000040    /* MAC loopback mode */
+#define E1000_RCTL_LBM_SLP        0x00000080    /* serial link loopback mode */
+#define E1000_RCTL_LBM_TCVR       0x000000C0    /* tcvr loopback mode */
+#define E1000_RCTL_DTYP_MASK      0x00000C00    /* Descriptor type mask */
+#define E1000_RCTL_DTYP_PS        0x00000400    /* Packet Split descriptor */
+#define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
+#define E1000_RCTL_RDMTS_QUAT     0x00000100    /* rx desc min threshold size */
+#define E1000_RCTL_RDMTS_EIGTH    0x00000200    /* rx desc min threshold size */
+#define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
+#define E1000_RCTL_MO_0           0x00000000    /* multicast offset 11:0 */
+#define E1000_RCTL_MO_1           0x00001000    /* multicast offset 12:1 */
+#define E1000_RCTL_MO_2           0x00002000    /* multicast offset 13:2 */
+#define E1000_RCTL_MO_3           0x00003000    /* multicast offset 15:4 */
+#define E1000_RCTL_MDR            0x00004000    /* multicast desc ring 0 */
+#define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
+/* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
+#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
+#define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
+#define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
+#define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
+/* these buffer sizes are valid if E1000_RCTL_BSEX is 1 */
+#define E1000_RCTL_SZ_16384       0x00010000    /* rx buffer size 16384 */
+#define E1000_RCTL_SZ_8192        0x00020000    /* rx buffer size 8192 */
+#define E1000_RCTL_SZ_4096        0x00030000    /* rx buffer size 4096 */
+#define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
+#define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
+#define E1000_RCTL_CFI            0x00100000    /* canonical form indicator */
+#define E1000_RCTL_DPF            0x00400000    /* discard pause frames */
+#define E1000_RCTL_PMCF           0x00800000    /* pass MAC control frames */
+#define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
+#define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
+#define E1000_RCTL_FLXBUF_MASK    0x78000000    /* Flexible buffer size */
+#define E1000_RCTL_FLXBUF_SHIFT   27            /* Flexible buffer shift */
+
+/*
+ * Use byte values for the following shift parameters
+ * Usage:
+ *     psrctl |= (((ROUNDUP(value0, 128) >> E1000_PSRCTL_BSIZE0_SHIFT) &
+ *                  E1000_PSRCTL_BSIZE0_MASK) |
+ *                ((ROUNDUP(value1, 1024) >> E1000_PSRCTL_BSIZE1_SHIFT) &
+ *                  E1000_PSRCTL_BSIZE1_MASK) |
+ *                ((ROUNDUP(value2, 1024) << E1000_PSRCTL_BSIZE2_SHIFT) &
+ *                  E1000_PSRCTL_BSIZE2_MASK) |
+ *                ((ROUNDUP(value3, 1024) << E1000_PSRCTL_BSIZE3_SHIFT) |;
+ *                  E1000_PSRCTL_BSIZE3_MASK))
+ * where value0 = [128..16256],  default=256
+ *       value1 = [1024..64512], default=4096
+ *       value2 = [0..64512],    default=4096
+ *       value3 = [0..64512],    default=0
+ */
+
+#define E1000_PSRCTL_BSIZE0_MASK   0x0000007F
+#define E1000_PSRCTL_BSIZE1_MASK   0x00003F00
+#define E1000_PSRCTL_BSIZE2_MASK   0x003F0000
+#define E1000_PSRCTL_BSIZE3_MASK   0x3F000000
+
+#define E1000_PSRCTL_BSIZE0_SHIFT  7            /* Shift _right_ 7 */
+#define E1000_PSRCTL_BSIZE1_SHIFT  2            /* Shift _right_ 2 */
+#define E1000_PSRCTL_BSIZE2_SHIFT  6            /* Shift _left_ 6 */
+#define E1000_PSRCTL_BSIZE3_SHIFT 14            /* Shift _left_ 14 */
+
+/* SWFW_SYNC Definitions */
+#define E1000_SWFW_EEP_SM   0x1
+#define E1000_SWFW_PHY0_SM  0x2
+#define E1000_SWFW_PHY1_SM  0x4
+#define E1000_SWFW_CSR_SM   0x8
+
+/* FACTPS Definitions */
+#define E1000_FACTPS_LFS    0x40000000  /* LAN Function Select */
+/* Device Control */
+#define E1000_CTRL_FD       0x00000001  /* Full duplex.0=half; 1=full */
+#define E1000_CTRL_BEM      0x00000002  /* Endian Mode.0=little,1=big */
+#define E1000_CTRL_PRIOR    0x00000004  /* Priority on PCI. 0=rx,1=fair */
+#define E1000_CTRL_GIO_MASTER_DISABLE 0x00000004 /*Blocks new Master requests */
+#define E1000_CTRL_LRST     0x00000008  /* Link reset. 0=normal,1=reset */
+#define E1000_CTRL_TME      0x00000010  /* Test mode. 0=normal,1=test */
+#define E1000_CTRL_SLE      0x00000020  /* Serial Link on 0=dis,1=en */
+#define E1000_CTRL_ASDE     0x00000020  /* Auto-speed detect enable */
+#define E1000_CTRL_SLU      0x00000040  /* Set link up (Force Link) */
+#define E1000_CTRL_ILOS     0x00000080  /* Invert Loss-Of Signal */
+#define E1000_CTRL_SPD_SEL  0x00000300  /* Speed Select Mask */
+#define E1000_CTRL_SPD_10   0x00000000  /* Force 10Mb */
+#define E1000_CTRL_SPD_100  0x00000100  /* Force 100Mb */
+#define E1000_CTRL_SPD_1000 0x00000200  /* Force 1Gb */
+#define E1000_CTRL_BEM32    0x00000400  /* Big Endian 32 mode */
+#define E1000_CTRL_FRCSPD   0x00000800  /* Force Speed */
+#define E1000_CTRL_FRCDPX   0x00001000  /* Force Duplex */
+#define E1000_CTRL_D_UD_EN  0x00002000  /* Dock/Undock enable */
+#define E1000_CTRL_D_UD_POLARITY 0x00004000 /* Defined polarity of Dock/Undock
+                                             * indication in SDP[0] */
+#define E1000_CTRL_FORCE_PHY_RESET 0x00008000 /* Reset both PHY ports, through
+                                               * PHYRST_N pin */
+#define E1000_CTRL_EXT_LINK_EN 0x00010000 /* enable link status from external
+                                           * LINK_0 and LINK_1 pins */
+#define E1000_CTRL_SWDPIN0  0x00040000  /* SWDPIN 0 value */
+#define E1000_CTRL_SWDPIN1  0x00080000  /* SWDPIN 1 value */
+#define E1000_CTRL_SWDPIN2  0x00100000  /* SWDPIN 2 value */
+#define E1000_CTRL_SWDPIN3  0x00200000  /* SWDPIN 3 value */
+#define E1000_CTRL_SWDPIO0  0x00400000  /* SWDPIN 0 Input or output */
+#define E1000_CTRL_SWDPIO1  0x00800000  /* SWDPIN 1 input or output */
+#define E1000_CTRL_SWDPIO2  0x01000000  /* SWDPIN 2 input or output */
+#define E1000_CTRL_SWDPIO3  0x02000000  /* SWDPIN 3 input or output */
+#define E1000_CTRL_RST      0x04000000  /* Global reset */
+#define E1000_CTRL_RFCE     0x08000000  /* Receive Flow Control enable */
+#define E1000_CTRL_TFCE     0x10000000  /* Transmit flow control enable */
+#define E1000_CTRL_RTE      0x20000000  /* Routing tag enable */
+#define E1000_CTRL_VME      0x40000000  /* IEEE VLAN mode enable */
+#define E1000_CTRL_PHY_RST  0x80000000  /* PHY Reset */
+#define E1000_CTRL_SW2FW_INT 0x02000000 /* Initiate an interrupt to ME */
+#define E1000_CTRL_I2C_ENA  0x02000000  /* I2C enable */
+
+/*
+ * Bit definitions for the Management Data IO (MDIO) and Management Data
+ * Clock (MDC) pins in the Device Control Register.
+ */
+#define E1000_CTRL_PHY_RESET_DIR  E1000_CTRL_SWDPIO0
+#define E1000_CTRL_PHY_RESET      E1000_CTRL_SWDPIN0
+#define E1000_CTRL_MDIO_DIR       E1000_CTRL_SWDPIO2
+#define E1000_CTRL_MDIO           E1000_CTRL_SWDPIN2
+#define E1000_CTRL_MDC_DIR        E1000_CTRL_SWDPIO3
+#define E1000_CTRL_MDC            E1000_CTRL_SWDPIN3
+#define E1000_CTRL_PHY_RESET_DIR4 E1000_CTRL_EXT_SDP4_DIR
+#define E1000_CTRL_PHY_RESET4     E1000_CTRL_EXT_SDP4_DATA
+
+#define E1000_CONNSW_ENRGSRC             0x4
+#define E1000_PCS_CFG_PCS_EN             8
+#define E1000_PCS_LCTL_FLV_LINK_UP       1
+#define E1000_PCS_LCTL_FSV_10            0
+#define E1000_PCS_LCTL_FSV_100           2
+#define E1000_PCS_LCTL_FSV_1000          4
+#define E1000_PCS_LCTL_FDV_FULL          8
+#define E1000_PCS_LCTL_FSD               0x10
+#define E1000_PCS_LCTL_FORCE_LINK        0x20
+#define E1000_PCS_LCTL_LOW_LINK_LATCH    0x40
+#define E1000_PCS_LCTL_FORCE_FCTRL       0x80
+#define E1000_PCS_LCTL_AN_ENABLE         0x10000
+#define E1000_PCS_LCTL_AN_RESTART        0x20000
+#define E1000_PCS_LCTL_AN_TIMEOUT        0x40000
+#define E1000_PCS_LCTL_AN_SGMII_BYPASS   0x80000
+#define E1000_PCS_LCTL_AN_SGMII_TRIGGER  0x100000
+#define E1000_PCS_LCTL_FAST_LINK_TIMER   0x1000000
+#define E1000_PCS_LCTL_LINK_OK_FIX       0x2000000
+#define E1000_PCS_LCTL_CRS_ON_NI         0x4000000
+#define E1000_ENABLE_SERDES_LOOPBACK     0x0410
+
+#define E1000_PCS_LSTS_LINK_OK           1
+#define E1000_PCS_LSTS_SPEED_10          0
+#define E1000_PCS_LSTS_SPEED_100         2
+#define E1000_PCS_LSTS_SPEED_1000        4
+#define E1000_PCS_LSTS_DUPLEX_FULL       8
+#define E1000_PCS_LSTS_SYNK_OK           0x10
+#define E1000_PCS_LSTS_AN_COMPLETE       0x10000
+#define E1000_PCS_LSTS_AN_PAGE_RX        0x20000
+#define E1000_PCS_LSTS_AN_TIMED_OUT      0x40000
+#define E1000_PCS_LSTS_AN_REMOTE_FAULT   0x80000
+#define E1000_PCS_LSTS_AN_ERROR_RWS      0x100000
+
+/* Device Status */
+#define E1000_STATUS_FD         0x00000001      /* Full duplex.0=half,1=full */
+#define E1000_STATUS_LU         0x00000002      /* Link up.0=no,1=link */
+#define E1000_STATUS_FUNC_MASK  0x0000000C      /* PCI Function Mask */
+#define E1000_STATUS_FUNC_SHIFT 2
+#define E1000_STATUS_FUNC_0     0x00000000      /* Function 0 */
+#define E1000_STATUS_FUNC_1     0x00000004      /* Function 1 */
+#define E1000_STATUS_TXOFF      0x00000010      /* transmission paused */
+#define E1000_STATUS_TBIMODE    0x00000020      /* TBI mode */
+#define E1000_STATUS_SPEED_MASK 0x000000C0
+#define E1000_STATUS_SPEED_10   0x00000000      /* Speed 10Mb/s */
+#define E1000_STATUS_SPEED_100  0x00000040      /* Speed 100Mb/s */
+#define E1000_STATUS_SPEED_1000 0x00000080      /* Speed 1000Mb/s */
+#define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion by NVM */
+#define E1000_STATUS_ASDV       0x00000300      /* Auto speed detect value */
+#define E1000_STATUS_DOCK_CI    0x00000800      /* Change in Dock/Undock state.
+                                                 * Clear on write '0'. */
+#define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Master request status */
+#define E1000_STATUS_MTXCKOK    0x00000400      /* MTX clock running OK */
+#define E1000_STATUS_PCI66      0x00000800      /* In 66Mhz slot */
+#define E1000_STATUS_BUS64      0x00001000      /* In 64 bit slot */
+#define E1000_STATUS_PCIX_MODE  0x00002000      /* PCI-X mode */
+#define E1000_STATUS_PCIX_SPEED 0x0000C000      /* PCI-X bus speed */
+#define E1000_STATUS_BMC_SKU_0  0x00100000 /* BMC USB redirect disabled */
+#define E1000_STATUS_BMC_SKU_1  0x00200000 /* BMC SRAM disabled */
+#define E1000_STATUS_BMC_SKU_2  0x00400000 /* BMC SDRAM disabled */
+#define E1000_STATUS_BMC_CRYPTO 0x00800000 /* BMC crypto disabled */
+#define E1000_STATUS_BMC_LITE   0x01000000 /* BMC external code execution
+                                            * disabled */
+#define E1000_STATUS_RGMII_ENABLE 0x02000000 /* RGMII disabled */
+#define E1000_STATUS_FUSE_8       0x04000000
+#define E1000_STATUS_FUSE_9       0x08000000
+#define E1000_STATUS_SERDES0_DIS  0x10000000 /* SERDES disabled on port 0 */
+#define E1000_STATUS_SERDES1_DIS  0x20000000 /* SERDES disabled on port 1 */
+
+/* Constants used to interpret the masked PCI-X bus speed. */
+#define E1000_STATUS_PCIX_SPEED_66  0x00000000 /* PCI-X bus speed  50-66 MHz */
+#define E1000_STATUS_PCIX_SPEED_100 0x00004000 /* PCI-X bus speed  66-100 MHz */
+#define E1000_STATUS_PCIX_SPEED_133 0x00008000 /* PCI-X bus speed 100-133 MHz */
+
+#define SPEED_10    10
+#define SPEED_100   100
+#define SPEED_1000  1000
+#define HALF_DUPLEX 1
+#define FULL_DUPLEX 2
+
+#define PHY_FORCE_TIME   20
+
+#define ADVERTISE_10_HALF                 0x0001
+#define ADVERTISE_10_FULL                 0x0002
+#define ADVERTISE_100_HALF                0x0004
+#define ADVERTISE_100_FULL                0x0008
+#define ADVERTISE_1000_HALF               0x0010 /* Not used, just FYI */
+#define ADVERTISE_1000_FULL               0x0020
+
+/* 1000/H is not supported, nor spec-compliant. */
+#define E1000_ALL_SPEED_DUPLEX  (ADVERTISE_10_HALF |   ADVERTISE_10_FULL | \
+                                ADVERTISE_100_HALF |  ADVERTISE_100_FULL | \
+                                                     ADVERTISE_1000_FULL)
+#define E1000_ALL_NOT_GIG       (ADVERTISE_10_HALF |   ADVERTISE_10_FULL | \
+                                ADVERTISE_100_HALF |  ADVERTISE_100_FULL)
+#define E1000_ALL_100_SPEED    (ADVERTISE_100_HALF |  ADVERTISE_100_FULL)
+#define E1000_ALL_10_SPEED      (ADVERTISE_10_HALF |   ADVERTISE_10_FULL)
+#define E1000_ALL_FULL_DUPLEX   (ADVERTISE_10_FULL |  ADVERTISE_100_FULL | \
+                                                     ADVERTISE_1000_FULL)
+#define E1000_ALL_HALF_DUPLEX   (ADVERTISE_10_HALF |  ADVERTISE_100_HALF)
+
+#define AUTONEG_ADVERTISE_SPEED_DEFAULT   E1000_ALL_SPEED_DUPLEX
+
+/* LED Control */
+#define E1000_LEDCTL_LED0_MODE_MASK       0x0000000F
+#define E1000_LEDCTL_LED0_MODE_SHIFT      0
+#define E1000_LEDCTL_LED0_BLINK_RATE      0x00000020
+#define E1000_LEDCTL_LED0_IVRT            0x00000040
+#define E1000_LEDCTL_LED0_BLINK           0x00000080
+#define E1000_LEDCTL_LED1_MODE_MASK       0x00000F00
+#define E1000_LEDCTL_LED1_MODE_SHIFT      8
+#define E1000_LEDCTL_LED1_BLINK_RATE      0x00002000
+#define E1000_LEDCTL_LED1_IVRT            0x00004000
+#define E1000_LEDCTL_LED1_BLINK           0x00008000
+#define E1000_LEDCTL_LED2_MODE_MASK       0x000F0000
+#define E1000_LEDCTL_LED2_MODE_SHIFT      16
+#define E1000_LEDCTL_LED2_BLINK_RATE      0x00200000
+#define E1000_LEDCTL_LED2_IVRT            0x00400000
+#define E1000_LEDCTL_LED2_BLINK           0x00800000
+#define E1000_LEDCTL_LED3_MODE_MASK       0x0F000000
+#define E1000_LEDCTL_LED3_MODE_SHIFT      24
+#define E1000_LEDCTL_LED3_BLINK_RATE      0x20000000
+#define E1000_LEDCTL_LED3_IVRT            0x40000000
+#define E1000_LEDCTL_LED3_BLINK           0x80000000
+
+#define E1000_LEDCTL_MODE_LINK_10_1000  0x0
+#define E1000_LEDCTL_MODE_LINK_100_1000 0x1
+#define E1000_LEDCTL_MODE_LINK_UP       0x2
+#define E1000_LEDCTL_MODE_ACTIVITY      0x3
+#define E1000_LEDCTL_MODE_LINK_ACTIVITY 0x4
+#define E1000_LEDCTL_MODE_LINK_10       0x5
+#define E1000_LEDCTL_MODE_LINK_100      0x6
+#define E1000_LEDCTL_MODE_LINK_1000     0x7
+#define E1000_LEDCTL_MODE_PCIX_MODE     0x8
+#define E1000_LEDCTL_MODE_FULL_DUPLEX   0x9
+#define E1000_LEDCTL_MODE_COLLISION     0xA
+#define E1000_LEDCTL_MODE_BUS_SPEED     0xB
+#define E1000_LEDCTL_MODE_BUS_SIZE      0xC
+#define E1000_LEDCTL_MODE_PAUSED        0xD
+#define E1000_LEDCTL_MODE_LED_ON        0xE
+#define E1000_LEDCTL_MODE_LED_OFF       0xF
+
+/* Transmit Descriptor bit definitions */
+#define E1000_TXD_DTYP_D     0x00100000 /* Data Descriptor */
+#define E1000_TXD_DTYP_C     0x00000000 /* Context Descriptor */
+#define E1000_TXD_POPTS_SHIFT 8         /* POPTS shift */
+#define E1000_TXD_POPTS_IXSM 0x01       /* Insert IP checksum */
+#define E1000_TXD_POPTS_TXSM 0x02       /* Insert TCP/UDP checksum */
+#define E1000_TXD_CMD_EOP    0x01000000 /* End of Packet */
+#define E1000_TXD_CMD_IFCS   0x02000000 /* Insert FCS (Ethernet CRC) */
+#define E1000_TXD_CMD_IC     0x04000000 /* Insert Checksum */
+#define E1000_TXD_CMD_RS     0x08000000 /* Report Status */
+#define E1000_TXD_CMD_RPS    0x10000000 /* Report Packet Sent */
+#define E1000_TXD_CMD_DEXT   0x20000000 /* Descriptor extension (0 = legacy) */
+#define E1000_TXD_CMD_VLE    0x40000000 /* Add VLAN tag */
+#define E1000_TXD_CMD_IDE    0x80000000 /* Enable Tidv register */
+#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */
+#define E1000_TXD_STAT_EC    0x00000002 /* Excess Collisions */
+#define E1000_TXD_STAT_LC    0x00000004 /* Late Collisions */
+#define E1000_TXD_STAT_TU    0x00000008 /* Transmit underrun */
+#define E1000_TXD_CMD_TCP    0x01000000 /* TCP packet */
+#define E1000_TXD_CMD_IP     0x02000000 /* IP packet */
+#define E1000_TXD_CMD_TSE    0x04000000 /* TCP Seg enable */
+#define E1000_TXD_STAT_TC    0x00000004 /* Tx Underrun */
+/* Extended desc bits for Linksec and timesync */
+
+/* Transmit Control */
+#define E1000_TCTL_RST    0x00000001    /* software reset */
+#define E1000_TCTL_EN     0x00000002    /* enable tx */
+#define E1000_TCTL_BCE    0x00000004    /* busy check enable */
+#define E1000_TCTL_PSP    0x00000008    /* pad short packets */
+#define E1000_TCTL_CT     0x00000ff0    /* collision threshold */
+#define E1000_TCTL_COLD   0x003ff000    /* collision distance */
+#define E1000_TCTL_SWXOFF 0x00400000    /* SW Xoff transmission */
+#define E1000_TCTL_PBE    0x00800000    /* Packet Burst Enable */
+#define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
+#define E1000_TCTL_NRTU   0x02000000    /* No Re-transmit on underrun */
+#define E1000_TCTL_MULR   0x10000000    /* Multiple request support */
+
+/* Transmit Arbitration Count */
+#define E1000_TARC0_ENABLE     0x00000400   /* Enable Tx Queue 0 */
+
+/* SerDes Control */
+#define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
+
+/* Receive Checksum Control */
+#define E1000_RXCSUM_PCSS_MASK 0x000000FF   /* Packet Checksum Start */
+#define E1000_RXCSUM_IPOFL     0x00000100   /* IPv4 checksum offload */
+#define E1000_RXCSUM_TUOFL     0x00000200   /* TCP / UDP checksum offload */
+#define E1000_RXCSUM_IPV6OFL   0x00000400   /* IPv6 checksum offload */
+#define E1000_RXCSUM_CRCOFL    0x00000800   /* CRC32 offload enable */
+#define E1000_RXCSUM_IPPCSE    0x00001000   /* IP payload checksum enable */
+#define E1000_RXCSUM_PCSD      0x00002000   /* packet checksum disabled */
+
+/* Header split receive */
+#define E1000_RFCTL_ISCSI_DIS           0x00000001
+#define E1000_RFCTL_ISCSI_DWC_MASK      0x0000003E
+#define E1000_RFCTL_ISCSI_DWC_SHIFT     1
+#define E1000_RFCTL_NFSW_DIS            0x00000040
+#define E1000_RFCTL_NFSR_DIS            0x00000080
+#define E1000_RFCTL_NFS_VER_MASK        0x00000300
+#define E1000_RFCTL_NFS_VER_SHIFT       8
+#define E1000_RFCTL_IPV6_DIS            0x00000400
+#define E1000_RFCTL_IPV6_XSUM_DIS       0x00000800
+#define E1000_RFCTL_ACK_DIS             0x00001000
+#define E1000_RFCTL_ACKD_DIS            0x00002000
+#define E1000_RFCTL_IPFRSP_DIS          0x00004000
+#define E1000_RFCTL_EXTEN               0x00008000
+#define E1000_RFCTL_IPV6_EX_DIS         0x00010000
+#define E1000_RFCTL_NEW_IPV6_EXT_DIS    0x00020000
+#define E1000_RFCTL_LEF                 0x00040000
+
+/* Collision related configuration parameters */
+#define E1000_COLLISION_THRESHOLD       15
+#define E1000_CT_SHIFT                  4
+#define E1000_COLLISION_DISTANCE        63
+#define E1000_COLD_SHIFT                12
+
+/* Default values for the transmit IPG register */
+#define DEFAULT_82543_TIPG_IPGT_FIBER  9
+#define DEFAULT_82543_TIPG_IPGT_COPPER 8
+
+#define E1000_TIPG_IPGT_MASK  0x000003FF
+#define E1000_TIPG_IPGR1_MASK 0x000FFC00
+#define E1000_TIPG_IPGR2_MASK 0x3FF00000
+
+#define DEFAULT_82543_TIPG_IPGR1 8
+#define E1000_TIPG_IPGR1_SHIFT  10
+
+#define DEFAULT_82543_TIPG_IPGR2 6
+#define DEFAULT_80003ES2LAN_TIPG_IPGR2 7
+#define E1000_TIPG_IPGR2_SHIFT  20
+
+/* Ethertype field values */
+#define ETHERNET_IEEE_VLAN_TYPE 0x8100  /* 802.3ac packet */
+
+#define ETHERNET_FCS_SIZE       4
+#define MAX_JUMBO_FRAME_SIZE    0x3F00
+
+/* Extended Configuration Control and Size */
+#define E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP      0x00000020
+#define E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE       0x00000001
+#define E1000_EXTCNF_CTRL_SWFLAG                 0x00000020
+#define E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_MASK   0x00FF0000
+#define E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH_SHIFT          16
+#define E1000_EXTCNF_CTRL_EXT_CNF_POINTER_MASK   0x0FFF0000
+#define E1000_EXTCNF_CTRL_EXT_CNF_POINTER_SHIFT          16
+
+#define E1000_PHY_CTRL_SPD_EN             0x00000001
+#define E1000_PHY_CTRL_D0A_LPLU           0x00000002
+#define E1000_PHY_CTRL_NOND0A_LPLU        0x00000004
+#define E1000_PHY_CTRL_NOND0A_GBE_DISABLE 0x00000008
+#define E1000_PHY_CTRL_GBE_DISABLE        0x00000040
+
+#define E1000_KABGTXD_BGSQLBIAS           0x00050000
+
+/* PBA constants */
+#define E1000_PBA_6K  0x0006	/* 6KB */
+#define E1000_PBA_8K  0x0008    /* 8KB */
+#define E1000_PBA_12K 0x000C    /* 12KB */
+#define E1000_PBA_14K 0x000E    /* 14KB */
+#define E1000_PBA_16K 0x0010    /* 16KB */
+#define E1000_PBA_18K 0x0012
+#define E1000_PBA_20K 0x0014
+#define E1000_PBA_22K 0x0016
+#define E1000_PBA_24K 0x0018
+#define E1000_PBA_30K 0x001E
+#define E1000_PBA_32K 0x0020
+#define E1000_PBA_34K 0x0022
+#define E1000_PBA_35K 0x0023
+#define E1000_PBA_38K 0x0026
+#define E1000_PBA_40K 0x0028
+#define E1000_PBA_48K 0x0030    /* 48KB */
+#define E1000_PBA_64K 0x0040    /* 64KB */
+
+#define E1000_PBS_16K E1000_PBA_16K
+#define E1000_PBS_24K E1000_PBA_24K
+
+#define IFS_MAX       80
+#define IFS_MIN       40
+#define IFS_RATIO     4
+#define IFS_STEP      10
+#define MIN_NUM_XMITS 1000
+
+/* SW Semaphore Register */
+#define E1000_SWSM_SMBI         0x00000001 /* Driver Semaphore bit */
+#define E1000_SWSM_SWESMBI      0x00000002 /* FW Semaphore bit */
+#define E1000_SWSM_WMNG         0x00000004 /* Wake MNG Clock */
+#define E1000_SWSM_DRV_LOAD     0x00000008 /* Driver Loaded Bit */
+
+/* Interrupt Cause Read */
+#define E1000_ICR_TXDW          0x00000001 /* Transmit desc written back */
+#define E1000_ICR_TXQE          0x00000002 /* Transmit Queue empty */
+#define E1000_ICR_LSC           0x00000004 /* Link Status Change */
+#define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
+#define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
+#define E1000_ICR_RXO           0x00000040 /* rx overrun */
+#define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
+#define E1000_ICR_VMMB          0x00000100 /* VM MB event */
+#define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
+#define E1000_ICR_RXCFG         0x00000400 /* Rx /c/ ordered set */
+#define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
+#define E1000_ICR_GPI_EN1       0x00001000 /* GP Int 1 */
+#define E1000_ICR_GPI_EN2       0x00002000 /* GP Int 2 */
+#define E1000_ICR_GPI_EN3       0x00004000 /* GP Int 3 */
+#define E1000_ICR_TXD_LOW       0x00008000
+#define E1000_ICR_SRPD          0x00010000
+#define E1000_ICR_ACK           0x00020000 /* Receive Ack frame */
+#define E1000_ICR_MNG           0x00040000 /* Manageability event */
+#define E1000_ICR_DOCK          0x00080000 /* Dock/Undock */
+#define E1000_ICR_INT_ASSERTED  0x80000000 /* If this bit asserted, the driver
+                                            * should claim the interrupt */
+#define E1000_ICR_RXD_FIFO_PAR0 0x00100000 /* Q0 Rx desc FIFO parity error */
+#define E1000_ICR_TXD_FIFO_PAR0 0x00200000 /* Q0 Tx desc FIFO parity error */
+#define E1000_ICR_HOST_ARB_PAR  0x00400000 /* host arb read buffer parity err */
+#define E1000_ICR_PB_PAR        0x00800000 /* packet buffer parity error */
+#define E1000_ICR_RXD_FIFO_PAR1 0x01000000 /* Q1 Rx desc FIFO parity error */
+#define E1000_ICR_TXD_FIFO_PAR1 0x02000000 /* Q1 Tx desc FIFO parity error */
+#define E1000_ICR_ALL_PARITY    0x03F00000 /* all parity error bits */
+#define E1000_ICR_DSW           0x00000020 /* FW changed the status of DISSW
+                                            * bit in the FWSM */
+#define E1000_ICR_PHYINT        0x00001000 /* LAN connected device generates
+                                            * an interrupt */
+#define E1000_ICR_DOUTSYNC      0x10000000 /* NIC DMA out of sync */
+#define E1000_ICR_EPRST         0x00100000 /* ME hardware reset occurs */
+
+
+/* Extended Interrupt Cause Read */
+#define E1000_EICR_RX_QUEUE0    0x00000001 /* Rx Queue 0 Interrupt */
+#define E1000_EICR_RX_QUEUE1    0x00000002 /* Rx Queue 1 Interrupt */
+#define E1000_EICR_RX_QUEUE2    0x00000004 /* Rx Queue 2 Interrupt */
+#define E1000_EICR_RX_QUEUE3    0x00000008 /* Rx Queue 3 Interrupt */
+#define E1000_EICR_TX_QUEUE0    0x00000100 /* Tx Queue 0 Interrupt */
+#define E1000_EICR_TX_QUEUE1    0x00000200 /* Tx Queue 1 Interrupt */
+#define E1000_EICR_TX_QUEUE2    0x00000400 /* Tx Queue 2 Interrupt */
+#define E1000_EICR_TX_QUEUE3    0x00000800 /* Tx Queue 3 Interrupt */
+#define E1000_EICR_TCP_TIMER    0x40000000 /* TCP Timer */
+#define E1000_EICR_OTHER        0x80000000 /* Interrupt Cause Active */
+/* TCP Timer */
+#define E1000_TCPTIMER_KS       0x00000100 /* KickStart */
+#define E1000_TCPTIMER_COUNT_ENABLE       0x00000200 /* Count Enable */
+#define E1000_TCPTIMER_COUNT_FINISH       0x00000400 /* Count finish */
+#define E1000_TCPTIMER_LOOP     0x00000800 /* Loop */
+
+/*
+ * This defines the bits that are set in the Interrupt Mask
+ * Set/Read Register.  Each bit is documented below:
+ *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
+ *   o RXSEQ  = Receive Sequence Error
+ */
+#define POLL_IMS_ENABLE_MASK ( \
+    E1000_IMS_RXDMT0 |    \
+    E1000_IMS_RXSEQ)
+
+/*
+ * This defines the bits that are set in the Interrupt Mask
+ * Set/Read Register.  Each bit is documented below:
+ *   o RXT0   = Receiver Timer Interrupt (ring 0)
+ *   o TXDW   = Transmit Descriptor Written Back
+ *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
+ *   o RXSEQ  = Receive Sequence Error
+ *   o LSC    = Link Status Change
+ */
+#define IMS_ENABLE_MASK ( \
+    E1000_IMS_RXT0   |    \
+    E1000_IMS_TXDW   |    \
+    E1000_IMS_RXDMT0 |    \
+    E1000_IMS_RXSEQ  |    \
+    E1000_IMS_LSC)
+
+/* Interrupt Mask Set */
+#define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
+#define E1000_IMS_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
+#define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_IMS_VMMB      E1000_ICR_VMMB      /* Mail box activity */
+#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
+#define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_IMS_RXO       E1000_ICR_RXO       /* rx overrun */
+#define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_IMS_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
+#define E1000_IMS_RXCFG     E1000_ICR_RXCFG     /* Rx /c/ ordered set */
+#define E1000_IMS_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
+#define E1000_IMS_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
+#define E1000_IMS_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
+#define E1000_IMS_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
+#define E1000_IMS_TXD_LOW   E1000_ICR_TXD_LOW
+#define E1000_IMS_SRPD      E1000_ICR_SRPD
+#define E1000_IMS_ACK       E1000_ICR_ACK       /* Receive Ack frame */
+#define E1000_IMS_MNG       E1000_ICR_MNG       /* Manageability event */
+#define E1000_IMS_DOCK      E1000_ICR_DOCK      /* Dock/Undock */
+#define E1000_IMS_RXD_FIFO_PAR0 E1000_ICR_RXD_FIFO_PAR0 /* Q0 Rx desc FIFO
+                                                         * parity error */
+#define E1000_IMS_TXD_FIFO_PAR0 E1000_ICR_TXD_FIFO_PAR0 /* Q0 Tx desc FIFO
+                                                         * parity error */
+#define E1000_IMS_HOST_ARB_PAR  E1000_ICR_HOST_ARB_PAR  /* host arb read buffer
+                                                         * parity error */
+#define E1000_IMS_PB_PAR        E1000_ICR_PB_PAR        /* packet buffer parity
+                                                         * error */
+#define E1000_IMS_RXD_FIFO_PAR1 E1000_ICR_RXD_FIFO_PAR1 /* Q1 Rx desc FIFO
+                                                         * parity error */
+#define E1000_IMS_TXD_FIFO_PAR1 E1000_ICR_TXD_FIFO_PAR1 /* Q1 Tx desc FIFO
+                                                         * parity error */
+#define E1000_IMS_DSW       E1000_ICR_DSW
+#define E1000_IMS_PHYINT    E1000_ICR_PHYINT
+#define E1000_IMS_DOUTSYNC  E1000_ICR_DOUTSYNC /* NIC DMA out of sync */
+#define E1000_IMS_EPRST     E1000_ICR_EPRST
+
+/* Extended Interrupt Mask Set */
+#define E1000_EIMS_RX_QUEUE0    E1000_EICR_RX_QUEUE0 /* Rx Queue 0 Interrupt */
+#define E1000_EIMS_RX_QUEUE1    E1000_EICR_RX_QUEUE1 /* Rx Queue 1 Interrupt */
+#define E1000_EIMS_RX_QUEUE2    E1000_EICR_RX_QUEUE2 /* Rx Queue 2 Interrupt */
+#define E1000_EIMS_RX_QUEUE3    E1000_EICR_RX_QUEUE3 /* Rx Queue 3 Interrupt */
+#define E1000_EIMS_TX_QUEUE0    E1000_EICR_TX_QUEUE0 /* Tx Queue 0 Interrupt */
+#define E1000_EIMS_TX_QUEUE1    E1000_EICR_TX_QUEUE1 /* Tx Queue 1 Interrupt */
+#define E1000_EIMS_TX_QUEUE2    E1000_EICR_TX_QUEUE2 /* Tx Queue 2 Interrupt */
+#define E1000_EIMS_TX_QUEUE3    E1000_EICR_TX_QUEUE3 /* Tx Queue 3 Interrupt */
+#define E1000_EIMS_TCP_TIMER    E1000_EICR_TCP_TIMER /* TCP Timer */
+#define E1000_EIMS_OTHER        E1000_EICR_OTHER   /* Interrupt Cause Active */
+
+/* Interrupt Cause Set */
+#define E1000_ICS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
+#define E1000_ICS_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
+#define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_ICS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
+#define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_ICS_RXO       E1000_ICR_RXO       /* rx overrun */
+#define E1000_ICS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_ICS_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
+#define E1000_ICS_RXCFG     E1000_ICR_RXCFG     /* Rx /c/ ordered set */
+#define E1000_ICS_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
+#define E1000_ICS_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
+#define E1000_ICS_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
+#define E1000_ICS_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
+#define E1000_ICS_TXD_LOW   E1000_ICR_TXD_LOW
+#define E1000_ICS_SRPD      E1000_ICR_SRPD
+#define E1000_ICS_ACK       E1000_ICR_ACK       /* Receive Ack frame */
+#define E1000_ICS_MNG       E1000_ICR_MNG       /* Manageability event */
+#define E1000_ICS_DOCK      E1000_ICR_DOCK      /* Dock/Undock */
+#define E1000_ICS_RXD_FIFO_PAR0 E1000_ICR_RXD_FIFO_PAR0 /* Q0 Rx desc FIFO
+                                                         * parity error */
+#define E1000_ICS_TXD_FIFO_PAR0 E1000_ICR_TXD_FIFO_PAR0 /* Q0 Tx desc FIFO
+                                                         * parity error */
+#define E1000_ICS_HOST_ARB_PAR  E1000_ICR_HOST_ARB_PAR  /* host arb read buffer
+                                                         * parity error */
+#define E1000_ICS_PB_PAR        E1000_ICR_PB_PAR        /* packet buffer parity
+                                                         * error */
+#define E1000_ICS_RXD_FIFO_PAR1 E1000_ICR_RXD_FIFO_PAR1 /* Q1 Rx desc FIFO
+                                                         * parity error */
+#define E1000_ICS_TXD_FIFO_PAR1 E1000_ICR_TXD_FIFO_PAR1 /* Q1 Tx desc FIFO
+                                                         * parity error */
+#define E1000_ICS_DSW       E1000_ICR_DSW
+#define E1000_ICS_DOUTSYNC  E1000_ICR_DOUTSYNC /* NIC DMA out of sync */
+#define E1000_ICS_PHYINT    E1000_ICR_PHYINT
+#define E1000_ICS_EPRST     E1000_ICR_EPRST
+
+/* Extended Interrupt Cause Set */
+#define E1000_EICS_RX_QUEUE0    E1000_EICR_RX_QUEUE0 /* Rx Queue 0 Interrupt */
+#define E1000_EICS_RX_QUEUE1    E1000_EICR_RX_QUEUE1 /* Rx Queue 1 Interrupt */
+#define E1000_EICS_RX_QUEUE2    E1000_EICR_RX_QUEUE2 /* Rx Queue 2 Interrupt */
+#define E1000_EICS_RX_QUEUE3    E1000_EICR_RX_QUEUE3 /* Rx Queue 3 Interrupt */
+#define E1000_EICS_TX_QUEUE0    E1000_EICR_TX_QUEUE0 /* Tx Queue 0 Interrupt */
+#define E1000_EICS_TX_QUEUE1    E1000_EICR_TX_QUEUE1 /* Tx Queue 1 Interrupt */
+#define E1000_EICS_TX_QUEUE2    E1000_EICR_TX_QUEUE2 /* Tx Queue 2 Interrupt */
+#define E1000_EICS_TX_QUEUE3    E1000_EICR_TX_QUEUE3 /* Tx Queue 3 Interrupt */
+#define E1000_EICS_TCP_TIMER    E1000_EICR_TCP_TIMER /* TCP Timer */
+#define E1000_EICS_OTHER        E1000_EICR_OTHER   /* Interrupt Cause Active */
+
+#define E1000_EITR_ITR_INT_MASK 0x0000FFFF
+
+/* Transmit Descriptor Control */
+#define E1000_TXDCTL_PTHRESH 0x0000003F /* TXDCTL Prefetch Threshold */
+#define E1000_TXDCTL_HTHRESH 0x00003F00 /* TXDCTL Host Threshold */
+#define E1000_TXDCTL_WTHRESH 0x003F0000 /* TXDCTL Writeback Threshold */
+#define E1000_TXDCTL_GRAN    0x01000000 /* TXDCTL Granularity */
+#define E1000_TXDCTL_LWTHRESH 0xFE000000 /* TXDCTL Low Threshold */
+#define E1000_TXDCTL_FULL_TX_DESC_WB 0x01010000 /* GRAN=1, WTHRESH=1 */
+#define E1000_TXDCTL_MAX_TX_DESC_PREFETCH 0x0100001F /* GRAN=1, PTHRESH=31 */
+/* Enable the counting of descriptors still to be processed. */
+#define E1000_TXDCTL_COUNT_DESC 0x00400000
+
+/* Flow Control Constants */
+#define FLOW_CONTROL_ADDRESS_LOW  0x00C28001
+#define FLOW_CONTROL_ADDRESS_HIGH 0x00000100
+#define FLOW_CONTROL_TYPE         0x8808
+
+/* 802.1q VLAN Packet Size */
+#define VLAN_TAG_SIZE              4    /* 802.3ac tag (not DMA'd) */
+#define E1000_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bits) */
+
+/* Receive Address */
+/*
+ * Number of high/low register pairs in the RAR. The RAR (Receive Address
+ * Registers) holds the directed and multicast addresses that we monitor.
+ * Technically, we have 16 spots.  However, we reserve one of these spots
+ * (RAR[15]) for our directed address used by controllers with
+ * manageability enabled, allowing us room for 15 multicast addresses.
+ */
+#define E1000_RAR_ENTRIES     15
+#define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */
+
+/* Error Codes */
+#define E1000_SUCCESS      0
+#define E1000_ERR_NVM      1
+#define E1000_ERR_PHY      2
+#define E1000_ERR_CONFIG   3
+#define E1000_ERR_PARAM    4
+#define E1000_ERR_MAC_INIT 5
+#define E1000_ERR_PHY_TYPE 6
+#define E1000_ERR_RESET   9
+#define E1000_ERR_MASTER_REQUESTS_PENDING 10
+#define E1000_ERR_HOST_INTERFACE_COMMAND 11
+#define E1000_BLK_PHY_RESET   12
+#define E1000_ERR_SWFW_SYNC 13
+#define E1000_NOT_IMPLEMENTED 14
+
+/* Loop limit on how long we wait for auto-negotiation to complete */
+#define FIBER_LINK_UP_LIMIT               50
+#define COPPER_LINK_UP_LIMIT              10
+#define PHY_AUTO_NEG_LIMIT                45
+#define PHY_FORCE_LIMIT                   20
+/* Number of 100 microseconds we wait for PCI Express master disable */
+#define MASTER_DISABLE_TIMEOUT      800
+/* Number of milliseconds we wait for PHY configuration done after MAC reset */
+#define PHY_CFG_TIMEOUT             100
+/* Number of 2 milliseconds we wait for acquiring MDIO ownership. */
+#define MDIO_OWNERSHIP_TIMEOUT      10
+/* Number of milliseconds for NVM auto read done after MAC reset. */
+#define AUTO_READ_DONE_TIMEOUT      10
+
+/* Flow Control */
+#define E1000_FCRTH_RTH  0x0000FFF8     /* Mask Bits[15:3] for RTH */
+#define E1000_FCRTH_XFCE 0x80000000     /* External Flow Control Enable */
+#define E1000_FCRTL_RTL  0x0000FFF8     /* Mask Bits[15:3] for RTL */
+#define E1000_FCRTL_XONE 0x80000000     /* Enable XON frame transmission */
+
+/* Transmit Configuration Word */
+#define E1000_TXCW_FD         0x00000020        /* TXCW full duplex */
+#define E1000_TXCW_HD         0x00000040        /* TXCW half duplex */
+#define E1000_TXCW_PAUSE      0x00000080        /* TXCW sym pause request */
+#define E1000_TXCW_ASM_DIR    0x00000100        /* TXCW astm pause direction */
+#define E1000_TXCW_PAUSE_MASK 0x00000180        /* TXCW pause request mask */
+#define E1000_TXCW_RF         0x00003000        /* TXCW remote fault */
+#define E1000_TXCW_NP         0x00008000        /* TXCW next page */
+#define E1000_TXCW_CW         0x0000ffff        /* TxConfigWord mask */
+#define E1000_TXCW_TXC        0x40000000        /* Transmit Config control */
+#define E1000_TXCW_ANE        0x80000000        /* Auto-neg enable */
+
+/* Receive Configuration Word */
+#define E1000_RXCW_CW         0x0000ffff        /* RxConfigWord mask */
+#define E1000_RXCW_NC         0x04000000        /* Receive config no carrier */
+#define E1000_RXCW_IV         0x08000000        /* Receive config invalid */
+#define E1000_RXCW_CC         0x10000000        /* Receive config change */
+#define E1000_RXCW_C          0x20000000        /* Receive config */
+#define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch */
+#define E1000_RXCW_ANC        0x80000000        /* Auto-neg complete */
+
+/* PCI Express Control */
+#define E1000_GCR_RXD_NO_SNOOP          0x00000001
+#define E1000_GCR_RXDSCW_NO_SNOOP       0x00000002
+#define E1000_GCR_RXDSCR_NO_SNOOP       0x00000004
+#define E1000_GCR_TXD_NO_SNOOP          0x00000008
+#define E1000_GCR_TXDSCW_NO_SNOOP       0x00000010
+#define E1000_GCR_TXDSCR_NO_SNOOP       0x00000020
+
+#define PCIE_NO_SNOOP_ALL (E1000_GCR_RXD_NO_SNOOP         | \
+                           E1000_GCR_RXDSCW_NO_SNOOP      | \
+                           E1000_GCR_RXDSCR_NO_SNOOP      | \
+                           E1000_GCR_TXD_NO_SNOOP         | \
+                           E1000_GCR_TXDSCW_NO_SNOOP      | \
+                           E1000_GCR_TXDSCR_NO_SNOOP)
+
+/* PHY Control Register */
+#define MII_CR_SPEED_SELECT_MSB 0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
+#define MII_CR_COLL_TEST_ENABLE 0x0080  /* Collision test enable */
+#define MII_CR_FULL_DUPLEX      0x0100  /* FDX =1, half duplex =0 */
+#define MII_CR_RESTART_AUTO_NEG 0x0200  /* Restart auto negotiation */
+#define MII_CR_ISOLATE          0x0400  /* Isolate PHY from MII */
+#define MII_CR_POWER_DOWN       0x0800  /* Power down */
+#define MII_CR_AUTO_NEG_EN      0x1000  /* Auto Neg Enable */
+#define MII_CR_SPEED_SELECT_LSB 0x2000  /* bits 6,13: 10=1000, 01=100, 00=10 */
+#define MII_CR_LOOPBACK         0x4000  /* 0 = normal, 1 = loopback */
+#define MII_CR_RESET            0x8000  /* 0 = normal, 1 = PHY reset */
+#define MII_CR_SPEED_1000       0x0040
+#define MII_CR_SPEED_100        0x2000
+#define MII_CR_SPEED_10         0x0000
+
+/* PHY Status Register */
+#define MII_SR_EXTENDED_CAPS     0x0001 /* Extended register capabilities */
+#define MII_SR_JABBER_DETECT     0x0002 /* Jabber Detected */
+#define MII_SR_LINK_STATUS       0x0004 /* Link Status 1 = link */
+#define MII_SR_AUTONEG_CAPS      0x0008 /* Auto Neg Capable */
+#define MII_SR_REMOTE_FAULT      0x0010 /* Remote Fault Detect */
+#define MII_SR_AUTONEG_COMPLETE  0x0020 /* Auto Neg Complete */
+#define MII_SR_PREAMBLE_SUPPRESS 0x0040 /* Preamble may be suppressed */
+#define MII_SR_EXTENDED_STATUS   0x0100 /* Ext. status info in Reg 0x0F */
+#define MII_SR_100T2_HD_CAPS     0x0200 /* 100T2 Half Duplex Capable */
+#define MII_SR_100T2_FD_CAPS     0x0400 /* 100T2 Full Duplex Capable */
+#define MII_SR_10T_HD_CAPS       0x0800 /* 10T   Half Duplex Capable */
+#define MII_SR_10T_FD_CAPS       0x1000 /* 10T   Full Duplex Capable */
+#define MII_SR_100X_HD_CAPS      0x2000 /* 100X  Half Duplex Capable */
+#define MII_SR_100X_FD_CAPS      0x4000 /* 100X  Full Duplex Capable */
+#define MII_SR_100T4_CAPS        0x8000 /* 100T4 Capable */
+
+/* Autoneg Advertisement Register */
+#define NWAY_AR_SELECTOR_FIELD   0x0001   /* indicates IEEE 802.3 CSMA/CD */
+#define NWAY_AR_10T_HD_CAPS      0x0020   /* 10T   Half Duplex Capable */
+#define NWAY_AR_10T_FD_CAPS      0x0040   /* 10T   Full Duplex Capable */
+#define NWAY_AR_100TX_HD_CAPS    0x0080   /* 100TX Half Duplex Capable */
+#define NWAY_AR_100TX_FD_CAPS    0x0100   /* 100TX Full Duplex Capable */
+#define NWAY_AR_100T4_CAPS       0x0200   /* 100T4 Capable */
+#define NWAY_AR_PAUSE            0x0400   /* Pause operation desired */
+#define NWAY_AR_ASM_DIR          0x0800   /* Asymmetric Pause Direction bit */
+#define NWAY_AR_REMOTE_FAULT     0x2000   /* Remote Fault detected */
+#define NWAY_AR_NEXT_PAGE        0x8000   /* Next Page ability supported */
+
+/* Link Partner Ability Register (Base Page) */
+#define NWAY_LPAR_SELECTOR_FIELD 0x0000 /* LP protocol selector field */
+#define NWAY_LPAR_10T_HD_CAPS    0x0020 /* LP is 10T   Half Duplex Capable */
+#define NWAY_LPAR_10T_FD_CAPS    0x0040 /* LP is 10T   Full Duplex Capable */
+#define NWAY_LPAR_100TX_HD_CAPS  0x0080 /* LP is 100TX Half Duplex Capable */
+#define NWAY_LPAR_100TX_FD_CAPS  0x0100 /* LP is 100TX Full Duplex Capable */
+#define NWAY_LPAR_100T4_CAPS     0x0200 /* LP is 100T4 Capable */
+#define NWAY_LPAR_PAUSE          0x0400 /* LP Pause operation desired */
+#define NWAY_LPAR_ASM_DIR        0x0800 /* LP Asymmetric Pause Direction bit */
+#define NWAY_LPAR_REMOTE_FAULT   0x2000 /* LP has detected Remote Fault */
+#define NWAY_LPAR_ACKNOWLEDGE    0x4000 /* LP has rx'd link code word */
+#define NWAY_LPAR_NEXT_PAGE      0x8000 /* Next Page ability supported */
+
+/* Autoneg Expansion Register */
+#define NWAY_ER_LP_NWAY_CAPS      0x0001 /* LP has Auto Neg Capability */
+#define NWAY_ER_PAGE_RXD          0x0002 /* LP is 10T   Half Duplex Capable */
+#define NWAY_ER_NEXT_PAGE_CAPS    0x0004 /* LP is 10T   Full Duplex Capable */
+#define NWAY_ER_LP_NEXT_PAGE_CAPS 0x0008 /* LP is 100TX Half Duplex Capable */
+#define NWAY_ER_PAR_DETECT_FAULT  0x0010 /* LP is 100TX Full Duplex Capable */
+
+/* 1000BASE-T Control Register */
+#define CR_1000T_ASYM_PAUSE      0x0080 /* Advertise asymmetric pause bit */
+#define CR_1000T_HD_CAPS         0x0100 /* Advertise 1000T HD capability */
+#define CR_1000T_FD_CAPS         0x0200 /* Advertise 1000T FD capability  */
+#define CR_1000T_REPEATER_DTE    0x0400 /* 1=Repeater/switch device port */
+                                        /* 0=DTE device */
+#define CR_1000T_MS_VALUE        0x0800 /* 1=Configure PHY as Master */
+                                        /* 0=Configure PHY as Slave */
+#define CR_1000T_MS_ENABLE       0x1000 /* 1=Master/Slave manual config value */
+                                        /* 0=Automatic Master/Slave config */
+#define CR_1000T_TEST_MODE_NORMAL 0x0000 /* Normal Operation */
+#define CR_1000T_TEST_MODE_1     0x2000 /* Transmit Waveform test */
+#define CR_1000T_TEST_MODE_2     0x4000 /* Master Transmit Jitter test */
+#define CR_1000T_TEST_MODE_3     0x6000 /* Slave Transmit Jitter test */
+#define CR_1000T_TEST_MODE_4     0x8000 /* Transmitter Distortion test */
+
+/* 1000BASE-T Status Register */
+#define SR_1000T_IDLE_ERROR_CNT   0x00FF /* Num idle errors since last read */
+#define SR_1000T_ASYM_PAUSE_DIR   0x0100 /* LP asymmetric pause direction bit */
+#define SR_1000T_LP_HD_CAPS       0x0400 /* LP is 1000T HD capable */
+#define SR_1000T_LP_FD_CAPS       0x0800 /* LP is 1000T FD capable */
+#define SR_1000T_REMOTE_RX_STATUS 0x1000 /* Remote receiver OK */
+#define SR_1000T_LOCAL_RX_STATUS  0x2000 /* Local receiver OK */
+#define SR_1000T_MS_CONFIG_RES    0x4000 /* 1=Local Tx is Master, 0=Slave */
+#define SR_1000T_MS_CONFIG_FAULT  0x8000 /* Master/Slave config fault */
+
+#define SR_1000T_PHY_EXCESSIVE_IDLE_ERR_COUNT 5
+
+/* PHY 1000 MII Register/Bit Definitions */
+/* PHY Registers defined by IEEE */
+#define PHY_CONTROL      0x00 /* Control Register */
+#define PHY_STATUS       0x01 /* Status Register */
+#define PHY_ID1          0x02 /* Phy Id Reg (word 1) */
+#define PHY_ID2          0x03 /* Phy Id Reg (word 2) */
+#define PHY_AUTONEG_ADV  0x04 /* Autoneg Advertisement */
+#define PHY_LP_ABILITY   0x05 /* Link Partner Ability (Base Page) */
+#define PHY_AUTONEG_EXP  0x06 /* Autoneg Expansion Reg */
+#define PHY_NEXT_PAGE_TX 0x07 /* Next Page Tx */
+#define PHY_LP_NEXT_PAGE 0x08 /* Link Partner Next Page */
+#define PHY_1000T_CTRL   0x09 /* 1000Base-T Control Reg */
+#define PHY_1000T_STATUS 0x0A /* 1000Base-T Status Reg */
+#define PHY_EXT_STATUS   0x0F /* Extended Status Reg */
+
+/* NVM Control */
+#define E1000_EECD_SK        0x00000001 /* NVM Clock */
+#define E1000_EECD_CS        0x00000002 /* NVM Chip Select */
+#define E1000_EECD_DI        0x00000004 /* NVM Data In */
+#define E1000_EECD_DO        0x00000008 /* NVM Data Out */
+#define E1000_EECD_FWE_MASK  0x00000030
+#define E1000_EECD_FWE_DIS   0x00000010 /* Disable FLASH writes */
+#define E1000_EECD_FWE_EN    0x00000020 /* Enable FLASH writes */
+#define E1000_EECD_FWE_SHIFT 4
+#define E1000_EECD_REQ       0x00000040 /* NVM Access Request */
+#define E1000_EECD_GNT       0x00000080 /* NVM Access Grant */
+#define E1000_EECD_PRES      0x00000100 /* NVM Present */
+#define E1000_EECD_SIZE      0x00000200 /* NVM Size (0=64 word 1=256 word) */
+/* NVM Addressing bits based on type 0=small, 1=large */
+#define E1000_EECD_ADDR_BITS 0x00000400
+#define E1000_EECD_TYPE      0x00002000 /* NVM Type (1-SPI, 0-Microwire) */
+#define E1000_NVM_GRANT_ATTEMPTS   1000 /* NVM # attempts to gain grant */
+#define E1000_EECD_AUTO_RD          0x00000200  /* NVM Auto Read done */
+#define E1000_EECD_SIZE_EX_MASK     0x00007800  /* NVM Size */
+#define E1000_EECD_SIZE_EX_SHIFT     11
+#define E1000_EECD_NVADDS    0x00018000 /* NVM Address Size */
+#define E1000_EECD_SELSHAD   0x00020000 /* Select Shadow RAM */
+#define E1000_EECD_INITSRAM  0x00040000 /* Initialize Shadow RAM */
+#define E1000_EECD_FLUPD     0x00080000 /* Update FLASH */
+#define E1000_EECD_AUPDEN    0x00100000 /* Enable Autonomous FLASH update */
+#define E1000_EECD_SHADV     0x00200000 /* Shadow RAM Data Valid */
+#define E1000_EECD_SEC1VAL   0x00400000 /* Sector One Valid */
+#define E1000_EECD_SECVAL_SHIFT      22
+#define E1000_EECD_SEC1VAL_VALID_MASK (E1000_EECD_AUTO_RD | E1000_EECD_PRES)
+
+#define E1000_NVM_SWDPIN0   0x0001   /* SWDPIN 0 NVM Value */
+#define E1000_NVM_LED_LOGIC 0x0020   /* Led Logic Word */
+#define E1000_NVM_RW_REG_DATA   16   /* Offset to data in NVM read/write regs */
+#define E1000_NVM_RW_REG_DONE   2    /* Offset to READ/WRITE done bit */
+#define E1000_NVM_RW_REG_START  1    /* Start operation */
+#define E1000_NVM_RW_ADDR_SHIFT 2    /* Shift to the address bits */
+#define E1000_NVM_POLL_WRITE    1    /* Flag for polling for write complete */
+#define E1000_NVM_POLL_READ     0    /* Flag for polling for read complete */
+#define E1000_FLASH_UPDATES  2000
+
+/* NVM Word Offsets */
+#define NVM_COMPAT                 0x0003
+#define NVM_ID_LED_SETTINGS        0x0004
+#define NVM_VERSION                0x0005
+#define NVM_SERDES_AMPLITUDE       0x0006 /* SERDES output amplitude */
+#define NVM_PHY_CLASS_WORD         0x0007
+#define NVM_INIT_CONTROL1_REG      0x000A
+#define NVM_INIT_CONTROL2_REG      0x000F
+#define NVM_SWDEF_PINS_CTRL_PORT_1 0x0010
+#define NVM_INIT_CONTROL3_PORT_B   0x0014
+#define NVM_INIT_3GIO_3            0x001A
+#define NVM_SWDEF_PINS_CTRL_PORT_0 0x0020
+#define NVM_INIT_CONTROL3_PORT_A   0x0024
+#define NVM_CFG                    0x0012
+#define NVM_FLASH_VERSION          0x0032
+#define NVM_ALT_MAC_ADDR_PTR       0x0037
+#define NVM_CHECKSUM_REG           0x003F
+
+#define E1000_NVM_CFG_DONE_PORT_0  0x40000 /* MNG config cycle done */
+#define E1000_NVM_CFG_DONE_PORT_1  0x80000 /* ...for second port */
+
+/* Mask bits for fields in Word 0x0f of the NVM */
+#define NVM_WORD0F_PAUSE_MASK       0x3000
+#define NVM_WORD0F_PAUSE            0x1000
+#define NVM_WORD0F_ASM_DIR          0x2000
+#define NVM_WORD0F_ANE              0x0800
+#define NVM_WORD0F_SWPDIO_EXT_MASK  0x00F0
+#define NVM_WORD0F_LPLU             0x0001
+
+/* Mask bits for fields in Word 0x1a of the NVM */
+#define NVM_WORD1A_ASPM_MASK  0x000C
+
+/* For checksumming, the sum of all words in the NVM should equal 0xBABA. */
+#define NVM_SUM                    0xBABA
+
+#define NVM_MAC_ADDR_OFFSET        0
+#define NVM_PBA_OFFSET_0           8
+#define NVM_PBA_OFFSET_1           9
+#define NVM_RESERVED_WORD          0xFFFF
+#define NVM_PHY_CLASS_A            0x8000
+#define NVM_SERDES_AMPLITUDE_MASK  0x000F
+#define NVM_SIZE_MASK              0x1C00
+#define NVM_SIZE_SHIFT             10
+#define NVM_WORD_SIZE_BASE_SHIFT   6
+#define NVM_SWDPIO_EXT_SHIFT       4
+
+/* NVM Commands - SPI */
+#define NVM_MAX_RETRY_SPI          5000 /* Max wait of 5ms, for RDY signal */
+#define NVM_READ_OPCODE_SPI        0x03 /* NVM read opcode */
+#define NVM_WRITE_OPCODE_SPI       0x02 /* NVM write opcode */
+#define NVM_A8_OPCODE_SPI          0x08 /* opcode bit-3 = address bit-8 */
+#define NVM_WREN_OPCODE_SPI        0x06 /* NVM set Write Enable latch */
+#define NVM_WRDI_OPCODE_SPI        0x04 /* NVM reset Write Enable latch */
+#define NVM_RDSR_OPCODE_SPI        0x05 /* NVM read Status register */
+#define NVM_WRSR_OPCODE_SPI        0x01 /* NVM write Status register */
+
+/* SPI NVM Status Register */
+#define NVM_STATUS_RDY_SPI         0x01
+#define NVM_STATUS_WEN_SPI         0x02
+#define NVM_STATUS_BP0_SPI         0x04
+#define NVM_STATUS_BP1_SPI         0x08
+#define NVM_STATUS_WPEN_SPI        0x80
+
+/* Word definitions for ID LED Settings */
+#define ID_LED_RESERVED_0000 0x0000
+#define ID_LED_RESERVED_FFFF 0xFFFF
+#define ID_LED_DEFAULT       ((ID_LED_OFF1_ON2  << 12) | \
+                              (ID_LED_OFF1_OFF2 <<  8) | \
+                              (ID_LED_DEF1_DEF2 <<  4) | \
+                              (ID_LED_DEF1_DEF2))
+#define ID_LED_DEF1_DEF2     0x1
+#define ID_LED_DEF1_ON2      0x2
+#define ID_LED_DEF1_OFF2     0x3
+#define ID_LED_ON1_DEF2      0x4
+#define ID_LED_ON1_ON2       0x5
+#define ID_LED_ON1_OFF2      0x6
+#define ID_LED_OFF1_DEF2     0x7
+#define ID_LED_OFF1_ON2      0x8
+#define ID_LED_OFF1_OFF2     0x9
+
+#define IGP_ACTIVITY_LED_MASK   0xFFFFF0FF
+#define IGP_ACTIVITY_LED_ENABLE 0x0300
+#define IGP_LED3_MODE           0x07000000
+
+/* PCI/PCI-X/PCI-EX Config space */
+#define PCI_HEADER_TYPE_REGISTER     0x0E
+#define PCIE_LINK_STATUS             0x12
+
+#define PCI_HEADER_TYPE_MULTIFUNC    0x80
+#define PCIE_LINK_WIDTH_MASK         0x3F0
+#define PCIE_LINK_WIDTH_SHIFT        4
+
+#ifndef ETH_ADDR_LEN
+#define ETH_ADDR_LEN                 6
+#endif
+
+#define PHY_REVISION_MASK      0xFFFFFFF0
+#define MAX_PHY_REG_ADDRESS    0x1F  /* 5 bit address bus (0-0x1F) */
+#define MAX_PHY_MULTI_PAGE_REG 0xF
+
+/* Bit definitions for valid PHY IDs. */
+/*
+ * I = Integrated
+ * E = External
+ */
+#define M88E1000_E_PHY_ID    0x01410C50
+#define M88E1000_I_PHY_ID    0x01410C30
+#define M88E1011_I_PHY_ID    0x01410C20
+#define IGP01E1000_I_PHY_ID  0x02A80380
+#define M88E1011_I_REV_4     0x04
+#define M88E1111_I_PHY_ID    0x01410CC0
+#define GG82563_E_PHY_ID     0x01410CA0
+#define IGP03E1000_E_PHY_ID  0x02A80390
+#define IFE_E_PHY_ID         0x02A80330
+#define IFE_PLUS_E_PHY_ID    0x02A80320
+#define IFE_C_E_PHY_ID       0x02A80310
+#define IGP04E1000_E_PHY_ID  0x02A80391
+#define M88_VENDOR           0x0141
+
+/* M88E1000 Specific Registers */
+#define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
+#define M88E1000_PHY_SPEC_STATUS   0x11  /* PHY Specific Status Register */
+#define M88E1000_INT_ENABLE        0x12  /* Interrupt Enable Register */
+#define M88E1000_INT_STATUS        0x13  /* Interrupt Status Register */
+#define M88E1000_EXT_PHY_SPEC_CTRL 0x14  /* Extended PHY Specific Control */
+#define M88E1000_RX_ERR_CNTR       0x15  /* Receive Error Counter */
+
+#define M88E1000_PHY_EXT_CTRL      0x1A  /* PHY extend control register */
+#define M88E1000_PHY_PAGE_SELECT   0x1D  /* Reg 29 for page number setting */
+#define M88E1000_PHY_GEN_CONTROL   0x1E  /* Its meaning depends on reg 29 */
+#define M88E1000_PHY_VCO_REG_BIT8  0x100 /* Bits 8 & 11 are adjusted for */
+#define M88E1000_PHY_VCO_REG_BIT11 0x800    /* improved BER performance */
+
+/* M88E1000 PHY Specific Control Register */
+#define M88E1000_PSCR_JABBER_DISABLE    0x0001 /* 1=Jabber Function disabled */
+#define M88E1000_PSCR_POLARITY_REVERSAL 0x0002 /* 1=Polarity Reversal enabled */
+#define M88E1000_PSCR_SQE_TEST          0x0004 /* 1=SQE Test enabled */
+/* 1=CLK125 low, 0=CLK125 toggling */
+#define M88E1000_PSCR_CLK125_DISABLE    0x0010
+#define M88E1000_PSCR_MDI_MANUAL_MODE  0x0000  /* MDI Crossover Mode bits 6:5 */
+                                               /* Manual MDI configuration */
+#define M88E1000_PSCR_MDIX_MANUAL_MODE 0x0020  /* Manual MDIX configuration */
+/* 1000BASE-T: Auto crossover, 100BASE-TX/10BASE-T: MDI Mode */
+#define M88E1000_PSCR_AUTO_X_1000T     0x0040
+/* Auto crossover enabled all speeds */
+#define M88E1000_PSCR_AUTO_X_MODE      0x0060
+/*
+ * 1=Enable Extended 10BASE-T distance (Lower 10BASE-T Rx Threshold
+ * 0=Normal 10BASE-T Rx Threshold
+ */
+#define M88E1000_PSCR_EN_10BT_EXT_DIST 0x0080
+/* 1=5-bit interface in 100BASE-TX, 0=MII interface in 100BASE-TX */
+#define M88E1000_PSCR_MII_5BIT_ENABLE      0x0100
+#define M88E1000_PSCR_SCRAMBLER_DISABLE    0x0200 /* 1=Scrambler disable */
+#define M88E1000_PSCR_FORCE_LINK_GOOD      0x0400 /* 1=Force link good */
+#define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800 /* 1=Assert CRS on Transmit */
+
+/* M88E1000 PHY Specific Status Register */
+#define M88E1000_PSSR_JABBER             0x0001 /* 1=Jabber */
+#define M88E1000_PSSR_REV_POLARITY       0x0002 /* 1=Polarity reversed */
+#define M88E1000_PSSR_DOWNSHIFT          0x0020 /* 1=Downshifted */
+#define M88E1000_PSSR_MDIX               0x0040 /* 1=MDIX; 0=MDI */
+/*
+ * 0 = <50M
+ * 1 = 50-80M
+ * 2 = 80-110M
+ * 3 = 110-140M
+ * 4 = >140M
+ */
+#define M88E1000_PSSR_CABLE_LENGTH       0x0380
+#define M88E1000_PSSR_LINK               0x0400 /* 1=Link up, 0=Link down */
+#define M88E1000_PSSR_SPD_DPLX_RESOLVED  0x0800 /* 1=Speed & Duplex resolved */
+#define M88E1000_PSSR_PAGE_RCVD          0x1000 /* 1=Page received */
+#define M88E1000_PSSR_DPLX               0x2000 /* 1=Duplex 0=Half Duplex */
+#define M88E1000_PSSR_SPEED              0xC000 /* Speed, bits 14:15 */
+#define M88E1000_PSSR_10MBS              0x0000 /* 00=10Mbs */
+#define M88E1000_PSSR_100MBS             0x4000 /* 01=100Mbs */
+#define M88E1000_PSSR_1000MBS            0x8000 /* 10=1000Mbs */
+
+#define M88E1000_PSSR_CABLE_LENGTH_SHIFT 7
+
+/* M88E1000 Extended PHY Specific Control Register */
+#define M88E1000_EPSCR_FIBER_LOOPBACK 0x4000 /* 1=Fiber loopback */
+/*
+ * 1 = Lost lock detect enabled.
+ * Will assert lost lock and bring
+ * link down if idle not seen
+ * within 1ms in 1000BASE-T
+ */
+#define M88E1000_EPSCR_DOWN_NO_IDLE   0x8000
+/*
+ * Number of times we will attempt to autonegotiate before downshifting if we
+ * are the master
+ */
+#define M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK 0x0C00
+#define M88E1000_EPSCR_MASTER_DOWNSHIFT_1X   0x0000
+#define M88E1000_EPSCR_MASTER_DOWNSHIFT_2X   0x0400
+#define M88E1000_EPSCR_MASTER_DOWNSHIFT_3X   0x0800
+#define M88E1000_EPSCR_MASTER_DOWNSHIFT_4X   0x0C00
+/*
+ * Number of times we will attempt to autonegotiate before downshifting if we
+ * are the slave
+ */
+#define M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK  0x0300
+#define M88E1000_EPSCR_SLAVE_DOWNSHIFT_DIS   0x0000
+#define M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X    0x0100
+#define M88E1000_EPSCR_SLAVE_DOWNSHIFT_2X    0x0200
+#define M88E1000_EPSCR_SLAVE_DOWNSHIFT_3X    0x0300
+#define M88E1000_EPSCR_TX_CLK_2_5     0x0060 /* 2.5 MHz TX_CLK */
+#define M88E1000_EPSCR_TX_CLK_25      0x0070 /* 25  MHz TX_CLK */
+#define M88E1000_EPSCR_TX_CLK_0       0x0000 /* NO  TX_CLK */
+
+/* M88EC018 Rev 2 specific DownShift settings */
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_1X    0x0000
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_2X    0x0200
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_3X    0x0400
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_4X    0x0600
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_6X    0x0A00
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_7X    0x0C00
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_8X    0x0E00
+
+/*
+ * Bits...
+ * 15-5: page
+ * 4-0: register offset
+ */
+#define GG82563_PAGE_SHIFT        5
+#define GG82563_REG(page, reg)    \
+        (((page) << GG82563_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))
+#define GG82563_MIN_ALT_REG       30
+
+/* GG82563 Specific Registers */
+#define GG82563_PHY_SPEC_CTRL           \
+        GG82563_REG(0, 16) /* PHY Specific Control */
+#define GG82563_PHY_SPEC_STATUS         \
+        GG82563_REG(0, 17) /* PHY Specific Status */
+#define GG82563_PHY_INT_ENABLE          \
+        GG82563_REG(0, 18) /* Interrupt Enable */
+#define GG82563_PHY_SPEC_STATUS_2       \
+        GG82563_REG(0, 19) /* PHY Specific Status 2 */
+#define GG82563_PHY_RX_ERR_CNTR         \
+        GG82563_REG(0, 21) /* Receive Error Counter */
+#define GG82563_PHY_PAGE_SELECT         \
+        GG82563_REG(0, 22) /* Page Select */
+#define GG82563_PHY_SPEC_CTRL_2         \
+        GG82563_REG(0, 26) /* PHY Specific Control 2 */
+#define GG82563_PHY_PAGE_SELECT_ALT     \
+        GG82563_REG(0, 29) /* Alternate Page Select */
+#define GG82563_PHY_TEST_CLK_CTRL       \
+        GG82563_REG(0, 30) /* Test Clock Control (use reg. 29 to select) */
+
+#define GG82563_PHY_MAC_SPEC_CTRL       \
+        GG82563_REG(2, 21) /* MAC Specific Control Register */
+#define GG82563_PHY_MAC_SPEC_CTRL_2     \
+        GG82563_REG(2, 26) /* MAC Specific Control 2 */
+
+#define GG82563_PHY_DSP_DISTANCE    \
+        GG82563_REG(5, 26) /* DSP Distance */
+
+/* Page 193 - Port Control Registers */
+#define GG82563_PHY_KMRN_MODE_CTRL   \
+        GG82563_REG(193, 16) /* Kumeran Mode Control */
+#define GG82563_PHY_PORT_RESET          \
+        GG82563_REG(193, 17) /* Port Reset */
+#define GG82563_PHY_REVISION_ID         \
+        GG82563_REG(193, 18) /* Revision ID */
+#define GG82563_PHY_DEVICE_ID           \
+        GG82563_REG(193, 19) /* Device ID */
+#define GG82563_PHY_PWR_MGMT_CTRL       \
+        GG82563_REG(193, 20) /* Power Management Control */
+#define GG82563_PHY_RATE_ADAPT_CTRL     \
+        GG82563_REG(193, 25) /* Rate Adaptation Control */
+
+/* Page 194 - KMRN Registers */
+#define GG82563_PHY_KMRN_FIFO_CTRL_STAT \
+        GG82563_REG(194, 16) /* FIFO's Control/Status */
+#define GG82563_PHY_KMRN_CTRL           \
+        GG82563_REG(194, 17) /* Control */
+#define GG82563_PHY_INBAND_CTRL         \
+        GG82563_REG(194, 18) /* Inband Control */
+#define GG82563_PHY_KMRN_DIAGNOSTIC     \
+        GG82563_REG(194, 19) /* Diagnostic */
+#define GG82563_PHY_ACK_TIMEOUTS        \
+        GG82563_REG(194, 20) /* Acknowledge Timeouts */
+#define GG82563_PHY_ADV_ABILITY         \
+        GG82563_REG(194, 21) /* Advertised Ability */
+#define GG82563_PHY_LINK_PARTNER_ADV_ABILITY \
+        GG82563_REG(194, 23) /* Link Partner Advertised Ability */
+#define GG82563_PHY_ADV_NEXT_PAGE       \
+        GG82563_REG(194, 24) /* Advertised Next Page */
+#define GG82563_PHY_LINK_PARTNER_ADV_NEXT_PAGE \
+        GG82563_REG(194, 25) /* Link Partner Advertised Next page */
+#define GG82563_PHY_KMRN_MISC           \
+        GG82563_REG(194, 26) /* Misc. */
+
+/* MDI Control */
+#define E1000_MDIC_DATA_MASK 0x0000FFFF
+#define E1000_MDIC_REG_MASK  0x001F0000
+#define E1000_MDIC_REG_SHIFT 16
+#define E1000_MDIC_PHY_MASK  0x03E00000
+#define E1000_MDIC_PHY_SHIFT 21
+#define E1000_MDIC_OP_WRITE  0x04000000
+#define E1000_MDIC_OP_READ   0x08000000
+#define E1000_MDIC_READY     0x10000000
+#define E1000_MDIC_INT_EN    0x20000000
+#define E1000_MDIC_ERROR     0x40000000
+
+/* SerDes Control */
+#define E1000_GEN_CTL_READY             0x80000000
+#define E1000_GEN_CTL_ADDRESS_SHIFT     8
+#define E1000_GEN_POLL_TIMEOUT          640
+
+/* LinkSec register fields */
+#define E1000_LSECTXCAP_SUM_MASK        0x00FF0000
+#define E1000_LSECTXCAP_SUM_SHIFT       16
+#define E1000_LSECRXCAP_SUM_MASK        0x00FF0000
+#define E1000_LSECRXCAP_SUM_SHIFT       16
+
+#define E1000_LSECTXCTRL_EN_MASK        0x00000003
+#define E1000_LSECTXCTRL_DISABLE        0x0
+#define E1000_LSECTXCTRL_AUTH           0x1
+#define E1000_LSECTXCTRL_AUTH_ENCRYPT   0x2
+#define E1000_LSECTXCTRL_AISCI          0x00000020
+#define E1000_LSECTXCTRL_PNTHRSH_MASK   0xFFFFFF00
+#define E1000_LSECTXCTRL_RSV_MASK       0x000000D8
+
+#define E1000_LSECRXCTRL_EN_MASK        0x0000000C
+#define E1000_LSECRXCTRL_EN_SHIFT       2
+#define E1000_LSECRXCTRL_DISABLE        0x0
+#define E1000_LSECRXCTRL_CHECK          0x1
+#define E1000_LSECRXCTRL_STRICT         0x2
+#define E1000_LSECRXCTRL_DROP           0x3
+#define E1000_LSECRXCTRL_PLSH           0x00000040
+#define E1000_LSECRXCTRL_RP             0x00000080
+#define E1000_LSECRXCTRL_RSV_MASK       0xFFFFFF33
+
+#endif /* _E1000_DEFINES_H_ */
diff -Npur igbvf-0.5.2/src/e1000_hw.h igbvf-0.5.2.orig/src/e1000_hw.h
--- igbvf-0.5.2/src/e1000_hw.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_hw.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,669 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_HW_H_
+#define _E1000_HW_H_
+
+#include "e1000_osdep.h"
+#include "e1000_regs.h"
+#include "e1000_defines.h"
+
+struct e1000_hw;
+
+#define E1000_DEV_ID_82576                    0x10C9
+#define E1000_DEV_ID_82576_VF                 0x10CA
+#define E1000_DEV_ID_82575EB_COPPER           0x10A7
+#define E1000_DEV_ID_82575EB_FIBER_SERDES     0x10A9
+#define E1000_DEV_ID_82575GB_QUAD_COPPER      0x10D6
+#define E1000_REVISION_0 0
+#define E1000_REVISION_1 1
+#define E1000_REVISION_2 2
+#define E1000_REVISION_3 3
+#define E1000_REVISION_4 4
+
+#define E1000_FUNC_0     0
+#define E1000_FUNC_1     1
+
+enum e1000_mac_type {
+	e1000_undefined = 0,
+	e1000_82575,
+	e1000_82576,
+	e1000_vfadapt,
+	e1000_num_macs  /* List is 1-based, so subtract 1 for true count. */
+};
+
+enum e1000_media_type {
+	e1000_media_type_unknown = 0,
+	e1000_media_type_copper = 1,
+	e1000_media_type_fiber = 2,
+	e1000_media_type_internal_serdes = 3,
+	e1000_num_media_types
+};
+
+enum e1000_nvm_type {
+	e1000_nvm_unknown = 0,
+	e1000_nvm_none,
+	e1000_nvm_eeprom_spi,
+	e1000_nvm_flash_hw,
+	e1000_nvm_flash_sw
+};
+
+enum e1000_nvm_override {
+	e1000_nvm_override_none = 0,
+	e1000_nvm_override_spi_small,
+	e1000_nvm_override_spi_large,
+};
+
+enum e1000_phy_type {
+	e1000_phy_unknown = 0,
+	e1000_phy_none,
+	e1000_phy_m88,
+	e1000_phy_igp,
+	e1000_phy_igp_2,
+	e1000_phy_gg82563,
+	e1000_phy_igp_3,
+	e1000_phy_ife,
+	e1000_phy_vf,
+};
+
+enum e1000_bus_type {
+	e1000_bus_type_unknown = 0,
+	e1000_bus_type_pci,
+	e1000_bus_type_pcix,
+	e1000_bus_type_pci_express,
+	e1000_bus_type_reserved
+};
+
+enum e1000_bus_speed {
+	e1000_bus_speed_unknown = 0,
+	e1000_bus_speed_33,
+	e1000_bus_speed_66,
+	e1000_bus_speed_100,
+	e1000_bus_speed_120,
+	e1000_bus_speed_133,
+	e1000_bus_speed_2500,
+	e1000_bus_speed_5000,
+	e1000_bus_speed_reserved
+};
+
+enum e1000_bus_width {
+	e1000_bus_width_unknown = 0,
+	e1000_bus_width_pcie_x1,
+	e1000_bus_width_pcie_x2,
+	e1000_bus_width_pcie_x4 = 4,
+	e1000_bus_width_pcie_x8 = 8,
+	e1000_bus_width_32,
+	e1000_bus_width_64,
+	e1000_bus_width_reserved
+};
+
+enum e1000_1000t_rx_status {
+	e1000_1000t_rx_status_not_ok = 0,
+	e1000_1000t_rx_status_ok,
+	e1000_1000t_rx_status_undefined = 0xFF
+};
+
+enum e1000_rev_polarity {
+	e1000_rev_polarity_normal = 0,
+	e1000_rev_polarity_reversed,
+	e1000_rev_polarity_undefined = 0xFF
+};
+
+enum e1000_fc_mode {
+	e1000_fc_none = 0,
+	e1000_fc_rx_pause,
+	e1000_fc_tx_pause,
+	e1000_fc_full,
+	e1000_fc_default = 0xFF
+};
+
+enum e1000_ms_type {
+	e1000_ms_hw_default = 0,
+	e1000_ms_force_master,
+	e1000_ms_force_slave,
+	e1000_ms_auto
+};
+
+enum e1000_smart_speed {
+	e1000_smart_speed_default = 0,
+	e1000_smart_speed_on,
+	e1000_smart_speed_off
+};
+
+/* Receive Descriptor */
+struct e1000_rx_desc {
+	__le64 buffer_addr; /* Address of the descriptor's data buffer */
+	__le16 length;      /* Length of data DMAed into data buffer */
+	__le16 csum;        /* Packet checksum */
+	u8  status;         /* Descriptor status */
+	u8  errors;         /* Descriptor Errors */
+	__le16 special;
+};
+
+/* Receive Descriptor - Extended */
+union e1000_rx_desc_extended {
+	struct {
+		__le64 buffer_addr;
+		__le64 reserved;
+	} read;
+	struct {
+		struct {
+			__le32 mrq;           /* Multiple Rx Queues */
+			union {
+				__le32 rss;         /* RSS Hash */
+				struct {
+					__le16 ip_id;  /* IP id */
+					__le16 csum;   /* Packet Checksum */
+				} csum_ip;
+			} hi_dword;
+		} lower;
+		struct {
+			__le32 status_error;  /* ext status/error */
+			__le16 length;
+			__le16 vlan;          /* VLAN tag */
+		} upper;
+	} wb;  /* writeback */
+};
+
+#define MAX_PS_BUFFERS 4
+/* Receive Descriptor - Packet Split */
+union e1000_rx_desc_packet_split {
+	struct {
+		/* one buffer for protocol header(s), three data buffers */
+		__le64 buffer_addr[MAX_PS_BUFFERS];
+	} read;
+	struct {
+		struct {
+			__le32 mrq;           /* Multiple Rx Queues */
+			union {
+				__le32 rss;           /* RSS Hash */
+				struct {
+					__le16 ip_id;    /* IP id */
+					__le16 csum;     /* Packet Checksum */
+				} csum_ip;
+			} hi_dword;
+		} lower;
+		struct {
+			__le32 status_error;  /* ext status/error */
+			__le16 length0;       /* length of buffer 0 */
+			__le16 vlan;          /* VLAN tag */
+		} middle;
+		struct {
+			__le16 header_status;
+			__le16 length[3];     /* length of buffers 1-3 */
+		} upper;
+		__le64 reserved;
+	} wb; /* writeback */
+};
+
+/* Transmit Descriptor */
+struct e1000_tx_desc {
+	__le64 buffer_addr;   /* Address of the descriptor's data buffer */
+	union {
+		__le32 data;
+		struct {
+			__le16 length;    /* Data buffer length */
+			u8 cso;           /* Checksum offset */
+			u8 cmd;           /* Descriptor control */
+		} flags;
+	} lower;
+	union {
+		__le32 data;
+		struct {
+			u8 status;        /* Descriptor status */
+			u8 css;           /* Checksum start */
+			__le16 special;
+		} fields;
+	} upper;
+};
+
+/* Offload Context Descriptor */
+struct e1000_context_desc {
+	union {
+		__le32 ip_config;
+		struct {
+			u8 ipcss;         /* IP checksum start */
+			u8 ipcso;         /* IP checksum offset */
+			__le16 ipcse;     /* IP checksum end */
+		} ip_fields;
+	} lower_setup;
+	union {
+		__le32 tcp_config;
+		struct {
+			u8 tucss;         /* TCP checksum start */
+			u8 tucso;         /* TCP checksum offset */
+			__le16 tucse;     /* TCP checksum end */
+		} tcp_fields;
+	} upper_setup;
+	__le32 cmd_and_length;
+	union {
+		__le32 data;
+		struct {
+			u8 status;        /* Descriptor status */
+			u8 hdr_len;       /* Header length */
+			__le16 mss;       /* Maximum segment size */
+		} fields;
+	} tcp_seg_setup;
+};
+
+/* Offload data descriptor */
+struct e1000_data_desc {
+	__le64 buffer_addr;   /* Address of the descriptor's buffer address */
+	union {
+		__le32 data;
+		struct {
+			__le16 length;    /* Data buffer length */
+			u8 typ_len_ext;
+			u8 cmd;
+		} flags;
+	} lower;
+	union {
+		__le32 data;
+		struct {
+			u8 status;        /* Descriptor status */
+			u8 popts;         /* Packet Options */
+			__le16 special;
+		} fields;
+	} upper;
+};
+
+/* Statistics counters collected by the MAC */
+struct e1000_hw_stats {
+	u64 crcerrs;
+	u64 algnerrc;
+	u64 symerrs;
+	u64 rxerrc;
+	u64 mpc;
+	u64 scc;
+	u64 ecol;
+	u64 mcc;
+	u64 latecol;
+	u64 colc;
+	u64 dc;
+	u64 tncrs;
+	u64 sec;
+	u64 cexterr;
+	u64 rlec;
+	u64 xonrxc;
+	u64 xontxc;
+	u64 xoffrxc;
+	u64 xofftxc;
+	u64 fcruc;
+	u64 prc64;
+	u64 prc127;
+	u64 prc255;
+	u64 prc511;
+	u64 prc1023;
+	u64 prc1522;
+	u64 gprc;
+	u64 bprc;
+	u64 mprc;
+	u64 gptc;
+	u64 gorc;
+	u64 gotc;
+	u64 rnbc;
+	u64 ruc;
+	u64 rfc;
+	u64 roc;
+	u64 rjc;
+	u64 mgprc;
+	u64 mgpdc;
+	u64 mgptc;
+	u64 tor;
+	u64 tot;
+	u64 tpr;
+	u64 tpt;
+	u64 ptc64;
+	u64 ptc127;
+	u64 ptc255;
+	u64 ptc511;
+	u64 ptc1023;
+	u64 ptc1522;
+	u64 mptc;
+	u64 bptc;
+	u64 tsctc;
+	u64 tsctfc;
+	u64 iac;
+	u64 icrxptc;
+	u64 icrxatc;
+	u64 ictxptc;
+	u64 ictxatc;
+	u64 ictxqec;
+	u64 ictxqmtc;
+	u64 icrxdmtc;
+	u64 icrxoc;
+	u64 cbtmpc;
+	u64 htdpmc;
+	u64 cbrdpc;
+	u64 cbrmpc;
+	u64 rpthc;
+	u64 hgptc;
+	u64 htcbdpc;
+	u64 hgorc;
+	u64 hgotc;
+	u64 lenerrs;
+	u64 scvpc;
+	u64 hrmpc;
+	u64 doosync;
+};
+
+struct e1000_vf_stats {
+	u64 base_gprc;
+	u64 base_gptc;
+	u64 base_gorc;
+	u64 base_gotc;
+	u64 base_mprc;
+	u64 base_gotlbc;
+	u64 base_gptlbc;
+	u64 base_gorlbc;
+	u64 base_gprlbc;
+
+	u32 last_gprc;
+	u32 last_gptc;
+	u32 last_gorc;
+	u32 last_gotc;
+	u32 last_mprc;
+	u32 last_gotlbc;
+	u32 last_gptlbc;
+	u32 last_gorlbc;
+	u32 last_gprlbc;
+
+	u64 gprc;
+	u64 gptc;
+	u64 gorc;
+	u64 gotc;
+	u64 mprc;
+	u64 gotlbc;
+	u64 gptlbc;
+	u64 gorlbc;
+	u64 gprlbc;
+};
+
+struct e1000_phy_stats {
+	u32 idle_errors;
+	u32 receive_errors;
+};
+
+struct e1000_host_mng_dhcp_cookie {
+	u32 signature;
+	u8  status;
+	u8  reserved0;
+	u16 vlan_id;
+	u32 reserved1;
+	u16 reserved2;
+	u8  reserved3;
+	u8  checksum;
+};
+
+/* Host Interface "Rev 1" */
+struct e1000_host_command_header {
+	u8 command_id;
+	u8 command_length;
+	u8 command_options;
+	u8 checksum;
+};
+
+#define E1000_HI_MAX_DATA_LENGTH     252
+struct e1000_host_command_info {
+	struct e1000_host_command_header command_header;
+	u8 command_data[E1000_HI_MAX_DATA_LENGTH];
+};
+
+/* Host Interface "Rev 2" */
+struct e1000_host_mng_command_header {
+	u8  command_id;
+	u8  checksum;
+	u16 reserved1;
+	u16 reserved2;
+	u16 command_length;
+};
+
+#define E1000_HI_MAX_MNG_DATA_LENGTH 0x6F8
+struct e1000_host_mng_command_info {
+	struct e1000_host_mng_command_header command_header;
+	u8 command_data[E1000_HI_MAX_MNG_DATA_LENGTH];
+};
+
+#include "e1000_mac.h"
+#include "e1000_phy.h"
+#include "e1000_nvm.h"
+#include "e1000_manage.h"
+
+struct e1000_mac_operations {
+	/* Function pointers for the MAC. */
+	s32  (*init_params)(struct e1000_hw *);
+	s32  (*id_led_init)(struct e1000_hw *);
+	s32  (*blink_led)(struct e1000_hw *);
+	s32  (*check_for_link)(struct e1000_hw *);
+	bool (*check_mng_mode)(struct e1000_hw *hw);
+	s32  (*cleanup_led)(struct e1000_hw *);
+	void (*clear_hw_cntrs)(struct e1000_hw *);
+	void (*clear_vfta)(struct e1000_hw *);
+	s32  (*get_bus_info)(struct e1000_hw *);
+	void (*set_lan_id)(struct e1000_hw *);
+	s32  (*get_link_up_info)(struct e1000_hw *, u16 *, u16 *);
+	s32  (*led_on)(struct e1000_hw *);
+	s32  (*led_off)(struct e1000_hw *);
+	void (*update_mc_addr_list)(struct e1000_hw *, u8 *, u32, u32, u32);
+	s32  (*reset_hw)(struct e1000_hw *);
+	s32  (*init_hw)(struct e1000_hw *);
+	void (*shutdown_serdes)(struct e1000_hw *);
+	s32  (*setup_link)(struct e1000_hw *);
+	s32  (*setup_physical_interface)(struct e1000_hw *);
+	s32  (*setup_led)(struct e1000_hw *);
+	void (*write_vfta)(struct e1000_hw *, u32, u32);
+	void (*mta_set)(struct e1000_hw *, u32);
+	void (*config_collision_dist)(struct e1000_hw *);
+	void (*rar_set)(struct e1000_hw *, u8*, u32);
+	s32  (*read_mac_addr)(struct e1000_hw *);
+	s32  (*validate_mdi_setting)(struct e1000_hw *);
+	s32  (*mng_host_if_write)(struct e1000_hw *, u8*, u16, u16, u8*);
+	s32  (*mng_write_cmd_header)(struct e1000_hw *hw,
+                      struct e1000_host_mng_command_header*);
+	s32  (*mng_enable_host_if)(struct e1000_hw *);
+	s32  (*wait_autoneg)(struct e1000_hw *);
+};
+
+struct e1000_phy_operations {
+	s32  (*init_params)(struct e1000_hw *);
+	s32  (*acquire)(struct e1000_hw *);
+	s32  (*check_polarity)(struct e1000_hw *);
+	s32  (*check_reset_block)(struct e1000_hw *);
+	s32  (*commit)(struct e1000_hw *);
+	s32  (*force_speed_duplex)(struct e1000_hw *);
+	s32  (*get_cfg_done)(struct e1000_hw *hw);
+	s32  (*get_cable_length)(struct e1000_hw *);
+	s32  (*get_info)(struct e1000_hw *);
+	s32  (*read_reg)(struct e1000_hw *, u32, u16 *);
+	void (*release)(struct e1000_hw *);
+	s32  (*reset)(struct e1000_hw *);
+	s32  (*set_d0_lplu_state)(struct e1000_hw *, bool);
+	s32  (*set_d3_lplu_state)(struct e1000_hw *, bool);
+	s32  (*write_reg)(struct e1000_hw *, u32, u16);
+	void (*power_up)(struct e1000_hw *);
+	void (*power_down)(struct e1000_hw *);
+};
+
+struct e1000_nvm_operations {
+	s32  (*init_params)(struct e1000_hw *);
+	s32  (*acquire)(struct e1000_hw *);
+	s32  (*read)(struct e1000_hw *, u16, u16, u16 *);
+	void (*release)(struct e1000_hw *);
+	void (*reload)(struct e1000_hw *);
+	s32  (*update)(struct e1000_hw *);
+	s32  (*valid_led_default)(struct e1000_hw *, u16 *);
+	s32  (*validate)(struct e1000_hw *);
+	s32  (*write)(struct e1000_hw *, u16, u16, u16 *);
+};
+
+struct e1000_mac_info {
+	struct e1000_mac_operations ops;
+	u8 addr[6];
+	u8 perm_addr[6];
+
+	enum e1000_mac_type type;
+
+	u32 collision_delta;
+	u32 ledctl_default;
+	u32 ledctl_mode1;
+	u32 ledctl_mode2;
+	u32 mc_filter_type;
+	u32 tx_packet_delta;
+	u32 txcw;
+
+	u16 current_ifs_val;
+	u16 ifs_max_val;
+	u16 ifs_min_val;
+	u16 ifs_ratio;
+	u16 ifs_step_size;
+	u16 mta_reg_count;
+	u16 rar_entry_count;
+
+	u8  forced_speed_duplex;
+
+	bool adaptive_ifs;
+	bool arc_subsystem_valid;
+	bool asf_firmware_present;
+	bool autoneg;
+	bool autoneg_failed;
+	bool get_link_status;
+	bool in_ifs_mode;
+	bool serdes_has_link;
+	bool tx_pkt_filtering;
+};
+
+struct e1000_phy_info {
+	struct e1000_phy_operations ops;
+	enum e1000_phy_type type;
+
+	enum e1000_1000t_rx_status local_rx;
+	enum e1000_1000t_rx_status remote_rx;
+	enum e1000_ms_type ms_type;
+	enum e1000_ms_type original_ms_type;
+	enum e1000_rev_polarity cable_polarity;
+	enum e1000_smart_speed smart_speed;
+
+	u32 addr;
+	u32 id;
+	u32 reset_delay_us; /* in usec */
+	u32 revision;
+
+	enum e1000_media_type media_type;
+
+	u16 autoneg_advertised;
+	u16 autoneg_mask;
+	u16 cable_length;
+	u16 max_cable_length;
+	u16 min_cable_length;
+
+	u8 mdix;
+
+	bool disable_polarity_correction;
+	bool is_mdix;
+	bool polarity_correction;
+	bool reset_disable;
+	bool speed_downgraded;
+	bool autoneg_wait_to_complete;
+};
+
+struct e1000_nvm_info {
+	struct e1000_nvm_operations ops;
+	enum e1000_nvm_type type;
+	enum e1000_nvm_override override;
+
+	u32 flash_bank_size;
+	u32 flash_base_addr;
+
+	u16 word_size;
+	u16 delay_usec;
+	u16 address_bits;
+	u16 opcode_bits;
+	u16 page_size;
+};
+
+struct e1000_bus_info {
+	enum e1000_bus_type type;
+	enum e1000_bus_speed speed;
+	enum e1000_bus_width width;
+
+	u16 func;
+	u16 pci_cmd_word;
+};
+
+struct e1000_fc_info {
+	u32 high_water;          /* Flow control high-water mark */
+	u32 low_water;           /* Flow control low-water mark */
+	u16 pause_time;          /* Flow control pause timer */
+	bool send_xon;           /* Flow control send XON */
+	bool strict_ieee;        /* Strict IEEE mode */
+	enum e1000_fc_mode current_mode; /* FC mode in effect */
+	enum e1000_fc_mode requested_mode; /* FC mode requested by caller */
+};
+
+struct e1000_dev_spec_82575 {
+	bool sgmii_active;
+};
+
+struct e1000_dev_spec_vf {
+	u32	vf_number;
+};
+
+struct e1000_hw {
+	void *back;
+
+	u8 __iomem *hw_addr;
+	u8 __iomem *flash_address;
+	unsigned long io_base;
+
+	struct e1000_mac_info  mac;
+	struct e1000_fc_info   fc;
+	struct e1000_phy_info  phy;
+	struct e1000_nvm_info  nvm;
+	struct e1000_bus_info  bus;
+	struct e1000_host_mng_dhcp_cookie mng_cookie;
+
+	union {
+		struct e1000_dev_spec_82575	_82575;
+		struct e1000_dev_spec_vf	vf;
+	} dev_spec;
+
+	u16 device_id;
+	u16 subsystem_vendor_id;
+	u16 subsystem_device_id;
+	u16 vendor_id;
+
+	u8  revision_id;
+};
+
+#include "e1000_82575.h"
+
+/* These functions must be implemented by drivers */
+s32  e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
+void e1000_read_pci_cfg(struct e1000_hw *hw, u32 reg, u16 *value);
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_mac.c igbvf-0.5.2.orig/src/e1000_mac.c
--- igbvf-0.5.2/src/e1000_mac.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_mac.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,2126 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000_hw.h"
+
+static u32 e1000_hash_mc_addr_generic(struct e1000_hw *hw, u8 *mc_addr);
+static s32 e1000_set_default_fc_generic(struct e1000_hw *hw);
+static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw);
+static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw);
+static s32 e1000_validate_mdi_setting_generic(struct e1000_hw *hw);
+
+/**
+ *  e1000_init_mac_ops_generic - Initialize MAC function pointers
+ *  @hw: pointer to the HW structure
+ *
+ *  Setups up the function pointers to no-op functions
+ **/
+void e1000_init_mac_ops_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	DEBUGFUNC("e1000_init_mac_ops_generic");
+
+	/* General Setup */
+	mac->ops.init_hw = e1000_null_ops_generic;
+	mac->ops.reset_hw = e1000_null_ops_generic;
+	mac->ops.setup_physical_interface = e1000_null_ops_generic;
+	mac->ops.get_bus_info = e1000_null_ops_generic;
+	mac->ops.set_lan_id = e1000_set_lan_id_multi_port_pcie;
+	mac->ops.read_mac_addr = e1000_read_mac_addr_generic;
+	mac->ops.config_collision_dist = e1000_config_collision_dist_generic;
+	mac->ops.clear_hw_cntrs = e1000_null_mac_generic;
+	/* LED */
+	mac->ops.cleanup_led = e1000_null_ops_generic;
+	mac->ops.setup_led = e1000_null_ops_generic;
+	mac->ops.blink_led = e1000_null_ops_generic;
+	mac->ops.led_on = e1000_null_ops_generic;
+	mac->ops.led_off = e1000_null_ops_generic;
+	/* LINK */
+	mac->ops.setup_link = e1000_null_ops_generic;
+	mac->ops.get_link_up_info = e1000_null_link_info;
+	mac->ops.check_for_link = e1000_null_ops_generic;
+	mac->ops.wait_autoneg = e1000_wait_autoneg_generic;
+	/* Management */
+	mac->ops.check_mng_mode = e1000_null_mng_mode;
+	mac->ops.mng_host_if_write = e1000_mng_host_if_write_generic;
+	mac->ops.mng_write_cmd_header = e1000_mng_write_cmd_header_generic;
+	mac->ops.mng_enable_host_if = e1000_mng_enable_host_if_generic;
+	/* VLAN, MC, etc. */
+	mac->ops.update_mc_addr_list = e1000_null_update_mc;
+	mac->ops.clear_vfta = e1000_null_mac_generic;
+	mac->ops.write_vfta = e1000_null_write_vfta;
+	mac->ops.mta_set = e1000_null_mta_set;
+	mac->ops.rar_set = e1000_rar_set_generic;
+	mac->ops.validate_mdi_setting = e1000_validate_mdi_setting_generic;
+}
+
+/**
+ *  e1000_null_ops_generic - No-op function, returns 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_ops_generic(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_null_ops_generic");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_null_mac_generic - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_mac_generic(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_null_mac_generic");
+	return;
+}
+
+/**
+ *  e1000_null_link_info - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_link_info(struct e1000_hw *hw, u16 *s, u16 *d)
+{
+	DEBUGFUNC("e1000_null_link_info");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_null_mng_mode - No-op function, return false
+ *  @hw: pointer to the HW structure
+ **/
+bool e1000_null_mng_mode(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_null_mng_mode");
+	return false;
+}
+
+/**
+ *  e1000_null_update_mc - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_update_mc(struct e1000_hw *hw, u8 *h, u32 a, u32 b, u32 c)
+{
+	DEBUGFUNC("e1000_null_update_mc");
+	return;
+}
+
+/**
+ *  e1000_null_write_vfta - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_write_vfta(struct e1000_hw *hw, u32 a, u32 b)
+{
+	DEBUGFUNC("e1000_null_write_vfta");
+	return;
+}
+
+/**
+ *  e1000_null_set_mta - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_mta_set(struct e1000_hw *hw, u32 a)
+{
+	DEBUGFUNC("e1000_null_mta_set");
+	return;
+}
+
+/**
+ *  e1000_null_rar_set - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_rar_set(struct e1000_hw *hw, u8 *h, u32 a)
+{
+	DEBUGFUNC("e1000_null_rar_set");
+	return;
+}
+
+/**
+ *  e1000_get_bus_info_pcie_generic - Get PCIe bus information
+ *  @hw: pointer to the HW structure
+ *
+ *  Determines and stores the system bus information for a particular
+ *  network interface.  The following bus information is determined and stored:
+ *  bus speed, bus width, type (PCIe), and PCIe function.
+ **/
+s32 e1000_get_bus_info_pcie_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	struct e1000_bus_info *bus = &hw->bus;
+
+	s32 ret_val;
+	u16 pcie_link_status;
+
+	DEBUGFUNC("e1000_get_bus_info_pcie_generic");
+
+	bus->type = e1000_bus_type_pci_express;
+	bus->speed = e1000_bus_speed_2500;
+
+	ret_val = e1000_read_pcie_cap_reg(hw,
+	                                  PCIE_LINK_STATUS,
+	                                  &pcie_link_status);
+	if (ret_val)
+		bus->width = e1000_bus_width_unknown;
+	else
+		bus->width = (enum e1000_bus_width)((pcie_link_status &
+		                                PCIE_LINK_WIDTH_MASK) >>
+		                               PCIE_LINK_WIDTH_SHIFT);
+
+	mac->ops.set_lan_id(hw);
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_set_lan_id_multi_port_pcie - Set LAN id for PCIe multiple port devices
+ *
+ *  @hw: pointer to the HW structure
+ *
+ *  Determines the LAN function id by reading memory-mapped registers
+ *  and swaps the port value if requested.
+ **/
+void e1000_set_lan_id_multi_port_pcie(struct e1000_hw *hw)
+{
+	struct e1000_bus_info *bus = &hw->bus;
+	u32 reg;
+
+	/*
+	 * The status register reports the correct function number
+	 * for the device regardless of function swap state.
+	 */
+	reg = E1000_READ_REG(hw, E1000_STATUS);
+	bus->func = (reg & E1000_STATUS_FUNC_MASK) >> E1000_STATUS_FUNC_SHIFT;
+}
+
+/**
+ *  e1000_set_lan_id_multi_port_pci - Set LAN id for PCI multiple port devices
+ *  @hw: pointer to the HW structure
+ *
+ *  Determines the LAN function id by reading PCI config space.
+ **/
+void e1000_set_lan_id_multi_port_pci(struct e1000_hw *hw)
+{
+	struct e1000_bus_info *bus = &hw->bus;
+	u16 pci_header_type;
+	u32 status;
+
+	e1000_read_pci_cfg(hw, PCI_HEADER_TYPE_REGISTER, &pci_header_type);
+	if (pci_header_type & PCI_HEADER_TYPE_MULTIFUNC) {
+		status = E1000_READ_REG(hw, E1000_STATUS);
+		bus->func = (status & E1000_STATUS_FUNC_MASK)
+		            >> E1000_STATUS_FUNC_SHIFT;
+	} else {
+		bus->func = 0;
+	}
+}
+
+/**
+ *  e1000_set_lan_id_single_port - Set LAN id for a single port device
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets the LAN function id to zero for a single port device.
+ **/
+void e1000_set_lan_id_single_port(struct e1000_hw *hw)
+{
+	struct e1000_bus_info *bus = &hw->bus;
+
+	bus->func = 0;
+}
+
+/**
+ *  e1000_clear_vfta_generic - Clear VLAN filter table
+ *  @hw: pointer to the HW structure
+ *
+ *  Clears the register array which contains the VLAN filter table by
+ *  setting all the values to 0.
+ **/
+void e1000_clear_vfta_generic(struct e1000_hw *hw)
+{
+	u32 offset;
+
+	DEBUGFUNC("e1000_clear_vfta_generic");
+
+	for (offset = 0; offset < E1000_VLAN_FILTER_TBL_SIZE; offset++) {
+		E1000_WRITE_REG_ARRAY(hw, E1000_VFTA, offset, 0);
+		E1000_WRITE_FLUSH(hw);
+	}
+}
+
+/**
+ *  e1000_write_vfta_generic - Write value to VLAN filter table
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset in VLAN filter table
+ *  @value: register value written to VLAN filter table
+ *
+ *  Writes value at the given offset in the register array which stores
+ *  the VLAN filter table.
+ **/
+void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value)
+{
+	DEBUGFUNC("e1000_write_vfta_generic");
+
+	E1000_WRITE_REG_ARRAY(hw, E1000_VFTA, offset, value);
+	E1000_WRITE_FLUSH(hw);
+}
+
+/**
+ *  e1000_init_rx_addrs_generic - Initialize receive address's
+ *  @hw: pointer to the HW structure
+ *  @rar_count: receive address registers
+ *
+ *  Setups the receive address registers by setting the base receive address
+ *  register to the devices MAC address and clearing all the other receive
+ *  address registers to 0.
+ **/
+void e1000_init_rx_addrs_generic(struct e1000_hw *hw, u16 rar_count)
+{
+	u32 i;
+
+	DEBUGFUNC("e1000_init_rx_addrs_generic");
+
+	/* Setup the receive address */
+	DEBUGOUT("Programming MAC Address into RAR[0]\n");
+
+	hw->mac.ops.rar_set(hw, hw->mac.addr, 0);
+
+	/* Zero out the other (rar_entry_count - 1) receive addresses */
+	DEBUGOUT1("Clearing RAR[1-%u]\n", rar_count-1);
+	for (i = 1; i < rar_count; i++) {
+		E1000_WRITE_REG_ARRAY(hw, E1000_RA, (i << 1), 0);
+		E1000_WRITE_FLUSH(hw);
+		E1000_WRITE_REG_ARRAY(hw, E1000_RA, ((i << 1) + 1), 0);
+		E1000_WRITE_FLUSH(hw);
+	}
+}
+
+/**
+ *  e1000_check_alt_mac_addr_generic - Check for alternate MAC addr
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks the nvm for an alternate MAC address.  An alternate MAC address
+ *  can be setup by pre-boot software and must be treated like a permanent
+ *  address and must override the actual permanent MAC address.  If an
+ *  alternate MAC address is found it is saved in the hw struct and
+ *  programmed into RAR0 and the function returns success, otherwise the
+ *  function returns an error.
+ **/
+s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
+{
+	u32 i;
+	s32 ret_val = E1000_SUCCESS;
+	u16 offset, nvm_alt_mac_addr_offset, nvm_data;
+	u8 alt_mac_addr[ETH_ADDR_LEN];
+
+	DEBUGFUNC("e1000_check_alt_mac_addr_generic");
+
+	ret_val = hw->nvm.ops.read(hw, NVM_ALT_MAC_ADDR_PTR, 1,
+	                         &nvm_alt_mac_addr_offset);
+	if (ret_val) {
+		DEBUGOUT("NVM Read Error\n");
+		goto out;
+	}
+
+	if (nvm_alt_mac_addr_offset == 0xFFFF) {
+		ret_val = -(E1000_NOT_IMPLEMENTED);
+		goto out;
+	}
+
+	if (hw->bus.func == E1000_FUNC_1)
+		nvm_alt_mac_addr_offset += ETH_ADDR_LEN/sizeof(u16);
+
+	for (i = 0; i < ETH_ADDR_LEN; i += 2) {
+		offset = nvm_alt_mac_addr_offset + (i >> 1);
+		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
+		if (ret_val) {
+			DEBUGOUT("NVM Read Error\n");
+			goto out;
+		}
+
+		alt_mac_addr[i] = (u8)(nvm_data & 0xFF);
+		alt_mac_addr[i + 1] = (u8)(nvm_data >> 8);
+	}
+
+	/* if multicast bit is set, the alternate address will not be used */
+	if (alt_mac_addr[0] & 0x01) {
+		ret_val = -(E1000_NOT_IMPLEMENTED);
+		goto out;
+	}
+
+	for (i = 0; i < ETH_ADDR_LEN; i++)
+		hw->mac.addr[i] = hw->mac.perm_addr[i] = alt_mac_addr[i];
+
+	hw->mac.ops.rar_set(hw, hw->mac.perm_addr, 0);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_rar_set_generic - Set receive address register
+ *  @hw: pointer to the HW structure
+ *  @addr: pointer to the receive address
+ *  @index: receive address array register
+ *
+ *  Sets the receive address array register at index to the address passed
+ *  in by addr.
+ **/
+void e1000_rar_set_generic(struct e1000_hw *hw, u8 *addr, u32 index)
+{
+	u32 rar_low, rar_high;
+
+	DEBUGFUNC("e1000_rar_set_generic");
+
+	/*
+	 * HW expects these in little endian so we reverse the byte order
+	 * from network order (big endian) to little endian
+	 */
+	rar_low = ((u32) addr[0] |
+	           ((u32) addr[1] << 8) |
+	           ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
+
+	rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
+
+	/* If MAC address zero, no need to set the AV bit */
+	if (rar_low || rar_high)
+		rar_high |= E1000_RAH_AV;
+
+	/*
+	 * Some bridges will combine consecutive 32-bit writes into
+	 * a single burst write, which will malfunction on some
+	 * 82546 parts.  The flush avoids this.
+	 */
+	E1000_WRITE_REG(hw, E1000_RAL(index), rar_low);
+	E1000_WRITE_FLUSH(hw);
+	E1000_WRITE_REG(hw, E1000_RAH(index), rar_high);
+}
+
+/**
+ *  e1000_mta_set_generic - Set multicast filter table address
+ *  @hw: pointer to the HW structure
+ *  @hash_value: determines the MTA register and bit to set
+ *
+ *  The multicast table address is a register array of 32-bit registers.
+ *  The hash_value is used to determine what register the bit is in, the
+ *  current value is read, the new bit is OR'd in and the new value is
+ *  written back into the register.
+ **/
+void e1000_mta_set_generic(struct e1000_hw *hw, u32 hash_value)
+{
+	u32 hash_bit, hash_reg, mta;
+
+	DEBUGFUNC("e1000_mta_set_generic");
+	/*
+	 * The MTA is a register array of 32-bit registers. It is
+	 * treated like an array of (32*mta_reg_count) bits.  We want to
+	 * set bit BitArray[hash_value]. So we figure out what register
+	 * the bit is in, read it, OR in the new bit, then write
+	 * back the new value.  The (hw->mac.mta_reg_count - 1) serves as a
+	 * mask to bits 31:5 of the hash value which gives us the
+	 * register we're modifying.  The hash bit within that register
+	 * is determined by the lower 5 bits of the hash value.
+	 */
+	hash_reg = (hash_value >> 5) & (hw->mac.mta_reg_count - 1);
+	hash_bit = hash_value & 0x1F;
+
+	mta = E1000_READ_REG_ARRAY(hw, E1000_MTA, hash_reg);
+
+	mta |= (1 << hash_bit);
+
+	E1000_WRITE_REG_ARRAY(hw, E1000_MTA, hash_reg, mta);
+	E1000_WRITE_FLUSH(hw);
+}
+
+/**
+ *  e1000_update_mc_addr_list_generic - Update Multicast addresses
+ *  @hw: pointer to the HW structure
+ *  @mc_addr_list: array of multicast addresses to program
+ *  @mc_addr_count: number of multicast addresses to program
+ *  @rar_used_count: the first RAR register free to program
+ *  @rar_count: total number of supported Receive Address Registers
+ *
+ *  Updates the Receive Address Registers and Multicast Table Array.
+ *  The caller must have a packed mc_addr_list of multicast addresses.
+ *  The parameter rar_count will usually be hw->mac.rar_entry_count
+ *  unless there are workarounds that change this.
+ **/
+void e1000_update_mc_addr_list_generic(struct e1000_hw *hw,
+                                       u8 *mc_addr_list, u32 mc_addr_count,
+                                       u32 rar_used_count, u32 rar_count)
+{
+	u32 hash_value;
+	u32 i;
+
+	DEBUGFUNC("e1000_update_mc_addr_list_generic");
+
+	/*
+	 * Load the first set of multicast addresses into the exact
+	 * filters (RAR).  If there are not enough to fill the RAR
+	 * array, clear the filters.
+	 */
+	for (i = rar_used_count; i < rar_count; i++) {
+		if (mc_addr_count) {
+			hw->mac.ops.rar_set(hw, mc_addr_list, i);
+			mc_addr_count--;
+			mc_addr_list += ETH_ADDR_LEN;
+		} else {
+			E1000_WRITE_REG_ARRAY(hw, E1000_RA, i << 1, 0);
+			E1000_WRITE_FLUSH(hw);
+			E1000_WRITE_REG_ARRAY(hw, E1000_RA, (i << 1) + 1, 0);
+			E1000_WRITE_FLUSH(hw);
+		}
+	}
+
+	/* Clear the old settings from the MTA */
+	DEBUGOUT("Clearing MTA\n");
+	for (i = 0; i < hw->mac.mta_reg_count; i++) {
+		E1000_WRITE_REG_ARRAY(hw, E1000_MTA, i, 0);
+		E1000_WRITE_FLUSH(hw);
+	}
+
+	/* Load any remaining multicast addresses into the hash table. */
+	for (; mc_addr_count > 0; mc_addr_count--) {
+		hash_value = e1000_hash_mc_addr_generic(hw, mc_addr_list);
+		DEBUGOUT1("Hash value = 0x%03X\n", hash_value);
+		hw->mac.ops.mta_set(hw, hash_value);
+		mc_addr_list += ETH_ADDR_LEN;
+	}
+}
+
+/**
+ *  e1000_hash_mc_addr_generic - Generate a multicast hash value
+ *  @hw: pointer to the HW structure
+ *  @mc_addr: pointer to a multicast address
+ *
+ *  Generates a multicast address hash value which is used to determine
+ *  the multicast filter table array address and new table value.  See
+ *  e1000_mta_set_generic()
+ **/
+static u32 e1000_hash_mc_addr_generic(struct e1000_hw *hw, u8 *mc_addr)
+{
+	u32 hash_value, hash_mask;
+	u8 bit_shift = 0;
+
+	DEBUGFUNC("e1000_hash_mc_addr_generic");
+
+	/* Register count multiplied by bits per register */
+	hash_mask = (hw->mac.mta_reg_count * 32) - 1;
+
+	/*
+	 * For a mc_filter_type of 0, bit_shift is the number of left-shifts
+	 * where 0xFF would still fall within the hash mask.
+	 */
+	while (hash_mask >> bit_shift != 0xFF)
+		bit_shift++;
+
+	/*
+	 * The portion of the address that is used for the hash table
+	 * is determined by the mc_filter_type setting.
+	 * The algorithm is such that there is a total of 8 bits of shifting.
+	 * The bit_shift for a mc_filter_type of 0 represents the number of
+	 * left-shifts where the MSB of mc_addr[5] would still fall within
+	 * the hash_mask.  Case 0 does this exactly.  Since there are a total
+	 * of 8 bits of shifting, then mc_addr[4] will shift right the
+	 * remaining number of bits. Thus 8 - bit_shift.  The rest of the
+	 * cases are a variation of this algorithm...essentially raising the
+	 * number of bits to shift mc_addr[5] left, while still keeping the
+	 * 8-bit shifting total.
+	 *
+	 * For example, given the following Destination MAC Address and an
+	 * mta register count of 128 (thus a 4096-bit vector and 0xFFF mask),
+	 * we can see that the bit_shift for case 0 is 4.  These are the hash
+	 * values resulting from each mc_filter_type...
+	 * [0] [1] [2] [3] [4] [5]
+	 * 01  AA  00  12  34  56
+	 * LSB                 MSB
+	 *
+	 * case 0: hash_value = ((0x34 >> 4) | (0x56 << 4)) & 0xFFF = 0x563
+	 * case 1: hash_value = ((0x34 >> 3) | (0x56 << 5)) & 0xFFF = 0xAC6
+	 * case 2: hash_value = ((0x34 >> 2) | (0x56 << 6)) & 0xFFF = 0x163
+	 * case 3: hash_value = ((0x34 >> 0) | (0x56 << 8)) & 0xFFF = 0x634
+	 */
+	switch (hw->mac.mc_filter_type) {
+	default:
+	case 0:
+		break;
+	case 1:
+		bit_shift += 1;
+		break;
+	case 2:
+		bit_shift += 2;
+		break;
+	case 3:
+		bit_shift += 4;
+		break;
+	}
+
+	hash_value = hash_mask & (((mc_addr[4] >> (8 - bit_shift)) |
+	                          (((u16) mc_addr[5]) << bit_shift)));
+
+	return hash_value;
+}
+
+/**
+ *  e1000_clear_hw_cntrs_base_generic - Clear base hardware counters
+ *  @hw: pointer to the HW structure
+ *
+ *  Clears the base hardware counters by reading the counter registers.
+ **/
+void e1000_clear_hw_cntrs_base_generic(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_clear_hw_cntrs_base_generic");
+
+	E1000_READ_REG(hw, E1000_CRCERRS);
+	E1000_READ_REG(hw, E1000_SYMERRS);
+	E1000_READ_REG(hw, E1000_MPC);
+	E1000_READ_REG(hw, E1000_SCC);
+	E1000_READ_REG(hw, E1000_ECOL);
+	E1000_READ_REG(hw, E1000_MCC);
+	E1000_READ_REG(hw, E1000_LATECOL);
+	E1000_READ_REG(hw, E1000_COLC);
+	E1000_READ_REG(hw, E1000_DC);
+	E1000_READ_REG(hw, E1000_SEC);
+	E1000_READ_REG(hw, E1000_RLEC);
+	E1000_READ_REG(hw, E1000_XONRXC);
+	E1000_READ_REG(hw, E1000_XONTXC);
+	E1000_READ_REG(hw, E1000_XOFFRXC);
+	E1000_READ_REG(hw, E1000_XOFFTXC);
+	E1000_READ_REG(hw, E1000_FCRUC);
+	E1000_READ_REG(hw, E1000_GPRC);
+	E1000_READ_REG(hw, E1000_BPRC);
+	E1000_READ_REG(hw, E1000_MPRC);
+	E1000_READ_REG(hw, E1000_GPTC);
+	E1000_READ_REG(hw, E1000_GORCL);
+	E1000_READ_REG(hw, E1000_GORCH);
+	E1000_READ_REG(hw, E1000_GOTCL);
+	E1000_READ_REG(hw, E1000_GOTCH);
+	E1000_READ_REG(hw, E1000_RNBC);
+	E1000_READ_REG(hw, E1000_RUC);
+	E1000_READ_REG(hw, E1000_RFC);
+	E1000_READ_REG(hw, E1000_ROC);
+	E1000_READ_REG(hw, E1000_RJC);
+	E1000_READ_REG(hw, E1000_TORL);
+	E1000_READ_REG(hw, E1000_TORH);
+	E1000_READ_REG(hw, E1000_TOTL);
+	E1000_READ_REG(hw, E1000_TOTH);
+	E1000_READ_REG(hw, E1000_TPR);
+	E1000_READ_REG(hw, E1000_TPT);
+	E1000_READ_REG(hw, E1000_MPTC);
+	E1000_READ_REG(hw, E1000_BPTC);
+}
+
+/**
+ *  e1000_check_for_copper_link_generic - Check for link (Copper)
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks to see of the link status of the hardware has changed.  If a
+ *  change in link status has been detected, then we read the PHY registers
+ *  to get the current speed/duplex if link exists.
+ **/
+s32 e1000_check_for_copper_link_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	s32 ret_val;
+	bool link;
+
+	DEBUGFUNC("e1000_check_for_copper_link");
+
+	/*
+	 * We only want to go out to the PHY registers to see if Auto-Neg
+	 * has completed and/or if our link status has changed.  The
+	 * get_link_status flag is set upon receiving a Link Status
+	 * Change or Rx Sequence Error interrupt.
+	 */
+	if (!mac->get_link_status) {
+		ret_val = E1000_SUCCESS;
+		goto out;
+	}
+
+	/*
+	 * First we want to see if the MII Status Register reports
+	 * link.  If so, then we want to get the current speed/duplex
+	 * of the PHY.
+	 */
+	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	if (ret_val)
+		goto out;
+
+	if (!link)
+		goto out; /* No link detected */
+
+	mac->get_link_status = false;
+
+	/*
+	 * Check if there was DownShift, must be checked
+	 * immediately after link-up
+	 */
+	e1000_check_downshift_generic(hw);
+
+	/*
+	 * If we are forcing speed/duplex, then we simply return since
+	 * we have already determined whether we have link or not.
+	 */
+	if (!mac->autoneg) {
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	/*
+	 * Auto-Neg is enabled.  Auto Speed Detection takes care
+	 * of MAC speed/duplex configuration.  So we only need to
+	 * configure Collision Distance in the MAC.
+	 */
+	e1000_config_collision_dist_generic(hw);
+
+	/*
+	 * Configure Flow Control now that Auto-Neg has completed.
+	 * First, we need to restore the desired flow control
+	 * settings because we may have had to re-autoneg with a
+	 * different link partner.
+	 */
+	ret_val = e1000_config_fc_after_link_up_generic(hw);
+	if (ret_val)
+		DEBUGOUT("Error configuring flow control\n");
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_check_for_fiber_link_generic - Check for link (Fiber)
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks for link up on the hardware.  If link is not up and we have
+ *  a signal, then we need to force link up.
+ **/
+s32 e1000_check_for_fiber_link_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	u32 rxcw;
+	u32 ctrl;
+	u32 status;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_check_for_fiber_link_generic");
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+	status = E1000_READ_REG(hw, E1000_STATUS);
+	rxcw = E1000_READ_REG(hw, E1000_RXCW);
+
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
+	 * cannot auto-negotiate), the cable is plugged in (we have signal),
+	 * and our link partner is not trying to auto-negotiate with us (we
+	 * are receiving idles or data), we need to force link up. We also
+	 * need to give auto-negotiation time to complete, in case the cable
+	 * was just plugged in. The autoneg_failed flag does this.
+	 */
+	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
+	if ((ctrl & E1000_CTRL_SWDPIN1) && (!(status & E1000_STATUS_LU)) &&
+	    (!(rxcw & E1000_RXCW_C))) {
+		if (mac->autoneg_failed == 0) {
+			mac->autoneg_failed = 1;
+			goto out;
+		}
+		DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
+
+		/* Disable auto-negotiation in the TXCW register */
+		E1000_WRITE_REG(hw, E1000_TXCW, (mac->txcw & ~E1000_TXCW_ANE));
+
+		/* Force link-up and also force full-duplex. */
+		ctrl = E1000_READ_REG(hw, E1000_CTRL);
+		ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
+		E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+
+		/* Configure Flow Control after forcing link up. */
+		ret_val = e1000_config_fc_after_link_up_generic(hw);
+		if (ret_val) {
+			DEBUGOUT("Error configuring flow control\n");
+			goto out;
+		}
+	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
+		 * sets, re-enable auto-negotiation in the TXCW register
+		 * and disable forced link in the Device Control register
+		 * in an attempt to auto-negotiate with our link partner.
+		 */
+		DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		E1000_WRITE_REG(hw, E1000_TXCW, mac->txcw);
+		E1000_WRITE_REG(hw, E1000_CTRL, (ctrl & ~E1000_CTRL_SLU));
+
+		mac->serdes_has_link = true;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_check_for_serdes_link_generic - Check for link (Serdes)
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks for link up on the hardware.  If link is not up and we have
+ *  a signal, then we need to force link up.
+ **/
+s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	u32 rxcw;
+	u32 ctrl;
+	u32 status;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_check_for_serdes_link_generic");
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+	status = E1000_READ_REG(hw, E1000_STATUS);
+	rxcw = E1000_READ_REG(hw, E1000_RXCW);
+
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
+	 * cannot auto-negotiate), and our link partner is not trying to
+	 * auto-negotiate with us (we are receiving idles or data),
+	 * we need to force link up. We also need to give auto-negotiation
+	 * time to complete.
+	 */
+	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
+	if ((!(status & E1000_STATUS_LU)) && (!(rxcw & E1000_RXCW_C))) {
+		if (mac->autoneg_failed == 0) {
+			mac->autoneg_failed = 1;
+			goto out;
+		}
+		DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
+
+		/* Disable auto-negotiation in the TXCW register */
+		E1000_WRITE_REG(hw, E1000_TXCW, (mac->txcw & ~E1000_TXCW_ANE));
+
+		/* Force link-up and also force full-duplex. */
+		ctrl = E1000_READ_REG(hw, E1000_CTRL);
+		ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
+		E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+
+		/* Configure Flow Control after forcing link up. */
+		ret_val = e1000_config_fc_after_link_up_generic(hw);
+		if (ret_val) {
+			DEBUGOUT("Error configuring flow control\n");
+			goto out;
+		}
+	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
+		 * sets, re-enable auto-negotiation in the TXCW register
+		 * and disable forced link in the Device Control register
+		 * in an attempt to auto-negotiate with our link partner.
+		 */
+		DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		E1000_WRITE_REG(hw, E1000_TXCW, mac->txcw);
+		E1000_WRITE_REG(hw, E1000_CTRL, (ctrl & ~E1000_CTRL_SLU));
+
+		mac->serdes_has_link = true;
+	} else if (!(E1000_TXCW_ANE & E1000_READ_REG(hw, E1000_TXCW))) {
+		/*
+		 * If we force link for non-auto-negotiation switch, check
+		 * link status based on MAC synchronization for internal
+		 * serdes media type.
+		 */
+		/* SYNCH bit and IV bit are sticky. */
+		usec_delay(10);
+		rxcw = E1000_READ_REG(hw, E1000_RXCW);
+		if (rxcw & E1000_RXCW_SYNCH) {
+			if (!(rxcw & E1000_RXCW_IV)) {
+				mac->serdes_has_link = true;
+				DEBUGOUT("SERDES: Link up - forced.\n");
+			}
+		} else {
+			mac->serdes_has_link = false;
+			DEBUGOUT("SERDES: Link down - force failed.\n");
+		}
+	}
+
+	if (E1000_TXCW_ANE & E1000_READ_REG(hw, E1000_TXCW)) {
+		status = E1000_READ_REG(hw, E1000_STATUS);
+		if (status & E1000_STATUS_LU) {
+			/* SYNCH bit and IV bit are sticky, so reread rxcw. */
+			usec_delay(10);
+			rxcw = E1000_READ_REG(hw, E1000_RXCW);
+			if (rxcw & E1000_RXCW_SYNCH) {
+				if (!(rxcw & E1000_RXCW_IV)) {
+					mac->serdes_has_link = true;
+					DEBUGOUT("SERDES: Link up - autoneg "
+					   "completed sucessfully.\n");
+				} else {
+					mac->serdes_has_link = false;
+					DEBUGOUT("SERDES: Link down - invalid"
+					   "codewords detected in autoneg.\n");
+				}
+			} else {
+				mac->serdes_has_link = false;
+				DEBUGOUT("SERDES: Link down - no sync.\n");
+			}
+		} else {
+			mac->serdes_has_link = false;
+			DEBUGOUT("SERDES: Link down - autoneg failed\n");
+		}
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_setup_link_generic - Setup flow control and link settings
+ *  @hw: pointer to the HW structure
+ *
+ *  Determines which flow control settings to use, then configures flow
+ *  control.  Calls the appropriate media-specific link configuration
+ *  function.  Assuming the adapter has a valid link partner, a valid link
+ *  should be established.  Assumes the hardware has previously been reset
+ *  and the transmitter and receiver are not enabled.
+ **/
+s32 e1000_setup_link_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_setup_link_generic");
+
+	/*
+	 * In the case of the phy reset being blocked, we already have a link.
+	 * We do not need to set it up again.
+	 */
+	if (hw->phy.ops.check_reset_block)
+		if (hw->phy.ops.check_reset_block(hw))
+			goto out;
+
+	/*
+	 * If requested flow control is set to default, set flow control
+	 * based on the EEPROM flow control settings.
+	 */
+	if (hw->fc.requested_mode == e1000_fc_default) {
+		ret_val = e1000_set_default_fc_generic(hw);
+		if (ret_val)
+			goto out;
+	}
+
+	/*
+	 * Save off the requested flow control mode for use later.  Depending
+	 * on the link partner's capabilities, we may or may not use this mode.
+	 */
+	hw->fc.current_mode = hw->fc.requested_mode;
+
+	DEBUGOUT1("After fix-ups FlowControl is now = %x\n",
+		hw->fc.current_mode);
+
+	/* Call the necessary media_type subroutine to configure the link. */
+	ret_val = hw->mac.ops.setup_physical_interface(hw);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Initialize the flow control address, type, and PAUSE timer
+	 * registers to their default values.  This is done even if flow
+	 * control is disabled, because it does not hurt anything to
+	 * initialize these registers.
+	 */
+	DEBUGOUT("Initializing the Flow Control address, type and timer regs\n");
+	E1000_WRITE_REG(hw, E1000_FCT, FLOW_CONTROL_TYPE);
+	E1000_WRITE_REG(hw, E1000_FCAH, FLOW_CONTROL_ADDRESS_HIGH);
+	E1000_WRITE_REG(hw, E1000_FCAL, FLOW_CONTROL_ADDRESS_LOW);
+
+	E1000_WRITE_REG(hw, E1000_FCTTV, hw->fc.pause_time);
+
+	ret_val = e1000_set_fc_watermarks_generic(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_setup_fiber_serdes_link_generic - Setup link for fiber/serdes
+ *  @hw: pointer to the HW structure
+ *
+ *  Configures collision distance and flow control for fiber and serdes
+ *  links.  Upon successful setup, poll for link.
+ **/
+s32 e1000_setup_fiber_serdes_link_generic(struct e1000_hw *hw)
+{
+	u32 ctrl;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_setup_fiber_serdes_link_generic");
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+
+	/* Take the link out of reset */
+	ctrl &= ~E1000_CTRL_LRST;
+
+	e1000_config_collision_dist_generic(hw);
+
+	ret_val = e1000_commit_fc_settings_generic(hw);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Since auto-negotiation is enabled, take the link out of reset (the
+	 * link will be in reset, because we previously reset the chip). This
+	 * will restart auto-negotiation.  If auto-negotiation is successful
+	 * then the link-up status bit will be set and the flow control enable
+	 * bits (RFCE and TFCE) will be set according to their negotiated value.
+	 */
+	DEBUGOUT("Auto-negotiation enabled\n");
+
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+	E1000_WRITE_FLUSH(hw);
+	msec_delay(1);
+
+	/*
+	 * For these adapters, the SW definable pin 1 is set when the optics
+	 * detect a signal.  If we have a signal, then poll for a "Link-Up"
+	 * indication.
+	 */
+	if (hw->phy.media_type == e1000_media_type_internal_serdes ||
+	    (E1000_READ_REG(hw, E1000_CTRL) & E1000_CTRL_SWDPIN1)) {
+		ret_val = e1000_poll_fiber_serdes_link_generic(hw);
+	} else {
+		DEBUGOUT("No signal detected\n");
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_config_collision_dist_generic - Configure collision distance
+ *  @hw: pointer to the HW structure
+ *
+ *  Configures the collision distance to the default value and is used
+ *  during link setup. Currently no func pointer exists and all
+ *  implementations are handled in the generic version of this function.
+ **/
+void e1000_config_collision_dist_generic(struct e1000_hw *hw)
+{
+	u32 tctl;
+
+	DEBUGFUNC("e1000_config_collision_dist_generic");
+
+	tctl = E1000_READ_REG(hw, E1000_TCTL);
+
+	tctl &= ~E1000_TCTL_COLD;
+	tctl |= E1000_COLLISION_DISTANCE << E1000_COLD_SHIFT;
+
+	E1000_WRITE_REG(hw, E1000_TCTL, tctl);
+	E1000_WRITE_FLUSH(hw);
+}
+
+/**
+ *  e1000_poll_fiber_serdes_link_generic - Poll for link up
+ *  @hw: pointer to the HW structure
+ *
+ *  Polls for link up by reading the status register, if link fails to come
+ *  up with auto-negotiation, then the link is forced if a signal is detected.
+ **/
+static s32 e1000_poll_fiber_serdes_link_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	u32 i, status;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_poll_fiber_serdes_link_generic");
+
+	/*
+	 * If we have a signal (the cable is plugged in, or assumed true for
+	 * serdes media) then poll for a "Link-Up" indication in the Device
+	 * Status Register.  Time-out if a link isn't seen in 500 milliseconds
+	 * seconds (Auto-negotiation should complete in less than 500
+	 * milliseconds even if the other end is doing it in SW).
+	 */
+	for (i = 0; i < FIBER_LINK_UP_LIMIT; i++) {
+		msec_delay(10);
+		status = E1000_READ_REG(hw, E1000_STATUS);
+		if (status & E1000_STATUS_LU)
+			break;
+	}
+	if (i == FIBER_LINK_UP_LIMIT) {
+		DEBUGOUT("Never got a valid link from auto-neg!!!\n");
+		mac->autoneg_failed = 1;
+		/*
+		 * AutoNeg failed to achieve a link, so we'll call
+		 * mac->check_for_link. This routine will force the
+		 * link up if we detect a signal. This will allow us to
+		 * communicate with non-autonegotiating link partners.
+		 */
+		ret_val = hw->mac.ops.check_for_link(hw);
+		if (ret_val) {
+			DEBUGOUT("Error while checking for link\n");
+			goto out;
+		}
+		mac->autoneg_failed = 0;
+	} else {
+		mac->autoneg_failed = 0;
+		DEBUGOUT("Valid Link Found\n");
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_commit_fc_settings_generic - Configure flow control
+ *  @hw: pointer to the HW structure
+ *
+ *  Write the flow control settings to the Transmit Config Word Register (TXCW)
+ *  base on the flow control settings in e1000_mac_info.
+ **/
+static s32 e1000_commit_fc_settings_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	u32 txcw;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_commit_fc_settings_generic");
+
+	/*
+	 * Check for a software override of the flow control settings, and
+	 * setup the device accordingly.  If auto-negotiation is enabled, then
+	 * software will have to set the "PAUSE" bits to the correct value in
+	 * the Transmit Config Word Register (TXCW) and re-start auto-
+	 * negotiation.  However, if auto-negotiation is disabled, then
+	 * software will have to manually configure the two flow control enable
+	 * bits in the CTRL register.
+	 *
+	 * The possible values of the "fc" parameter are:
+	 *      0:  Flow control is completely disabled
+	 *      1:  Rx flow control is enabled (we can receive pause frames,
+	 *          but not send pause frames).
+	 *      2:  Tx flow control is enabled (we can send pause frames but we
+	 *          do not support receiving pause frames).
+	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
+	 */
+	switch (hw->fc.current_mode) {
+	case e1000_fc_none:
+		/* Flow control completely disabled by a software over-ride. */
+		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD);
+		break;
+	case e1000_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled and Tx Flow control is disabled
+		 * by a software over-ride. Since there really isn't a way to
+		 * advertise that we are capable of Rx Pause ONLY, we will
+		 * advertise that we support both symmetric and asymmetric RX
+		 * PAUSE.  Later, we will disable the adapter's ability to send
+		 * PAUSE frames.
+		 */
+		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
+		break;
+	case e1000_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is disabled,
+		 * by a software over-ride.
+		 */
+		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_ASM_DIR);
+		break;
+	case e1000_fc_full:
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
+		 * over-ride.
+		 */
+		txcw = (E1000_TXCW_ANE | E1000_TXCW_FD | E1000_TXCW_PAUSE_MASK);
+		break;
+	default:
+		DEBUGOUT("Flow control param set incorrectly\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+		break;
+	}
+
+	E1000_WRITE_REG(hw, E1000_TXCW, txcw);
+	mac->txcw = txcw;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_set_fc_watermarks_generic - Set flow control high/low watermarks
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets the flow control high/low threshold (watermark) registers.  If
+ *  flow control XON frame transmission is enabled, then set XON frame
+ *  transmission as well.
+ **/
+s32 e1000_set_fc_watermarks_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u32 fcrtl = 0, fcrth = 0;
+
+	DEBUGFUNC("e1000_set_fc_watermarks_generic");
+
+	/*
+	 * Set the flow control receive threshold registers.  Normally,
+	 * these registers will be set to a default threshold that may be
+	 * adjusted later by the driver's runtime code.  However, if the
+	 * ability to transmit pause frames is not enabled, then these
+	 * registers will be set to 0.
+	 */
+	if (hw->fc.current_mode & e1000_fc_tx_pause) {
+		/*
+		 * We need to set up the Receive Threshold high and low water
+		 * marks as well as (optionally) enabling the transmission of
+		 * XON frames.
+		 */
+		fcrtl = hw->fc.low_water;
+		if (hw->fc.send_xon)
+			fcrtl |= E1000_FCRTL_XONE;
+
+		fcrth = hw->fc.high_water;
+	}
+	E1000_WRITE_REG(hw, E1000_FCRTL, fcrtl);
+	E1000_WRITE_REG(hw, E1000_FCRTH, fcrth);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_set_default_fc_generic - Set flow control default values
+ *  @hw: pointer to the HW structure
+ *
+ *  Read the EEPROM for the default values for flow control and store the
+ *  values.
+ **/
+static s32 e1000_set_default_fc_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u16 nvm_data;
+
+	DEBUGFUNC("e1000_set_default_fc_generic");
+
+	/*
+	 * Read and store word 0x0F of the EEPROM. This word contains bits
+	 * that determine the hardware's default PAUSE (flow control) mode,
+	 * a bit that determines whether the HW defaults to enabling or
+	 * disabling auto-negotiation, and the direction of the
+	 * SW defined pins. If there is no SW over-ride of the flow
+	 * control setting, then the variable hw->fc will
+	 * be initialized based on a value in the EEPROM.
+	 */
+	ret_val = hw->nvm.ops.read(hw, NVM_INIT_CONTROL2_REG, 1, &nvm_data);
+
+	if (ret_val) {
+		DEBUGOUT("NVM Read Error\n");
+		goto out;
+	}
+
+	if ((nvm_data & NVM_WORD0F_PAUSE_MASK) == 0)
+		hw->fc.requested_mode = e1000_fc_none;
+	else if ((nvm_data & NVM_WORD0F_PAUSE_MASK) ==
+		 NVM_WORD0F_ASM_DIR)
+		hw->fc.requested_mode = e1000_fc_tx_pause;
+	else
+		hw->fc.requested_mode = e1000_fc_full;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_force_mac_fc_generic - Force the MAC's flow control settings
+ *  @hw: pointer to the HW structure
+ *
+ *  Force the MAC's flow control settings.  Sets the TFCE and RFCE bits in the
+ *  device control register to reflect the adapter settings.  TFCE and RFCE
+ *  need to be explicitly set by software when a copper PHY is used because
+ *  autonegotiation is managed by the PHY rather than the MAC.  Software must
+ *  also configure these bits when link is forced on a fiber connection.
+ **/
+s32 e1000_force_mac_fc_generic(struct e1000_hw *hw)
+{
+	u32 ctrl;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_force_mac_fc_generic");
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+
+	/*
+	 * Because we didn't get link via the internal auto-negotiation
+	 * mechanism (we either forced link or we got link via PHY
+	 * auto-neg), we have to manually enable/disable transmit an
+	 * receive flow control.
+	 *
+	 * The "Case" statement below enables/disable flow control
+	 * according to the "hw->fc.current_mode" parameter.
+	 *
+	 * The possible values of the "fc" parameter are:
+	 *      0:  Flow control is completely disabled
+	 *      1:  Rx flow control is enabled (we can receive pause
+	 *          frames but not send pause frames).
+	 *      2:  Tx flow control is enabled (we can send pause frames
+	 *          frames but we do not receive pause frames).
+	 *      3:  Both Rx and Tx flow control (symmetric) is enabled.
+	 *  other:  No other values should be possible at this point.
+	 */
+	DEBUGOUT1("hw->fc.current_mode = %u\n", hw->fc.current_mode);
+
+	switch (hw->fc.current_mode) {
+	case e1000_fc_none:
+		ctrl &= (~(E1000_CTRL_TFCE | E1000_CTRL_RFCE));
+		break;
+	case e1000_fc_rx_pause:
+		ctrl &= (~E1000_CTRL_TFCE);
+		ctrl |= E1000_CTRL_RFCE;
+		break;
+	case e1000_fc_tx_pause:
+		ctrl &= (~E1000_CTRL_RFCE);
+		ctrl |= E1000_CTRL_TFCE;
+		break;
+	case e1000_fc_full:
+		ctrl |= (E1000_CTRL_TFCE | E1000_CTRL_RFCE);
+		break;
+	default:
+		DEBUGOUT("Flow control param set incorrectly\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_config_fc_after_link_up_generic - Configures flow control after link
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks the status of auto-negotiation after link up to ensure that the
+ *  speed and duplex were not forced.  If the link needed to be forced, then
+ *  flow control needs to be forced also.  If auto-negotiation is enabled
+ *  and did not fail, then we configure flow control based on our link
+ *  partner.
+ **/
+s32 e1000_config_fc_after_link_up_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	s32 ret_val = E1000_SUCCESS;
+	u16 mii_status_reg, mii_nway_adv_reg, mii_nway_lp_ability_reg;
+	u16 speed, duplex;
+
+	DEBUGFUNC("e1000_config_fc_after_link_up_generic");
+
+	/*
+	 * Check for the case where we have fiber media and auto-neg failed
+	 * so we had to force link.  In this case, we need to force the
+	 * configuration of the MAC to match the "fc" parameter.
+	 */
+	if (mac->autoneg_failed) {
+		if (hw->phy.media_type == e1000_media_type_fiber ||
+		    hw->phy.media_type == e1000_media_type_internal_serdes)
+			ret_val = e1000_force_mac_fc_generic(hw);
+	} else {
+		if (hw->phy.media_type == e1000_media_type_copper)
+			ret_val = e1000_force_mac_fc_generic(hw);
+	}
+
+	if (ret_val) {
+		DEBUGOUT("Error forcing flow control settings\n");
+		goto out;
+	}
+
+	/*
+	 * Check for the case where we have copper media and auto-neg is
+	 * enabled.  In this case, we need to check and see if Auto-Neg
+	 * has completed, and if so, how the PHY and link partner has
+	 * flow control configured.
+	 */
+	if ((hw->phy.media_type == e1000_media_type_copper) && mac->autoneg) {
+		/*
+		 * Read the MII Status Register and check to see if AutoNeg
+		 * has completed.  We read this twice because this reg has
+		 * some "sticky" (latched) bits.
+		 */
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &mii_status_reg);
+		if (ret_val)
+			goto out;
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &mii_status_reg);
+		if (ret_val)
+			goto out;
+
+		if (!(mii_status_reg & MII_SR_AUTONEG_COMPLETE)) {
+			DEBUGOUT("Copper PHY and Auto Neg "
+			         "has not completed.\n");
+			goto out;
+		}
+
+		/*
+		 * The AutoNeg process has completed, so we now need to
+		 * read both the Auto Negotiation Advertisement
+		 * Register (Address 4) and the Auto_Negotiation Base
+		 * Page Ability Register (Address 5) to determine how
+		 * flow control was negotiated.
+		 */
+		ret_val = hw->phy.ops.read_reg(hw, PHY_AUTONEG_ADV,
+		                             &mii_nway_adv_reg);
+		if (ret_val)
+			goto out;
+		ret_val = hw->phy.ops.read_reg(hw, PHY_LP_ABILITY,
+		                             &mii_nway_lp_ability_reg);
+		if (ret_val)
+			goto out;
+
+		/*
+		 * Two bits in the Auto Negotiation Advertisement Register
+		 * (Address 4) and two bits in the Auto Negotiation Base
+		 * Page Ability Register (Address 5) determine flow control
+		 * for both the PHY and the link partner.  The following
+		 * table, taken out of the IEEE 802.3ab/D6.0 dated March 25,
+		 * 1999, describes these PAUSE resolution bits and how flow
+		 * control is determined based upon these settings.
+		 * NOTE:  DC = Don't Care
+		 *
+		 *   LOCAL DEVICE  |   LINK PARTNER
+		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | NIC Resolution
+		 *-------|---------|-------|---------|--------------------
+		 *   0   |    0    |  DC   |   DC    | e1000_fc_none
+		 *   0   |    1    |   0   |   DC    | e1000_fc_none
+		 *   0   |    1    |   1   |    0    | e1000_fc_none
+		 *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
+		 *   1   |    0    |   0   |   DC    | e1000_fc_none
+		 *   1   |   DC    |   1   |   DC    | e1000_fc_full
+		 *   1   |    1    |   0   |    0    | e1000_fc_none
+		 *   1   |    1    |   0   |    1    | e1000_fc_rx_pause
+		 *
+		 * Are both PAUSE bits set to 1?  If so, this implies
+		 * Symmetric Flow Control is enabled at both ends.  The
+		 * ASM_DIR bits are irrelevant per the spec.
+		 *
+		 * For Symmetric Flow Control:
+		 *
+		 *   LOCAL DEVICE  |   LINK PARTNER
+		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
+		 *-------|---------|-------|---------|--------------------
+		 *   1   |   DC    |   1   |   DC    | E1000_fc_full
+		 *
+		 */
+		if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
+		    (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE)) {
+			/*
+			 * Now we need to check if the user selected Rx ONLY
+			 * of pause frames.  In this case, we had to advertise
+			 * FULL flow control because we could not advertise RX
+			 * ONLY. Hence, we must now check to see if we need to
+			 * turn OFF  the TRANSMISSION of PAUSE frames.
+			 */
+			if (hw->fc.requested_mode == e1000_fc_full) {
+				hw->fc.current_mode = e1000_fc_full;
+				DEBUGOUT("Flow Control = FULL.\r\n");
+			} else {
+				hw->fc.current_mode = e1000_fc_rx_pause;
+				DEBUGOUT("Flow Control = "
+				         "RX PAUSE frames only.\r\n");
+			}
+		}
+		/*
+		 * For receiving PAUSE frames ONLY.
+		 *
+		 *   LOCAL DEVICE  |   LINK PARTNER
+		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
+		 *-------|---------|-------|---------|--------------------
+		 *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
+		 */
+		else if (!(mii_nway_adv_reg & NWAY_AR_PAUSE) &&
+		          (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
+		          (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
+		          (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
+			hw->fc.current_mode = e1000_fc_tx_pause;
+			DEBUGOUT("Flow Control = TX PAUSE frames only.\r\n");
+		}
+		/*
+		 * For transmitting PAUSE frames ONLY.
+		 *
+		 *   LOCAL DEVICE  |   LINK PARTNER
+		 * PAUSE | ASM_DIR | PAUSE | ASM_DIR | Result
+		 *-------|---------|-------|---------|--------------------
+		 *   1   |    1    |   0   |    1    | e1000_fc_rx_pause
+		 */
+		else if ((mii_nway_adv_reg & NWAY_AR_PAUSE) &&
+		         (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
+		         !(mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
+		         (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
+			hw->fc.current_mode = e1000_fc_rx_pause;
+			DEBUGOUT("Flow Control = RX PAUSE frames only.\r\n");
+		} else {
+			/*
+			 * Per the IEEE spec, at this point flow control
+			 * should be disabled.
+			 */
+			hw->fc.current_mode = e1000_fc_none;
+			DEBUGOUT("Flow Control = NONE.\r\n");
+		}
+
+		/*
+		 * Now we need to do one last check...  If we auto-
+		 * negotiated to HALF DUPLEX, flow control should not be
+		 * enabled per IEEE 802.3 spec.
+		 */
+		ret_val = mac->ops.get_link_up_info(hw, &speed, &duplex);
+		if (ret_val) {
+			DEBUGOUT("Error getting link speed and duplex\n");
+			goto out;
+		}
+
+		if (duplex == HALF_DUPLEX)
+			hw->fc.current_mode = e1000_fc_none;
+
+		/*
+		 * Now we call a subroutine to actually force the MAC
+		 * controller to use the correct flow control settings.
+		 */
+		ret_val = e1000_force_mac_fc_generic(hw);
+		if (ret_val) {
+			DEBUGOUT("Error forcing flow control settings\n");
+			goto out;
+		}
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_speed_and_duplex_copper_generic - Retrieve current speed/duplex
+ *  @hw: pointer to the HW structure
+ *  @speed: stores the current speed
+ *  @duplex: stores the current duplex
+ *
+ *  Read the status register for the current speed/duplex and store the current
+ *  speed and duplex for copper connections.
+ **/
+s32 e1000_get_speed_and_duplex_copper_generic(struct e1000_hw *hw, u16 *speed,
+                                              u16 *duplex)
+{
+	u32 status;
+
+	DEBUGFUNC("e1000_get_speed_and_duplex_copper_generic");
+
+	status = E1000_READ_REG(hw, E1000_STATUS);
+	if (status & E1000_STATUS_SPEED_1000) {
+		*speed = SPEED_1000;
+		DEBUGOUT("1000 Mbs, ");
+	} else if (status & E1000_STATUS_SPEED_100) {
+		*speed = SPEED_100;
+		DEBUGOUT("100 Mbs, ");
+	} else {
+		*speed = SPEED_10;
+		DEBUGOUT("10 Mbs, ");
+	}
+
+	if (status & E1000_STATUS_FD) {
+		*duplex = FULL_DUPLEX;
+		DEBUGOUT("Full Duplex\n");
+	} else {
+		*duplex = HALF_DUPLEX;
+		DEBUGOUT("Half Duplex\n");
+	}
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_get_speed_and_duplex_fiber_generic - Retrieve current speed/duplex
+ *  @hw: pointer to the HW structure
+ *  @speed: stores the current speed
+ *  @duplex: stores the current duplex
+ *
+ *  Sets the speed and duplex to gigabit full duplex (the only possible option)
+ *  for fiber/serdes links.
+ **/
+s32 e1000_get_speed_and_duplex_fiber_serdes_generic(struct e1000_hw *hw,
+                                                    u16 *speed, u16 *duplex)
+{
+	DEBUGFUNC("e1000_get_speed_and_duplex_fiber_serdes_generic");
+
+	*speed = SPEED_1000;
+	*duplex = FULL_DUPLEX;
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_get_hw_semaphore_generic - Acquire hardware semaphore
+ *  @hw: pointer to the HW structure
+ *
+ *  Acquire the HW semaphore to access the PHY or NVM
+ **/
+s32 e1000_get_hw_semaphore_generic(struct e1000_hw *hw)
+{
+	u32 swsm;
+	s32 ret_val = E1000_SUCCESS;
+	s32 timeout = hw->nvm.word_size + 1;
+	s32 i = 0;
+
+	DEBUGFUNC("e1000_get_hw_semaphore_generic");
+
+	/* Get the SW semaphore */
+	while (i < timeout) {
+		swsm = E1000_READ_REG(hw, E1000_SWSM);
+		if (!(swsm & E1000_SWSM_SMBI))
+			break;
+
+		usec_delay(50);
+		i++;
+	}
+
+	if (i == timeout) {
+		DEBUGOUT("Driver can't access device - SMBI bit is set.\n");
+		ret_val = -E1000_ERR_NVM;
+		goto out;
+	}
+
+	/* Get the FW semaphore. */
+	for (i = 0; i < timeout; i++) {
+		swsm = E1000_READ_REG(hw, E1000_SWSM);
+		E1000_WRITE_REG(hw, E1000_SWSM, swsm | E1000_SWSM_SWESMBI);
+
+		/* Semaphore acquired if bit latched */
+		if (E1000_READ_REG(hw, E1000_SWSM) & E1000_SWSM_SWESMBI)
+			break;
+
+		usec_delay(50);
+	}
+
+	if (i == timeout) {
+		/* Release semaphores */
+		e1000_put_hw_semaphore_generic(hw);
+		DEBUGOUT("Driver can't access the NVM\n");
+		ret_val = -E1000_ERR_NVM;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_put_hw_semaphore_generic - Release hardware semaphore
+ *  @hw: pointer to the HW structure
+ *
+ *  Release hardware semaphore used to access the PHY or NVM
+ **/
+void e1000_put_hw_semaphore_generic(struct e1000_hw *hw)
+{
+	u32 swsm;
+
+	DEBUGFUNC("e1000_put_hw_semaphore_generic");
+
+	swsm = E1000_READ_REG(hw, E1000_SWSM);
+
+	swsm &= ~(E1000_SWSM_SMBI | E1000_SWSM_SWESMBI);
+
+	E1000_WRITE_REG(hw, E1000_SWSM, swsm);
+}
+
+/**
+ *  e1000_get_auto_rd_done_generic - Check for auto read completion
+ *  @hw: pointer to the HW structure
+ *
+ *  Check EEPROM for Auto Read done bit.
+ **/
+s32 e1000_get_auto_rd_done_generic(struct e1000_hw *hw)
+{
+	s32 i = 0;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_get_auto_rd_done_generic");
+
+	while (i < AUTO_READ_DONE_TIMEOUT) {
+		if (E1000_READ_REG(hw, E1000_EECD) & E1000_EECD_AUTO_RD)
+			break;
+		msec_delay(1);
+		i++;
+	}
+
+	if (i == AUTO_READ_DONE_TIMEOUT) {
+		DEBUGOUT("Auto read by HW from NVM has not completed.\n");
+		ret_val = -E1000_ERR_RESET;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_valid_led_default_generic - Verify a valid default LED config
+ *  @hw: pointer to the HW structure
+ *  @data: pointer to the NVM (EEPROM)
+ *
+ *  Read the EEPROM for the current default LED configuration.  If the
+ *  LED configuration is not valid, set to a valid LED configuration.
+ **/
+s32 e1000_valid_led_default_generic(struct e1000_hw *hw, u16 *data)
+{
+	s32 ret_val;
+
+	DEBUGFUNC("e1000_valid_led_default_generic");
+
+	ret_val = hw->nvm.ops.read(hw, NVM_ID_LED_SETTINGS, 1, data);
+	if (ret_val) {
+		DEBUGOUT("NVM Read Error\n");
+		goto out;
+	}
+
+	if (*data == ID_LED_RESERVED_0000 || *data == ID_LED_RESERVED_FFFF)
+		*data = ID_LED_DEFAULT;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_id_led_init_generic -
+ *  @hw: pointer to the HW structure
+ *
+ **/
+s32 e1000_id_led_init_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	s32 ret_val;
+	const u32 ledctl_mask = 0x000000FF;
+	const u32 ledctl_on = E1000_LEDCTL_MODE_LED_ON;
+	const u32 ledctl_off = E1000_LEDCTL_MODE_LED_OFF;
+	u16 data, i, temp;
+	const u16 led_mask = 0x0F;
+
+	DEBUGFUNC("e1000_id_led_init_generic");
+
+	ret_val = hw->nvm.ops.valid_led_default(hw, &data);
+	if (ret_val)
+		goto out;
+
+	mac->ledctl_default = E1000_READ_REG(hw, E1000_LEDCTL);
+	mac->ledctl_mode1 = mac->ledctl_default;
+	mac->ledctl_mode2 = mac->ledctl_default;
+
+	for (i = 0; i < 4; i++) {
+		temp = (data >> (i << 2)) & led_mask;
+		switch (temp) {
+		case ID_LED_ON1_DEF2:
+		case ID_LED_ON1_ON2:
+		case ID_LED_ON1_OFF2:
+			mac->ledctl_mode1 &= ~(ledctl_mask << (i << 3));
+			mac->ledctl_mode1 |= ledctl_on << (i << 3);
+			break;
+		case ID_LED_OFF1_DEF2:
+		case ID_LED_OFF1_ON2:
+		case ID_LED_OFF1_OFF2:
+			mac->ledctl_mode1 &= ~(ledctl_mask << (i << 3));
+			mac->ledctl_mode1 |= ledctl_off << (i << 3);
+			break;
+		default:
+			/* Do nothing */
+			break;
+		}
+		switch (temp) {
+		case ID_LED_DEF1_ON2:
+		case ID_LED_ON1_ON2:
+		case ID_LED_OFF1_ON2:
+			mac->ledctl_mode2 &= ~(ledctl_mask << (i << 3));
+			mac->ledctl_mode2 |= ledctl_on << (i << 3);
+			break;
+		case ID_LED_DEF1_OFF2:
+		case ID_LED_ON1_OFF2:
+		case ID_LED_OFF1_OFF2:
+			mac->ledctl_mode2 &= ~(ledctl_mask << (i << 3));
+			mac->ledctl_mode2 |= ledctl_off << (i << 3);
+			break;
+		default:
+			/* Do nothing */
+			break;
+		}
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_setup_led_generic - Configures SW controllable LED
+ *  @hw: pointer to the HW structure
+ *
+ *  This prepares the SW controllable LED for use and saves the current state
+ *  of the LED so it can be later restored.
+ **/
+s32 e1000_setup_led_generic(struct e1000_hw *hw)
+{
+	u32 ledctl;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_setup_led_generic");
+
+	if (hw->mac.ops.setup_led != e1000_setup_led_generic) {
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	if (hw->phy.media_type == e1000_media_type_fiber) {
+		ledctl = E1000_READ_REG(hw, E1000_LEDCTL);
+		hw->mac.ledctl_default = ledctl;
+		/* Turn off LED0 */
+		ledctl &= ~(E1000_LEDCTL_LED0_IVRT |
+		            E1000_LEDCTL_LED0_BLINK |
+		            E1000_LEDCTL_LED0_MODE_MASK);
+		ledctl |= (E1000_LEDCTL_MODE_LED_OFF <<
+		           E1000_LEDCTL_LED0_MODE_SHIFT);
+		E1000_WRITE_REG(hw, E1000_LEDCTL, ledctl);
+	} else if (hw->phy.media_type == e1000_media_type_copper) {
+		E1000_WRITE_REG(hw, E1000_LEDCTL, hw->mac.ledctl_mode1);
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_cleanup_led_generic - Set LED config to default operation
+ *  @hw: pointer to the HW structure
+ *
+ *  Remove the current LED configuration and set the LED configuration
+ *  to the default value, saved from the EEPROM.
+ **/
+s32 e1000_cleanup_led_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_cleanup_led_generic");
+
+	if (hw->mac.ops.cleanup_led != e1000_cleanup_led_generic) {
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	E1000_WRITE_REG(hw, E1000_LEDCTL, hw->mac.ledctl_default);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_blink_led_generic - Blink LED
+ *  @hw: pointer to the HW structure
+ *
+ *  Blink the LEDs which are set to be on.
+ **/
+s32 e1000_blink_led_generic(struct e1000_hw *hw)
+{
+	u32 ledctl_blink = 0;
+	u32 i;
+
+	DEBUGFUNC("e1000_blink_led_generic");
+
+	if (hw->phy.media_type == e1000_media_type_fiber) {
+		/* always blink LED0 for PCI-E fiber */
+		ledctl_blink = E1000_LEDCTL_LED0_BLINK |
+		     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
+	} else {
+		/*
+		 * set the blink bit for each LED that's "on" (0x0E)
+		 * in ledctl_mode2
+		 */
+		ledctl_blink = hw->mac.ledctl_mode2;
+		for (i = 0; i < 4; i++)
+			if (((hw->mac.ledctl_mode2 >> (i * 8)) & 0xFF) ==
+			    E1000_LEDCTL_MODE_LED_ON)
+				ledctl_blink |= (E1000_LEDCTL_LED0_BLINK <<
+				                 (i * 8));
+	}
+
+	E1000_WRITE_REG(hw, E1000_LEDCTL, ledctl_blink);
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_led_on_generic - Turn LED on
+ *  @hw: pointer to the HW structure
+ *
+ *  Turn LED on.
+ **/
+s32 e1000_led_on_generic(struct e1000_hw *hw)
+{
+	u32 ctrl;
+
+	DEBUGFUNC("e1000_led_on_generic");
+
+	switch (hw->phy.media_type) {
+	case e1000_media_type_fiber:
+		ctrl = E1000_READ_REG(hw, E1000_CTRL);
+		ctrl &= ~E1000_CTRL_SWDPIN0;
+		ctrl |= E1000_CTRL_SWDPIO0;
+		E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+		break;
+	case e1000_media_type_copper:
+		E1000_WRITE_REG(hw, E1000_LEDCTL, hw->mac.ledctl_mode2);
+		break;
+	default:
+		break;
+	}
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_led_off_generic - Turn LED off
+ *  @hw: pointer to the HW structure
+ *
+ *  Turn LED off.
+ **/
+s32 e1000_led_off_generic(struct e1000_hw *hw)
+{
+	u32 ctrl;
+
+	DEBUGFUNC("e1000_led_off_generic");
+
+	switch (hw->phy.media_type) {
+	case e1000_media_type_fiber:
+		ctrl = E1000_READ_REG(hw, E1000_CTRL);
+		ctrl |= E1000_CTRL_SWDPIN0;
+		ctrl |= E1000_CTRL_SWDPIO0;
+		E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+		break;
+	case e1000_media_type_copper:
+		E1000_WRITE_REG(hw, E1000_LEDCTL, hw->mac.ledctl_mode1);
+		break;
+	default:
+		break;
+	}
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_set_pcie_no_snoop_generic - Set PCI-express capabilities
+ *  @hw: pointer to the HW structure
+ *  @no_snoop: bitmap of snoop events
+ *
+ *  Set the PCI-express register to snoop for events enabled in 'no_snoop'.
+ **/
+void e1000_set_pcie_no_snoop_generic(struct e1000_hw *hw, u32 no_snoop)
+{
+	u32 gcr;
+
+	DEBUGFUNC("e1000_set_pcie_no_snoop_generic");
+
+	if (hw->bus.type != e1000_bus_type_pci_express)
+		goto out;
+
+	if (no_snoop) {
+		gcr = E1000_READ_REG(hw, E1000_GCR);
+		gcr &= ~(PCIE_NO_SNOOP_ALL);
+		gcr |= no_snoop;
+		E1000_WRITE_REG(hw, E1000_GCR, gcr);
+	}
+out:
+	return;
+}
+
+/**
+ *  e1000_disable_pcie_master_generic - Disables PCI-express master access
+ *  @hw: pointer to the HW structure
+ *
+ *  Returns 0 (E1000_SUCCESS) if successful, else returns -10
+ *  (-E1000_ERR_MASTER_REQUESTS_PENDING) if master disable bit has not caused
+ *  the master requests to be disabled.
+ *
+ *  Disables PCI-Express master access and verifies there are no pending
+ *  requests.
+ **/
+s32 e1000_disable_pcie_master_generic(struct e1000_hw *hw)
+{
+	u32 ctrl;
+	s32 timeout = MASTER_DISABLE_TIMEOUT;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_disable_pcie_master_generic");
+
+	if (hw->bus.type != e1000_bus_type_pci_express)
+		goto out;
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+	ctrl |= E1000_CTRL_GIO_MASTER_DISABLE;
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+
+	while (timeout) {
+		if (!(E1000_READ_REG(hw, E1000_STATUS) &
+		      E1000_STATUS_GIO_MASTER_ENABLE))
+			break;
+		usec_delay(100);
+		timeout--;
+	}
+
+	if (!timeout) {
+		DEBUGOUT("Master requests are pending.\n");
+		ret_val = -E1000_ERR_MASTER_REQUESTS_PENDING;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_reset_adaptive_generic - Reset Adaptive Interframe Spacing
+ *  @hw: pointer to the HW structure
+ *
+ *  Reset the Adaptive Interframe Spacing throttle to default values.
+ **/
+void e1000_reset_adaptive_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+
+	DEBUGFUNC("e1000_reset_adaptive_generic");
+
+	if (!mac->adaptive_ifs) {
+		DEBUGOUT("Not in Adaptive IFS mode!\n");
+		goto out;
+	}
+
+	mac->current_ifs_val = 0;
+	mac->ifs_min_val = IFS_MIN;
+	mac->ifs_max_val = IFS_MAX;
+	mac->ifs_step_size = IFS_STEP;
+	mac->ifs_ratio = IFS_RATIO;
+
+	mac->in_ifs_mode = false;
+	E1000_WRITE_REG(hw, E1000_AIT, 0);
+out:
+	return;
+}
+
+/**
+ *  e1000_update_adaptive_generic - Update Adaptive Interframe Spacing
+ *  @hw: pointer to the HW structure
+ *
+ *  Update the Adaptive Interframe Spacing Throttle value based on the
+ *  time between transmitted packets and time between collisions.
+ **/
+void e1000_update_adaptive_generic(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+
+	DEBUGFUNC("e1000_update_adaptive_generic");
+
+	if (!mac->adaptive_ifs) {
+		DEBUGOUT("Not in Adaptive IFS mode!\n");
+		goto out;
+	}
+
+	if ((mac->collision_delta * mac->ifs_ratio) > mac->tx_packet_delta) {
+		if (mac->tx_packet_delta > MIN_NUM_XMITS) {
+			mac->in_ifs_mode = true;
+			if (mac->current_ifs_val < mac->ifs_max_val) {
+				if (!mac->current_ifs_val)
+					mac->current_ifs_val = mac->ifs_min_val;
+				else
+					mac->current_ifs_val +=
+						mac->ifs_step_size;
+				E1000_WRITE_REG(hw, E1000_AIT, mac->current_ifs_val);
+			}
+		}
+	} else {
+		if (mac->in_ifs_mode &&
+		    (mac->tx_packet_delta <= MIN_NUM_XMITS)) {
+			mac->current_ifs_val = 0;
+			mac->in_ifs_mode = false;
+			E1000_WRITE_REG(hw, E1000_AIT, 0);
+		}
+	}
+out:
+	return;
+}
+
+/**
+ *  e1000_validate_mdi_setting_generic - Verify MDI/MDIx settings
+ *  @hw: pointer to the HW structure
+ *
+ *  Verify that when not using auto-negotiation that MDI/MDIx is correctly
+ *  set, which is forced to MDI mode only.
+ **/
+s32 e1000_validate_mdi_setting_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_validate_mdi_setting_generic");
+
+	if (!hw->mac.autoneg && (hw->phy.mdix == 0 || hw->phy.mdix == 3)) {
+		DEBUGOUT("Invalid MDI setting detected\n");
+		hw->phy.mdix = 1;
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_write_8bit_ctrl_reg_generic - Write a 8bit CTRL register
+ *  @hw: pointer to the HW structure
+ *  @reg: 32bit register offset such as E1000_SCTL
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Writes an address/data control type register.  There are several of these
+ *  and they all have the format address << 8 | data and bit 31 is polled for
+ *  completion.
+ **/
+s32 e1000_write_8bit_ctrl_reg_generic(struct e1000_hw *hw, u32 reg,
+                                      u32 offset, u8 data)
+{
+	u32 i, regvalue = 0;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_write_8bit_ctrl_reg_generic");
+
+	/* Set up the address and data */
+	regvalue = ((u32)data) | (offset << E1000_GEN_CTL_ADDRESS_SHIFT);
+	E1000_WRITE_REG(hw, reg, regvalue);
+
+	/* Poll the ready bit to see if the MDI read completed */
+	for (i = 0; i < E1000_GEN_POLL_TIMEOUT; i++) {
+		usec_delay(5);
+		regvalue = E1000_READ_REG(hw, reg);
+		if (regvalue & E1000_GEN_CTL_READY)
+			break;
+	}
+	if (!(regvalue & E1000_GEN_CTL_READY)) {
+		DEBUGOUT1("Reg %08x did not indicate ready\n", reg);
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
diff -Npur igbvf-0.5.2/src/e1000_mac.h igbvf-0.5.2.orig/src/e1000_mac.h
--- igbvf-0.5.2/src/e1000_mac.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_mac.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,90 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_MAC_H_
+#define _E1000_MAC_H_
+
+/*
+ * Functions that should not be called directly from drivers but can be used
+ * by other files in this 'shared code'
+ */
+void e1000_init_mac_ops_generic(struct e1000_hw *hw);
+void e1000_null_mac_generic(struct e1000_hw *hw);
+s32  e1000_null_ops_generic(struct e1000_hw *hw);
+s32  e1000_null_link_info(struct e1000_hw *hw, u16 *s, u16 *d);
+bool e1000_null_mng_mode(struct e1000_hw *hw);
+void e1000_null_update_mc(struct e1000_hw *hw, u8 *h, u32 a, u32 b, u32 c);
+void e1000_null_write_vfta(struct e1000_hw *hw, u32 a, u32 b);
+void e1000_null_mta_set(struct e1000_hw *hw, u32 a);
+void e1000_null_rar_set(struct e1000_hw *hw, u8 *h, u32 a);
+s32  e1000_blink_led_generic(struct e1000_hw *hw);
+s32  e1000_check_for_copper_link_generic(struct e1000_hw *hw);
+s32  e1000_check_for_fiber_link_generic(struct e1000_hw *hw);
+s32  e1000_check_for_serdes_link_generic(struct e1000_hw *hw);
+s32  e1000_cleanup_led_generic(struct e1000_hw *hw);
+s32  e1000_config_fc_after_link_up_generic(struct e1000_hw *hw);
+s32  e1000_disable_pcie_master_generic(struct e1000_hw *hw);
+s32  e1000_force_mac_fc_generic(struct e1000_hw *hw);
+s32  e1000_get_auto_rd_done_generic(struct e1000_hw *hw);
+s32  e1000_get_bus_info_pcie_generic(struct e1000_hw *hw);
+void e1000_set_lan_id_single_port(struct e1000_hw *hw);
+void e1000_set_lan_id_multi_port_pci(struct e1000_hw *hw);
+void e1000_set_lan_id_multi_port_pcie(struct e1000_hw *hw);
+s32  e1000_get_hw_semaphore_generic(struct e1000_hw *hw);
+s32  e1000_get_speed_and_duplex_copper_generic(struct e1000_hw *hw, u16 *speed,
+                                               u16 *duplex);
+s32  e1000_get_speed_and_duplex_fiber_serdes_generic(struct e1000_hw *hw,
+                                                     u16 *speed, u16 *duplex);
+s32  e1000_id_led_init_generic(struct e1000_hw *hw);
+s32  e1000_led_on_generic(struct e1000_hw *hw);
+s32  e1000_led_off_generic(struct e1000_hw *hw);
+void e1000_update_mc_addr_list_generic(struct e1000_hw *hw,
+	                               u8 *mc_addr_list, u32 mc_addr_count,
+	                               u32 rar_used_count, u32 rar_count);
+s32  e1000_set_fc_watermarks_generic(struct e1000_hw *hw);
+s32  e1000_setup_fiber_serdes_link_generic(struct e1000_hw *hw);
+s32  e1000_setup_led_generic(struct e1000_hw *hw);
+s32  e1000_setup_link_generic(struct e1000_hw *hw);
+s32  e1000_write_8bit_ctrl_reg_generic(struct e1000_hw *hw, u32 reg,
+                                       u32 offset, u8 data);
+
+void e1000_clear_hw_cntrs_base_generic(struct e1000_hw *hw);
+void e1000_clear_vfta_generic(struct e1000_hw *hw);
+void e1000_config_collision_dist_generic(struct e1000_hw *hw);
+void e1000_init_rx_addrs_generic(struct e1000_hw *hw, u16 rar_count);
+void e1000_mta_set_generic(struct e1000_hw *hw, u32 hash_value);
+void e1000_pcix_mmrbc_workaround_generic(struct e1000_hw *hw);
+void e1000_put_hw_semaphore_generic(struct e1000_hw *hw);
+void e1000_rar_set_generic(struct e1000_hw *hw, u8 *addr, u32 index);
+s32  e1000_check_alt_mac_addr_generic(struct e1000_hw *hw);
+void e1000_reset_adaptive_generic(struct e1000_hw *hw);
+void e1000_set_pcie_no_snoop_generic(struct e1000_hw *hw, u32 no_snoop);
+void e1000_update_adaptive_generic(struct e1000_hw *hw);
+void e1000_write_vfta_generic(struct e1000_hw *hw, u32 offset, u32 value);
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_manage.c igbvf-0.5.2.orig/src/e1000_manage.c
--- igbvf-0.5.2/src/e1000_manage.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_manage.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,384 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000_hw.h"
+
+static u8 e1000_calculate_checksum(u8 *buffer, u32 length);
+
+/**
+ *  e1000_calculate_checksum - Calculate checksum for buffer
+ *  @buffer: pointer to EEPROM
+ *  @length: size of EEPROM to calculate a checksum for
+ *
+ *  Calculates the checksum for some buffer on a specified length.  The
+ *  checksum calculated is returned.
+ **/
+static u8 e1000_calculate_checksum(u8 *buffer, u32 length)
+{
+	u32 i;
+	u8  sum = 0;
+
+	DEBUGFUNC("e1000_calculate_checksum");
+
+	if (!buffer)
+		return 0;
+
+	for (i = 0; i < length; i++)
+		sum += buffer[i];
+
+	return (u8) (0 - sum);
+}
+
+/**
+ *  e1000_mng_enable_host_if_generic - Checks host interface is enabled
+ *  @hw: pointer to the HW structure
+ *
+ *  Returns E1000_success upon success, else E1000_ERR_HOST_INTERFACE_COMMAND
+ *
+ *  This function checks whether the HOST IF is enabled for command operation
+ *  and also checks whether the previous command is completed.  It busy waits
+ *  in case of previous command is not completed.
+ **/
+s32 e1000_mng_enable_host_if_generic(struct e1000_hw *hw)
+{
+	u32 hicr;
+	s32 ret_val = E1000_SUCCESS;
+	u8  i;
+
+	DEBUGFUNC("e1000_mng_enable_host_if_generic");
+
+	/* Check that the host interface is enabled. */
+	hicr = E1000_READ_REG(hw, E1000_HICR);
+	if ((hicr & E1000_HICR_EN) == 0) {
+		DEBUGOUT("E1000_HOST_EN bit disabled.\n");
+		ret_val = -E1000_ERR_HOST_INTERFACE_COMMAND;
+		goto out;
+	}
+	/* check the previous command is completed */
+	for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
+		hicr = E1000_READ_REG(hw, E1000_HICR);
+		if (!(hicr & E1000_HICR_C))
+			break;
+		msec_delay_irq(1);
+	}
+
+	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
+		DEBUGOUT("Previous command timeout failed .\n");
+		ret_val = -E1000_ERR_HOST_INTERFACE_COMMAND;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_check_mng_mode_generic - Generic check management mode
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the firmware semaphore register and returns true (>0) if
+ *  manageability is enabled, else false (0).
+ **/
+bool e1000_check_mng_mode_generic(struct e1000_hw *hw)
+{
+	u32 fwsm;
+
+	DEBUGFUNC("e1000_check_mng_mode_generic");
+
+	fwsm = E1000_READ_REG(hw, E1000_FWSM);
+
+	return (fwsm & E1000_FWSM_MODE_MASK) ==
+	        (E1000_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
+}
+
+/**
+ *  e1000_enable_tx_pkt_filtering_generic - Enable packet filtering on TX
+ *  @hw: pointer to the HW structure
+ *
+ *  Enables packet filtering on transmit packets if manageability is enabled
+ *  and host interface is enabled.
+ **/
+bool e1000_enable_tx_pkt_filtering_generic(struct e1000_hw *hw)
+{
+	struct e1000_host_mng_dhcp_cookie *hdr = &hw->mng_cookie;
+	u32 *buffer = (u32 *)&hw->mng_cookie;
+	u32 offset;
+	s32 ret_val, hdr_csum, csum;
+	u8 i, len;
+	bool tx_filter = true;
+
+	DEBUGFUNC("e1000_enable_tx_pkt_filtering_generic");
+
+	/* No manageability, no filtering */
+	if (!hw->mac.ops.check_mng_mode(hw)) {
+		tx_filter = false;
+		goto out;
+	}
+
+	/*
+	 * If we can't read from the host interface for whatever
+	 * reason, disable filtering.
+	 */
+	ret_val = hw->mac.ops.mng_enable_host_if(hw);
+	if (ret_val != E1000_SUCCESS) {
+		tx_filter = false;
+		goto out;
+	}
+
+	/* Read in the header.  Length and offset are in dwords. */
+	len    = E1000_MNG_DHCP_COOKIE_LENGTH >> 2;
+	offset = E1000_MNG_DHCP_COOKIE_OFFSET >> 2;
+	for (i = 0; i < len; i++) {
+		*(buffer + i) = E1000_READ_REG_ARRAY_DWORD(hw,
+		                                           E1000_HOST_IF,
+		                                           offset + i);
+	}
+	hdr_csum = hdr->checksum;
+	hdr->checksum = 0;
+	csum = e1000_calculate_checksum((u8 *)hdr,
+	                                E1000_MNG_DHCP_COOKIE_LENGTH);
+	/*
+	 * If either the checksums or signature don't match, then
+	 * the cookie area isn't considered valid, in which case we
+	 * take the safe route of assuming Tx filtering is enabled.
+	 */
+	if (hdr_csum != csum)
+		goto out;
+	if (hdr->signature != E1000_IAMT_SIGNATURE)
+		goto out;
+
+	/* Cookie area is valid, make the final check for filtering. */
+	if (!(hdr->status & E1000_MNG_DHCP_COOKIE_STATUS_PARSING))
+		tx_filter = false;
+
+out:
+	hw->mac.tx_pkt_filtering = tx_filter;
+	return tx_filter;
+}
+
+/**
+ *  e1000_mng_write_dhcp_info_generic - Writes DHCP info to host interface
+ *  @hw: pointer to the HW structure
+ *  @buffer: pointer to the host interface
+ *  @length: size of the buffer
+ *
+ *  Writes the DHCP information to the host interface.
+ **/
+s32 e1000_mng_write_dhcp_info_generic(struct e1000_hw *hw, u8 *buffer,
+                                      u16 length)
+{
+	struct e1000_host_mng_command_header hdr;
+	s32 ret_val;
+	u32 hicr;
+
+	DEBUGFUNC("e1000_mng_write_dhcp_info_generic");
+
+	hdr.command_id = E1000_MNG_DHCP_TX_PAYLOAD_CMD;
+	hdr.command_length = length;
+	hdr.reserved1 = 0;
+	hdr.reserved2 = 0;
+	hdr.checksum = 0;
+
+	/* Enable the host interface */
+	ret_val = hw->mac.ops.mng_enable_host_if(hw);
+	if (ret_val)
+		goto out;
+
+	/* Populate the host interface with the contents of "buffer". */
+	ret_val = hw->mac.ops.mng_host_if_write(hw, buffer, length,
+	                                  sizeof(hdr), &(hdr.checksum));
+	if (ret_val)
+		goto out;
+
+	/* Write the manageability command header */
+	ret_val = hw->mac.ops.mng_write_cmd_header(hw, &hdr);
+	if (ret_val)
+		goto out;
+
+	/* Tell the ARC a new command is pending. */
+	hicr = E1000_READ_REG(hw, E1000_HICR);
+	E1000_WRITE_REG(hw, E1000_HICR, hicr | E1000_HICR_C);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_mng_write_cmd_header_generic - Writes manageability command header
+ *  @hw: pointer to the HW structure
+ *  @hdr: pointer to the host interface command header
+ *
+ *  Writes the command header after does the checksum calculation.
+ **/
+s32 e1000_mng_write_cmd_header_generic(struct e1000_hw *hw,
+                                    struct e1000_host_mng_command_header *hdr)
+{
+	u16 i, length = sizeof(struct e1000_host_mng_command_header);
+
+	DEBUGFUNC("e1000_mng_write_cmd_header_generic");
+
+	/* Write the whole command header structure with new checksum. */
+
+	hdr->checksum = e1000_calculate_checksum((u8 *)hdr, length);
+
+	length >>= 2;
+	/* Write the relevant command block into the ram area. */
+	for (i = 0; i < length; i++) {
+		E1000_WRITE_REG_ARRAY_DWORD(hw, E1000_HOST_IF, i,
+		                            *((u32 *) hdr + i));
+		E1000_WRITE_FLUSH(hw);
+	}
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_mng_host_if_write_generic - Write to the manageability host interface
+ *  @hw: pointer to the HW structure
+ *  @buffer: pointer to the host interface buffer
+ *  @length: size of the buffer
+ *  @offset: location in the buffer to write to
+ *  @sum: sum of the data (not checksum)
+ *
+ *  This function writes the buffer content at the offset given on the host if.
+ *  It also does alignment considerations to do the writes in most efficient
+ *  way.  Also fills up the sum of the buffer in *buffer parameter.
+ **/
+s32 e1000_mng_host_if_write_generic(struct e1000_hw *hw, u8 *buffer,
+                                    u16 length, u16 offset, u8 *sum)
+{
+	u8 *tmp;
+	u8 *bufptr = buffer;
+	u32 data = 0;
+	s32 ret_val = E1000_SUCCESS;
+	u16 remaining, i, j, prev_bytes;
+
+	DEBUGFUNC("e1000_mng_host_if_write_generic");
+
+	/* sum = only sum of the data and it is not checksum */
+
+	if (length == 0 || offset + length > E1000_HI_MAX_MNG_DATA_LENGTH) {
+		ret_val = -E1000_ERR_PARAM;
+		goto out;
+	}
+
+	tmp = (u8 *)&data;
+	prev_bytes = offset & 0x3;
+	offset >>= 2;
+
+	if (prev_bytes) {
+		data = E1000_READ_REG_ARRAY_DWORD(hw, E1000_HOST_IF, offset);
+		for (j = prev_bytes; j < sizeof(u32); j++) {
+			*(tmp + j) = *bufptr++;
+			*sum += *(tmp + j);
+		}
+		E1000_WRITE_REG_ARRAY_DWORD(hw, E1000_HOST_IF, offset, data);
+		length -= j - prev_bytes;
+		offset++;
+	}
+
+	remaining = length & 0x3;
+	length -= remaining;
+
+	/* Calculate length in DWORDs */
+	length >>= 2;
+
+	/*
+	 * The device driver writes the relevant command block into the
+	 * ram area.
+	 */
+	for (i = 0; i < length; i++) {
+		for (j = 0; j < sizeof(u32); j++) {
+			*(tmp + j) = *bufptr++;
+			*sum += *(tmp + j);
+		}
+
+		E1000_WRITE_REG_ARRAY_DWORD(hw, E1000_HOST_IF, offset + i,
+		                            data);
+	}
+	if (remaining) {
+		for (j = 0; j < sizeof(u32); j++) {
+			if (j < remaining)
+				*(tmp + j) = *bufptr++;
+			else
+				*(tmp + j) = 0;
+
+			*sum += *(tmp + j);
+		}
+		E1000_WRITE_REG_ARRAY_DWORD(hw, E1000_HOST_IF, offset + i, data);
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_enable_mng_pass_thru - Enable processing of ARP's
+ *  @hw: pointer to the HW structure
+ *
+ *  Verifies the hardware needs to allow ARPs to be processed by the host.
+ **/
+bool e1000_enable_mng_pass_thru(struct e1000_hw *hw)
+{
+	u32 manc;
+	u32 fwsm, factps;
+	bool ret_val = false;
+
+	DEBUGFUNC("e1000_enable_mng_pass_thru");
+
+	if (!hw->mac.asf_firmware_present)
+		goto out;
+
+	manc = E1000_READ_REG(hw, E1000_MANC);
+
+	if (!(manc & E1000_MANC_RCV_TCO_EN) ||
+	    !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
+		goto out;
+
+	if (hw->mac.arc_subsystem_valid) {
+		fwsm = E1000_READ_REG(hw, E1000_FWSM);
+		factps = E1000_READ_REG(hw, E1000_FACTPS);
+
+		if (!(factps & E1000_FACTPS_MNGCG) &&
+		    ((fwsm & E1000_FWSM_MODE_MASK) ==
+		     (e1000_mng_mode_pt << E1000_FWSM_MODE_SHIFT))) {
+			ret_val = true;
+			goto out;
+		}
+	} else {
+		if ((manc & E1000_MANC_SMBUS_EN) &&
+		    !(manc & E1000_MANC_ASF_EN)) {
+			ret_val = true;
+			goto out;
+		}
+	}
+
+out:
+	return ret_val;
+}
+
diff -Npur igbvf-0.5.2/src/e1000_manage.h igbvf-0.5.2.orig/src/e1000_manage.h
--- igbvf-0.5.2/src/e1000_manage.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_manage.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,82 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_MANAGE_H_
+#define _E1000_MANAGE_H_
+
+bool e1000_check_mng_mode_generic(struct e1000_hw *hw);
+bool e1000_enable_tx_pkt_filtering_generic(struct e1000_hw *hw);
+s32  e1000_mng_enable_host_if_generic(struct e1000_hw *hw);
+s32  e1000_mng_host_if_write_generic(struct e1000_hw *hw, u8 *buffer,
+                                     u16 length, u16 offset, u8 *sum);
+s32  e1000_mng_write_cmd_header_generic(struct e1000_hw *hw,
+                                    struct e1000_host_mng_command_header *hdr);
+s32  e1000_mng_write_dhcp_info_generic(struct e1000_hw *hw,
+                                       u8 *buffer, u16 length);
+bool e1000_enable_mng_pass_thru(struct e1000_hw *hw);
+
+enum e1000_mng_mode {
+	e1000_mng_mode_none = 0,
+	e1000_mng_mode_asf,
+	e1000_mng_mode_pt,
+	e1000_mng_mode_ipmi,
+	e1000_mng_mode_host_if_only
+};
+
+#define E1000_FACTPS_MNGCG    0x20000000
+
+#define E1000_FWSM_MODE_MASK  0xE
+#define E1000_FWSM_MODE_SHIFT 1
+
+#define E1000_MNG_IAMT_MODE                  0x3
+#define E1000_MNG_DHCP_COOKIE_LENGTH         0x10
+#define E1000_MNG_DHCP_COOKIE_OFFSET         0x6F0
+#define E1000_MNG_DHCP_COMMAND_TIMEOUT       10
+#define E1000_MNG_DHCP_TX_PAYLOAD_CMD        64
+#define E1000_MNG_DHCP_COOKIE_STATUS_PARSING 0x1
+#define E1000_MNG_DHCP_COOKIE_STATUS_VLAN    0x2
+
+#define E1000_VFTA_ENTRY_SHIFT               5
+#define E1000_VFTA_ENTRY_MASK                0x7F
+#define E1000_VFTA_ENTRY_BIT_SHIFT_MASK      0x1F
+
+#define E1000_HI_MAX_BLOCK_BYTE_LENGTH       1792 /* Num of bytes in range */
+#define E1000_HI_MAX_BLOCK_DWORD_LENGTH      448 /* Num of dwords in range */
+#define E1000_HI_COMMAND_TIMEOUT             500 /* Process HI command limit */
+
+#define E1000_HICR_EN              0x01  /* Enable bit - RO */
+/* Driver sets this bit when done to put command in RAM */
+#define E1000_HICR_C               0x02
+#define E1000_HICR_SV              0x04  /* Status Validity */
+#define E1000_HICR_FW_RESET_ENABLE 0x40
+#define E1000_HICR_FW_RESET        0x80
+
+/* Intel(R) Active Management Technology signature */
+#define E1000_IAMT_SIGNATURE  0x544D4149
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_nvm.c igbvf-0.5.2.orig/src/e1000_nvm.c
--- igbvf-0.5.2/src/e1000_nvm.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_nvm.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,681 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000_hw.h"
+
+static void e1000_stop_nvm(struct e1000_hw *hw);
+static void e1000_reload_nvm_generic(struct e1000_hw *hw);
+
+/**
+ *  e1000_init_nvm_ops_generic - Initialize NVM function pointers
+ *  @hw: pointer to the HW structure
+ *
+ *  Setups up the function pointers to no-op functions
+ **/
+void e1000_init_nvm_ops_generic(struct e1000_hw *hw)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	DEBUGFUNC("e1000_init_nvm_ops_generic");
+
+	/* Initialize function pointers */
+	nvm->ops.acquire = e1000_null_ops_generic;
+	nvm->ops.read = e1000_null_read_nvm;
+	nvm->ops.release = e1000_null_nvm_generic;
+	nvm->ops.reload = e1000_reload_nvm_generic;
+	nvm->ops.update = e1000_null_ops_generic;
+	nvm->ops.valid_led_default = e1000_null_led_default;
+	nvm->ops.validate = e1000_null_ops_generic;
+	nvm->ops.write = e1000_null_write_nvm;
+}
+
+/**
+ *  e1000_null_nvm_read - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_read_nvm(struct e1000_hw *hw, u16 a, u16 b, u16 *c)
+{
+	DEBUGFUNC("e1000_null_read_nvm");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_null_nvm_generic - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_nvm_generic(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_null_nvm_generic");
+	return;
+}
+
+/**
+ *  e1000_null_led_default - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_led_default(struct e1000_hw *hw, u16 *data)
+{
+	DEBUGFUNC("e1000_null_led_default");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_null_write_nvm - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_write_nvm(struct e1000_hw *hw, u16 a, u16 b, u16 *c)
+{
+	DEBUGFUNC("e1000_null_write_nvm");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_raise_eec_clk - Raise EEPROM clock
+ *  @hw: pointer to the HW structure
+ *  @eecd: pointer to the EEPROM
+ *
+ *  Enable/Raise the EEPROM clock bit.
+ **/
+static void e1000_raise_eec_clk(struct e1000_hw *hw, u32 *eecd)
+{
+	*eecd = *eecd | E1000_EECD_SK;
+	E1000_WRITE_REG(hw, E1000_EECD, *eecd);
+	E1000_WRITE_FLUSH(hw);
+	usec_delay(hw->nvm.delay_usec);
+}
+
+/**
+ *  e1000_lower_eec_clk - Lower EEPROM clock
+ *  @hw: pointer to the HW structure
+ *  @eecd: pointer to the EEPROM
+ *
+ *  Clear/Lower the EEPROM clock bit.
+ **/
+static void e1000_lower_eec_clk(struct e1000_hw *hw, u32 *eecd)
+{
+	*eecd = *eecd & ~E1000_EECD_SK;
+	E1000_WRITE_REG(hw, E1000_EECD, *eecd);
+	E1000_WRITE_FLUSH(hw);
+	usec_delay(hw->nvm.delay_usec);
+}
+
+/**
+ *  e1000_shift_out_eec_bits - Shift data bits our to the EEPROM
+ *  @hw: pointer to the HW structure
+ *  @data: data to send to the EEPROM
+ *  @count: number of bits to shift out
+ *
+ *  We need to shift 'count' bits out to the EEPROM.  So, the value in the
+ *  "data" parameter will be shifted out to the EEPROM one bit at a time.
+ *  In order to do this, "data" must be broken down into bits.
+ **/
+static void e1000_shift_out_eec_bits(struct e1000_hw *hw, u16 data, u16 count)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 eecd = E1000_READ_REG(hw, E1000_EECD);
+	u32 mask;
+
+	DEBUGFUNC("e1000_shift_out_eec_bits");
+
+	mask = 0x01 << (count - 1);
+	if (nvm->type == e1000_nvm_eeprom_spi)
+		eecd |= E1000_EECD_DO;
+
+	do {
+		eecd &= ~E1000_EECD_DI;
+
+		if (data & mask)
+			eecd |= E1000_EECD_DI;
+
+		E1000_WRITE_REG(hw, E1000_EECD, eecd);
+		E1000_WRITE_FLUSH(hw);
+
+		usec_delay(nvm->delay_usec);
+
+		e1000_raise_eec_clk(hw, &eecd);
+		e1000_lower_eec_clk(hw, &eecd);
+
+		mask >>= 1;
+	} while (mask);
+
+	eecd &= ~E1000_EECD_DI;
+	E1000_WRITE_REG(hw, E1000_EECD, eecd);
+}
+
+/**
+ *  e1000_shift_in_eec_bits - Shift data bits in from the EEPROM
+ *  @hw: pointer to the HW structure
+ *  @count: number of bits to shift in
+ *
+ *  In order to read a register from the EEPROM, we need to shift 'count' bits
+ *  in from the EEPROM.  Bits are "shifted in" by raising the clock input to
+ *  the EEPROM (setting the SK bit), and then reading the value of the data out
+ *  "DO" bit.  During this "shifting in" process the data in "DI" bit should
+ *  always be clear.
+ **/
+static u16 e1000_shift_in_eec_bits(struct e1000_hw *hw, u16 count)
+{
+	u32 eecd;
+	u32 i;
+	u16 data;
+
+	DEBUGFUNC("e1000_shift_in_eec_bits");
+
+	eecd = E1000_READ_REG(hw, E1000_EECD);
+
+	eecd &= ~(E1000_EECD_DO | E1000_EECD_DI);
+	data = 0;
+
+	for (i = 0; i < count; i++) {
+		data <<= 1;
+		e1000_raise_eec_clk(hw, &eecd);
+
+		eecd = E1000_READ_REG(hw, E1000_EECD);
+
+		eecd &= ~E1000_EECD_DI;
+		if (eecd & E1000_EECD_DO)
+			data |= 1;
+
+		e1000_lower_eec_clk(hw, &eecd);
+	}
+
+	return data;
+}
+
+/**
+ *  e1000_poll_eerd_eewr_done - Poll for EEPROM read/write completion
+ *  @hw: pointer to the HW structure
+ *  @ee_reg: EEPROM flag for polling
+ *
+ *  Polls the EEPROM status bit for either read or write completion based
+ *  upon the value of 'ee_reg'.
+ **/
+s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg)
+{
+	u32 attempts = 100000;
+	u32 i, reg = 0;
+	s32 ret_val = -E1000_ERR_NVM;
+
+	DEBUGFUNC("e1000_poll_eerd_eewr_done");
+
+	for (i = 0; i < attempts; i++) {
+		if (ee_reg == E1000_NVM_POLL_READ)
+			reg = E1000_READ_REG(hw, E1000_EERD);
+		else
+			reg = E1000_READ_REG(hw, E1000_EEWR);
+
+		if (reg & E1000_NVM_RW_REG_DONE) {
+			ret_val = E1000_SUCCESS;
+			break;
+		}
+
+		usec_delay(5);
+	}
+
+	return ret_val;
+}
+
+/**
+ *  e1000_acquire_nvm_generic - Generic request for access to EEPROM
+ *  @hw: pointer to the HW structure
+ *
+ *  Set the EEPROM access request bit and wait for EEPROM access grant bit.
+ *  Return successful if access grant bit set, else clear the request for
+ *  EEPROM access and return -E1000_ERR_NVM (-1).
+ **/
+s32 e1000_acquire_nvm_generic(struct e1000_hw *hw)
+{
+	u32 eecd = E1000_READ_REG(hw, E1000_EECD);
+	s32 timeout = E1000_NVM_GRANT_ATTEMPTS;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_acquire_nvm_generic");
+
+	E1000_WRITE_REG(hw, E1000_EECD, eecd | E1000_EECD_REQ);
+	eecd = E1000_READ_REG(hw, E1000_EECD);
+
+	while (timeout) {
+		if (eecd & E1000_EECD_GNT)
+			break;
+		usec_delay(5);
+		eecd = E1000_READ_REG(hw, E1000_EECD);
+		timeout--;
+	}
+
+	if (!timeout) {
+		eecd &= ~E1000_EECD_REQ;
+		E1000_WRITE_REG(hw, E1000_EECD, eecd);
+		DEBUGOUT("Could not acquire NVM grant\n");
+		ret_val = -E1000_ERR_NVM;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  e1000_standby_nvm - Return EEPROM to standby state
+ *  @hw: pointer to the HW structure
+ *
+ *  Return the EEPROM to a standby state.
+ **/
+static void e1000_standby_nvm(struct e1000_hw *hw)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 eecd = E1000_READ_REG(hw, E1000_EECD);
+
+	DEBUGFUNC("e1000_standby_nvm");
+
+	if (nvm->type == e1000_nvm_eeprom_spi) {
+		/* Toggle CS to flush commands */
+		eecd |= E1000_EECD_CS;
+		E1000_WRITE_REG(hw, E1000_EECD, eecd);
+		E1000_WRITE_FLUSH(hw);
+		usec_delay(nvm->delay_usec);
+		eecd &= ~E1000_EECD_CS;
+		E1000_WRITE_REG(hw, E1000_EECD, eecd);
+		E1000_WRITE_FLUSH(hw);
+		usec_delay(nvm->delay_usec);
+	}
+}
+
+/**
+ *  e1000_stop_nvm - Terminate EEPROM command
+ *  @hw: pointer to the HW structure
+ *
+ *  Terminates the current command by inverting the EEPROM's chip select pin.
+ **/
+static void e1000_stop_nvm(struct e1000_hw *hw)
+{
+	u32 eecd;
+
+	DEBUGFUNC("e1000_stop_nvm");
+
+	eecd = E1000_READ_REG(hw, E1000_EECD);
+	if (hw->nvm.type == e1000_nvm_eeprom_spi) {
+		/* Pull CS high */
+		eecd |= E1000_EECD_CS;
+		e1000_lower_eec_clk(hw, &eecd);
+	}
+}
+
+/**
+ *  e1000_release_nvm_generic - Release exclusive access to EEPROM
+ *  @hw: pointer to the HW structure
+ *
+ *  Stop any current commands to the EEPROM and clear the EEPROM request bit.
+ **/
+void e1000_release_nvm_generic(struct e1000_hw *hw)
+{
+	u32 eecd;
+
+	DEBUGFUNC("e1000_release_nvm_generic");
+
+	e1000_stop_nvm(hw);
+
+	eecd = E1000_READ_REG(hw, E1000_EECD);
+	eecd &= ~E1000_EECD_REQ;
+	E1000_WRITE_REG(hw, E1000_EECD, eecd);
+}
+
+/**
+ *  e1000_ready_nvm_eeprom - Prepares EEPROM for read/write
+ *  @hw: pointer to the HW structure
+ *
+ *  Setups the EEPROM for reading and writing.
+ **/
+static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 eecd = E1000_READ_REG(hw, E1000_EECD);
+	s32 ret_val = E1000_SUCCESS;
+	u16 timeout = 0;
+	u8 spi_stat_reg;
+
+	DEBUGFUNC("e1000_ready_nvm_eeprom");
+
+	if (nvm->type == e1000_nvm_eeprom_spi) {
+		/* Clear SK and CS */
+		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
+		E1000_WRITE_REG(hw, E1000_EECD, eecd);
+		usec_delay(1);
+		timeout = NVM_MAX_RETRY_SPI;
+
+		/*
+		 * Read "Status Register" repeatedly until the LSB is cleared.
+		 * The EEPROM will signal that the command has been completed
+		 * by clearing bit 0 of the internal status register.  If it's
+		 * not cleared within 'timeout', then error out.
+		 */
+		while (timeout) {
+			e1000_shift_out_eec_bits(hw, NVM_RDSR_OPCODE_SPI,
+			                         hw->nvm.opcode_bits);
+			spi_stat_reg = (u8)e1000_shift_in_eec_bits(hw, 8);
+			if (!(spi_stat_reg & NVM_STATUS_RDY_SPI))
+				break;
+
+			usec_delay(5);
+			e1000_standby_nvm(hw);
+			timeout--;
+		}
+
+		if (!timeout) {
+			DEBUGOUT("SPI NVM Status error\n");
+			ret_val = -E1000_ERR_NVM;
+			goto out;
+		}
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_nvm_eerd - Reads EEPROM using EERD register
+ *  @hw: pointer to the HW structure
+ *  @offset: offset of word in the EEPROM to read
+ *  @words: number of words to read
+ *  @data: word read from the EEPROM
+ *
+ *  Reads a 16 bit word from the EEPROM using the EERD register.
+ **/
+s32 e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	u32 i, eerd = 0;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_read_nvm_eerd");
+
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * too many words for the offset, and not enough words.
+	 */
+	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
+	    (words == 0)) {
+		DEBUGOUT("nvm parameter(s) out of bounds\n");
+		ret_val = -E1000_ERR_NVM;
+		goto out;
+	}
+
+	for (i = 0; i < words; i++) {
+		eerd = ((offset+i) << E1000_NVM_RW_ADDR_SHIFT) +
+		       E1000_NVM_RW_REG_START;
+
+		E1000_WRITE_REG(hw, E1000_EERD, eerd);
+		ret_val = e1000_poll_eerd_eewr_done(hw, E1000_NVM_POLL_READ);
+		if (ret_val)
+			break;
+
+		data[i] = (E1000_READ_REG(hw, E1000_EERD) >>
+		           E1000_NVM_RW_REG_DATA);
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_write_nvm_spi - Write to EEPROM using SPI
+ *  @hw: pointer to the HW structure
+ *  @offset: offset within the EEPROM to be written to
+ *  @words: number of words to write
+ *  @data: 16 bit word(s) to be written to the EEPROM
+ *
+ *  Writes data to EEPROM at offset using SPI interface.
+ *
+ *  If e1000_update_nvm_checksum is not called after this function , the
+ *  EEPROM will most likely contain an invalid checksum.
+ **/
+s32 e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
+{
+	struct e1000_nvm_info *nvm = &hw->nvm;
+	s32 ret_val;
+	u16 widx = 0;
+
+	DEBUGFUNC("e1000_write_nvm_spi");
+
+	/*
+	 * A check for invalid values:  offset too large, too many words,
+	 * and not enough words.
+	 */
+	if ((offset >= nvm->word_size) || (words > (nvm->word_size - offset)) ||
+	    (words == 0)) {
+		DEBUGOUT("nvm parameter(s) out of bounds\n");
+		ret_val = -E1000_ERR_NVM;
+		goto out;
+	}
+
+	ret_val = nvm->ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	while (widx < words) {
+		u8 write_opcode = NVM_WRITE_OPCODE_SPI;
+
+		ret_val = e1000_ready_nvm_eeprom(hw);
+		if (ret_val)
+			goto release;
+
+		e1000_standby_nvm(hw);
+
+		/* Send the WRITE ENABLE command (8 bit opcode) */
+		e1000_shift_out_eec_bits(hw, NVM_WREN_OPCODE_SPI,
+		                         nvm->opcode_bits);
+
+		e1000_standby_nvm(hw);
+
+		/*
+		 * Some SPI eeproms use the 8th address bit embedded in the
+		 * opcode
+		 */
+		if ((nvm->address_bits == 8) && (offset >= 128))
+			write_opcode |= NVM_A8_OPCODE_SPI;
+
+		/* Send the Write command (8-bit opcode + addr) */
+		e1000_shift_out_eec_bits(hw, write_opcode, nvm->opcode_bits);
+		e1000_shift_out_eec_bits(hw, (u16)((offset + widx) * 2),
+		                         nvm->address_bits);
+
+		/* Loop to allow for up to whole page write of eeprom */
+		while (widx < words) {
+			u16 word_out = data[widx];
+			word_out = (word_out >> 8) | (word_out << 8);
+			e1000_shift_out_eec_bits(hw, word_out, 16);
+			widx++;
+
+			if ((((offset + widx) * 2) % nvm->page_size) == 0) {
+				e1000_standby_nvm(hw);
+				break;
+			}
+		}
+	}
+
+	msec_delay(10);
+release:
+	nvm->ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_pba_num_generic - Read device part number
+ *  @hw: pointer to the HW structure
+ *  @pba_num: pointer to device part number
+ *
+ *  Reads the product board assembly (PBA) number from the EEPROM and stores
+ *  the value in pba_num.
+ **/
+s32 e1000_read_pba_num_generic(struct e1000_hw *hw, u32 *pba_num)
+{
+	s32  ret_val;
+	u16 nvm_data;
+
+	DEBUGFUNC("e1000_read_pba_num_generic");
+
+	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
+	if (ret_val) {
+		DEBUGOUT("NVM Read Error\n");
+		goto out;
+	}
+	*pba_num = (u32)(nvm_data << 16);
+
+	ret_val = hw->nvm.ops.read(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
+	if (ret_val) {
+		DEBUGOUT("NVM Read Error\n");
+		goto out;
+	}
+	*pba_num |= nvm_data;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_mac_addr_generic - Read device MAC address
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the device MAC address from the EEPROM and stores the value.
+ *  Since devices with two ports use the same EEPROM, we increment the
+ *  last bit in the MAC address for the second port.
+ **/
+s32 e1000_read_mac_addr_generic(struct e1000_hw *hw)
+{
+	s32  ret_val = E1000_SUCCESS;
+	u16 offset, nvm_data, i;
+
+	DEBUGFUNC("e1000_read_mac_addr");
+
+	for (i = 0; i < ETH_ADDR_LEN; i += 2) {
+		offset = i >> 1;
+		ret_val = hw->nvm.ops.read(hw, offset, 1, &nvm_data);
+		if (ret_val) {
+			DEBUGOUT("NVM Read Error\n");
+			goto out;
+		}
+		hw->mac.perm_addr[i] = (u8)(nvm_data & 0xFF);
+		hw->mac.perm_addr[i+1] = (u8)(nvm_data >> 8);
+	}
+
+	/* Flip last bit of mac address if we're on second port */
+	if (hw->bus.func == E1000_FUNC_1)
+		hw->mac.perm_addr[5] ^= 1;
+
+	for (i = 0; i < ETH_ADDR_LEN; i++)
+		hw->mac.addr[i] = hw->mac.perm_addr[i];
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_validate_nvm_checksum_generic - Validate EEPROM checksum
+ *  @hw: pointer to the HW structure
+ *
+ *  Calculates the EEPROM checksum by reading/adding each word of the EEPROM
+ *  and then verifies that the sum of the EEPROM is equal to 0xBABA.
+ **/
+s32 e1000_validate_nvm_checksum_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u16 checksum = 0;
+	u16 i, nvm_data;
+
+	DEBUGFUNC("e1000_validate_nvm_checksum_generic");
+
+	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
+		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
+		if (ret_val) {
+			DEBUGOUT("NVM Read Error\n");
+			goto out;
+		}
+		checksum += nvm_data;
+	}
+
+	if (checksum != (u16) NVM_SUM) {
+		DEBUGOUT("NVM Checksum Invalid\n");
+		ret_val = -E1000_ERR_NVM;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_update_nvm_checksum_generic - Update EEPROM checksum
+ *  @hw: pointer to the HW structure
+ *
+ *  Updates the EEPROM checksum by reading/adding each word of the EEPROM
+ *  up to the checksum.  Then calculates the EEPROM checksum and writes the
+ *  value to the EEPROM.
+ **/
+s32 e1000_update_nvm_checksum_generic(struct e1000_hw *hw)
+{
+	s32  ret_val;
+	u16 checksum = 0;
+	u16 i, nvm_data;
+
+	DEBUGFUNC("e1000_update_nvm_checksum");
+
+	for (i = 0; i < NVM_CHECKSUM_REG; i++) {
+		ret_val = hw->nvm.ops.read(hw, i, 1, &nvm_data);
+		if (ret_val) {
+			DEBUGOUT("NVM Read Error while updating checksum.\n");
+			goto out;
+		}
+		checksum += nvm_data;
+	}
+	checksum = (u16) NVM_SUM - checksum;
+	ret_val = hw->nvm.ops.write(hw, NVM_CHECKSUM_REG, 1, &checksum);
+	if (ret_val)
+		DEBUGOUT("NVM Write Error while updating checksum.\n");
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_reload_nvm_generic - Reloads EEPROM
+ *  @hw: pointer to the HW structure
+ *
+ *  Reloads the EEPROM by setting the "Reinitialize from EEPROM" bit in the
+ *  extended control register.
+ **/
+static void e1000_reload_nvm_generic(struct e1000_hw *hw)
+{
+	u32 ctrl_ext;
+
+	DEBUGFUNC("e1000_reload_nvm_generic");
+
+	usec_delay(10);
+	ctrl_ext = E1000_READ_REG(hw, E1000_CTRL_EXT);
+	ctrl_ext |= E1000_CTRL_EXT_EE_RST;
+	E1000_WRITE_REG(hw, E1000_CTRL_EXT, ctrl_ext);
+	E1000_WRITE_FLUSH(hw);
+}
+
diff -Npur igbvf-0.5.2/src/e1000_nvm.h igbvf-0.5.2.orig/src/e1000_nvm.h
--- igbvf-0.5.2/src/e1000_nvm.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_nvm.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,55 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_NVM_H_
+#define _E1000_NVM_H_
+
+void e1000_init_nvm_ops_generic(struct e1000_hw *hw);
+s32  e1000_null_read_nvm(struct e1000_hw *hw, u16 a, u16 b, u16 *c);
+void e1000_null_nvm_generic(struct e1000_hw *hw);
+s32  e1000_null_led_default(struct e1000_hw *hw, u16 *data);
+s32  e1000_null_write_nvm(struct e1000_hw *hw, u16 a, u16 b, u16 *c);
+s32  e1000_acquire_nvm_generic(struct e1000_hw *hw);
+
+s32  e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
+s32  e1000_read_mac_addr_generic(struct e1000_hw *hw);
+s32  e1000_read_pba_num_generic(struct e1000_hw *hw, u32 *pba_num);
+s32  e1000_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words,
+                         u16 *data);
+s32  e1000_valid_led_default_generic(struct e1000_hw *hw, u16 *data);
+s32  e1000_validate_nvm_checksum_generic(struct e1000_hw *hw);
+s32  e1000_write_nvm_eewr(struct e1000_hw *hw, u16 offset,
+                          u16 words, u16 *data);
+s32  e1000_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words,
+                         u16 *data);
+s32  e1000_update_nvm_checksum_generic(struct e1000_hw *hw);
+void e1000_release_nvm_generic(struct e1000_hw *hw);
+
+#define E1000_STM_OPCODE  0xDB00
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_osdep.h igbvf-0.5.2.orig/src/e1000_osdep.h
--- igbvf-0.5.2/src/e1000_osdep.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_osdep.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,121 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+
+/* glue for the OS-dependent part of igbvf
+ * includes register access macros
+ */
+
+#ifndef _E1000_OSDEP_H_
+#define _E1000_OSDEP_H_
+
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/interrupt.h>
+#include <linux/if_ether.h>
+
+#include "kcompat.h"
+
+#define usec_delay(x) udelay(x)
+#ifndef msec_delay
+#define msec_delay(x)	do { if(in_interrupt()) { \
+				/* Don't sleep in interrupt context! */ \
+	                	BUG(); \
+			} else { \
+				msleep(x); \
+			} } while (0)
+
+/* Some workarounds require millisecond delays and are run during interrupt
+ * context.  Most notably, when establishing link, the phy may need tweaking
+ * but cannot process phy register reads/writes faster than millisecond
+ * intervals...and we establish link due to a "link status change" interrupt.
+ */
+#define msec_delay_irq(x) mdelay(x)
+#endif
+
+#define PCI_COMMAND_REGISTER   PCI_COMMAND
+#define CMD_MEM_WRT_INVALIDATE PCI_COMMAND_INVALIDATE
+#define ETH_ADDR_LEN           ETH_ALEN
+
+
+#if 0
+#define DEBUGOUT(S)
+#define DEBUGOUT1(S, A...)
+#else /* #if 0 */
+#define DEBUGOUT(S) printk(KERN_DEBUG S)
+#define DEBUGOUT1(S, A...) printk(KERN_DEBUG S, A)
+#endif
+
+#define DEBUGFUNC(F) DEBUGOUT(F "\n")
+#define DEBUGOUT2 DEBUGOUT1
+#define DEBUGOUT3 DEBUGOUT2
+#define DEBUGOUT7 DEBUGOUT3
+
+#define E1000_WRITE_REG(a, reg, value) ( \
+    writel((value), ((a)->hw_addr + reg)))
+
+#define E1000_READ_REG(a, reg) (readl((a)->hw_addr + reg))
+
+#define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
+    writel((value), ((a)->hw_addr + reg + ((offset) << 2))))
+
+#define E1000_READ_REG_ARRAY(a, reg, offset) ( \
+    readl((a)->hw_addr + reg + ((offset) << 2)))
+
+#define E1000_READ_REG_ARRAY_DWORD E1000_READ_REG_ARRAY
+#define E1000_WRITE_REG_ARRAY_DWORD E1000_WRITE_REG_ARRAY
+
+#define E1000_WRITE_REG_ARRAY_WORD(a, reg, offset, value) ( \
+    writew((value), ((a)->hw_addr + reg + ((offset) << 1))))
+
+#define E1000_READ_REG_ARRAY_WORD(a, reg, offset) ( \
+    readw((a)->hw_addr + reg + ((offset) << 1)))
+
+#define E1000_WRITE_REG_ARRAY_BYTE(a, reg, offset, value) ( \
+    writeb((value), ((a)->hw_addr + reg + (offset))))
+
+#define E1000_READ_REG_ARRAY_BYTE(a, reg, offset) ( \
+    readb((a)->hw_addr + reg + (offset)))
+
+#define E1000_WRITE_REG_IO(a, reg, offset) do { \
+    outl(reg, ((a)->io_base));                  \
+    outl(offset, ((a)->io_base + 4));      } while(0)
+
+#define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, E1000_STATUS)
+
+#define E1000_WRITE_FLASH_REG(a, reg, value) ( \
+    writel((value), ((a)->flash_address + reg)))
+
+#define E1000_WRITE_FLASH_REG16(a, reg, value) ( \
+    writew((value), ((a)->flash_address + reg)))
+
+#define E1000_READ_FLASH_REG(a, reg) (readl((a)->flash_address + reg))
+
+#define E1000_READ_FLASH_REG16(a, reg) (readw((a)->flash_address + reg))
+
+#endif /* _E1000_OSDEP_H_ */
diff -Npur igbvf-0.5.2/src/e1000_phy.c igbvf-0.5.2.orig/src/e1000_phy.c
--- igbvf-0.5.2/src/e1000_phy.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_phy.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,2170 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include "e1000_hw.h"
+
+static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw);
+/* Cable length tables */
+static const u16 e1000_m88_cable_length_table[] =
+	{ 0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+#define M88E1000_CABLE_LENGTH_TABLE_SIZE \
+                (sizeof(e1000_m88_cable_length_table) / \
+                 sizeof(e1000_m88_cable_length_table[0]))
+
+static const u16 e1000_igp_2_cable_length_table[] =
+    { 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
+      0, 0, 0, 3, 6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41,
+      6, 10, 14, 18, 22, 26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61,
+      21, 26, 31, 35, 40, 44, 49, 53, 57, 61, 65, 68, 72, 75, 79, 82,
+      40, 45, 51, 56, 61, 66, 70, 75, 79, 83, 87, 91, 94, 98, 101, 104,
+      60, 66, 72, 77, 82, 87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121,
+      83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
+      104, 109, 114, 118, 121, 124};
+#define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
+                (sizeof(e1000_igp_2_cable_length_table) / \
+                 sizeof(e1000_igp_2_cable_length_table[0]))
+
+/**
+ *  e1000_init_phy_ops_generic - Initialize PHY function pointers
+ *  @hw: pointer to the HW structure
+ *
+ *  Setups up the function pointers to no-op functions
+ **/
+void e1000_init_phy_ops_generic(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	DEBUGFUNC("e1000_init_phy_ops_generic");
+
+	/* Initialize function pointers */
+	phy->ops.acquire = e1000_null_ops_generic;
+	phy->ops.check_polarity = e1000_null_ops_generic;
+	phy->ops.check_reset_block = e1000_null_ops_generic;
+	phy->ops.commit = e1000_null_ops_generic;
+	phy->ops.force_speed_duplex = e1000_null_ops_generic;
+	phy->ops.get_cfg_done = e1000_null_ops_generic;
+	phy->ops.get_cable_length = e1000_null_ops_generic;
+	phy->ops.get_info = e1000_null_ops_generic;
+	phy->ops.read_reg = e1000_null_read_reg;
+	phy->ops.release = e1000_null_phy_generic;
+	phy->ops.reset = e1000_null_ops_generic;
+	phy->ops.set_d0_lplu_state = e1000_null_lplu_state;
+	phy->ops.set_d3_lplu_state = e1000_null_lplu_state;
+	phy->ops.write_reg = e1000_null_write_reg;
+	phy->ops.power_up = e1000_null_phy_generic;
+	phy->ops.power_down = e1000_null_phy_generic;
+}
+
+/**
+ *  e1000_null_read_reg - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_read_reg(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	DEBUGFUNC("e1000_null_read_reg");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_null_phy_generic - No-op function, return void
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_null_phy_generic(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_null_phy_generic");
+	return;
+}
+
+/**
+ *  e1000_null_lplu_state - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_lplu_state(struct e1000_hw *hw, bool active)
+{
+	DEBUGFUNC("e1000_null_lplu_state");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_null_write_reg - No-op function, return 0
+ *  @hw: pointer to the HW structure
+ **/
+s32 e1000_null_write_reg(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	DEBUGFUNC("e1000_null_write_reg");
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_check_reset_block_generic - Check if PHY reset is blocked
+ *  @hw: pointer to the HW structure
+ *
+ *  Read the PHY management control register and check whether a PHY reset
+ *  is blocked.  If a reset is not blocked return E1000_SUCCESS, otherwise
+ *  return E1000_BLK_PHY_RESET (12).
+ **/
+s32 e1000_check_reset_block_generic(struct e1000_hw *hw)
+{
+	u32 manc;
+
+	DEBUGFUNC("e1000_check_reset_block");
+
+	manc = E1000_READ_REG(hw, E1000_MANC);
+
+	return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ?
+	       E1000_BLK_PHY_RESET : E1000_SUCCESS;
+}
+
+/**
+ *  e1000_get_phy_id - Retrieve the PHY ID and revision
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the PHY registers and stores the PHY ID and possibly the PHY
+ *  revision in the hardware structure.
+ **/
+s32 e1000_get_phy_id(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val = E1000_SUCCESS;
+	u16 phy_id;
+
+	DEBUGFUNC("e1000_get_phy_id");
+
+	if (!(phy->ops.read_reg))
+		goto out;
+
+	ret_val = phy->ops.read_reg(hw, PHY_ID1, &phy_id);
+	if (ret_val)
+		goto out;
+
+	phy->id = (u32)(phy_id << 16);
+	usec_delay(20);
+	ret_val = phy->ops.read_reg(hw, PHY_ID2, &phy_id);
+	if (ret_val)
+		goto out;
+
+	phy->id |= (u32)(phy_id & PHY_REVISION_MASK);
+	phy->revision = (u32)(phy_id & ~PHY_REVISION_MASK);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_reset_dsp_generic - Reset PHY DSP
+ *  @hw: pointer to the HW structure
+ *
+ *  Reset the digital signal processor.
+ **/
+s32 e1000_phy_reset_dsp_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_phy_reset_dsp_generic");
+
+	if (!(hw->phy.ops.write_reg))
+		goto out;
+
+	ret_val = hw->phy.ops.write_reg(hw, M88E1000_PHY_GEN_CONTROL, 0xC1);
+	if (ret_val)
+		goto out;
+
+	ret_val = hw->phy.ops.write_reg(hw, M88E1000_PHY_GEN_CONTROL, 0);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_phy_reg_mdic - Read MDI control register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Reads the MDI control register in the PHY at offset and stores the
+ *  information read to data.
+ **/
+s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	u32 i, mdic = 0;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_read_phy_reg_mdic");
+
+	/*
+	 * Set up Op-code, Phy Address, and register offset in the MDI
+	 * Control register.  The MAC will take care of interfacing with the
+	 * PHY to retrieve the desired data.
+	 */
+	mdic = ((offset << E1000_MDIC_REG_SHIFT) |
+	        (phy->addr << E1000_MDIC_PHY_SHIFT) |
+	        (E1000_MDIC_OP_READ));
+
+	E1000_WRITE_REG(hw, E1000_MDIC, mdic);
+
+	/*
+	 * Poll the ready bit to see if the MDI read completed
+	 * Increasing the time out as testing showed failures with
+	 * the lower time out
+	 */
+	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
+		usec_delay(50);
+		mdic = E1000_READ_REG(hw, E1000_MDIC);
+		if (mdic & E1000_MDIC_READY)
+			break;
+	}
+	if (!(mdic & E1000_MDIC_READY)) {
+		DEBUGOUT("MDI Read did not complete\n");
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+	if (mdic & E1000_MDIC_ERROR) {
+		DEBUGOUT("MDI Error\n");
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+	*data = (u16) mdic;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_write_phy_reg_mdic - Write MDI control register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write to register at offset
+ *
+ *  Writes data to MDI control register in the PHY at offset.
+ **/
+s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	u32 i, mdic = 0;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_write_phy_reg_mdic");
+
+	/*
+	 * Set up Op-code, Phy Address, and register offset in the MDI
+	 * Control register.  The MAC will take care of interfacing with the
+	 * PHY to retrieve the desired data.
+	 */
+	mdic = (((u32)data) |
+	        (offset << E1000_MDIC_REG_SHIFT) |
+	        (phy->addr << E1000_MDIC_PHY_SHIFT) |
+	        (E1000_MDIC_OP_WRITE));
+
+	E1000_WRITE_REG(hw, E1000_MDIC, mdic);
+
+	/*
+	 * Poll the ready bit to see if the MDI read completed
+	 * Increasing the time out as testing showed failures with
+	 * the lower time out
+	 */
+	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
+		usec_delay(50);
+		mdic = E1000_READ_REG(hw, E1000_MDIC);
+		if (mdic & E1000_MDIC_READY)
+			break;
+	}
+	if (!(mdic & E1000_MDIC_READY)) {
+		DEBUGOUT("MDI Write did not complete\n");
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+	if (mdic & E1000_MDIC_ERROR) {
+		DEBUGOUT("MDI Error\n");
+		ret_val = -E1000_ERR_PHY;
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_phy_reg_m88 - Read m88 PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphores before exiting.
+ **/
+s32 e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_read_phy_reg_m88");
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	ret_val = e1000_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                  data);
+
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_write_phy_reg_m88 - Write m88 PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary, then writes the data to PHY register
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_write_phy_reg_m88");
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	ret_val = e1000_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                   data);
+
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_phy_reg_igp - Read igp PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphores before exiting.
+ **/
+s32 e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_read_phy_reg_igp");
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		ret_val = e1000_write_phy_reg_mdic(hw,
+		                                   IGP01E1000_PHY_PAGE_SELECT,
+		                                   (u16)offset);
+		if (ret_val) {
+			hw->phy.ops.release(hw);
+			goto out;
+		}
+	}
+
+	ret_val = e1000_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                  data);
+
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_write_phy_reg_igp - Write igp PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary, then writes the data to PHY register
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_write_phy_reg_igp");
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	if (offset > MAX_PHY_MULTI_PAGE_REG) {
+		ret_val = e1000_write_phy_reg_mdic(hw,
+		                                   IGP01E1000_PHY_PAGE_SELECT,
+		                                   (u16)offset);
+		if (ret_val) {
+			hw->phy.ops.release(hw);
+			goto out;
+		}
+	}
+
+	ret_val = e1000_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
+	                                   data);
+
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_read_kmrn_reg_generic - Read kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary.  Then reads the PHY register at offset
+ *  using the kumeran interface.  The information retrieved is stored in data.
+ *  Release any acquired semaphores before exiting.
+ **/
+s32 e1000_read_kmrn_reg_generic(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	u32 kmrnctrlsta;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_read_kmrn_reg_generic");
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
+	               E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
+	E1000_WRITE_REG(hw, E1000_KMRNCTRLSTA, kmrnctrlsta);
+
+	usec_delay(2);
+
+	kmrnctrlsta = E1000_READ_REG(hw, E1000_KMRNCTRLSTA);
+	*data = (u16)kmrnctrlsta;
+
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_write_kmrn_reg_generic - Write kumeran register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary.  Then write the data to PHY register
+ *  at the offset using the kumeran interface.  Release any acquired semaphores
+ *  before exiting.
+ **/
+s32 e1000_write_kmrn_reg_generic(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	u32 kmrnctrlsta;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_write_kmrn_reg_generic");
+
+	if (!(hw->phy.ops.acquire))
+		goto out;
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
+	               E1000_KMRNCTRLSTA_OFFSET) | data;
+	E1000_WRITE_REG(hw, E1000_KMRNCTRLSTA, kmrnctrlsta);
+
+	usec_delay(2);
+	hw->phy.ops.release(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_copper_link_setup_m88 - Setup m88 PHY's for copper link
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets up MDI/MDI-X and polarity for m88 PHY's.  If necessary, transmit clock
+ *  and downshift values are set also.
+ **/
+s32 e1000_copper_link_setup_m88(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data;
+
+	DEBUGFUNC("e1000_copper_link_setup_m88");
+
+	if (phy->reset_disable) {
+		ret_val = E1000_SUCCESS;
+		goto out;
+	}
+
+	/* Enable CRS on TX. This must be set for half-duplex operation. */
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
+
+	/*
+	 * Options:
+	 *   MDI/MDI-X = 0 (default)
+	 *   0 - Auto for all speeds
+	 *   1 - MDI mode
+	 *   2 - MDI-X mode
+	 *   3 - Auto for 1000Base-T only (MDI-X for 10/100Base-T modes)
+	 */
+	phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
+
+	switch (phy->mdix) {
+	case 1:
+		phy_data |= M88E1000_PSCR_MDI_MANUAL_MODE;
+		break;
+	case 2:
+		phy_data |= M88E1000_PSCR_MDIX_MANUAL_MODE;
+		break;
+	case 3:
+		phy_data |= M88E1000_PSCR_AUTO_X_1000T;
+		break;
+	case 0:
+	default:
+		phy_data |= M88E1000_PSCR_AUTO_X_MODE;
+		break;
+	}
+
+	/*
+	 * Options:
+	 *   disable_polarity_correction = 0 (default)
+	 *       Automatic Correction for Reversed Cable Polarity
+	 *   0 - Disabled
+	 *   1 - Enabled
+	 */
+	phy_data &= ~M88E1000_PSCR_POLARITY_REVERSAL;
+	if (phy->disable_polarity_correction == 1)
+		phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
+
+	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
+	if (ret_val)
+		goto out;
+
+	if (phy->revision < E1000_REVISION_4) {
+		/*
+		 * Force TX_CLK in the Extended PHY Specific Control Register
+		 * to 25MHz clock.
+		 */
+		ret_val = phy->ops.read_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+		                             &phy_data);
+		if (ret_val)
+			goto out;
+
+		phy_data |= M88E1000_EPSCR_TX_CLK_25;
+
+		if ((phy->revision == E1000_REVISION_2) &&
+		    (phy->id == M88E1111_I_PHY_ID)) {
+			/* 82573L PHY - set the downshift counter to 5x. */
+			phy_data &= ~M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK;
+			phy_data |= M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X;
+		} else {
+			/* Configure Master and Slave downshift values */
+			phy_data &= ~(M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK |
+			             M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK);
+			phy_data |= (M88E1000_EPSCR_MASTER_DOWNSHIFT_1X |
+			             M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X);
+		}
+		ret_val = phy->ops.write_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+		                             phy_data);
+		if (ret_val)
+			goto out;
+	}
+
+	/* Commit the changes. */
+	ret_val = phy->ops.commit(hw);
+	if (ret_val) {
+		DEBUGOUT("Error committing the PHY changes\n");
+		goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_copper_link_setup_igp - Setup igp PHY's for copper link
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets up LPLU, MDI/MDI-X, polarity, Smartspeed and Master/Slave config for
+ *  igp PHY's.
+ **/
+s32 e1000_copper_link_setup_igp(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+
+	DEBUGFUNC("e1000_copper_link_setup_igp");
+
+	if (phy->reset_disable) {
+		ret_val = E1000_SUCCESS;
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.reset(hw);
+	if (ret_val) {
+		DEBUGOUT("Error resetting the PHY.\n");
+		goto out;
+	}
+
+	/*
+	 * Wait 100ms for MAC to configure PHY from NVM settings, to avoid
+	 * timeout issues when LFS is enabled.
+	 */
+	msec_delay(100);
+
+	/*
+	 * The NVM settings will configure LPLU in D3 for
+	 * non-IGP1 PHYs.
+	 */
+	if (phy->type == e1000_phy_igp) {
+		/* disable lplu d3 during driver init */
+		ret_val = hw->phy.ops.set_d3_lplu_state(hw, false);
+		if (ret_val) {
+			DEBUGOUT("Error Disabling LPLU D3\n");
+			goto out;
+		}
+	}
+
+	/* disable lplu d0 during driver init */
+	if (hw->phy.ops.set_d0_lplu_state) {
+		ret_val = hw->phy.ops.set_d0_lplu_state(hw, false);
+		if (ret_val) {
+			DEBUGOUT("Error Disabling LPLU D0\n");
+			goto out;
+		}
+	}
+	/* Configure mdi-mdix settings */
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CTRL, &data);
+	if (ret_val)
+		goto out;
+
+	data &= ~IGP01E1000_PSCR_AUTO_MDIX;
+
+	switch (phy->mdix) {
+	case 1:
+		data &= ~IGP01E1000_PSCR_FORCE_MDI_MDIX;
+		break;
+	case 2:
+		data |= IGP01E1000_PSCR_FORCE_MDI_MDIX;
+		break;
+	case 0:
+	default:
+		data |= IGP01E1000_PSCR_AUTO_MDIX;
+		break;
+	}
+	ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CTRL, data);
+	if (ret_val)
+		goto out;
+
+	/* set auto-master slave resolution settings */
+	if (hw->mac.autoneg) {
+		/*
+		 * when autonegotiation advertisement is only 1000Mbps then we
+		 * should disable SmartSpeed and enable Auto MasterSlave
+		 * resolution as hardware default.
+		 */
+		if (phy->autoneg_advertised == ADVERTISE_1000_FULL) {
+			/* Disable SmartSpeed */
+			ret_val = phy->ops.read_reg(hw,
+			                             IGP01E1000_PHY_PORT_CONFIG,
+			                             &data);
+			if (ret_val)
+				goto out;
+
+			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
+			ret_val = phy->ops.write_reg(hw,
+			                             IGP01E1000_PHY_PORT_CONFIG,
+			                             data);
+			if (ret_val)
+				goto out;
+
+			/* Set auto Master/Slave resolution process */
+			ret_val = phy->ops.read_reg(hw, PHY_1000T_CTRL, &data);
+			if (ret_val)
+				goto out;
+
+			data &= ~CR_1000T_MS_ENABLE;
+			ret_val = phy->ops.write_reg(hw, PHY_1000T_CTRL, data);
+			if (ret_val)
+				goto out;
+		}
+
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_CTRL, &data);
+		if (ret_val)
+			goto out;
+
+		/* load defaults for future use */
+		phy->original_ms_type = (data & CR_1000T_MS_ENABLE) ?
+			((data & CR_1000T_MS_VALUE) ?
+			e1000_ms_force_master :
+			e1000_ms_force_slave) :
+			e1000_ms_auto;
+
+		switch (phy->ms_type) {
+		case e1000_ms_force_master:
+			data |= (CR_1000T_MS_ENABLE | CR_1000T_MS_VALUE);
+			break;
+		case e1000_ms_force_slave:
+			data |= CR_1000T_MS_ENABLE;
+			data &= ~(CR_1000T_MS_VALUE);
+			break;
+		case e1000_ms_auto:
+			data &= ~CR_1000T_MS_ENABLE;
+		default:
+			break;
+		}
+		ret_val = phy->ops.write_reg(hw, PHY_1000T_CTRL, data);
+		if (ret_val)
+			goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_copper_link_autoneg - Setup/Enable autoneg for copper link
+ *  @hw: pointer to the HW structure
+ *
+ *  Performs initial bounds checking on autoneg advertisement parameter, then
+ *  configure to advertise the full capability.  Setup the PHY to autoneg
+ *  and restart the negotiation process between the link partner.  If
+ *  autoneg_wait_to_complete, then wait for autoneg to complete before exiting.
+ **/
+s32 e1000_copper_link_autoneg(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_ctrl;
+
+	DEBUGFUNC("e1000_copper_link_autoneg");
+
+	/*
+	 * Perform some bounds checking on the autoneg advertisement
+	 * parameter.
+	 */
+	phy->autoneg_advertised &= phy->autoneg_mask;
+
+	/*
+	 * If autoneg_advertised is zero, we assume it was not defaulted
+	 * by the calling code so we set to advertise full capability.
+	 */
+	if (phy->autoneg_advertised == 0)
+		phy->autoneg_advertised = phy->autoneg_mask;
+
+	DEBUGOUT("Reconfiguring auto-neg advertisement params\n");
+	ret_val = e1000_phy_setup_autoneg(hw);
+	if (ret_val) {
+		DEBUGOUT("Error Setting up Auto-Negotiation\n");
+		goto out;
+	}
+	DEBUGOUT("Restarting Auto-Neg\n");
+
+	/*
+	 * Restart auto-negotiation by setting the Auto Neg Enable bit and
+	 * the Auto Neg Restart bit in the PHY control register.
+	 */
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_ctrl);
+	if (ret_val)
+		goto out;
+
+	phy_ctrl |= (MII_CR_AUTO_NEG_EN | MII_CR_RESTART_AUTO_NEG);
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_ctrl);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Does the user want to wait for Auto-Neg to complete here, or
+	 * check at a later time (for example, callback routine).
+	 */
+	if (phy->autoneg_wait_to_complete) {
+		ret_val = hw->mac.ops.wait_autoneg(hw);
+		if (ret_val) {
+			DEBUGOUT("Error while waiting for "
+			         "autoneg to complete\n");
+			goto out;
+		}
+	}
+
+	hw->mac.get_link_status = true;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_setup_autoneg - Configure PHY for auto-negotiation
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the MII auto-neg advertisement register and/or the 1000T control
+ *  register and if the PHY is already setup for auto-negotiation, then
+ *  return successful.  Otherwise, setup advertisement and flow control to
+ *  the appropriate values for the wanted auto-negotiation.
+ **/
+static s32 e1000_phy_setup_autoneg(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 mii_autoneg_adv_reg;
+	u16 mii_1000t_ctrl_reg = 0;
+
+	DEBUGFUNC("e1000_phy_setup_autoneg");
+
+	phy->autoneg_advertised &= phy->autoneg_mask;
+
+	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
+	ret_val = phy->ops.read_reg(hw, PHY_AUTONEG_ADV, &mii_autoneg_adv_reg);
+	if (ret_val)
+		goto out;
+
+	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
+		/* Read the MII 1000Base-T Control Register (Address 9). */
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_CTRL,
+		                            &mii_1000t_ctrl_reg);
+		if (ret_val)
+			goto out;
+	}
+
+	/*
+	 * Need to parse both autoneg_advertised and fc and set up
+	 * the appropriate PHY registers.  First we will parse for
+	 * autoneg_advertised software override.  Since we can advertise
+	 * a plethora of combinations, we need to check each bit
+	 * individually.
+	 */
+
+	/*
+	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
+	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
+	 * the  1000Base-T Control Register (Address 9).
+	 */
+	mii_autoneg_adv_reg &= ~(NWAY_AR_100TX_FD_CAPS |
+	                         NWAY_AR_100TX_HD_CAPS |
+	                         NWAY_AR_10T_FD_CAPS   |
+	                         NWAY_AR_10T_HD_CAPS);
+	mii_1000t_ctrl_reg &= ~(CR_1000T_HD_CAPS | CR_1000T_FD_CAPS);
+
+	DEBUGOUT1("autoneg_advertised %x\n", phy->autoneg_advertised);
+
+	/* Do we want to advertise 10 Mb Half Duplex? */
+	if (phy->autoneg_advertised & ADVERTISE_10_HALF) {
+		DEBUGOUT("Advertise 10mb Half duplex\n");
+		mii_autoneg_adv_reg |= NWAY_AR_10T_HD_CAPS;
+	}
+
+	/* Do we want to advertise 10 Mb Full Duplex? */
+	if (phy->autoneg_advertised & ADVERTISE_10_FULL) {
+		DEBUGOUT("Advertise 10mb Full duplex\n");
+		mii_autoneg_adv_reg |= NWAY_AR_10T_FD_CAPS;
+	}
+
+	/* Do we want to advertise 100 Mb Half Duplex? */
+	if (phy->autoneg_advertised & ADVERTISE_100_HALF) {
+		DEBUGOUT("Advertise 100mb Half duplex\n");
+		mii_autoneg_adv_reg |= NWAY_AR_100TX_HD_CAPS;
+	}
+
+	/* Do we want to advertise 100 Mb Full Duplex? */
+	if (phy->autoneg_advertised & ADVERTISE_100_FULL) {
+		DEBUGOUT("Advertise 100mb Full duplex\n");
+		mii_autoneg_adv_reg |= NWAY_AR_100TX_FD_CAPS;
+	}
+
+	/* We do not allow the Phy to advertise 1000 Mb Half Duplex */
+	if (phy->autoneg_advertised & ADVERTISE_1000_HALF)
+		DEBUGOUT("Advertise 1000mb Half duplex request denied!\n");
+
+	/* Do we want to advertise 1000 Mb Full Duplex? */
+	if (phy->autoneg_advertised & ADVERTISE_1000_FULL) {
+		DEBUGOUT("Advertise 1000mb Full duplex\n");
+		mii_1000t_ctrl_reg |= CR_1000T_FD_CAPS;
+	}
+
+	/*
+	 * Check for a software override of the flow control settings, and
+	 * setup the PHY advertisement registers accordingly.  If
+	 * auto-negotiation is enabled, then software will have to set the
+	 * "PAUSE" bits to the correct value in the Auto-Negotiation
+	 * Advertisement Register (PHY_AUTONEG_ADV) and re-start auto-
+	 * negotiation.
+	 *
+	 * The possible values of the "fc" parameter are:
+	 *      0:  Flow control is completely disabled
+	 *      1:  Rx flow control is enabled (we can receive pause frames
+	 *          but not send pause frames).
+	 *      2:  Tx flow control is enabled (we can send pause frames
+	 *          but we do not support receiving pause frames).
+	 *      3:  Both Rx and Tx flow control (symmetric) are enabled.
+	 *  other:  No software override.  The flow control configuration
+	 *          in the EEPROM is used.
+	 */
+	switch (hw->fc.current_mode) {
+	case e1000_fc_none:
+		/*
+		 * Flow control (Rx & Tx) is completely disabled by a
+		 * software over-ride.
+		 */
+		mii_autoneg_adv_reg &= ~(NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
+		break;
+	case e1000_fc_rx_pause:
+		/*
+		 * Rx Flow control is enabled, and Tx Flow control is
+		 * disabled, by a software over-ride.
+		 *
+		 * Since there really isn't a way to advertise that we are
+		 * capable of Rx Pause ONLY, we will advertise that we
+		 * support both symmetric and asymmetric Rx PAUSE.  Later
+		 * (in e1000_config_fc_after_link_up) we will disable the
+		 * hw's ability to send PAUSE frames.
+		 */
+		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
+		break;
+	case e1000_fc_tx_pause:
+		/*
+		 * Tx Flow control is enabled, and Rx Flow control is
+		 * disabled, by a software over-ride.
+		 */
+		mii_autoneg_adv_reg |= NWAY_AR_ASM_DIR;
+		mii_autoneg_adv_reg &= ~NWAY_AR_PAUSE;
+		break;
+	case e1000_fc_full:
+		/*
+		 * Flow control (both Rx and Tx) is enabled by a software
+		 * over-ride.
+		 */
+		mii_autoneg_adv_reg |= (NWAY_AR_ASM_DIR | NWAY_AR_PAUSE);
+		break;
+	default:
+		DEBUGOUT("Flow control param set incorrectly\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	ret_val = phy->ops.write_reg(hw, PHY_AUTONEG_ADV, mii_autoneg_adv_reg);
+	if (ret_val)
+		goto out;
+
+	DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
+
+	if (phy->autoneg_mask & ADVERTISE_1000_FULL) {
+		ret_val = phy->ops.write_reg(hw,
+		                              PHY_1000T_CTRL,
+		                              mii_1000t_ctrl_reg);
+		if (ret_val)
+			goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_setup_copper_link_generic - Configure copper link settings
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls the appropriate function to configure the link for auto-neg or forced
+ *  speed and duplex.  Then we check for link, once link is established calls
+ *  to configure collision distance and flow control are called.  If link is
+ *  not established, we return -E1000_ERR_PHY (-2).
+ **/
+s32 e1000_setup_copper_link_generic(struct e1000_hw *hw)
+{
+	s32 ret_val;
+	bool link;
+
+	DEBUGFUNC("e1000_setup_copper_link_generic");
+
+	if (hw->mac.autoneg) {
+		/*
+		 * Setup autoneg and flow control advertisement and perform
+		 * autonegotiation.
+		 */
+		ret_val = e1000_copper_link_autoneg(hw);
+		if (ret_val)
+			goto out;
+	} else {
+		/*
+		 * PHY will be set to 10H, 10F, 100H or 100F
+		 * depending on user settings.
+		 */
+		DEBUGOUT("Forcing Speed and Duplex\n");
+		ret_val = hw->phy.ops.force_speed_duplex(hw);
+		if (ret_val) {
+			DEBUGOUT("Error Forcing Speed and Duplex\n");
+			goto out;
+		}
+	}
+
+	/*
+	 * Check link status. Wait up to 100 microseconds for link to become
+	 * valid.
+	 */
+	ret_val = e1000_phy_has_link_generic(hw,
+	                                     COPPER_LINK_UP_LIMIT,
+	                                     10,
+	                                     &link);
+	if (ret_val)
+		goto out;
+
+	if (link) {
+		DEBUGOUT("Valid link established!!!\n");
+		e1000_config_collision_dist_generic(hw);
+		ret_val = e1000_config_fc_after_link_up_generic(hw);
+	} else {
+		DEBUGOUT("Unable to establish link!!!\n");
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_force_speed_duplex_igp - Force speed/duplex for igp PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls the PHY setup function to force speed and duplex.  Clears the
+ *  auto-crossover to force MDI manually.  Waits for link and returns
+ *  successful if link up is successful, else -E1000_ERR_PHY (-2).
+ **/
+s32 e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data;
+	bool link;
+
+	DEBUGFUNC("e1000_phy_force_speed_duplex_igp");
+
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
+
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_data);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  IGP requires MDI
+	 * forced whenever speed and duplex are forced.
+	 */
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CTRL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data &= ~IGP01E1000_PSCR_AUTO_MDIX;
+	phy_data &= ~IGP01E1000_PSCR_FORCE_MDI_MDIX;
+
+	ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CTRL, phy_data);
+	if (ret_val)
+		goto out;
+
+	DEBUGOUT1("IGP PSCR: %X\n", phy_data);
+
+	usec_delay(1);
+
+	if (phy->autoneg_wait_to_complete) {
+		DEBUGOUT("Waiting for forced speed/duplex link on IGP phy.\n");
+
+		ret_val = e1000_phy_has_link_generic(hw,
+		                                     PHY_FORCE_LIMIT,
+		                                     100000,
+		                                     &link);
+		if (ret_val)
+			goto out;
+
+		if (!link)
+			DEBUGOUT("Link taking longer than expected.\n");
+
+		/* Try once more */
+		ret_val = e1000_phy_has_link_generic(hw,
+		                                     PHY_FORCE_LIMIT,
+		                                     100000,
+		                                     &link);
+		if (ret_val)
+			goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_force_speed_duplex_m88 - Force speed/duplex for m88 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls the PHY setup function to force speed and duplex.  Clears the
+ *  auto-crossover to force MDI manually.  Resets the PHY to commit the
+ *  changes.  If time expires while waiting for link up, we reset the DSP.
+ *  After reset, TX_CLK and CRS on Tx must be set.  Return successful upon
+ *  successful completion, else return corresponding error code.
+ **/
+s32 e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data;
+	bool link;
+
+	DEBUGFUNC("e1000_phy_force_speed_duplex_m88");
+
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  M88E1000 requires MDI
+	 * forced whenever speed and duplex are forced.
+	 */
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data &= ~M88E1000_PSCR_AUTO_X_MODE;
+	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
+	if (ret_val)
+		goto out;
+
+	DEBUGOUT1("M88E1000 PSCR: %X\n", phy_data);
+
+	ret_val = phy->ops.read_reg(hw, PHY_CONTROL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	e1000_phy_force_speed_duplex_setup(hw, &phy_data);
+
+	ret_val = phy->ops.write_reg(hw, PHY_CONTROL, phy_data);
+	if (ret_val)
+		goto out;
+
+	/* Reset the phy to commit changes. */
+	ret_val = hw->phy.ops.commit(hw);
+	if (ret_val)
+		goto out;
+
+	if (phy->autoneg_wait_to_complete) {
+		DEBUGOUT("Waiting for forced speed/duplex link on M88 phy.\n");
+
+		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
+		                                     100000, &link);
+		if (ret_val)
+			goto out;
+
+		if (!link) {
+			/*
+			 * We didn't get link.
+			 * Reset the DSP and cross our fingers.
+			 */
+			ret_val = phy->ops.write_reg(hw,
+			                              M88E1000_PHY_PAGE_SELECT,
+			                              0x001d);
+			if (ret_val)
+				goto out;
+			ret_val = e1000_phy_reset_dsp_generic(hw);
+			if (ret_val)
+				goto out;
+		}
+
+		/* Try once more */
+		ret_val = e1000_phy_has_link_generic(hw, PHY_FORCE_LIMIT,
+		                                     100000, &link);
+		if (ret_val)
+			goto out;
+	}
+
+	ret_val = phy->ops.read_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Resetting the phy means we need to re-force TX_CLK in the
+	 * Extended PHY Specific Control Register to 25MHz clock from
+	 * the reset value of 2.5MHz.
+	 */
+	phy_data |= M88E1000_EPSCR_TX_CLK_25;
+	ret_val = phy->ops.write_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * In addition, we must re-enable CRS on Tx for both half and full
+	 * duplex.
+	 */
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
+	ret_val = phy->ops.write_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_force_speed_duplex_setup - Configure forced PHY speed/duplex
+ *  @hw: pointer to the HW structure
+ *  @phy_ctrl: pointer to current value of PHY_CONTROL
+ *
+ *  Forces speed and duplex on the PHY by doing the following: disable flow
+ *  control, force speed/duplex on the MAC, disable auto speed detection,
+ *  disable auto-negotiation, configure duplex, configure speed, configure
+ *  the collision distance, write configuration to CTRL register.  The
+ *  caller must write to the PHY_CONTROL register for these settings to
+ *  take affect.
+ **/
+void e1000_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	u32 ctrl;
+
+	DEBUGFUNC("e1000_phy_force_speed_duplex_setup");
+
+	/* Turn off flow control when forcing speed/duplex */
+	hw->fc.current_mode = e1000_fc_none;
+
+	/* Force speed/duplex on the mac */
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+	ctrl |= (E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
+	ctrl &= ~E1000_CTRL_SPD_SEL;
+
+	/* Disable Auto Speed Detection */
+	ctrl &= ~E1000_CTRL_ASDE;
+
+	/* Disable autoneg on the phy */
+	*phy_ctrl &= ~MII_CR_AUTO_NEG_EN;
+
+	/* Forcing Full or Half Duplex? */
+	if (mac->forced_speed_duplex & E1000_ALL_HALF_DUPLEX) {
+		ctrl &= ~E1000_CTRL_FD;
+		*phy_ctrl &= ~MII_CR_FULL_DUPLEX;
+		DEBUGOUT("Half Duplex\n");
+	} else {
+		ctrl |= E1000_CTRL_FD;
+		*phy_ctrl |= MII_CR_FULL_DUPLEX;
+		DEBUGOUT("Full Duplex\n");
+	}
+
+	/* Forcing 10mb or 100mb? */
+	if (mac->forced_speed_duplex & E1000_ALL_100_SPEED) {
+		ctrl |= E1000_CTRL_SPD_100;
+		*phy_ctrl |= MII_CR_SPEED_100;
+		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_10);
+		DEBUGOUT("Forcing 100mb\n");
+	} else {
+		ctrl &= ~(E1000_CTRL_SPD_1000 | E1000_CTRL_SPD_100);
+		*phy_ctrl |= MII_CR_SPEED_10;
+		*phy_ctrl &= ~(MII_CR_SPEED_1000 | MII_CR_SPEED_100);
+		DEBUGOUT("Forcing 10mb\n");
+	}
+
+	e1000_config_collision_dist_generic(hw);
+
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+}
+
+/**
+ *  e1000_set_d3_lplu_state_generic - Sets low power link up state for D3
+ *  @hw: pointer to the HW structure
+ *  @active: boolean used to enable/disable lplu
+ *
+ *  Success returns 0, Failure returns 1
+ *
+ *  The low power link up (lplu) state is set to the power management level D3
+ *  and SmartSpeed is disabled when active is true, else clear lplu for D3
+ *  and enable Smartspeed.  LPLU and Smartspeed are mutually exclusive.  LPLU
+ *  is used during Dx states where the power conservation is most important.
+ *  During driver activity, SmartSpeed should be enabled so performance is
+ *  maintained.
+ **/
+s32 e1000_set_d3_lplu_state_generic(struct e1000_hw *hw, bool active)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val = E1000_SUCCESS;
+	u16 data;
+
+	DEBUGFUNC("e1000_set_d3_lplu_state_generic");
+
+	if (!(hw->phy.ops.read_reg))
+		goto out;
+
+	ret_val = phy->ops.read_reg(hw, IGP02E1000_PHY_POWER_MGMT, &data);
+	if (ret_val)
+		goto out;
+
+	if (!active) {
+		data &= ~IGP02E1000_PM_D3_LPLU;
+		ret_val = phy->ops.write_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+		                             data);
+		if (ret_val)
+			goto out;
+		/*
+		 * LPLU and SmartSpeed are mutually exclusive.  LPLU is used
+		 * during Dx states where the power conservation is most
+		 * important.  During driver activity we should enable
+		 * SmartSpeed, so performance is maintained.
+		 */
+		if (phy->smart_speed == e1000_smart_speed_on) {
+			ret_val = phy->ops.read_reg(hw,
+			                            IGP01E1000_PHY_PORT_CONFIG,
+			                            &data);
+			if (ret_val)
+				goto out;
+
+			data |= IGP01E1000_PSCFR_SMART_SPEED;
+			ret_val = phy->ops.write_reg(hw,
+			                             IGP01E1000_PHY_PORT_CONFIG,
+			                             data);
+			if (ret_val)
+				goto out;
+		} else if (phy->smart_speed == e1000_smart_speed_off) {
+			ret_val = phy->ops.read_reg(hw,
+			                             IGP01E1000_PHY_PORT_CONFIG,
+			                             &data);
+			if (ret_val)
+				goto out;
+
+			data &= ~IGP01E1000_PSCFR_SMART_SPEED;
+			ret_val = phy->ops.write_reg(hw,
+			                             IGP01E1000_PHY_PORT_CONFIG,
+			                             data);
+			if (ret_val)
+				goto out;
+		}
+	} else if ((phy->autoneg_advertised == E1000_ALL_SPEED_DUPLEX) ||
+	           (phy->autoneg_advertised == E1000_ALL_NOT_GIG) ||
+	           (phy->autoneg_advertised == E1000_ALL_10_SPEED)) {
+		data |= IGP02E1000_PM_D3_LPLU;
+		ret_val = phy->ops.write_reg(hw, IGP02E1000_PHY_POWER_MGMT,
+		                              data);
+		if (ret_val)
+			goto out;
+
+		/* When LPLU is enabled, we should disable SmartSpeed */
+		ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+		                             &data);
+		if (ret_val)
+			goto out;
+
+		data &= ~IGP01E1000_PSCFR_SMART_SPEED;
+		ret_val = phy->ops.write_reg(hw, IGP01E1000_PHY_PORT_CONFIG,
+		                              data);
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_check_downshift_generic - Checks whether a downshift in speed occurred
+ *  @hw: pointer to the HW structure
+ *
+ *  Success returns 0, Failure returns 1
+ *
+ *  A downshift is detected by querying the PHY link health.
+ **/
+s32 e1000_check_downshift_generic(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data, offset, mask;
+
+	DEBUGFUNC("e1000_check_downshift_generic");
+
+	switch (phy->type) {
+	case e1000_phy_m88:
+	case e1000_phy_gg82563:
+		offset	= M88E1000_PHY_SPEC_STATUS;
+		mask	= M88E1000_PSSR_DOWNSHIFT;
+		break;
+	case e1000_phy_igp_2:
+	case e1000_phy_igp:
+	case e1000_phy_igp_3:
+		offset	= IGP01E1000_PHY_LINK_HEALTH;
+		mask	= IGP01E1000_PLHR_SS_DOWNGRADE;
+		break;
+	default:
+		/* speed downshift not supported */
+		phy->speed_downgraded = false;
+		ret_val = E1000_SUCCESS;
+		goto out;
+	}
+
+	ret_val = phy->ops.read_reg(hw, offset, &phy_data);
+
+	if (!ret_val)
+		phy->speed_downgraded = (phy_data & mask) ? true : false;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_check_polarity_m88 - Checks the polarity.
+ *  @hw: pointer to the HW structure
+ *
+ *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
+ *
+ *  Polarity is determined based on the PHY specific status register.
+ **/
+s32 e1000_check_polarity_m88(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+
+	DEBUGFUNC("e1000_check_polarity_m88");
+
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &data);
+
+	if (!ret_val)
+		phy->cable_polarity = (data & M88E1000_PSSR_REV_POLARITY)
+		                      ? e1000_rev_polarity_reversed
+		                      : e1000_rev_polarity_normal;
+
+	return ret_val;
+}
+
+/**
+ *  e1000_check_polarity_igp - Checks the polarity.
+ *  @hw: pointer to the HW structure
+ *
+ *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
+ *
+ *  Polarity is determined based on the PHY port status register, and the
+ *  current speed (since there is no polarity at 100Mbps).
+ **/
+s32 e1000_check_polarity_igp(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data, offset, mask;
+
+	DEBUGFUNC("e1000_check_polarity_igp");
+
+	/*
+	 * Polarity is determined based on the speed of
+	 * our connection.
+	 */
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_STATUS, &data);
+	if (ret_val)
+		goto out;
+
+	if ((data & IGP01E1000_PSSR_SPEED_MASK) ==
+	    IGP01E1000_PSSR_SPEED_1000MBPS) {
+		offset	= IGP01E1000_PHY_PCS_INIT_REG;
+		mask	= IGP01E1000_PHY_POLARITY_MASK;
+	} else {
+		/*
+		 * This really only applies to 10Mbps since
+		 * there is no polarity for 100Mbps (always 0).
+		 */
+		offset	= IGP01E1000_PHY_PORT_STATUS;
+		mask	= IGP01E1000_PSSR_POLARITY_REVERSED;
+	}
+
+	ret_val = phy->ops.read_reg(hw, offset, &data);
+
+	if (!ret_val)
+		phy->cable_polarity = (data & mask)
+		                      ? e1000_rev_polarity_reversed
+		                      : e1000_rev_polarity_normal;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_wait_autoneg_generic - Wait for auto-neg completion
+ *  @hw: pointer to the HW structure
+ *
+ *  Waits for auto-negotiation to complete or for the auto-negotiation time
+ *  limit to expire, which ever happens first.
+ **/
+s32 e1000_wait_autoneg_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u16 i, phy_status;
+
+	DEBUGFUNC("e1000_wait_autoneg_generic");
+
+	if (!(hw->phy.ops.read_reg))
+		return E1000_SUCCESS;
+
+	/* Break after autoneg completes or PHY_AUTO_NEG_LIMIT expires. */
+	for (i = PHY_AUTO_NEG_LIMIT; i > 0; i--) {
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
+		if (ret_val)
+			break;
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
+		if (ret_val)
+			break;
+		if (phy_status & MII_SR_AUTONEG_COMPLETE)
+			break;
+		msec_delay(100);
+	}
+
+	/*
+	 * PHY_AUTO_NEG_TIME expiration doesn't guarantee auto-negotiation
+	 * has completed.
+	 */
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_has_link_generic - Polls PHY for link
+ *  @hw: pointer to the HW structure
+ *  @iterations: number of times to poll for link
+ *  @usec_interval: delay between polling attempts
+ *  @success: pointer to whether polling was successful or not
+ *
+ *  Polls the PHY status register for link, 'iterations' number of times.
+ **/
+s32 e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
+                               u32 usec_interval, bool *success)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u16 i, phy_status;
+
+	DEBUGFUNC("e1000_phy_has_link_generic");
+
+	if (!(hw->phy.ops.read_reg))
+		return E1000_SUCCESS;
+
+	for (i = 0; i < iterations; i++) {
+		/*
+		 * Some PHYs require the PHY_STATUS register to be read
+		 * twice due to the link bit being sticky.  No harm doing
+		 * it across the board.
+		 */
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
+		if (ret_val)
+			break;
+		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
+		if (ret_val)
+			break;
+		if (phy_status & MII_SR_LINK_STATUS)
+			break;
+		if (usec_interval >= 1000)
+			msec_delay_irq(usec_interval/1000);
+		else
+			usec_delay(usec_interval);
+	}
+
+	*success = (i < iterations) ? true : false;
+
+	return ret_val;
+}
+
+/**
+ *  e1000_get_cable_length_m88 - Determine cable length for m88 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Reads the PHY specific status register to retrieve the cable length
+ *  information.  The cable length is determined by averaging the minimum and
+ *  maximum values to get the "average" cable length.  The m88 PHY has four
+ *  possible cable length values, which are:
+ *	Register Value		Cable Length
+ *	0			< 50 meters
+ *	1			50 - 80 meters
+ *	2			80 - 110 meters
+ *	3			110 - 140 meters
+ *	4			> 140 meters
+ **/
+s32 e1000_get_cable_length_m88(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data, index;
+
+	DEBUGFUNC("e1000_get_cable_length_m88");
+
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
+	if (ret_val)
+		goto out;
+
+	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
+	        M88E1000_PSSR_CABLE_LENGTH_SHIFT;
+	if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE + 1) {
+		ret_val = E1000_ERR_PHY;
+		goto out;
+	}
+
+	phy->min_cable_length = e1000_m88_cable_length_table[index];
+	phy->max_cable_length = e1000_m88_cable_length_table[index+1];
+
+	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_cable_length_igp_2 - Determine cable length for igp2 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  The automatic gain control (agc) normalizes the amplitude of the
+ *  received signal, adjusting for the attenuation produced by the
+ *  cable.  By reading the AGC registers, which represent the
+ *  combination of coarse and fine gain value, the value can be put
+ *  into a lookup table to obtain the approximate cable length
+ *  for each channel.
+ **/
+s32 e1000_get_cable_length_igp_2(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val = E1000_SUCCESS;
+	u16 phy_data, i, agc_value = 0;
+	u16 cur_agc_index, max_agc_index = 0;
+	u16 min_agc_index = IGP02E1000_CABLE_LENGTH_TABLE_SIZE - 1;
+	u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
+	                                                 {IGP02E1000_PHY_AGC_A,
+	                                                  IGP02E1000_PHY_AGC_B,
+	                                                  IGP02E1000_PHY_AGC_C,
+	                                                  IGP02E1000_PHY_AGC_D};
+
+	DEBUGFUNC("e1000_get_cable_length_igp_2");
+
+	/* Read the AGC registers for all channels */
+	for (i = 0; i < IGP02E1000_PHY_CHANNEL_NUM; i++) {
+		ret_val = phy->ops.read_reg(hw, agc_reg_array[i], &phy_data);
+		if (ret_val)
+			goto out;
+
+		/*
+		 * Getting bits 15:9, which represent the combination of
+		 * coarse and fine gain values.  The result is a number
+		 * that can be put into the lookup table to obtain the
+		 * approximate cable length.
+		 */
+		cur_agc_index = (phy_data >> IGP02E1000_AGC_LENGTH_SHIFT) &
+		                IGP02E1000_AGC_LENGTH_MASK;
+
+		/* Array index bound check. */
+		if ((cur_agc_index >= IGP02E1000_CABLE_LENGTH_TABLE_SIZE) ||
+		    (cur_agc_index == 0)) {
+			ret_val = -E1000_ERR_PHY;
+			goto out;
+		}
+
+		/* Remove min & max AGC values from calculation. */
+		if (e1000_igp_2_cable_length_table[min_agc_index] >
+		    e1000_igp_2_cable_length_table[cur_agc_index])
+			min_agc_index = cur_agc_index;
+		if (e1000_igp_2_cable_length_table[max_agc_index] <
+		    e1000_igp_2_cable_length_table[cur_agc_index])
+			max_agc_index = cur_agc_index;
+
+		agc_value += e1000_igp_2_cable_length_table[cur_agc_index];
+	}
+
+	agc_value -= (e1000_igp_2_cable_length_table[min_agc_index] +
+	              e1000_igp_2_cable_length_table[max_agc_index]);
+	agc_value /= (IGP02E1000_PHY_CHANNEL_NUM - 2);
+
+	/* Calculate cable length with the error range of +/- 10 meters. */
+	phy->min_cable_length = ((agc_value - IGP02E1000_AGC_RANGE) > 0) ?
+	                         (agc_value - IGP02E1000_AGC_RANGE) : 0;
+	phy->max_cable_length = agc_value + IGP02E1000_AGC_RANGE;
+
+	phy->cable_length = (phy->min_cable_length + phy->max_cable_length) / 2;
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_phy_info_m88 - Retrieve PHY information
+ *  @hw: pointer to the HW structure
+ *
+ *  Valid for only copper links.  Read the PHY status register (sticky read)
+ *  to verify that link is up.  Read the PHY special control register to
+ *  determine the polarity and 10base-T extended distance.  Read the PHY
+ *  special status register to determine MDI/MDIx and current speed.  If
+ *  speed is 1000, then determine cable length, local and remote receiver.
+ **/
+s32 e1000_get_phy_info_m88(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32  ret_val;
+	u16 phy_data;
+	bool link;
+
+	DEBUGFUNC("e1000_get_phy_info_m88");
+
+	if (hw->phy.media_type != e1000_media_type_copper) {
+		DEBUGOUT("Phy info is only valid for copper media\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	if (ret_val)
+		goto out;
+
+	if (!link) {
+		DEBUGOUT("Phy info is only valid if link is up\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy->polarity_correction = (phy_data & M88E1000_PSCR_POLARITY_REVERSAL)
+	                           ? true : false;
+
+	ret_val = e1000_check_polarity_m88(hw);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy->is_mdix = (phy_data & M88E1000_PSSR_MDIX) ? true : false;
+
+	if ((phy_data & M88E1000_PSSR_SPEED) == M88E1000_PSSR_1000MBS) {
+		ret_val = hw->phy.ops.get_cable_length(hw);
+		if (ret_val)
+			goto out;
+
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_STATUS, &phy_data);
+		if (ret_val)
+			goto out;
+
+		phy->local_rx = (phy_data & SR_1000T_LOCAL_RX_STATUS)
+		                ? e1000_1000t_rx_status_ok
+		                : e1000_1000t_rx_status_not_ok;
+
+		phy->remote_rx = (phy_data & SR_1000T_REMOTE_RX_STATUS)
+		                 ? e1000_1000t_rx_status_ok
+		                 : e1000_1000t_rx_status_not_ok;
+	} else {
+		/* Set values to "undefined" */
+		phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
+		phy->local_rx = e1000_1000t_rx_status_undefined;
+		phy->remote_rx = e1000_1000t_rx_status_undefined;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_phy_info_igp - Retrieve igp PHY information
+ *  @hw: pointer to the HW structure
+ *
+ *  Read PHY status to determine if link is up.  If link is up, then
+ *  set/determine 10base-T extended distance and polarity correction.  Read
+ *  PHY port status to determine MDI/MDIx and speed.  Based on the speed,
+ *  determine on the cable length, local and remote receiver.
+ **/
+s32 e1000_get_phy_info_igp(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+	bool link;
+
+	DEBUGFUNC("e1000_get_phy_info_igp");
+
+	ret_val = e1000_phy_has_link_generic(hw, 1, 0, &link);
+	if (ret_val)
+		goto out;
+
+	if (!link) {
+		DEBUGOUT("Phy info is only valid if link is up\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	phy->polarity_correction = true;
+
+	ret_val = e1000_check_polarity_igp(hw);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.read_reg(hw, IGP01E1000_PHY_PORT_STATUS, &data);
+	if (ret_val)
+		goto out;
+
+	phy->is_mdix = (data & IGP01E1000_PSSR_MDIX) ? true : false;
+
+	if ((data & IGP01E1000_PSSR_SPEED_MASK) ==
+	    IGP01E1000_PSSR_SPEED_1000MBPS) {
+		ret_val = hw->phy.ops.get_cable_length(hw);
+		if (ret_val)
+			goto out;
+
+		ret_val = phy->ops.read_reg(hw, PHY_1000T_STATUS, &data);
+		if (ret_val)
+			goto out;
+
+		phy->local_rx = (data & SR_1000T_LOCAL_RX_STATUS)
+		                ? e1000_1000t_rx_status_ok
+		                : e1000_1000t_rx_status_not_ok;
+
+		phy->remote_rx = (data & SR_1000T_REMOTE_RX_STATUS)
+		                 ? e1000_1000t_rx_status_ok
+		                 : e1000_1000t_rx_status_not_ok;
+	} else {
+		phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
+		phy->local_rx = e1000_1000t_rx_status_undefined;
+		phy->remote_rx = e1000_1000t_rx_status_undefined;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_sw_reset_generic - PHY software reset
+ *  @hw: pointer to the HW structure
+ *
+ *  Does a software reset of the PHY by reading the PHY control register and
+ *  setting/write the control register reset bit to the PHY.
+ **/
+s32 e1000_phy_sw_reset_generic(struct e1000_hw *hw)
+{
+	s32 ret_val = E1000_SUCCESS;
+	u16 phy_ctrl;
+
+	DEBUGFUNC("e1000_phy_sw_reset_generic");
+
+	if (!(hw->phy.ops.read_reg))
+		goto out;
+
+	ret_val = hw->phy.ops.read_reg(hw, PHY_CONTROL, &phy_ctrl);
+	if (ret_val)
+		goto out;
+
+	phy_ctrl |= MII_CR_RESET;
+	ret_val = hw->phy.ops.write_reg(hw, PHY_CONTROL, phy_ctrl);
+	if (ret_val)
+		goto out;
+
+	usec_delay(1);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_hw_reset_generic - PHY hardware reset
+ *  @hw: pointer to the HW structure
+ *
+ *  Verify the reset block is not blocking us from resetting.  Acquire
+ *  semaphore (if necessary) and read/set/write the device control reset
+ *  bit in the PHY.  Wait the appropriate delay time for the device to
+ *  reset and release the semaphore (if necessary).
+ **/
+s32 e1000_phy_hw_reset_generic(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val = E1000_SUCCESS;
+	u32 ctrl;
+
+	DEBUGFUNC("e1000_phy_hw_reset_generic");
+
+	ret_val = phy->ops.check_reset_block(hw);
+	if (ret_val) {
+		ret_val = E1000_SUCCESS;
+		goto out;
+	}
+
+	ret_val = phy->ops.acquire(hw);
+	if (ret_val)
+		goto out;
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl | E1000_CTRL_PHY_RST);
+	E1000_WRITE_FLUSH(hw);
+
+	usec_delay(phy->reset_delay_us);
+
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl);
+	E1000_WRITE_FLUSH(hw);
+
+	usec_delay(150);
+
+	phy->ops.release(hw);
+
+	ret_val = phy->ops.get_cfg_done(hw);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_cfg_done_generic - Generic configuration done
+ *  @hw: pointer to the HW structure
+ *
+ *  Generic function to wait 10 milli-seconds for configuration to complete
+ *  and return success.
+ **/
+s32 e1000_get_cfg_done_generic(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_get_cfg_done_generic");
+
+	msec_delay_irq(10);
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_phy_init_script_igp3 - Inits the IGP3 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Initializes a Intel Gigabit PHY3 when an EEPROM is not present.
+ **/
+s32 e1000_phy_init_script_igp3(struct e1000_hw *hw)
+{
+	DEBUGOUT("Running IGP 3 PHY init script\n");
+
+	/* PHY init IGP 3 */
+	/* Enable rise/fall, 10-mode work in class-A */
+	hw->phy.ops.write_reg(hw, 0x2F5B, 0x9018);
+	/* Remove all caps from Replica path filter */
+	hw->phy.ops.write_reg(hw, 0x2F52, 0x0000);
+	/* Bias trimming for ADC, AFE and Driver (Default) */
+	hw->phy.ops.write_reg(hw, 0x2FB1, 0x8B24);
+	/* Increase Hybrid poly bias */
+	hw->phy.ops.write_reg(hw, 0x2FB2, 0xF8F0);
+	/* Add 4% to Tx amplitude in Gig mode */
+	hw->phy.ops.write_reg(hw, 0x2010, 0x10B0);
+	/* Disable trimming (TTT) */
+	hw->phy.ops.write_reg(hw, 0x2011, 0x0000);
+	/* Poly DC correction to 94.6% + 2% for all channels */
+	hw->phy.ops.write_reg(hw, 0x20DD, 0x249A);
+	/* ABS DC correction to 95.9% */
+	hw->phy.ops.write_reg(hw, 0x20DE, 0x00D3);
+	/* BG temp curve trim */
+	hw->phy.ops.write_reg(hw, 0x28B4, 0x04CE);
+	/* Increasing ADC OPAMP stage 1 currents to max */
+	hw->phy.ops.write_reg(hw, 0x2F70, 0x29E4);
+	/* Force 1000 ( required for enabling PHY regs configuration) */
+	hw->phy.ops.write_reg(hw, 0x0000, 0x0140);
+	/* Set upd_freq to 6 */
+	hw->phy.ops.write_reg(hw, 0x1F30, 0x1606);
+	/* Disable NPDFE */
+	hw->phy.ops.write_reg(hw, 0x1F31, 0xB814);
+	/* Disable adaptive fixed FFE (Default) */
+	hw->phy.ops.write_reg(hw, 0x1F35, 0x002A);
+	/* Enable FFE hysteresis */
+	hw->phy.ops.write_reg(hw, 0x1F3E, 0x0067);
+	/* Fixed FFE for short cable lengths */
+	hw->phy.ops.write_reg(hw, 0x1F54, 0x0065);
+	/* Fixed FFE for medium cable lengths */
+	hw->phy.ops.write_reg(hw, 0x1F55, 0x002A);
+	/* Fixed FFE for long cable lengths */
+	hw->phy.ops.write_reg(hw, 0x1F56, 0x002A);
+	/* Enable Adaptive Clip Threshold */
+	hw->phy.ops.write_reg(hw, 0x1F72, 0x3FB0);
+	/* AHT reset limit to 1 */
+	hw->phy.ops.write_reg(hw, 0x1F76, 0xC0FF);
+	/* Set AHT master delay to 127 msec */
+	hw->phy.ops.write_reg(hw, 0x1F77, 0x1DEC);
+	/* Set scan bits for AHT */
+	hw->phy.ops.write_reg(hw, 0x1F78, 0xF9EF);
+	/* Set AHT Preset bits */
+	hw->phy.ops.write_reg(hw, 0x1F79, 0x0210);
+	/* Change integ_factor of channel A to 3 */
+	hw->phy.ops.write_reg(hw, 0x1895, 0x0003);
+	/* Change prop_factor of channels BCD to 8 */
+	hw->phy.ops.write_reg(hw, 0x1796, 0x0008);
+	/* Change cg_icount + enable integbp for channels BCD */
+	hw->phy.ops.write_reg(hw, 0x1798, 0xD008);
+	/*
+	 * Change cg_icount + enable integbp + change prop_factor_master
+	 * to 8 for channel A
+	 */
+	hw->phy.ops.write_reg(hw, 0x1898, 0xD918);
+	/* Disable AHT in Slave mode on channel A */
+	hw->phy.ops.write_reg(hw, 0x187A, 0x0800);
+	/*
+	 * Enable LPLU and disable AN to 1000 in non-D0a states,
+	 * Enable SPD+B2B
+	 */
+	hw->phy.ops.write_reg(hw, 0x0019, 0x008D);
+	/* Enable restart AN on an1000_dis change */
+	hw->phy.ops.write_reg(hw, 0x001B, 0x2080);
+	/* Enable wh_fifo read clock in 10/100 modes */
+	hw->phy.ops.write_reg(hw, 0x0014, 0x0045);
+	/* Restart AN, Speed selection is 1000 */
+	hw->phy.ops.write_reg(hw, 0x0000, 0x1340);
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_get_phy_type_from_id - Get PHY type from id
+ *  @phy_id: phy_id read from the phy
+ *
+ *  Returns the phy type from the id.
+ **/
+enum e1000_phy_type e1000_get_phy_type_from_id(u32 phy_id)
+{
+	enum e1000_phy_type phy_type = e1000_phy_unknown;
+
+	switch (phy_id)	{
+	case M88E1000_I_PHY_ID:
+	case M88E1000_E_PHY_ID:
+	case M88E1111_I_PHY_ID:
+	case M88E1011_I_PHY_ID:
+		phy_type = e1000_phy_m88;
+		break;
+	case IGP01E1000_I_PHY_ID: /* IGP 1 & 2 share this */
+		phy_type = e1000_phy_igp_2;
+		break;
+	case GG82563_E_PHY_ID:
+		phy_type = e1000_phy_gg82563;
+		break;
+	case IGP03E1000_E_PHY_ID:
+		phy_type = e1000_phy_igp_3;
+		break;
+	case IFE_E_PHY_ID:
+	case IFE_PLUS_E_PHY_ID:
+	case IFE_C_E_PHY_ID:
+		phy_type = e1000_phy_ife;
+		break;
+	default:
+		phy_type = e1000_phy_unknown;
+		break;
+	}
+	return phy_type;
+}
+
+/**
+ *  e1000_determine_phy_address - Determines PHY address.
+ *  @hw: pointer to the HW structure
+ *
+ *  This uses a trial and error method to loop through possible PHY
+ *  addresses. It tests each by reading the PHY ID registers and
+ *  checking for a match.
+ **/
+s32 e1000_determine_phy_address(struct e1000_hw *hw)
+{
+	s32 ret_val = -E1000_ERR_PHY_TYPE;
+	u32 phy_addr = 0;
+	u32 i;
+	enum e1000_phy_type phy_type = e1000_phy_unknown;
+
+	hw->phy.id = phy_type;
+
+	for (phy_addr = 0; phy_addr < E1000_MAX_PHY_ADDR; phy_addr++) {
+		hw->phy.addr = phy_addr;
+		i = 0;
+
+		do {
+			e1000_get_phy_id(hw);
+			phy_type = e1000_get_phy_type_from_id(hw->phy.id);
+
+			/*
+			 * If phy_type is valid, break - we found our
+			 * PHY address
+			 */
+			if (phy_type  != e1000_phy_unknown) {
+				ret_val = E1000_SUCCESS;
+				goto out;
+			}
+			msec_delay(1);
+			i++;
+		} while (i < 10);
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ * e1000_power_up_phy_copper - Restore copper link in case of PHY power down
+ * @hw: pointer to the HW structure
+ *
+ * In the case of a PHY power down to save power, or to turn off link during a
+ * driver unload, or wake on lan is not enabled, restore the link to previous
+ * settings.
+ **/
+void e1000_power_up_phy_copper(struct e1000_hw *hw)
+{
+	u16 mii_reg = 0;
+
+	/* The PHY will retain its settings across a power down/up cycle */
+	hw->phy.ops.read_reg(hw, PHY_CONTROL, &mii_reg);
+	mii_reg &= ~MII_CR_POWER_DOWN;
+	hw->phy.ops.write_reg(hw, PHY_CONTROL, mii_reg);
+}
+
+/**
+ * e1000_power_down_phy_copper - Restore copper link in case of PHY power down
+ * @hw: pointer to the HW structure
+ *
+ * In the case of a PHY power down to save power, or to turn off link during a
+ * driver unload, or wake on lan is not enabled, restore the link to previous
+ * settings.
+ **/
+void e1000_power_down_phy_copper(struct e1000_hw *hw)
+{
+	u16 mii_reg = 0;
+
+	/* The PHY will retain its settings across a power down/up cycle */
+	hw->phy.ops.read_reg(hw, PHY_CONTROL, &mii_reg);
+	mii_reg |= MII_CR_POWER_DOWN;
+	hw->phy.ops.write_reg(hw, PHY_CONTROL, mii_reg);
+	msec_delay(1);
+}
diff -Npur igbvf-0.5.2/src/e1000_phy.h igbvf-0.5.2.orig/src/e1000_phy.h
--- igbvf-0.5.2/src/e1000_phy.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_phy.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,158 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_PHY_H_
+#define _E1000_PHY_H_
+
+void e1000_init_phy_ops_generic(struct e1000_hw *hw);
+s32  e1000_null_read_reg(struct e1000_hw *hw, u32 offset, u16 *data);
+void e1000_null_phy_generic(struct e1000_hw *hw);
+s32  e1000_null_lplu_state(struct e1000_hw *hw, bool active);
+s32  e1000_null_write_reg(struct e1000_hw *hw, u32 offset, u16 data);
+s32  e1000_check_downshift_generic(struct e1000_hw *hw);
+s32  e1000_check_polarity_m88(struct e1000_hw *hw);
+s32  e1000_check_polarity_igp(struct e1000_hw *hw);
+s32  e1000_check_reset_block_generic(struct e1000_hw *hw);
+s32  e1000_copper_link_autoneg(struct e1000_hw *hw);
+s32  e1000_copper_link_setup_igp(struct e1000_hw *hw);
+s32  e1000_copper_link_setup_m88(struct e1000_hw *hw);
+s32  e1000_phy_force_speed_duplex_igp(struct e1000_hw *hw);
+s32  e1000_phy_force_speed_duplex_m88(struct e1000_hw *hw);
+s32  e1000_get_cable_length_m88(struct e1000_hw *hw);
+s32  e1000_get_cable_length_igp_2(struct e1000_hw *hw);
+s32  e1000_get_cfg_done_generic(struct e1000_hw *hw);
+s32  e1000_get_phy_id(struct e1000_hw *hw);
+s32  e1000_get_phy_info_igp(struct e1000_hw *hw);
+s32  e1000_get_phy_info_m88(struct e1000_hw *hw);
+s32  e1000_phy_sw_reset_generic(struct e1000_hw *hw);
+void e1000_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
+s32  e1000_phy_hw_reset_generic(struct e1000_hw *hw);
+s32  e1000_phy_reset_dsp_generic(struct e1000_hw *hw);
+s32  e1000_read_kmrn_reg_generic(struct e1000_hw *hw, u32 offset, u16 *data);
+s32  e1000_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data);
+s32  e1000_read_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 *data);
+s32  e1000_set_d3_lplu_state_generic(struct e1000_hw *hw, bool active);
+s32  e1000_setup_copper_link_generic(struct e1000_hw *hw);
+s32  e1000_wait_autoneg_generic(struct e1000_hw *hw);
+s32  e1000_write_kmrn_reg_generic(struct e1000_hw *hw, u32 offset, u16 data);
+s32  e1000_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
+s32  e1000_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data);
+s32  e1000_phy_reset_dsp(struct e1000_hw *hw);
+s32  e1000_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
+                                u32 usec_interval, bool *success);
+s32  e1000_phy_init_script_igp3(struct e1000_hw *hw);
+enum e1000_phy_type e1000_get_phy_type_from_id(u32 phy_id);
+s32 e1000_determine_phy_address(struct e1000_hw *hw);
+void e1000_power_up_phy_copper(struct e1000_hw *hw);
+void e1000_power_down_phy_copper(struct e1000_hw *hw);
+s32 e1000_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data);
+s32 e1000_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
+
+#define E1000_MAX_PHY_ADDR                4
+
+/* IGP01E1000 Specific Registers */
+#define IGP01E1000_PHY_PORT_CONFIG        0x10 /* Port Config */
+#define IGP01E1000_PHY_PORT_STATUS        0x11 /* Status */
+#define IGP01E1000_PHY_PORT_CTRL          0x12 /* Control */
+#define IGP01E1000_PHY_LINK_HEALTH        0x13 /* PHY Link Health */
+#define IGP01E1000_GMII_FIFO              0x14 /* GMII FIFO */
+#define IGP01E1000_PHY_CHANNEL_QUALITY    0x15 /* PHY Channel Quality */
+#define IGP02E1000_PHY_POWER_MGMT         0x19 /* Power Management */
+#define IGP01E1000_PHY_PAGE_SELECT        0x1F /* Page Select */
+#define BM_PHY_PAGE_SELECT                22   /* Page Select for BM */
+#define IGP_PAGE_SHIFT                    5
+#define PHY_REG_MASK                      0x1F
+
+#define IGP01E1000_PHY_PCS_INIT_REG       0x00B4
+#define IGP01E1000_PHY_POLARITY_MASK      0x0078
+
+#define IGP01E1000_PSCR_AUTO_MDIX         0x1000
+#define IGP01E1000_PSCR_FORCE_MDI_MDIX    0x2000 /* 0=MDI, 1=MDIX */
+
+#define IGP01E1000_PSCFR_SMART_SPEED      0x0080
+
+/* Enable flexible speed on link-up */
+#define IGP01E1000_GMII_FLEX_SPD          0x0010
+#define IGP01E1000_GMII_SPD               0x0020 /* Enable SPD */
+
+#define IGP02E1000_PM_SPD                 0x0001 /* Smart Power Down */
+#define IGP02E1000_PM_D0_LPLU             0x0002 /* For D0a states */
+#define IGP02E1000_PM_D3_LPLU             0x0004 /* For all other states */
+
+#define IGP01E1000_PLHR_SS_DOWNGRADE      0x8000
+
+#define IGP01E1000_PSSR_POLARITY_REVERSED 0x0002
+#define IGP01E1000_PSSR_MDIX              0x0008
+#define IGP01E1000_PSSR_SPEED_MASK        0xC000
+#define IGP01E1000_PSSR_SPEED_1000MBPS    0xC000
+
+#define IGP02E1000_PHY_CHANNEL_NUM        4
+#define IGP02E1000_PHY_AGC_A              0x11B1
+#define IGP02E1000_PHY_AGC_B              0x12B1
+#define IGP02E1000_PHY_AGC_C              0x14B1
+#define IGP02E1000_PHY_AGC_D              0x18B1
+
+#define IGP02E1000_AGC_LENGTH_SHIFT       9   /* Course - 15:13, Fine - 12:9 */
+#define IGP02E1000_AGC_LENGTH_MASK        0x7F
+#define IGP02E1000_AGC_RANGE              15
+
+#define IGP03E1000_PHY_MISC_CTRL          0x1B
+#define IGP03E1000_PHY_MISC_DUPLEX_MANUAL_SET  0x1000 /* Manually Set Duplex */
+
+#define E1000_CABLE_LENGTH_UNDEFINED      0xFF
+
+#define E1000_KMRNCTRLSTA_OFFSET          0x001F0000
+#define E1000_KMRNCTRLSTA_OFFSET_SHIFT    16
+#define E1000_KMRNCTRLSTA_REN             0x00200000
+#define E1000_KMRNCTRLSTA_DIAG_OFFSET     0x3    /* Kumeran Diagnostic */
+#define E1000_KMRNCTRLSTA_DIAG_NELPBK     0x1000 /* Nearend Loopback mode */
+
+#define IFE_PHY_EXTENDED_STATUS_CONTROL 0x10
+#define IFE_PHY_SPECIAL_CONTROL     0x11 /* 100BaseTx PHY Special Control */
+#define IFE_PHY_SPECIAL_CONTROL_LED 0x1B /* PHY Special and LED Control */
+#define IFE_PHY_MDIX_CONTROL        0x1C /* MDI/MDI-X Control */
+
+/* IFE PHY Extended Status Control */
+#define IFE_PESC_POLARITY_REVERSED    0x0100
+
+/* IFE PHY Special Control */
+#define IFE_PSC_AUTO_POLARITY_DISABLE      0x0010
+#define IFE_PSC_FORCE_POLARITY             0x0020
+#define IFE_PSC_DISABLE_DYNAMIC_POWER_DOWN 0x0100
+
+/* IFE PHY Special Control and LED Control */
+#define IFE_PSCL_PROBE_MODE            0x0020
+#define IFE_PSCL_PROBE_LEDS_OFF        0x0006 /* Force LEDs 0 and 2 off */
+#define IFE_PSCL_PROBE_LEDS_ON         0x0007 /* Force LEDs 0 and 2 on */
+
+/* IFE PHY MDIX Control */
+#define IFE_PMC_MDIX_STATUS      0x0020 /* 1=MDI-X, 0=MDI */
+#define IFE_PMC_FORCE_MDIX       0x0040 /* 1=force MDI-X, 0=force MDI */
+#define IFE_PMC_AUTO_MDIX        0x0080 /* 1=enable auto MDI/MDI-X, 0=disable */
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_regs.h igbvf-0.5.2.orig/src/e1000_regs.h
--- igbvf-0.5.2/src/e1000_regs.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_regs.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,477 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _E1000_REGS_H_
+#define _E1000_REGS_H_
+
+#define E1000_CTRL     0x00000  /* Device Control - RW */
+#define E1000_CTRL_DUP 0x00004  /* Device Control Duplicate (Shadow) - RW */
+#define E1000_STATUS   0x00008  /* Device Status - RO */
+#define E1000_EECD     0x00010  /* EEPROM/Flash Control - RW */
+#define E1000_EERD     0x00014  /* EEPROM Read - RW */
+#define E1000_CTRL_EXT 0x00018  /* Extended Device Control - RW */
+#define E1000_FLA      0x0001C  /* Flash Access - RW */
+#define E1000_MDIC     0x00020  /* MDI Control - RW */
+#define E1000_SCTL     0x00024  /* SerDes Control - RW */
+#define E1000_FCAL     0x00028  /* Flow Control Address Low - RW */
+#define E1000_FCAH     0x0002C  /* Flow Control Address High -RW */
+#define E1000_FEXT     0x0002C  /* Future Extended - RW */
+#define E1000_FEXTNVM  0x00028  /* Future Extended NVM - RW */
+#define E1000_FCT      0x00030  /* Flow Control Type - RW */
+#define E1000_CONNSW   0x00034  /* Copper/Fiber switch control - RW */
+#define E1000_VET      0x00038  /* VLAN Ether Type - RW */
+#define E1000_ICR      0x000C0  /* Interrupt Cause Read - R/clr */
+#define E1000_ITR      0x000C4  /* Interrupt Throttling Rate - RW */
+#define E1000_ICS      0x000C8  /* Interrupt Cause Set - WO */
+#define E1000_IMS      0x000D0  /* Interrupt Mask Set - RW */
+#define E1000_IMC      0x000D8  /* Interrupt Mask Clear - WO */
+#define E1000_IAM      0x000E0  /* Interrupt Acknowledge Auto Mask */
+#define E1000_RCTL     0x00100  /* Rx Control - RW */
+#define E1000_FCTTV    0x00170  /* Flow Control Transmit Timer Value - RW */
+#define E1000_TXCW     0x00178  /* Tx Configuration Word - RW */
+#define E1000_RXCW     0x00180  /* Rx Configuration Word - RO */
+#define E1000_EICR     0x01580  /* Ext. Interrupt Cause Read - R/clr */
+#define E1000_EITR(_n) (0x01680 + (0x4 * (_n)))
+#define E1000_EICS     0x01520  /* Ext. Interrupt Cause Set - W0 */
+#define E1000_EIMS     0x01524  /* Ext. Interrupt Mask Set/Read - RW */
+#define E1000_EIMC     0x01528  /* Ext. Interrupt Mask Clear - WO */
+#define E1000_EIAC     0x0152C  /* Ext. Interrupt Auto Clear - RW */
+#define E1000_EIAM     0x01530  /* Ext. Interrupt Ack Auto Clear Mask - RW */
+#define E1000_GPIE     0x01514  /* General Purpose Interrupt Enable - RW */
+#define E1000_IVAR0    0x01700  /* Interrupt Vector Allocation (array) - RW */
+#define E1000_IVAR_MISC 0x01740 /* IVAR for "other" causes - RW */
+#define E1000_TCTL     0x00400  /* Tx Control - RW */
+#define E1000_TCTL_EXT 0x00404  /* Extended Tx Control - RW */
+#define E1000_TIPG     0x00410  /* Tx Inter-packet gap -RW */
+#define E1000_TBT      0x00448  /* Tx Burst Timer - RW */
+#define E1000_AIT      0x00458  /* Adaptive Interframe Spacing Throttle - RW */
+#define E1000_LEDCTL   0x00E00  /* LED Control - RW */
+#define E1000_EXTCNF_CTRL  0x00F00  /* Extended Configuration Control */
+#define E1000_EXTCNF_SIZE  0x00F08  /* Extended Configuration Size */
+#define E1000_PHY_CTRL     0x00F10  /* PHY Control Register in CSR */
+#define E1000_PBA      0x01000  /* Packet Buffer Allocation - RW */
+#define E1000_PBS      0x01008  /* Packet Buffer Size */
+#define E1000_EEMNGCTL 0x01010  /* MNG EEprom Control */
+#define E1000_EEARBC   0x01024  /* EEPROM Auto Read Bus Control */
+#define E1000_FLASHT   0x01028  /* FLASH Timer Register */
+#define E1000_EEWR     0x0102C  /* EEPROM Write Register - RW */
+#define E1000_FLSWCTL  0x01030  /* FLASH control register */
+#define E1000_FLSWDATA 0x01034  /* FLASH data register */
+#define E1000_FLSWCNT  0x01038  /* FLASH Access Counter */
+#define E1000_FLOP     0x0103C  /* FLASH Opcode Register */
+#define E1000_I2CCMD   0x01028  /* SFPI2C Command Register - RW */
+#define E1000_I2CPARAMS 0x0102C /* SFPI2C Parameters Register - RW */
+#define E1000_WDSTP    0x01040  /* Watchdog Setup - RW */
+#define E1000_SWDSTS   0x01044  /* SW Device Status - RW */
+#define E1000_FRTIMER  0x01048  /* Free Running Timer - RW */
+#define E1000_TCPTIMER 0x0104C  /* TCP Timer - RW */
+#define E1000_VPDDIAG  0x01060  /* VPD Diagnostic - RO */
+#define E1000_ICR_V2   0x01500  /* Interrupt Cause - new location - RC */
+#define E1000_ICS_V2   0x01504  /* Interrupt Cause Set - new location - WO */
+#define E1000_IMS_V2   0x01508  /* Interrupt Mask Set/Read - new location - RW */
+#define E1000_IMC_V2   0x0150C  /* Interrupt Mask Clear - new location - WO */
+#define E1000_IAM_V2   0x01510  /* Interrupt Ack Auto Mask - new location - RW */
+#define E1000_ERT      0x02008  /* Early Rx Threshold - RW */
+#define E1000_FCRTL    0x02160  /* Flow Control Receive Threshold Low - RW */
+#define E1000_FCRTH    0x02168  /* Flow Control Receive Threshold High - RW */
+#define E1000_PSRCTL   0x02170  /* Packet Split Receive Control - RW */
+#define E1000_RDFPCQ(_n)  (0x02430 + (0x4 * (_n)))
+#define E1000_PBRTH    0x02458  /* PB Rx Arbitration Threshold - RW */
+#define E1000_FCRTV    0x02460  /* Flow Control Refresh Timer Value - RW */
+/* Split and Replication Rx Control - RW */
+#define E1000_RDPUMB   0x025CC  /* DMA Rx Descriptor uC Mailbox - RW */
+#define E1000_RDPUAD   0x025D0  /* DMA Rx Descriptor uC Addr Command - RW */
+#define E1000_RDPUWD   0x025D4  /* DMA Rx Descriptor uC Data Write - RW */
+#define E1000_RDPURD   0x025D8  /* DMA Rx Descriptor uC Data Read - RW */
+#define E1000_RDPUCTL  0x025DC  /* DMA Rx Descriptor uC Control - RW */
+#define E1000_PBDIAG   0x02458  /* Packet Buffer Diagnostic - RW */
+#define E1000_RXPBS    0x02404  /* Rx Packet Buffer Size - RW */
+#define E1000_RXCTL(_n)   (0x0C014 + (0x40 * (_n)))
+#define E1000_RQDPC(_n)   (0x0C030 + (0x40 * (_n)))
+#define E1000_TXCTL(_n)   (0x0E014 + (0x40 * (_n)))
+#define E1000_RXCTL(_n)   (0x0C014 + (0x40 * (_n)))
+#define E1000_RQDPC(_n)   (0x0C030 + (0x40 * (_n)))
+#define E1000_RDTR     0x02820  /* Rx Delay Timer - RW */
+#define E1000_RADV     0x0282C  /* Rx Interrupt Absolute Delay Timer - RW */
+/*
+ * Convenience macros
+ *
+ * Note: "_n" is the queue number of the register to be written to.
+ *
+ * Example usage:
+ * E1000_RDBAL_REG(current_rx_queue)
+ */
+#define E1000_RDBAL(_n)      ((_n) < 4 ? (0x02800 + ((_n) * 0x100)) : \
+                                         (0x0C000 + ((_n) * 0x40)))
+#define E1000_RDBAH(_n)      ((_n) < 4 ? (0x02804 + ((_n) * 0x100)) : \
+                                         (0x0C004 + ((_n) * 0x40)))
+#define E1000_RDLEN(_n)      ((_n) < 4 ? (0x02808 + ((_n) * 0x100)) : \
+                                         (0x0C008 + ((_n) * 0x40)))
+#define E1000_SRRCTL(_n)     ((_n) < 4 ? (0x0280C + ((_n) * 0x100)) : \
+                                         (0x0C00C + ((_n) * 0x40)))
+#define E1000_RDH(_n)        ((_n) < 4 ? (0x02810 + ((_n) * 0x100)) : \
+                                         (0x0C010 + ((_n) * 0x40)))
+#define E1000_RDT(_n)        ((_n) < 4 ? (0x02818 + ((_n) * 0x100)) : \
+                                         (0x0C018 + ((_n) * 0x40)))
+#define E1000_RXDCTL(_n)     ((_n) < 4 ? (0x02828 + ((_n) * 0x100)) : \
+                                         (0x0C028 + ((_n) * 0x40)))
+#define E1000_TDBAL(_n)      ((_n) < 4 ? (0x03800 + ((_n) * 0x100)) : \
+                                         (0x0E000 + ((_n) * 0x40)))
+#define E1000_TDBAH(_n)      ((_n) < 4 ? (0x03804 + ((_n) * 0x100)) : \
+                                         (0x0E004 + ((_n) * 0x40)))
+#define E1000_TDLEN(_n)      ((_n) < 4 ? (0x03808 + ((_n) * 0x100)) : \
+                                         (0x0E008 + ((_n) * 0x40)))
+#define E1000_TDH(_n)        ((_n) < 4 ? (0x03810 + ((_n) * 0x100)) : \
+                                         (0x0E010 + ((_n) * 0x40)))
+#define E1000_TDT(_n)        ((_n) < 4 ? (0x03818 + ((_n) * 0x100)) : \
+                                         (0x0E018 + ((_n) * 0x40)))
+#define E1000_TXDCTL(_n)     ((_n) < 4 ? (0x03828 + ((_n) * 0x100)) : \
+                                         (0x0E028 + ((_n) * 0x40)))
+#define E1000_TARC(_n)       (0x03840 + (_n << 8))
+#define E1000_DCA_TXCTRL(_n) (0x03814 + (_n << 8))
+#define E1000_DCA_RXCTRL(_n) (0x02814 + (_n << 8))
+#define E1000_TDWBAL(_n)     ((_n) < 4 ? (0x03838 + ((_n) * 0x100)) : \
+                                         (0x0E038 + ((_n) * 0x40)))
+#define E1000_TDWBAH(_n)     ((_n) < 4 ? (0x0383C + ((_n) * 0x100)) : \
+                                         (0x0E03C + ((_n) * 0x40)))
+#define E1000_RSRPD    0x02C00  /* Rx Small Packet Detect - RW */
+#define E1000_RAID     0x02C08  /* Receive Ack Interrupt Delay - RW */
+#define E1000_TXDMAC   0x03000  /* Tx DMA Control - RW */
+#define E1000_KABGTXD  0x03004  /* AFE Band Gap Transmit Ref Data */
+#define E1000_PSRTYPE(_i)       (0x05480 + ((_i) * 4))
+#define E1000_RAL(_i)  (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : \
+                                       (0x054E0 + ((_i - 16) * 8)))
+#define E1000_RAH(_i)  (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : \
+                                       (0x054E4 + ((_i - 16) * 8)))
+#define E1000_IP4AT_REG(_i)     (0x05840 + ((_i) * 8))
+#define E1000_IP6AT_REG(_i)     (0x05880 + ((_i) * 4))
+#define E1000_WUPM_REG(_i)      (0x05A00 + ((_i) * 4))
+#define E1000_FFMT_REG(_i)      (0x09000 + ((_i) * 8))
+#define E1000_FFVT_REG(_i)      (0x09800 + ((_i) * 8))
+#define E1000_FFLT_REG(_i)      (0x05F00 + ((_i) * 8))
+#define E1000_PBSLAC   0x03100  /* Packet Buffer Slave Access Control */
+#define E1000_PBSLAD(_n)  (0x03110 + (0x4 * (_n)))  /* Packet Buffer DWORD (_n) */
+#define E1000_TXPBS    0x03404  /* Tx Packet Buffer Size - RW */
+#define E1000_TDFH     0x03410  /* Tx Data FIFO Head - RW */
+#define E1000_TDFT     0x03418  /* Tx Data FIFO Tail - RW */
+#define E1000_TDFHS    0x03420  /* Tx Data FIFO Head Saved - RW */
+#define E1000_TDFTS    0x03428  /* Tx Data FIFO Tail Saved - RW */
+#define E1000_TDFPC    0x03430  /* Tx Data FIFO Packet Count - RW */
+#define E1000_TDPUMB   0x0357C  /* DMA Tx Descriptor uC Mail Box - RW */
+#define E1000_TDPUAD   0x03580  /* DMA Tx Descriptor uC Addr Command - RW */
+#define E1000_TDPUWD   0x03584  /* DMA Tx Descriptor uC Data Write - RW */
+#define E1000_TDPURD   0x03588  /* DMA Tx Descriptor uC Data  Read  - RW */
+#define E1000_TDPUCTL  0x0358C  /* DMA Tx Descriptor uC Control - RW */
+#define E1000_DTXCTL   0x03590  /* DMA Tx Control - RW */
+#define E1000_DTXTCPFLGL 0x0359C /* DMA Tx Control flag low - RW */
+#define E1000_DTXTCPFLGH 0x035A0 /* DMA Tx Control flag high - RW */
+#define E1000_DTXMXSZRQ  0x03540 /* DMA Tx Max Total Allow Size Requests - RW */
+#define E1000_TIDV     0x03820  /* Tx Interrupt Delay Value - RW */
+#define E1000_TADV     0x0382C  /* Tx Interrupt Absolute Delay Val - RW */
+#define E1000_TSPMT    0x03830  /* TCP Segmentation PAD & Min Threshold - RW */
+#define E1000_CRCERRS  0x04000  /* CRC Error Count - R/clr */
+#define E1000_ALGNERRC 0x04004  /* Alignment Error Count - R/clr */
+#define E1000_SYMERRS  0x04008  /* Symbol Error Count - R/clr */
+#define E1000_RXERRC   0x0400C  /* Receive Error Count - R/clr */
+#define E1000_MPC      0x04010  /* Missed Packet Count - R/clr */
+#define E1000_SCC      0x04014  /* Single Collision Count - R/clr */
+#define E1000_ECOL     0x04018  /* Excessive Collision Count - R/clr */
+#define E1000_MCC      0x0401C  /* Multiple Collision Count - R/clr */
+#define E1000_LATECOL  0x04020  /* Late Collision Count - R/clr */
+#define E1000_COLC     0x04028  /* Collision Count - R/clr */
+#define E1000_DC       0x04030  /* Defer Count - R/clr */
+#define E1000_TNCRS    0x04034  /* Tx-No CRS - R/clr */
+#define E1000_SEC      0x04038  /* Sequence Error Count - R/clr */
+#define E1000_CEXTERR  0x0403C  /* Carrier Extension Error Count - R/clr */
+#define E1000_RLEC     0x04040  /* Receive Length Error Count - R/clr */
+#define E1000_XONRXC   0x04048  /* XON Rx Count - R/clr */
+#define E1000_XONTXC   0x0404C  /* XON Tx Count - R/clr */
+#define E1000_XOFFRXC  0x04050  /* XOFF Rx Count - R/clr */
+#define E1000_XOFFTXC  0x04054  /* XOFF Tx Count - R/clr */
+#define E1000_FCRUC    0x04058  /* Flow Control Rx Unsupported Count- R/clr */
+#define E1000_PRC64    0x0405C  /* Packets Rx (64 bytes) - R/clr */
+#define E1000_PRC127   0x04060  /* Packets Rx (65-127 bytes) - R/clr */
+#define E1000_PRC255   0x04064  /* Packets Rx (128-255 bytes) - R/clr */
+#define E1000_PRC511   0x04068  /* Packets Rx (255-511 bytes) - R/clr */
+#define E1000_PRC1023  0x0406C  /* Packets Rx (512-1023 bytes) - R/clr */
+#define E1000_PRC1522  0x04070  /* Packets Rx (1024-1522 bytes) - R/clr */
+#define E1000_GPRC     0x04074  /* Good Packets Rx Count - R/clr */
+#define E1000_BPRC     0x04078  /* Broadcast Packets Rx Count - R/clr */
+#define E1000_MPRC     0x0407C  /* Multicast Packets Rx Count - R/clr */
+#define E1000_GPTC     0x04080  /* Good Packets Tx Count - R/clr */
+#define E1000_GORCL    0x04088  /* Good Octets Rx Count Low - R/clr */
+#define E1000_GORCH    0x0408C  /* Good Octets Rx Count High - R/clr */
+#define E1000_GOTCL    0x04090  /* Good Octets Tx Count Low - R/clr */
+#define E1000_GOTCH    0x04094  /* Good Octets Tx Count High - R/clr */
+#define E1000_RNBC     0x040A0  /* Rx No Buffers Count - R/clr */
+#define E1000_RUC      0x040A4  /* Rx Undersize Count - R/clr */
+#define E1000_RFC      0x040A8  /* Rx Fragment Count - R/clr */
+#define E1000_ROC      0x040AC  /* Rx Oversize Count - R/clr */
+#define E1000_RJC      0x040B0  /* Rx Jabber Count - R/clr */
+#define E1000_MGTPRC   0x040B4  /* Management Packets Rx Count - R/clr */
+#define E1000_MGTPDC   0x040B8  /* Management Packets Dropped Count - R/clr */
+#define E1000_MGTPTC   0x040BC  /* Management Packets Tx Count - R/clr */
+#define E1000_TORL     0x040C0  /* Total Octets Rx Low - R/clr */
+#define E1000_TORH     0x040C4  /* Total Octets Rx High - R/clr */
+#define E1000_TOTL     0x040C8  /* Total Octets Tx Low - R/clr */
+#define E1000_TOTH     0x040CC  /* Total Octets Tx High - R/clr */
+#define E1000_TPR      0x040D0  /* Total Packets Rx - R/clr */
+#define E1000_TPT      0x040D4  /* Total Packets Tx - R/clr */
+#define E1000_PTC64    0x040D8  /* Packets Tx (64 bytes) - R/clr */
+#define E1000_PTC127   0x040DC  /* Packets Tx (65-127 bytes) - R/clr */
+#define E1000_PTC255   0x040E0  /* Packets Tx (128-255 bytes) - R/clr */
+#define E1000_PTC511   0x040E4  /* Packets Tx (256-511 bytes) - R/clr */
+#define E1000_PTC1023  0x040E8  /* Packets Tx (512-1023 bytes) - R/clr */
+#define E1000_PTC1522  0x040EC  /* Packets Tx (1024-1522 Bytes) - R/clr */
+#define E1000_MPTC     0x040F0  /* Multicast Packets Tx Count - R/clr */
+#define E1000_BPTC     0x040F4  /* Broadcast Packets Tx Count - R/clr */
+#define E1000_TSCTC    0x040F8  /* TCP Segmentation Context Tx - R/clr */
+#define E1000_TSCTFC   0x040FC  /* TCP Segmentation Context Tx Fail - R/clr */
+#define E1000_IAC      0x04100  /* Interrupt Assertion Count */
+#define E1000_ICRXPTC  0x04104  /* Interrupt Cause Rx Pkt Timer Expire Count */
+#define E1000_ICRXATC  0x04108  /* Interrupt Cause Rx Abs Timer Expire Count */
+#define E1000_ICTXPTC  0x0410C  /* Interrupt Cause Tx Pkt Timer Expire Count */
+#define E1000_ICTXATC  0x04110  /* Interrupt Cause Tx Abs Timer Expire Count */
+#define E1000_ICTXQEC  0x04118  /* Interrupt Cause Tx Queue Empty Count */
+#define E1000_ICTXQMTC 0x0411C  /* Interrupt Cause Tx Queue Min Thresh Count */
+#define E1000_ICRXDMTC 0x04120  /* Interrupt Cause Rx Desc Min Thresh Count */
+#define E1000_ICRXOC   0x04124  /* Interrupt Cause Receiver Overrun Count */
+
+#define E1000_VFGPRC   0x00F10
+#define E1000_VFGORC   0x00F18
+#define E1000_VFMPRC   0x00F3C
+#define E1000_VFGPTC   0x00F14
+#define E1000_VFGOTC   0x00F34
+#define E1000_VFGOTLBC 0x00F50
+#define E1000_VFGPTLBC 0x00F44
+#define E1000_VFGORLBC 0x00F48
+#define E1000_VFGPRLBC 0x00F40
+#define E1000_LSECTXUT        0x04300  /* LinkSec Tx Untagged Packet Count - OutPktsUntagged */
+#define E1000_LSECTXPKTE      0x04304  /* LinkSec Encrypted Tx Packets Count - OutPktsEncrypted */
+#define E1000_LSECTXPKTP      0x04308  /* LinkSec Protected Tx Packet Count - OutPktsProtected */
+#define E1000_LSECTXOCTE      0x0430C  /* LinkSec Encrypted Tx Octets Count - OutOctetsEncrypted */
+#define E1000_LSECTXOCTP      0x04310  /* LinkSec Protected Tx Octets Count - OutOctetsProtected */
+#define E1000_LSECRXUT        0x04314  /* LinkSec Untagged non-Strict Rx Packet Count - InPktsUntagged/InPktsNoTag */
+#define E1000_LSECRXOCTD      0x0431C  /* LinkSec Rx Octets Decrypted Count - InOctetsDecrypted */
+#define E1000_LSECRXOCTV      0x04320  /* LinkSec Rx Octets Validated - InOctetsValidated */
+#define E1000_LSECRXBAD       0x04324  /* LinkSec Rx Bad Tag - InPktsBadTag */
+#define E1000_LSECRXNOSCI     0x04328  /* LinkSec Rx Packet No SCI Count - InPktsNoSci */
+#define E1000_LSECRXUNSCI     0x0432C  /* LinkSec Rx Packet Unknown SCI Count - InPktsUnknownSci */
+#define E1000_LSECRXUNCH      0x04330  /* LinkSec Rx Unchecked Packets Count - InPktsUnchecked */
+#define E1000_LSECRXDELAY     0x04340  /* LinkSec Rx Delayed Packet Count - InPktsDelayed */
+#define E1000_LSECRXLATE      0x04350  /* LinkSec Rx Late Packets Count - InPktsLate */
+#define E1000_LSECRXOK(_n)    (0x04360 + (0x04 * (_n))) /* LinkSec Rx Packet OK Count - InPktsOk */
+#define E1000_LSECRXINV(_n)   (0x04380 + (0x04 * (_n))) /* LinkSec Rx Invalid Count - InPktsInvalid */
+#define E1000_LSECRXNV(_n)    (0x043A0 + (0x04 * (_n))) /* LinkSec Rx Not Valid Count - InPktsNotValid */
+#define E1000_LSECRXUNSA      0x043C0  /* LinkSec Rx Unused SA Count - InPktsUnusedSa */
+#define E1000_LSECRXNUSA      0x043D0  /* LinkSec Rx Not Using SA Count - InPktsNotUsingSa */
+#define E1000_LSECTXCAP       0x0B000  /* LinkSec Tx Capabilities Register - RO */
+#define E1000_LSECRXCAP       0x0B300  /* LinkSec Rx Capabilities Register - RO */
+#define E1000_LSECTXCTRL      0x0B004  /* LinkSec Tx Control - RW */
+#define E1000_LSECRXCTRL      0x0B304  /* LinkSec Rx Control - RW */
+#define E1000_LSECTXSCL       0x0B008  /* LinkSec Tx SCI Low - RW */
+#define E1000_LSECTXSCH       0x0B00C  /* LinkSec Tx SCI High - RW */
+#define E1000_LSECTXSA        0x0B010  /* LinkSec Tx SA0 - RW */
+#define E1000_LSECTXPN0       0x0B018  /* LinkSec Tx SA PN 0 - RW */
+#define E1000_LSECTXPN1       0x0B01C  /* LinkSec Tx SA PN 1 - RW */
+#define E1000_LSECRXSCL       0x0B3D0  /* LinkSec Rx SCI Low - RW */
+#define E1000_LSECRXSCH       0x0B3E0  /* LinkSec Rx SCI High - RW */
+#define E1000_LSECTXKEY0(_n)  (0x0B020 + (0x04 * (_n))) /* LinkSec Tx 128-bit Key 0 - WO */
+#define E1000_LSECTXKEY1(_n)  (0x0B030 + (0x04 * (_n))) /* LinkSec Tx 128-bit Key 1 - WO */
+#define E1000_LSECRXSA(_n)    (0x0B310 + (0x04 * (_n))) /* LinkSec Rx SAs - RW */
+#define E1000_LSECRXPN(_n)    (0x0B330 + (0x04 * (_n))) /* LinkSec Rx SAs - RW */
+/*
+ * LinkSec Rx Keys  - where _n is the SA no. and _m the 4 dwords of the 128 bit
+ * key - RW.
+ */
+#define E1000_LSECRXKEY(_n, _m) (0x0B350 + (0x10 * (_n)) + (0x04 * (_m)))
+
+#define E1000_SSVPC             0x041A0  /* Switch Security Violation Packet Count */
+#define E1000_IPSCTRL           0xB430   /* IpSec Control Register */
+#define E1000_IPSRXCMD          0x0B408  /* IPSec Rx Command Register - RW */
+#define E1000_IPSRXIDX          0x0B400  /* IPSec Rx Index - RW */
+#define E1000_IPSRXIPADDR(_n)   (0x0B420+ (0x04 * (_n)))  /* IPSec Rx IPv4/v6 Address - RW */
+#define E1000_IPSRXKEY(_n)      (0x0B410 + (0x04 * (_n))) /* IPSec Rx 128-bit Key - RW */
+#define E1000_IPSRXSALT         0x0B404  /* IPSec Rx Salt - RW */
+#define E1000_IPSRXSPI          0x0B40C  /* IPSec Rx SPI - RW */
+#define E1000_IPSTXKEY(_n)      (0x0B460 + (0x04 * (_n))) /* IPSec Tx 128-bit Key - RW */
+#define E1000_IPSTXSALT         0x0B454  /* IPSec Tx Salt - RW */
+#define E1000_IPSTXIDX          0x0B450  /* IPSec Tx SA IDX - RW */
+#define E1000_PCS_CFG0    0x04200  /* PCS Configuration 0 - RW */
+#define E1000_PCS_LCTL    0x04208  /* PCS Link Control - RW */
+#define E1000_PCS_LSTAT   0x0420C  /* PCS Link Status - RO */
+#define E1000_CBTMPC      0x0402C  /* Circuit Breaker Tx Packet Count */
+#define E1000_HTDPMC      0x0403C  /* Host Transmit Discarded Packets */
+#define E1000_CBRDPC      0x04044  /* Circuit Breaker Rx Dropped Count */
+#define E1000_CBRMPC      0x040FC  /* Circuit Breaker Rx Packet Count */
+#define E1000_RPTHC       0x04104  /* Rx Packets To Host */
+#define E1000_HGPTC       0x04118  /* Host Good Packets Tx Count */
+#define E1000_HTCBDPC     0x04124  /* Host Tx Circuit Breaker Dropped Count */
+#define E1000_HGORCL      0x04128  /* Host Good Octets Received Count Low */
+#define E1000_HGORCH      0x0412C  /* Host Good Octets Received Count High */
+#define E1000_HGOTCL      0x04130  /* Host Good Octets Transmit Count Low */
+#define E1000_HGOTCH      0x04134  /* Host Good Octets Transmit Count High */
+#define E1000_LENERRS     0x04138  /* Length Errors Count */
+#define E1000_SCVPC       0x04228  /* SerDes/SGMII Code Violation Pkt Count */
+#define E1000_HRMPC       0x0A018  /* Header Redirection Missed Packet Count */
+#define E1000_PCS_ANADV   0x04218  /* AN advertisement - RW */
+#define E1000_PCS_LPAB    0x0421C  /* Link Partner Ability - RW */
+#define E1000_PCS_NPTX    0x04220  /* AN Next Page Transmit - RW */
+#define E1000_PCS_LPABNP  0x04224  /* Link Partner Ability Next Page - RW */
+#define E1000_1GSTAT_RCV  0x04228  /* 1GSTAT Code Violation Packet Count - RW */
+#define E1000_RXCSUM   0x05000  /* Rx Checksum Control - RW */
+#define E1000_RLPML    0x05004  /* Rx Long Packet Max Length */
+#define E1000_RFCTL    0x05008  /* Receive Filter Control*/
+#define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
+#define E1000_RA       0x05400  /* Receive Address - RW Array */
+#define E1000_RA2      0x054E0  /* 2nd half of receive address array - RW Array */
+#define E1000_VFTA     0x05600  /* VLAN Filter Table Array - RW Array */
+#define E1000_VT_CTL   0x0581C  /* VMDq Control - RW */
+#define E1000_VFQA0    0x0B000  /* VLAN Filter Queue Array 0 - RW Array */
+#define E1000_VFQA1    0x0B200  /* VLAN Filter Queue Array 1 - RW Array */
+#define E1000_WUC      0x05800  /* Wakeup Control - RW */
+#define E1000_WUFC     0x05808  /* Wakeup Filter Control - RW */
+#define E1000_WUS      0x05810  /* Wakeup Status - RO */
+#define E1000_MANC     0x05820  /* Management Control - RW */
+#define E1000_IPAV     0x05838  /* IP Address Valid - RW */
+#define E1000_IP4AT    0x05840  /* IPv4 Address Table - RW Array */
+#define E1000_IP6AT    0x05880  /* IPv6 Address Table - RW Array */
+#define E1000_WUPL     0x05900  /* Wakeup Packet Length - RW */
+#define E1000_WUPM     0x05A00  /* Wakeup Packet Memory - RO A */
+#define E1000_PBACL    0x05B68  /* MSIx PBA Clear - Read/Write 1's to clear */
+#define E1000_FFLT     0x05F00  /* Flexible Filter Length Table - RW Array */
+#define E1000_HOST_IF  0x08800  /* Host Interface */
+#define E1000_FFMT     0x09000  /* Flexible Filter Mask Table - RW Array */
+#define E1000_FFVT     0x09800  /* Flexible Filter Value Table - RW Array */
+#define E1000_FHFT(_n)  (0x09000 + (_n * 0x100)) /* Flexible Host Filter Table */
+#define E1000_FHFT_EXT(_n) (0x09A00 + (_n * 0x100)) /* Ext Flexible Host Filter Table */
+
+
+#define E1000_KMRNCTRLSTA 0x00034 /* MAC-PHY interface - RW */
+#define E1000_MDPHYA      0x0003C /* PHY address - RW */
+#define E1000_MANC2H      0x05860 /* Management Control To Host - RW */
+#define E1000_SW_FW_SYNC  0x05B5C /* Software-Firmware Synchronization - RW */
+#define E1000_CCMCTL      0x05B48 /* CCM Control Register */
+#define E1000_GIOCTL      0x05B44 /* GIO Analog Control Register */
+#define E1000_SCCTL       0x05B4C /* PCIc PLL Configuration Register */
+#define E1000_GCR         0x05B00 /* PCI-Ex Control */
+#define E1000_GSCL_1    0x05B10 /* PCI-Ex Statistic Control #1 */
+#define E1000_GSCL_2    0x05B14 /* PCI-Ex Statistic Control #2 */
+#define E1000_GSCL_3    0x05B18 /* PCI-Ex Statistic Control #3 */
+#define E1000_GSCL_4    0x05B1C /* PCI-Ex Statistic Control #4 */
+#define E1000_FACTPS    0x05B30 /* Function Active and Power State to MNG */
+#define E1000_SWSM      0x05B50 /* SW Semaphore */
+#define E1000_FWSM      0x05B54 /* FW Semaphore */
+#define E1000_DCA_ID    0x05B70 /* DCA Requester ID Information - RO */
+#define E1000_DCA_CTRL  0x05B74 /* DCA Control - RW */
+#define E1000_FFLT_DBG  0x05F04 /* Debug Register */
+#define E1000_HICR      0x08F00 /* Host Interface Control */
+
+/* RSS registers */
+#define E1000_CPUVEC    0x02C10 /* CPU Vector Register - RW */
+#define E1000_MRQC      0x05818 /* Multiple Receive Control - RW */
+#define E1000_IMIR(_i)      (0x05A80 + ((_i) * 4))  /* Immediate Interrupt */
+#define E1000_IMIREXT(_i)   (0x05AA0 + ((_i) * 4))  /* Immediate Interrupt Ext*/
+#define E1000_IMIRVP    0x05AC0 /* Immediate Interrupt Rx VLAN Priority - RW */
+#define E1000_MSIXBM(_i)    (0x01600 + ((_i) * 4)) /* MSI-X Allocation Register
+                                                    * (_i) - RW */
+#define E1000_MSIXTADD(_i)  (0x0C000 + ((_i) * 0x10)) /* MSI-X Table entry addr
+                                                       * low reg - RW */
+#define E1000_MSIXTUADD(_i) (0x0C004 + ((_i) * 0x10)) /* MSI-X Table entry addr
+                                                       * upper reg - RW */
+#define E1000_MSIXTMSG(_i)  (0x0C008 + ((_i) * 0x10)) /* MSI-X Table entry
+                                                       * message reg - RW */
+#define E1000_MSIXVCTRL(_i) (0x0C00C + ((_i) * 0x10)) /* MSI-X Table entry
+                                                       * vector ctrl reg - RW */
+#define E1000_MSIXPBA    0x0E000 /* MSI-X Pending bit array */
+#define E1000_RETA(_i)  (0x05C00 + ((_i) * 4)) /* Redirection Table - RW */
+#define E1000_RSSRK(_i) (0x05C80 + ((_i) * 4)) /* RSS Random Key - RW */
+#define E1000_RSSIM     0x05864 /* RSS Interrupt Mask */
+#define E1000_RSSIR     0x05868 /* RSS Interrupt Request */
+/* VT Registers */
+#define E1000_SWPBS     0x03004 /* Switch Packet Buffer Size - RW */
+#define E1000_MBVFICR   0x00C80 /* Mailbox VF Cause - RWC */
+#define E1000_MBVFIMR   0x00C84 /* Mailbox VF int Mask - RW */
+#define E1000_VFLRE     0x00C88 /* VF Register Events - RWC */
+#define E1000_VFRE      0x00C8C /* VF Receive Enables */
+#define E1000_VFTE      0x00C90 /* VF Transmit Enables */
+#define E1000_QDE       0x02408 /* Queue Drop Enable - RW */
+#define E1000_DTXSWC    0x03500 /* DMA Tx Switch Control - RW */
+#define E1000_RPLOLR    0x05AF0 /* Replication Offload - RW */
+#define E1000_UTA       0x0A000 /* Unicast Table Array - RW */
+#define E1000_IOVTCL    0x05BBC /* IOV Control Register */
+#define E1000_VMRCTL    0X05D80 /* Virtual Mirror Rule Control */
+/* These act per VF so an array friendly macro is used */
+#define E1000_V2PMAILBOX(_n)   (0x00C40 + (4 * (_n)))
+#define E1000_P2VMAILBOX(_n)   (0x00C00 + (4 * (_n)))
+#define E1000_VMBMEM(_n)       (0x00800 + (64 * (_n)))
+#define E1000_VFVMBMEM(_n)     (0x00800 + (_n))
+#define E1000_VMOLR(_n)        (0x05AD0 + (4 * (_n)))
+#define E1000_VLVF(_n)         (0x05D00 + (4 * (_n))) /* VLAN Virtual Machine
+                                                       * Filter - RW */
+
+/* Filtering Registers */
+#define E1000_SAQF(_n)  (0x05980 + (4 * (_n))) /* Source Address Queue Fltr */
+#define E1000_DAQF(_n)  (0x059A0 + (4 * (_n))) /* Dest Address Queue Fltr */
+#define E1000_SPQF(_n)  (0x059C0 + (4 * (_n))) /* Source Port Queue Fltr */
+#define E1000_FTQF(_n)  (0x059E0 + (4 * (_n))) /* 5-tuple Queue Fltr */
+#define E1000_SYNQF(_n) (0x055FC + (4 * (_n))) /* SYN Packet Queue Fltr */
+#define E1000_ETQF(_n)  (0x05CB0 + (4 * (_n))) /* EType Queue Fltr */
+
+#define E1000_RTTDCS            0x3600  /* Reedtown Tx Desc plane control and status */
+#define E1000_RTTPCS            0x3474  /* Reedtown Tx Packet Plane control and status */
+#define E1000_RTRPCS            0x2474  /* Rx packet plane control and status */
+#define E1000_RTRUP2TC          0x05AC4 /* Rx User Priority to Traffic Class */
+#define E1000_RTTUP2TC          0x0418  /* Transmit User Priority to Traffic Class */
+#define E1000_RTTDTCRC(_n)      (0x3610 + ((_n) * 4)) /* Tx Desc plane TC Rate-scheduler config */
+#define E1000_RTTPTCRC(_n)      (0x3480 + ((_n) * 4)) /* Tx Packet plane TC Rate-Scheduler Config */
+#define E1000_RTRPTCRC(_n)      (0x2480 + ((_n) * 4)) /* Rx Packet plane TC Rate-Scheduler Config */
+#define E1000_RTTDTCRS(_n)      (0x3630 + ((_n) * 4)) /* Tx Desc Plane TC Rate-Scheduler Status */
+#define E1000_RTTDTCRM(_n)      (0x3650 + ((_n) * 4)) /* Tx Desc Plane TC Rate-Scheduler MMW */
+#define E1000_RTTPTCRS(_n)      (0x34A0 + ((_n) * 4)) /* Tx Packet plane TC Rate-Scheduler Status */
+#define E1000_RTTPTCRM(_n)      (0x34C0 + ((_n) * 4)) /* Tx Packet plane TC Rate-scheduler MMW */
+#define E1000_RTRPTCRS(_n)      (0x24A0 + ((_n) * 4)) /* Rx Packet plane TC Rate-Scheduler Status */
+#define E1000_RTRPTCRM(_n)      (0x24C0 + ((_n) * 4)) /* Rx Packet plane TC Rate-Scheduler MMW */
+#define E1000_RTTDVMRM(_n)      (0x3670 + ((_n) * 4)) /* Tx Desc plane VM Rate-Scheduler MMW*/
+#define E1000_RTTBCNRM(_n)      (0x3690 + ((_n) * 4)) /* Tx BCN Rate-Scheduler MMW */
+#define E1000_RTTDQSEL          0x3604  /* Tx Desc Plane Queue Select */
+#define E1000_RTTDVMRC          0x3608  /* Tx Desc Plane VM Rate-Scheduler Config */
+#define E1000_RTTDVMRS          0x360C  /* Tx Desc Plane VM Rate-Scheduler Status */
+#define E1000_RTTBCNRC          0x36B0  /* Tx BCN Rate-Scheduler Config */
+#define E1000_RTTBCNRS          0x36B4  /* Tx BCN Rate-Scheduler Status */
+#define E1000_RTTBCNCR          0xB200  /* Tx BCN Control Register */
+#define E1000_RTTBCNTG          0x35A4  /* Tx BCN Tagging */
+#define E1000_RTTBCNCP          0xB208  /* Tx BCN Congestion point */
+#define E1000_RTRBCNCR          0xB20C  /* Rx BCN Control Register */
+#define E1000_RTTBCNRD          0x36B8  /* Tx BCN Rate Drift */
+#define E1000_PFCTOP            0x1080  /* Priority Flow Control Type and Opcode */
+#define E1000_RTTBCNIDX         0xB204  /* Tx BCN Congestion Point */
+#define E1000_RTTBCNACH         0x0B214 /* Tx BCN Control High */
+#define E1000_RTTBCNACL         0x0B210 /* Tx BCN Control Low */
+
+#endif
diff -Npur igbvf-0.5.2/src/e1000_vf.c igbvf-0.5.2.orig/src/e1000_vf.c
--- igbvf-0.5.2/src/e1000_vf.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/e1000_vf.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,821 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+
+#include "e1000_hw.h"
+#include "e1000_82575.h"
+
+
+static s32       e1000_init_phy_params_vf(struct e1000_hw *hw);
+static s32       e1000_init_nvm_params_vf(struct e1000_hw *hw);
+static s32       e1000_init_mac_params_vf(struct e1000_hw *hw);
+static s32       e1000_get_bus_info_pcie_vf(struct e1000_hw *hw);
+static s32       e1000_check_for_link_vf(struct e1000_hw *hw);
+static s32       e1000_get_link_up_info_vf(struct e1000_hw *hw, u16 *speed,
+                                              u16 *duplex);
+static s32       e1000_setup_link_vf(struct e1000_hw *hw);
+static s32       e1000_init_hw_vf(struct e1000_hw *hw);
+static s32       e1000_reset_hw_vf(struct e1000_hw *hw);
+
+static void      e1000_release_vf(struct e1000_hw *hw);
+static s32       e1000_acquire_vf(struct e1000_hw *hw);
+static void      e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
+                                              u8 *mc_addr_list,
+                                              u32 mc_addr_count,
+                                              u32 rar_used_count,
+                                              u32 rar_count);
+
+/**
+ *  e1000_init_phy_params_vf - Inits PHY params
+ *  @hw: pointer to the HW structure
+ *
+ *  Doesn't do much - there's no PHY available to the VF.
+ **/
+static s32 e1000_init_phy_params_vf(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_init_phy_params_vf");
+	hw->phy.type = e1000_phy_vf;
+	hw->phy.ops.acquire = e1000_acquire_vf;
+	hw->phy.ops.release = e1000_release_vf;
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_init_nvm_params_vf - Inits NVM params
+ *  @hw: pointer to the HW structure
+ *
+ *  Doesn't do much - there's no NVM available to the VF.
+ **/
+static s32 e1000_init_nvm_params_vf(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_init_nvm_params_vf");
+	hw->nvm.type = e1000_nvm_none;
+	hw->nvm.ops.acquire = e1000_acquire_vf;
+	hw->nvm.ops.release = e1000_release_vf;
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_init_mac_params_vf - Inits MAC params
+ *  @hw: pointer to the HW structure
+ **/
+static s32 e1000_init_mac_params_vf(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+
+	DEBUGFUNC("e1000_init_mac_params_vf");
+
+	/* Set media type */
+	/*
+	 * Virtual functions don't care what they're media type is as they
+	 * have no direct access to the PHY, or the media.  That is handled
+	 * by the physical function driver.
+	 */
+	hw->phy.media_type = e1000_media_type_unknown;
+
+	/* VF's have no MTA Registers - PF feature only */
+	mac->mta_reg_count = 0;
+	/* VF's have no access to RAR entries  */
+	mac->rar_entry_count = 0;
+	/* No ASF features for the VF driver */
+	mac->asf_firmware_present = false;
+	/* No manageability features for the VF driver */
+	mac->arc_subsystem_valid = false;
+	/* Disable adaptive IFS mode so the generic funcs don't do anything */
+	mac->adaptive_ifs = false;
+
+	/* Function pointers */
+
+	/* bus type/speed/width */
+	mac->ops.get_bus_info = e1000_get_bus_info_pcie_vf;
+	/* reset */
+	mac->ops.reset_hw = e1000_reset_hw_vf;
+	/* hw initialization */
+	mac->ops.init_hw = e1000_init_hw_vf;
+	/* link setup */
+	mac->ops.setup_link = e1000_setup_link_vf;
+	/* check for link */
+	mac->ops.check_for_link = e1000_check_for_link_vf;
+	/* link info */
+	mac->ops.get_link_up_info = e1000_get_link_up_info_vf;
+
+	/* multicast address update */
+	mac->ops.update_mc_addr_list = e1000_update_mc_addr_list_vf;
+
+
+	return E1000_SUCCESS;
+}
+
+
+/**
+ *  e1000_acquire_vf - Acquire rights to access PHY or NVM.
+ *  @hw: pointer to the HW structure
+ *
+ *  There is no PHY or NVM so we want all attempts to acquire these to fail.
+ *  In addition, the MAC registers to access PHY/NVM don't exist so we don't
+ *  even want any SW to attempt to use them.
+ **/
+static s32 e1000_acquire_vf(struct e1000_hw *hw)
+{
+	return -E1000_ERR_PHY;
+}
+
+/**
+ *  e1000_release_vf - Release PHY or NVM
+ *  @hw: pointer to the HW structure
+ *
+ *  There is no PHY or NVM so we want all attempts to acquire these to fail.
+ *  In addition, the MAC registers to access PHY/NVM don't exist so we don't
+ *  even want any SW to attempt to use them.
+ **/
+static void e1000_release_vf(struct e1000_hw *hw)
+{
+	return;
+}
+
+/**
+ *  e1000_init_function_pointers_vf - Inits function pointers
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_init_function_pointers_vf(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_init_function_pointers_vf");
+
+	hw->mac.ops.init_params = e1000_init_mac_params_vf;
+	hw->nvm.ops.init_params = e1000_init_nvm_params_vf;
+	hw->phy.ops.init_params = e1000_init_phy_params_vf;
+}
+
+/**
+ *  e1000_get_bus_info_pcie_vf - Gets the bus info.
+ *  @hw: pointer to the HW structure
+ *
+ *  Virtual functions are not really on their own bus.
+ **/
+static s32 e1000_get_bus_info_pcie_vf(struct e1000_hw *hw)
+{
+	struct e1000_bus_info *bus = &hw->bus;
+
+	DEBUGFUNC("e1000_get_bus_info_pcie_vf");
+
+	/* Do not set type PCI-E because we don't want disable master to run */
+	bus->type = e1000_bus_type_reserved;
+	bus->speed = e1000_bus_speed_2500;
+
+	return 0;
+}
+
+/**
+ *  e1000_setup_link_vf - Sets up link.
+ *  @hw: pointer to the HW structure
+ *
+ *  Virtual functions cannot change link.
+ **/
+static s32 e1000_setup_link_vf(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_setup_link_vf");
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_get_link_up_info_vf - Gets link info.
+ *  @hw: pointer to the HW structure
+ *  @speed: pointer to 16 bit value to store link speed.
+ *  @duplex: pointer to 16 bit value to store duplex.
+ *
+ *  Since we cannot read the PHY and get accurate link info, we must rely upon
+ *  the status register's data which is often stale and inaccurate.
+ **/
+static s32 e1000_get_link_up_info_vf(struct e1000_hw *hw, u16 *speed,
+                                     u16 *duplex)
+{
+	s32 ret_val;
+
+	DEBUGFUNC("e1000_get_link_up_info_vf");
+
+	ret_val = e1000_get_speed_and_duplex_copper_generic(hw, speed,
+	                                                    duplex);
+	return ret_val;
+}
+
+/**
+ *  e1000_check_for_link_vf - Checks for link
+ *  @hw: pointer to the HW structure
+ *
+ *  Since we cannot do anything with link configuration, we just set the
+ *  get_link_status to false and exit.
+ **/
+static s32 e1000_check_for_link_vf(struct e1000_hw *hw)
+{
+	DEBUGFUNC("e1000_check_for_link_vf");
+	hw->mac.get_link_status = false;
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_reset_hw_vf - Resets the HW
+ *  @hw: pointer to the HW structure
+ *
+ *  VF's provide a function level reset. This is done using bit 26 of ctrl_reg.
+ *  This is all the reset we can perform on a VF.
+ **/
+static s32 e1000_reset_hw_vf(struct e1000_hw *hw)
+{
+	u32 ctrl;
+
+	DEBUGFUNC("e1000_reset_hw_vf");
+
+	ctrl = E1000_READ_REG(hw, E1000_CTRL);
+
+	DEBUGOUT("Issuing a function level reset to MAC\n");
+	E1000_WRITE_REG(hw, E1000_CTRL, ctrl | E1000_CTRL_RST);
+	usec_delay(100);
+
+	return E1000_SUCCESS;
+}
+
+/**
+ *  e1000_init_hw_vf - Inits the HW
+ *  @hw: pointer to the HW structure
+ *
+ *  Not much to do here except clear the PF Reset indication if there is one.
+ **/
+static s32 e1000_init_hw_vf(struct e1000_hw *hw)
+{
+	u32 v2p_mailbox = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_init_hw_vf");
+
+        /* Check for RSTI and take steps to clear... */
+        if (v2p_mailbox & E1000_V2PMAILBOX_RSTI) {
+		v2p_mailbox = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+		if ((v2p_mailbox & E1000_V2PMAILBOX_RSTI) != 0) {
+			/* Error Condition */
+			ret_val = -1;
+            }
+        }
+
+	return ret_val;
+}
+
+/**
+ *  e1000_update_mc_addr_list_vf - Update Multicast addresses
+ *  @hw: pointer to the HW structure
+ *  @mc_addr_list: array of multicast addresses to program
+ *  @mc_addr_count: number of multicast addresses to program
+ *  @rar_used_count: the first RAR register free to program
+ *  @rar_count: total number of supported Receive Address Registers
+ *
+ *  Updates the Receive Address Registers and Multicast Table Array.
+ *  The caller must have a packed mc_addr_list of multicast addresses.
+ *  The parameter rar_count will usually be hw->mac.rar_entry_count
+ *  unless there are workarounds that change this.
+ **/
+void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
+                                  u8 *mc_addr_list, u32 mc_addr_count,
+                                  u32 rar_used_count, u32 rar_count)
+{
+	u32 msgbuf[E1000_VFMAILBOX_SIZE];
+	u32 cnt;
+	u32 i;
+	u8 *p;
+
+	DEBUGFUNC("e1000_update_mc_addr_list_vf");
+
+	/* Each entry in the list uses 1.5 32 bit words.  We have 15
+	 * 32 bit words available in our HW msg buffer (minus 1 for the
+	 * msg type).  That's 10 addresses if we pack 'em right.  If
+	 * there are more than 10 MC addresses to add then punt the
+	 * extras for now and then add code to handle more than 10 later.
+	 * It would be unusual for a server to request that many multi-cast
+	 * addresses except for in large enterprise network environments.
+	 */
+
+	DEBUGOUT1("MC Addr Count = %d\n", mc_addr_count);
+
+	cnt = (mc_addr_count > 10) ? 10 : mc_addr_count;
+	msgbuf[0] = E1000_VF_SET_MULTICAST;
+	msgbuf[0] |= cnt << E1000_VT_MSGINFO_SHIFT;
+	p = (u8 *)&msgbuf[1];
+
+	for (i = 0; i < cnt; i++) {
+		memcpy(p, &mc_addr_list[i * 6], 6);
+		p += 6;
+	}
+
+	e1000_send_mail_to_pf_vf(hw, msgbuf, E1000_VFMAILBOX_SIZE);
+}
+
+/**
+ *  e1000_send_mail_to_pf_vf - Sends a mailbox message from VF to PF
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ **/
+s32 e1000_send_mail_to_pf_vf(struct e1000_hw *hw, u32 *msg, s16 size)
+{
+	u32 v2p_mailbox = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+	s32 ret_val = E1000_SUCCESS;
+	s16 i;
+
+	/*
+	 * What happens if you enter this function and PFSTS is set?  From
+	 * my thinking it should be an error, but obviously that means an
+	 * event was missed and the message should be stored somewhere.
+	 * but where?  Or maybe it should just be dropped on the floor?
+	 * I'll have to think 'pon it some more
+	 */
+
+	/*
+	 * if any of the indicated bits are set then there has been a
+	 * programming error or the PF has been reset underneath the feet
+	 * of the VF
+	 */
+	if (v2p_mailbox & (E1000_V2PMAILBOX_PFU |
+	                   E1000_V2PMAILBOX_PFSTS |
+	                   E1000_V2PMAILBOX_RSTI)) {
+		ret_val = -1;
+		goto out;
+	} else {
+		/* Take ownership of the buffer */
+		v2p_mailbox |= E1000_V2PMAILBOX_VFU;
+		E1000_WRITE_REG(hw, E1000_V2PMAILBOX(0), v2p_mailbox);
+		/* Make sure we have ownership now... */
+		if (v2p_mailbox & E1000_V2PMAILBOX_PFU) {
+			/*
+			 * oops, PF grabbed ownership while we were attempting
+			 * to take ownership - avoid the race condition
+			 */
+			ret_val = -1;
+			goto out;
+		}
+	}
+
+	/*
+	 * At this point we have established ownership of the VF mailbox memory
+	 * buffer.  IT IS IMPORTANT THAT THIS OWNERSHIP BE GIVEN UP!  Whether
+	 * success or failure, the VF ownership bit must be cleared before
+	 * exiting this function - so if you change this function keep that
+	 * in mind
+	 */
+
+	/* check for overflow */
+	if (size > E1000_VFMAILBOX_SIZE) {
+		ret_val = -1;
+		goto out;
+	}
+
+	/*
+	 * copy the caller specified message to the mailbox
+	 * memory buffer
+	 */
+	for (i = 0; i < size; i++) {
+		E1000_WRITE_REG(hw, E1000_VFVMBMEM(i * 4), msg[i]);
+	}
+
+	/* Interrupt the PF to tell it a message has been sent */
+	/*
+	 * The PF request bit is write only and will be read back
+	 * as zero on the next register read below - thus no need
+	 * to programmatically clear it
+	 */
+	v2p_mailbox |= E1000_V2PMAILBOX_REQ;
+	E1000_WRITE_REG(hw, E1000_V2PMAILBOX(0), v2p_mailbox);
+
+out:
+	/* Clear the VF mail box memory buffer ownership bit */
+	v2p_mailbox &= ~(E1000_V2PMAILBOX_VFU | E1000_V2PMAILBOX_REQ);
+
+	/* Clear VF ownership of the mail box memory buffer */
+	E1000_WRITE_REG(hw, E1000_V2PMAILBOX(0), v2p_mailbox);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_check_for_pf_ack_vf - checks to see if the PF has ACK'd
+ *  @hw: pointer to the HW structure
+ *
+ *  returns true if the PF has set the ACK bit or else false
+ **/
+bool e1000_check_for_pf_ack_vf(struct e1000_hw *hw)
+{
+	u32 v2p_mailbox = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+	bool ret_val = false;
+
+	if ((v2p_mailbox & E1000_V2PMAILBOX_PFACK)) {
+		ret_val = true;
+	}
+
+	return ret_val;
+}
+
+/**
+ *  e1000_receive_mail_from_pf_vf - Receives a mailbox message from PF to VF
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @size: Length of buffer
+ **/
+s32 e1000_receive_mail_from_pf_vf(struct e1000_hw *hw, u32 *msg, s16 size)
+{
+	u32 v2p_mailbox = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+	s32 ret_val = E1000_SUCCESS;
+	s16 i;
+
+	/*
+	 * copy the caller specified message to the mailbox
+	 * memory buffer
+	 */
+	for (i = 0; i < size; i++) {
+		msg[i] = E1000_READ_REG(hw, E1000_VFVMBMEM(i * 4));
+	}
+
+	/*
+	 * Acknowledge receipt of the message to the PF and then
+	 * we're done
+	 */
+	/* clear status indication bit */
+	v2p_mailbox &= ~(E1000_V2PMAILBOX_PFSTS | E1000_V2PMAILBOX_VFU);
+	v2p_mailbox |= E1000_V2PMAILBOX_ACK;	    /* Set PF Ack bit */
+	E1000_WRITE_REG(hw, E1000_V2PMAILBOX(0), v2p_mailbox);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_check_for_pf_mail_vf - checks to see if the PF has sent mail
+ *  @hw: pointer to the HW structure
+ *
+ *  returns true if the PF has set the Status bit or else false
+ **/
+bool e1000_check_for_pf_mail_vf(struct e1000_hw *hw, u32 *vf_mb_val)
+{
+	u32 v2p_mailbox = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+	bool ret_val = false;
+
+	if ((v2p_mailbox & E1000_V2PMAILBOX_PFSTS)) {
+		ret_val = true;
+	}
+
+	*vf_mb_val = v2p_mailbox;
+
+	return ret_val;
+}
+
+/**
+ *  e1000_send_mail_to_vf - Sends a mailbox message from PF to VF
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @vf_number: the VF index
+ *  @size: Length of buffer
+ **/
+s32 e1000_send_mail_to_vf(struct e1000_hw *hw, u32 *msg, u32 vf_number,
+                          s16 size)
+{
+	u32 p2v_mailbox = E1000_READ_REG(hw, E1000_P2VMAILBOX(vf_number));
+	s32 ret_val = E1000_SUCCESS;
+	s16 i;
+
+	/*
+	 * if the VF owns the mailbox then we can't grab the mailbox buffer
+	 * - mostly an indication of a programming error
+	 */
+	if (p2v_mailbox & E1000_P2VMAILBOX_VFU) {
+		ret_val = -1;
+		goto out_no_write;
+	} else {
+		/* Take ownership of the buffer */
+		p2v_mailbox |= E1000_P2VMAILBOX_PFU;
+		E1000_WRITE_REG(hw, E1000_P2VMAILBOX(vf_number), p2v_mailbox);
+		p2v_mailbox = E1000_READ_REG(hw, E1000_P2VMAILBOX(vf_number));
+		/* Make sure we have ownership now... */
+		if (p2v_mailbox & E1000_P2VMAILBOX_VFU) {
+			/*
+			 * oops, VF grabbed ownership while we were attempting
+			 * to take ownership - avoid the race condition
+			 */
+			ret_val = -2;
+			goto out_no_write;
+		}
+	}
+
+	/*
+	 * At this point we have established ownership of the PF mailbox memory
+	 * buffer.  IT IS IMPORTANT THAT THIS OWNERSHIP BE GIVEN UP!  Whether
+	 * success or failure, the PF ownership bit must be cleared before
+	 * exiting this function - so if you change this function keep that
+	 * in mind
+	 */
+
+	/* Clear PF ownership of the mail box memory buffer */
+	/*
+	 * Do this whether success or failure on the wait for ack from
+	 * the PF
+	 */
+	p2v_mailbox &= ~(E1000_P2VMAILBOX_PFU);
+
+	/* check for overflow */
+	if (size > E1000_VFMAILBOX_SIZE) {
+		ret_val = -3;
+		goto out;
+	}
+
+	/*
+	 * copy the caller specified message to the mailbox
+	 * memory buffer
+	 */
+	for (i = 0; i < size; i++) {
+		E1000_WRITE_REG(hw,
+				((E1000_VMBMEM(vf_number)) + (i * 4)), msg[i]);
+	}
+
+	/* Interrupt the VF to tell it a message has been sent */
+	p2v_mailbox |= E1000_P2VMAILBOX_STS;
+
+out:
+	E1000_WRITE_REG(hw, E1000_P2VMAILBOX(vf_number), p2v_mailbox);
+
+out_no_write:
+	return ret_val;
+
+}
+
+/**
+ *  e1000_receive_mail_from_vf - Receives a mailbox message from VF to PF
+ *  @hw: pointer to the HW structure
+ *  @msg: The message buffer
+ *  @vf_number: the VF index
+ *  @size: Length of buffer
+ **/
+s32 e1000_receive_mail_from_vf(struct e1000_hw *hw,
+                               u32 *msg, u32 vf_number, s16 size)
+{
+	u32 p2v_mailbox = E1000_READ_REG(hw, E1000_P2VMAILBOX(vf_number));
+	s16 i;
+
+	/*
+	 * Should we be checking if the VF has set the ownership bit?
+	 * I don't know... presumably well written software will set the
+	 * VF mailbox memory ownership bit but I can't think of a reason
+	 * to call it an error if it doesn't... I'll think 'pon it some more
+	 */
+
+	/*
+	 * No message ready polling mechanism - the presumption is that
+	 * the caller knows there is a message because of the interrupt
+	 * ack
+	 */
+
+	/*
+	 * copy the caller specified message to the mailbox
+	 * memory buffer
+	 */
+	for (i = 0; i < size; i++) {
+		msg[i] = E1000_READ_REG(hw,
+					((E1000_VMBMEM(vf_number)) + (i * 4)));
+	}
+
+	/*
+	 * Acknowledge receipt of the message to the VF and then
+	 * we're done
+	 */
+	p2v_mailbox |= E1000_P2VMAILBOX_ACK;	    /* Set PF Ack bit */
+	E1000_WRITE_REG(hw, E1000_P2VMAILBOX(vf_number), p2v_mailbox);
+
+	return E1000_SUCCESS;	/* Success is the only option  */
+}
+
+/**
+ *  e1000_vmdq_loopback_enable_vf - Enables VM to VM queue loopback replication
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_vmdq_loopback_enable_vf(struct e1000_hw *hw)
+{
+	u32 reg;
+
+	reg = E1000_READ_REG(hw, E1000_DTXSWC);
+	reg |= E1000_DTXSWC_VMDQ_LOOPBACK_EN;
+	E1000_WRITE_REG(hw, E1000_DTXSWC, reg);
+}
+
+/**
+ *  e1000_vmdq_loopback_disable_vf - Disable VM to VM queue loopbk replication
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_vmdq_loopback_disable_vf(struct e1000_hw *hw)
+{
+	u32 reg;
+
+	reg = E1000_READ_REG(hw, E1000_DTXSWC);
+	reg &= ~(E1000_DTXSWC_VMDQ_LOOPBACK_EN);
+	E1000_WRITE_REG(hw, E1000_DTXSWC, reg);
+}
+
+/**
+ *  e1000_vmdq_replication_enable_vf - Enable replication of brdcst & multicst
+ *  @hw: pointer to the HW structure
+ *
+ *  Enables replication of broadcast and multicast packets from the network
+ *  to VM's which have their respective broadcast and multicast accept
+ *  bits set in the VM Offload Register.  This gives the PF driver per
+ *  VM granularity control over which VM's get replicated broadcast traffic.
+ **/
+void e1000_vmdq_replication_enable_vf(struct e1000_hw *hw, u32 enables)
+{
+	u32 reg;
+	u32 i;
+
+	for (i = 0; i < MAX_NUM_VFS; i++) {
+		if (enables & (1 << i)) {
+			reg = E1000_READ_REG(hw, E1000_VMOLR(i));
+			reg |= (E1000_VMOLR_AUPE |
+				E1000_VMOLR_BAM |
+				E1000_VMOLR_MPME);
+			E1000_WRITE_REG(hw, E1000_VMOLR(i), reg);
+		}
+	}
+
+	reg = E1000_READ_REG(hw, E1000_VT_CTL);
+	reg |= E1000_VT_CTL_VM_REPL_EN;
+	E1000_WRITE_REG(hw, E1000_VT_CTL, reg);
+}
+
+/**
+ *  e1000_vmdq_replication_disable_vf - Disable replication of brdcst & multicst
+ *  @hw: pointer to the HW structure
+ *
+ *  Disables replication of broadcast and multicast packets to the VM's.
+ **/
+void e1000_vmdq_replication_disable_vf(struct e1000_hw *hw)
+{
+	u32 reg;
+
+	reg = E1000_READ_REG(hw, E1000_VT_CTL);
+	reg &= ~(E1000_VT_CTL_VM_REPL_EN);
+	E1000_WRITE_REG(hw, E1000_VT_CTL, reg);
+}
+
+/**
+ *  e1000_vmdq_enable_replication_mode_vf - Enables replication mode in the device
+ *  @hw: pointer to the HW structure
+ **/
+void e1000_vmdq_enable_replication_mode_vf(struct e1000_hw *hw)
+{
+	u32 reg;
+
+	reg = E1000_READ_REG(hw, E1000_VT_CTL);
+	reg |= E1000_VT_CTL_VM_REPL_EN;
+	E1000_WRITE_REG(hw, E1000_VT_CTL, reg);
+}
+
+/**
+ *  e1000_vmdq_broadcast_replication_enable_vf - Enable replication of brdcst
+ *  @hw: pointer to the HW structure
+ *  @enables: PoolSet Bit - if set to ALL_QUEUES, apply to all pools.
+ *
+ *  Enables replication of broadcast packets from the network
+ *  to VM's which have their respective broadcast accept
+ *  bits set in the VM Offload Register.  This gives the PF driver per
+ *  VM granularity control over which VM's get replicated broadcast traffic.
+ **/
+void e1000_vmdq_broadcast_replication_enable_vf(struct e1000_hw *hw,
+						u32 enables)
+{
+	u32 reg;
+	u32 i;
+
+	for (i = 0; i < MAX_NUM_VFS; i++) {
+		if ((enables == ALL_QUEUES) || (enables & (1 << i))) {
+			reg = E1000_READ_REG(hw, E1000_VMOLR(i));
+			reg |= E1000_VMOLR_BAM;
+			E1000_WRITE_REG(hw, E1000_VMOLR(i), reg);
+		}
+	}
+}
+
+/**
+ *  e1000_vmdq_multicast_replication_enable_vf - Enable replication of multicast
+ *  @hw: pointer to the HW structure
+ *  @enables: PoolSet Bit - if set to ALL_QUEUES, apply to all pools.
+ *
+ *  Enables replication of multicast packets from the network
+ *  to VM's which have their respective multicast promiscuous mode enable
+ *  bits set in the VM Offload Register.  This gives the PF driver per
+ *  VM granularity control over which VM's get replicated multicast traffic.
+ **/
+void e1000_vmdq_multicast_replication_enable_vf(struct e1000_hw *hw,
+						u32 enables)
+{
+	u32 reg;
+	u32 i;
+
+	for (i = 0; i < MAX_NUM_VFS; i++) {
+		if ((enables == ALL_QUEUES) || (enables & (1 << i))) {
+			reg = E1000_READ_REG(hw, E1000_VMOLR(i));
+			reg |= E1000_VMOLR_MPME;
+			E1000_WRITE_REG(hw, E1000_VMOLR(i), reg);
+		}
+	}
+}
+
+/**
+ *  e1000_vmdq_broadcast_replication_disable_vf - Disable replication
+ *  of broadcast
+ *  @hw: pointer to the HW structure
+ *  @disables: PoolSet Bit - if set to ALL_QUEUES, apply to all pools.
+ *
+ *  Disables replication of broadcast packets for specific pools. If
+ *  replication (bc/mc) is disabled on all pools then replication mode is
+ *  turned off.
+ **/
+void e1000_vmdq_broadcast_replication_disable_vf(struct e1000_hw *hw,
+						u32 disables)
+{
+	u32 reg;
+	u32 i;
+	u32 oneenabled = 0;
+
+	for (i = 0; i < MAX_NUM_VFS; i++) {
+		reg = E1000_READ_REG(hw, E1000_VMOLR(i));
+		if ((disables == ALL_QUEUES) || (disables & (1 << i))) {
+			reg &= ~(E1000_VMOLR_BAM);
+			E1000_WRITE_REG(hw, E1000_VMOLR(i), reg);
+		}
+		if (!oneenabled && (reg & (E1000_VMOLR_AUPE |
+				E1000_VMOLR_BAM |
+				E1000_VMOLR_MPME)))
+				oneenabled = 1;
+	}
+	if (!oneenabled) {
+		reg = E1000_READ_REG(hw, E1000_VT_CTL);
+		reg &= ~(E1000_VT_CTL_VM_REPL_EN);
+		E1000_WRITE_REG(hw, E1000_VT_CTL, reg);
+	}
+}
+
+/**
+ *  e1000_vmdq_multicast_replication_disable_vf - Disable replication
+ *  of multicast packets
+ *  @hw: pointer to the HW structure
+ *  @disables: PoolSet Bit - if set to ALL_QUEUES, apply to all pools.
+ *
+ *  Disables replication of multicast packets for specific pools. If
+ *  replication (bc/mc) is disabled on all pools then replication mode is
+ *  turned off.
+ **/
+void e1000_vmdq_multicast_replication_disable_vf(struct e1000_hw *hw,
+						u32 disables)
+{
+	u32 reg;
+	u32 i;
+	u32 oneenabled = 0;
+
+	for (i = 0; i < MAX_NUM_VFS; i++) {
+		reg = E1000_READ_REG(hw, E1000_VMOLR(i));
+		if ((disables == ALL_QUEUES) || (disables & (1 << i))) {
+			reg &= ~(E1000_VMOLR_MPME);
+			E1000_WRITE_REG(hw, E1000_VMOLR(i), reg);
+		}
+		if (!oneenabled && (reg & (E1000_VMOLR_AUPE |
+				E1000_VMOLR_BAM |
+				E1000_VMOLR_MPME)))
+				oneenabled = 1;
+	}
+
+	if (!oneenabled) {
+		reg = E1000_READ_REG(hw, E1000_VT_CTL);
+		reg &= ~(E1000_VT_CTL_VM_REPL_EN);
+		E1000_WRITE_REG(hw, E1000_VT_CTL, reg);
+	}
+}
+
diff -Npur igbvf-0.5.2/src/ethtool.c igbvf-0.5.2.orig/src/ethtool.c
--- igbvf-0.5.2/src/ethtool.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/ethtool.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,620 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+/* ethtool support for igbvf */
+
+#include <linux/netdevice.h>
+#ifdef SIOCETHTOOL
+#include <linux/ethtool.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+#include "igbvf.h"
+#ifdef NETIF_F_HW_VLAN_TX
+#include <linux/if_vlan.h>
+#endif
+
+#ifdef ETHTOOL_OPS_COMPAT
+#include "kcompat_ethtool.c"
+#endif
+
+struct igbvf_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+	int base_stat_offset;
+};
+
+#define IGBVF_STAT(m, b) sizeof(((struct igbvf_adapter *)0)->m), \
+		offsetof(struct igbvf_adapter, m), \
+		offsetof(struct igbvf_adapter, b)
+static const struct igbvf_stats igbvf_gstrings_stats[] = {
+	{ "rx_packets", IGBVF_STAT(stats.gprc, stats.base_gprc) },
+	{ "tx_packets", IGBVF_STAT(stats.gptc, stats.base_gptc) },
+	{ "rx_bytes", IGBVF_STAT(stats.gorc, stats.base_gorc) },
+	{ "tx_bytes", IGBVF_STAT(stats.gotc, stats.base_gotc) },
+	{ "multicast", IGBVF_STAT(stats.mprc, stats.base_mprc) },
+	{ "lbrx_bytes", IGBVF_STAT(stats.gorlbc, stats.base_gorlbc) },
+	{ "lbrx_packets", IGBVF_STAT(stats.gprlbc, stats.base_gprlbc) },
+	{ "tx_restart_queue", IGBVF_STAT(restart_queue, zero_base) },
+	{ "rx_long_byte_count", IGBVF_STAT(stats.gorc, stats.base_gorc) },
+	{ "rx_csum_offload_good", IGBVF_STAT(hw_csum_good, zero_base) },
+	{ "rx_csum_offload_errors", IGBVF_STAT(hw_csum_err, zero_base) },
+	{ "rx_header_split", IGBVF_STAT(rx_hdr_split, zero_base) },
+	{ "alloc_rx_buff_failed", IGBVF_STAT(alloc_rx_buff_failed, zero_base) },
+};
+
+#define IGBVF_GLOBAL_STATS_LEN	\
+	sizeof(igbvf_gstrings_stats) / sizeof(struct igbvf_stats)
+#define IGBVF_STATS_LEN (IGBVF_GLOBAL_STATS_LEN)
+static const char igbvf_gstrings_test[][ETH_GSTRING_LEN] = {
+	"Link test   (on/offline)"
+};
+#define IGBVF_TEST_LEN ARRAY_SIZE(igbvf_gstrings_test)
+
+static int igbvf_get_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
+
+	ecmd->supported   = SUPPORTED_1000baseT_Full;
+
+	ecmd->advertising = ADVERTISED_1000baseT_Full;
+
+	ecmd->port = -1;
+	ecmd->transceiver = XCVR_DUMMY1;
+
+	status = er32(STATUS);
+	if (status & E1000_STATUS_LU) {
+		if (status & E1000_STATUS_SPEED_1000)
+			ecmd->speed = 1000;
+		else if (status & E1000_STATUS_SPEED_100)
+			ecmd->speed = 100;
+		else
+			ecmd->speed = 10;
+
+		if (status & E1000_STATUS_FD)
+			ecmd->duplex = DUPLEX_FULL;
+		else
+			ecmd->duplex = DUPLEX_HALF;
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	ecmd->autoneg = AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static u32 igbvf_get_link(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
+
+	status = er32(STATUS);
+	return (status & E1000_STATUS_LU);
+}
+
+static int igbvf_set_settings(struct net_device *netdev,
+			      struct ethtool_cmd *ecmd)
+{
+	return -EOPNOTSUPP;
+}
+
+static void igbvf_get_pauseparam(struct net_device *netdev,
+				 struct ethtool_pauseparam *pause)
+{
+	return;
+}
+
+static int igbvf_set_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pause)
+{
+	return -EOPNOTSUPP;
+}
+
+static u32 igbvf_get_tx_csum(struct net_device *netdev)
+{
+	return ((netdev->features & NETIF_F_HW_CSUM) != 0);
+}
+
+static int igbvf_set_tx_csum(struct net_device *netdev, u32 data)
+{
+	if (data)
+		netdev->features |= NETIF_F_HW_CSUM;
+	else
+		netdev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
+}
+
+#ifdef NETIF_F_TSO
+static int igbvf_set_tso(struct net_device *netdev, u32 data)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	int i;
+	struct net_device *v_netdev;
+
+	if (data) {
+		netdev->features |= NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+		netdev->features |= NETIF_F_TSO6;
+#endif
+	} else {
+		netdev->features &= ~NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+		netdev->features &= ~NETIF_F_TSO6;
+#endif
+#ifdef NETIF_F_HW_VLAN_TX
+		/* disable TSO on all VLANs if they're present */
+		if (!adapter->vlgrp)
+			goto tso_out;
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			v_netdev = vlan_group_get_device(adapter->vlgrp, i);
+			if (!v_netdev)
+				continue;
+
+			v_netdev->features &= ~NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+			v_netdev->features &= ~NETIF_F_TSO6;
+#endif
+			vlan_group_set_device(adapter->vlgrp, i, v_netdev);
+		}
+#endif
+	}
+ 
+tso_out:
+	e_info("TSO is %s\n", data ? "Enabled" : "Disabled");
+	adapter->flags |= FLAG_TSO_FORCE;
+	return 0;
+}
+#endif
+
+static u32 igbvf_get_msglevel(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	return adapter->msg_enable;
+}
+
+static void igbvf_set_msglevel(struct net_device *netdev, u32 data)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	adapter->msg_enable = data;
+}
+
+static int igbvf_get_regs_len(struct net_device *netdev)
+{
+#define IGBVF_REGS_LEN 32 /* overestimate */
+	return IGBVF_REGS_LEN * sizeof(u32);
+}
+
+static void igbvf_get_regs(struct net_device *netdev,
+			   struct ethtool_regs *regs, void *p)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 *regs_buff = p;
+	u16 phy_data;
+	u8 revision_id;
+
+	memset(p, 0, IGBVF_REGS_LEN * sizeof(u32));
+
+	pci_read_config_byte(adapter->pdev, PCI_REVISION_ID, &revision_id);
+
+	regs->version = (1 << 24) | (revision_id << 16) | adapter->pdev->device;
+
+	regs_buff[0]  = er32(CTRL);
+	regs_buff[1]  = er32(STATUS);
+
+	regs_buff[2]  = er32(RCTL);
+	regs_buff[3]  = er32(RDLEN(0));
+	regs_buff[4]  = er32(RDH(0));
+	regs_buff[5]  = er32(RDT(0));
+	regs_buff[6]  = er32(RDTR);
+
+	regs_buff[7]  = er32(TCTL);
+	regs_buff[8]  = er32(TDLEN(0));
+	regs_buff[9]  = er32(TDH(0));
+	regs_buff[10] = er32(TDT(0));
+	regs_buff[11] = er32(TIDV);
+
+	regs_buff[12] = adapter->hw.phy.type;  /* PHY type (IGP=1, M88=0) */
+	if (hw->phy.type == e1000_phy_m88) {
+		hw->phy.ops.read_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
+		regs_buff[13] = (u32)phy_data; /* cable length */
+		regs_buff[14] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
+		regs_buff[15] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
+		regs_buff[16] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
+		hw->phy.ops.read_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
+		regs_buff[17] = (u32)phy_data; /* extended 10bt distance */
+		regs_buff[18] = regs_buff[13]; /* cable polarity */
+		regs_buff[19] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
+		regs_buff[20] = regs_buff[17]; /* polarity correction */
+		/* phy receive errors */
+		regs_buff[22] = 0; /* No phy stats in a VF device */
+		regs_buff[23] = regs_buff[13]; /* mdix mode */
+	}
+	regs_buff[21] = /* No phy stats in a VF device */
+	regs_buff[24] = (u32)phy_data;  /* phy local receiver status */
+	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
+}
+
+static int igbvf_get_eeprom_len(struct net_device *netdev)
+{
+	return 0;
+}
+
+static int igbvf_get_eeprom(struct net_device *netdev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	return -EOPNOTSUPP;
+}
+
+static int igbvf_set_eeprom(struct net_device *netdev,
+			    struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+	return -EOPNOTSUPP;
+}
+
+static void igbvf_get_drvinfo(struct net_device *netdev,
+			      struct ethtool_drvinfo *drvinfo)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	char firmware_version[32] = "N/A";
+
+	strncpy(drvinfo->driver,  igbvf_driver_name, 32);
+	strncpy(drvinfo->version, igbvf_driver_version, 32);
+	strncpy(drvinfo->fw_version, firmware_version, 32);
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+	drvinfo->regdump_len = igbvf_get_regs_len(netdev);
+	drvinfo->eedump_len = igbvf_get_eeprom_len(netdev);
+}
+
+static void igbvf_get_ringparam(struct net_device *netdev,
+				struct ethtool_ringparam *ring)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+
+	ring->rx_max_pending = IGBVF_MAX_RXD;
+	ring->tx_max_pending = IGBVF_MAX_TXD;
+	ring->rx_mini_max_pending = 0;
+	ring->rx_jumbo_max_pending = 0;
+	ring->rx_pending = rx_ring->count;
+	ring->tx_pending = tx_ring->count;
+	ring->rx_mini_pending = 0;
+	ring->rx_jumbo_pending = 0;
+}
+
+static int igbvf_set_ringparam(struct net_device *netdev,
+			       struct ethtool_ringparam *ring)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct igbvf_ring *tx_ring, *tx_old;
+	struct igbvf_ring *rx_ring, *rx_old;
+	int err;
+
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
+		return -EINVAL;
+
+	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
+		msleep(1);
+
+	if (netif_running(adapter->netdev))
+		igbvf_down(adapter);
+
+	tx_old = adapter->tx_ring;
+	rx_old = adapter->rx_ring;
+
+	err = -ENOMEM;
+	tx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
+	if (!tx_ring)
+		goto err_alloc_tx;
+	/*
+	 * use a memcpy to save any previously configured
+	 * items like napi structs from having to be
+	 * reinitialized
+	 */
+	memcpy(tx_ring, tx_old, sizeof(struct igbvf_ring));
+
+	rx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
+	if (!rx_ring)
+		goto err_alloc_rx;
+	memcpy(rx_ring, rx_old, sizeof(struct igbvf_ring));
+
+	adapter->tx_ring = tx_ring;
+	adapter->rx_ring = rx_ring;
+
+	rx_ring->count = max(ring->rx_pending, (u32)IGBVF_MIN_RXD);
+	rx_ring->count = min(rx_ring->count, (u32)(IGBVF_MAX_RXD));
+	rx_ring->count = ALIGN(rx_ring->count, REQ_RX_DESCRIPTOR_MULTIPLE);
+
+	tx_ring->count = max(ring->tx_pending, (u32)IGBVF_MIN_TXD);
+	tx_ring->count = min(tx_ring->count, (u32)(IGBVF_MAX_TXD));
+	tx_ring->count = ALIGN(tx_ring->count, REQ_TX_DESCRIPTOR_MULTIPLE);
+
+	if (netif_running(adapter->netdev)) {
+		/* Try to get new resources before deleting old */
+		err = igbvf_setup_rx_resources(adapter);
+		if (err)
+			goto err_setup_rx;
+		err = igbvf_setup_tx_resources(adapter);
+		if (err)
+			goto err_setup_tx;
+
+		/*
+		 * restore the old in order to free it,
+		 * then add in the new
+		 */
+		adapter->rx_ring = rx_old;
+		adapter->tx_ring = tx_old;
+		igbvf_free_rx_resources(adapter);
+		igbvf_free_tx_resources(adapter);
+		kfree(tx_old);
+		kfree(rx_old);
+		adapter->rx_ring = rx_ring;
+		adapter->tx_ring = tx_ring;
+		err = igbvf_up(adapter);
+		if (err)
+			goto err_setup;
+	}
+
+	clear_bit(__IGBVF_RESETTING, &adapter->state);
+	return 0;
+err_setup_tx:
+	igbvf_free_rx_resources(adapter);
+err_setup_rx:
+	adapter->rx_ring = rx_old;
+	adapter->tx_ring = tx_old;
+	kfree(rx_ring);
+err_alloc_rx:
+	kfree(tx_ring);
+err_alloc_tx:
+	igbvf_up(adapter);
+err_setup:
+	clear_bit(__IGBVF_RESETTING, &adapter->state);
+	return err;
+}
+
+static int igbvf_link_test(struct igbvf_adapter *adapter, u64 *data)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	*data = 0;
+	if (hw->phy.media_type == e1000_media_type_internal_serdes) {
+		int i = 0;
+		hw->mac.serdes_has_link = 0;
+
+		/*
+		 * On some blade server designs, link establishment
+		 * could take as long as 2-3 minutes
+		 */
+		do {
+			hw->mac.ops.check_for_link(hw);
+			if (hw->mac.serdes_has_link)
+				return *data;
+			msleep(20);
+		} while (i++ < 3750);
+
+		*data = 1;
+	} else {
+		hw->mac.ops.check_for_link(hw);
+		if (hw->mac.autoneg)
+			msleep(4000);
+
+		if (!(er32(STATUS) &
+		      E1000_STATUS_LU))
+			*data = 1;
+	}
+	return *data;
+}
+
+static int igbvf_get_self_test_count(struct net_device *netdev)
+{
+	return IGBVF_TEST_LEN;
+}
+
+static int igbvf_get_stats_count(struct net_device *netdev)
+{
+	return IGBVF_STATS_LEN;
+}
+
+static void igbvf_diag_test(struct net_device *netdev,
+			    struct ethtool_test *eth_test, u64 *data)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	set_bit(__IGBVF_TESTING, &adapter->state);
+
+	/*
+	 * Link test performed before hardware reset so autoneg doesn't
+	 * interfere with test result
+	 */
+	if (igbvf_link_test(adapter, &data[0]))
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+
+	clear_bit(__IGBVF_TESTING, &adapter->state);
+	msleep_interruptible(4 * 1000);
+}
+
+static void igbvf_get_wol(struct net_device *netdev,
+			  struct ethtool_wolinfo *wol)
+{
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	return;
+}
+
+static int igbvf_set_wol(struct net_device *netdev,
+			 struct ethtool_wolinfo *wol)
+{
+	return -EOPNOTSUPP;
+}
+
+static int igbvf_phys_id(struct net_device *netdev, u32 data)
+{
+	return 0;
+}
+
+static int igbvf_get_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	if (adapter->itr_setting <= 3)
+		ec->rx_coalesce_usecs = adapter->itr_setting;
+	else
+		ec->rx_coalesce_usecs = adapter->itr_setting >> 2;
+
+	return 0;
+}
+
+static int igbvf_set_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *ec)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	if ((ec->rx_coalesce_usecs > IGBVF_MAX_ITR_USECS) ||
+	    ((ec->rx_coalesce_usecs > 3) &&
+	     (ec->rx_coalesce_usecs < IGBVF_MIN_ITR_USECS)) ||
+	    (ec->rx_coalesce_usecs == 2))
+		return -EINVAL;
+
+	/* convert to rate of irq's per second */
+	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <= 3) {
+		adapter->itr = IGBVF_START_ITR;
+		adapter->itr_setting = ec->rx_coalesce_usecs;
+	} else {
+		adapter->itr = ec->rx_coalesce_usecs << 2;
+		adapter->itr_setting = adapter->itr;
+	}
+
+	writel(adapter->itr,
+	       hw->hw_addr + adapter->rx_ring[0].itr_register);
+
+	return 0;
+}
+
+static int igbvf_nway_reset(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	if (netif_running(netdev))
+		igbvf_reinit_locked(adapter);
+	return 0;
+}
+
+
+static void igbvf_get_ethtool_stats(struct net_device *netdev,
+				    struct ethtool_stats *stats,
+				    u64 *data)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	igbvf_update_stats(adapter);
+	for (i = 0; i < IGBVF_GLOBAL_STATS_LEN; i++) {
+		char *p = (char *)adapter+igbvf_gstrings_stats[i].stat_offset;
+		char *b = (char *)adapter+igbvf_gstrings_stats[i].base_stat_offset;
+		data[i] = ((igbvf_gstrings_stats[i].sizeof_stat ==
+			    sizeof(u64)) ? *(u64 *)p : *(u32 *)p) -
+			  ((igbvf_gstrings_stats[i].sizeof_stat ==
+			    sizeof(u64)) ? *(u64 *)b : *(u32 *)b);
+	}
+
+}
+
+static void igbvf_get_strings(struct net_device *netdev, u32 stringset,
+			      u8 *data)
+{
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, *igbvf_gstrings_test, sizeof(igbvf_gstrings_test));
+		break;
+	case ETH_SS_STATS:
+		for (i = 0; i < IGBVF_GLOBAL_STATS_LEN; i++) {
+			memcpy(p, igbvf_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static const struct ethtool_ops igbvf_ethtool_ops = {
+	.get_settings		= igbvf_get_settings,
+	.set_settings		= igbvf_set_settings,
+	.get_drvinfo		= igbvf_get_drvinfo,
+	.get_regs_len		= igbvf_get_regs_len,
+	.get_regs		= igbvf_get_regs,
+	.get_wol		= igbvf_get_wol,
+	.set_wol		= igbvf_set_wol,
+	.get_msglevel		= igbvf_get_msglevel,
+	.set_msglevel		= igbvf_set_msglevel,
+	.nway_reset		= igbvf_nway_reset,
+	.get_link		= igbvf_get_link,
+	.get_eeprom_len		= igbvf_get_eeprom_len,
+	.get_eeprom		= igbvf_get_eeprom,
+	.set_eeprom		= igbvf_set_eeprom,
+	.get_ringparam		= igbvf_get_ringparam,
+	.set_ringparam		= igbvf_set_ringparam,
+	.get_pauseparam		= igbvf_get_pauseparam,
+	.set_pauseparam		= igbvf_set_pauseparam,
+	.get_tx_csum		= igbvf_get_tx_csum,
+	.set_tx_csum		= igbvf_set_tx_csum,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= igbvf_set_tso,
+#endif
+	.self_test		= igbvf_diag_test,
+	.get_strings		= igbvf_get_strings,
+	.phys_id		= igbvf_phys_id,
+	.get_ethtool_stats	= igbvf_get_ethtool_stats,
+	.self_test_count	= igbvf_get_self_test_count,
+	.get_stats_count	= igbvf_get_stats_count,
+	.get_coalesce		= igbvf_get_coalesce,
+	.set_coalesce		= igbvf_set_coalesce,
+};
+
+void igbvf_set_ethtool_ops(struct net_device *netdev)
+{
+	/* have to "undeclare" const on this struct to remove warnings */
+	SET_ETHTOOL_OPS(netdev, (struct ethtool_ops *)&igbvf_ethtool_ops);
+}
+#endif /* SIOCETHTOOL */
diff -Npur igbvf-0.5.2/src/igbvf.h igbvf-0.5.2.orig/src/igbvf.h
--- igbvf-0.5.2/src/igbvf.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/igbvf.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,368 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+/* Linux PRO/1000 Ethernet Driver main header file */
+
+#ifndef _IGBVF_H_
+#define _IGBVF_H_
+
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <asm/io.h>
+#include <linux/netdevice.h>
+
+#include "kcompat.h"
+
+#include "e1000_hw.h"
+
+struct igbvf_info;
+
+#define e_printk(level, adapter, format, arg...) \
+	printk(level "%s: %s: " format, pci_name(adapter->pdev), \
+	       adapter->netdev->name, ## arg)
+
+#define e_dbg(format, arg...) do { (void)(adapter); } while (0)
+
+#define e_err(format, arg...) \
+	e_printk(KERN_ERR, adapter, format, ## arg)
+#define e_info(format, arg...) \
+	e_printk(KERN_INFO, adapter, format, ## arg)
+#define e_warn(format, arg...) \
+	e_printk(KERN_WARNING, adapter, format, ## arg)
+#define e_notice(format, arg...) \
+	e_printk(KERN_NOTICE, adapter, format, ## arg)
+
+
+/* Interrupt defines */
+#define IGBVF_START_ITR                    648 /* ~6000 ints/sec */
+
+/* Interrupt modes, as used by the IntMode paramter */
+#define IGBVF_INT_MODE_LEGACY		0
+#define IGBVF_INT_MODE_MSI		1
+#define IGBVF_INT_MODE_MSIX		2
+
+/* Tx/Rx descriptor defines */
+#define IGBVF_DEFAULT_TXD		256
+#define IGBVF_MAX_TXD			4096
+#define IGBVF_MIN_TXD			80
+
+#define IGBVF_DEFAULT_RXD		256
+#define IGBVF_MAX_RXD			4096
+#define IGBVF_MIN_RXD			80
+
+#define IGBVF_MIN_ITR_USECS		10 /* 100000 irq/sec */
+#define IGBVF_MAX_ITR_USECS		10000 /* 100    irq/sec */
+
+/* Early Receive defines */
+#define IGBVF_ERT_2048			0x100
+
+#define IGBVF_FC_PAUSE_TIME		0x0680 /* 858 usec */
+
+/* How many Tx Descriptors do we need to call netif_wake_queue ? */
+/* How many Rx Buffers do we bundle into one write to the hardware ? */
+#define IGBVF_RX_BUFFER_WRITE		16 /* Must be power of 2 */
+
+#define AUTO_ALL_MODES			0
+#define IGBVF_EEPROM_APME		0x0400
+
+#define IGBVF_MNG_VLAN_NONE		(-1)
+
+/* Number of packet split data buffers (not including the header buffer) */
+#define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
+
+enum igbvf_boards {
+	board_vf,
+};
+
+struct igbvf_queue_stats {
+	u64 packets;
+	u64 bytes;
+};
+
+/*
+ * wrappers around a pointer to a socket buffer,
+ * so a DMA handle can be stored along with the buffer
+ */
+struct igbvf_buffer {
+	dma_addr_t dma;
+	struct sk_buff *skb;
+	union {
+		/* Tx */
+		struct {
+			unsigned long time_stamp;
+			u16 length;
+			u16 next_to_watch;
+		};
+		/* Rx */
+		struct {
+			struct page *page;
+			u64 page_dma;
+			unsigned int page_offset;
+		};
+	};
+	struct page *page;
+};
+
+struct igbvf_ring {
+	void *desc;			/* pointer to ring memory  */
+	dma_addr_t dma;			/* phys address of ring    */
+	unsigned int size;		/* length of ring in bytes */
+	unsigned int count;		/* number of desc. in ring */
+
+	u16 next_to_use;
+	u16 next_to_clean;
+
+	u16 head;
+	u16 tail;
+
+	/* array of buffer information structs */
+	struct igbvf_buffer *buffer_info;
+
+	char name[IFNAMSIZ + 5];
+	u32 eims_value;
+	u32 itr_val;
+	u16 itr_register;
+	int set_itr;
+
+	struct sk_buff *rx_skb_top;
+
+	struct igbvf_queue_stats stats;
+};
+
+/* board specific private data structure */
+struct igbvf_adapter {
+	struct timer_list watchdog_timer;
+	struct timer_list phy_info_timer;
+	struct timer_list blink_timer;
+
+	struct work_struct reset_task;
+	struct work_struct watchdog_task;
+	struct work_struct msg_handler_task;
+	struct work_struct pf_has_reset_task;
+
+	const struct igbvf_info *ei;
+
+	struct vlan_group *vlgrp;
+	u32 bd_number;
+	u32 rx_buffer_len;
+	u32 polling_interval;
+	u16 mng_vlan_id;
+	u16 link_speed;
+	u16 link_duplex;
+
+	spinlock_t tx_queue_lock; /* prevent concurrent tail updates */
+
+	/* track device up/down/testing state */
+	unsigned long state;
+
+	/* Interrupt Throttle Rate */
+	u32 itr;
+	u32 itr_setting;
+	u16 tx_itr;
+	u16 rx_itr;
+
+	/*
+	 * Tx
+	 */
+	struct igbvf_ring *tx_ring /* One per active queue */
+						____cacheline_aligned_in_smp;
+
+	struct napi_struct napi;
+
+	unsigned long tx_queue_len;
+	unsigned int restart_queue;
+	u32 txd_cmd;
+
+	bool detect_tx_hung;
+	u8 tx_timeout_factor;
+
+	u32 tx_int_delay;
+	u32 tx_abs_int_delay;
+
+	unsigned int total_tx_bytes;
+	unsigned int total_tx_packets;
+	unsigned int total_rx_bytes;
+	unsigned int total_rx_packets;
+
+	/* Tx stats */
+	u32 tx_timeout_count;
+	u32 tx_fifo_head;
+	u32 tx_head_addr;
+	u32 tx_fifo_size;
+	u32 tx_dma_failed;
+
+	/*
+	 * Rx
+	 */
+	bool (*clean_rx) (struct igbvf_adapter *adapter,
+			  int *work_done, int work_to_do)
+						____cacheline_aligned_in_smp;
+	void (*alloc_rx_buf) (struct igbvf_adapter *adapter,
+			      int cleaned_count);
+	struct igbvf_ring *rx_ring;
+
+	u32 rx_int_delay;
+	u32 rx_abs_int_delay;
+
+	/* Rx stats */
+	u64 hw_csum_err;
+	u64 hw_csum_good;
+	u64 rx_hdr_split;
+	u32 alloc_rx_buff_failed;
+	u32 rx_dma_failed;
+
+	unsigned int rx_ps_hdr_size;
+	u32 max_frame_size;
+	u32 min_frame_size;
+
+	/* OS defined structs */
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	struct net_device_stats net_stats;
+	spinlock_t stats_lock;      /* prevent concurrent stats updates */
+
+	/* structs defined in e1000_hw.h */
+	struct e1000_hw hw;
+
+	/* The VF counters don't clear on read so we have to get a base
+	 * count on driver start up and always subtract that base on
+	 * on the first update, thus the flag..
+	 */
+	struct e1000_vf_stats stats;
+	u64 zero_base;
+
+	struct igbvf_ring test_tx_ring;
+	struct igbvf_ring test_rx_ring;
+	u32 test_icr;
+
+	u32 msg_enable;
+	struct msix_entry *msix_entries;
+	int int_mode;
+	u32 eims_enable_mask;
+	u32 eims_other;
+	u32 int_counter0;
+	u32 int_counter1;
+
+	u32 eeprom_wol;
+	u32 wol;
+	u32 pba;
+
+	bool fc_autoneg;
+
+	unsigned long led_status;
+
+	unsigned int flags;
+	u32 *config_space;
+	u32 vf_mb_val;
+	bool jumbo_frames_enabled;
+};
+
+struct igbvf_info {
+	enum e1000_mac_type	mac;
+	unsigned int		flags;
+	u32			pba;
+	void			(*init_ops)(struct e1000_hw *);
+	s32			(*get_variants)(struct igbvf_adapter *);
+};
+
+/* hardware capability, feature, and workaround flags */
+#define FLAG_HAS_HW_VLAN_FILTER           (1 << 0)
+#define FLAG_HAS_JUMBO_FRAMES             (1 << 1)
+#define FLAG_MSI_ENABLED                  (1 << 2)
+#define FLAG_RX_CSUM_ENABLED              (1 << 3)
+#define FLAG_TSO_FORCE                    (1 << 4)
+#define FLAG_RX_RESTART_NOW               (1 << 5)
+#define FLAG_RX_NEEDS_RESTART             (1 << 6)
+
+#define IGBVF_DESC_UNUSED(R) \
+	((((R)->next_to_clean > (R)->next_to_use) ? 0 : (R)->count) + \
+	(R)->next_to_clean - (R)->next_to_use - 1)
+
+#define IGBVF_RX_DESC_ADV(R, i)	    \
+	(&(((union e1000_adv_rx_desc *)((R).desc))[i]))
+#define IGBVF_TX_DESC_ADV(R, i)	    \
+	(&(((union e1000_adv_tx_desc *)((R).desc))[i]))
+#define IGBVF_TX_CTXTDESC_ADV(R, i)	    \
+	(&(((struct e1000_adv_tx_context_desc *)((R).desc))[i]))
+#define IGBVF_RX_DESC_PS(R, i)	    \
+	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
+#define IGBVF_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
+#define IGBVF_RX_DESC(R, i)		IGBVF_GET_DESC(R, i, e1000_rx_desc)
+#define IGBVF_TX_DESC(R, i)		IGBVF_GET_DESC(R, i, e1000_tx_desc)
+#define IGBVF_CONTEXT_DESC(R, i)	IGBVF_GET_DESC(R, i, e1000_context_desc)
+
+enum igbvf_state_t {
+	__IGBVF_TESTING,
+	__IGBVF_RESETTING,
+	__IGBVF_DOWN
+};
+
+enum latency_range {
+	lowest_latency = 0,
+	low_latency = 1,
+	bulk_latency = 2,
+	latency_invalid = 255
+};
+
+extern char igbvf_driver_name[];
+extern const char igbvf_driver_version[];
+
+extern void igbvf_check_options(struct igbvf_adapter *adapter);
+extern void igbvf_set_ethtool_ops(struct net_device *netdev);
+#ifdef ETHTOOL_OPS_COMPAT
+extern int ethtool_ioctl(struct ifreq *ifr);
+#endif
+
+extern int igbvf_up(struct igbvf_adapter *adapter);
+extern void igbvf_down(struct igbvf_adapter *adapter);
+extern void igbvf_reinit_locked(struct igbvf_adapter *adapter);
+extern void igbvf_reset(struct igbvf_adapter *adapter);
+extern int igbvf_setup_rx_resources(struct igbvf_adapter *adapter);
+extern int igbvf_setup_tx_resources(struct igbvf_adapter *adapter);
+extern void igbvf_free_rx_resources(struct igbvf_adapter *adapter);
+extern void igbvf_free_tx_resources(struct igbvf_adapter *adapter);
+extern void igbvf_update_stats(struct igbvf_adapter *adapter);
+extern void igbvf_set_interrupt_capability(struct igbvf_adapter *adapter);
+extern void igbvf_reset_interrupt_capability(struct igbvf_adapter *adapter);
+
+extern unsigned int copybreak;
+
+static inline u32 __er32(struct e1000_hw *hw, unsigned long reg)
+{
+	return readl(hw->hw_addr + reg);
+}
+
+static inline void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
+{
+	writel(val, hw->hw_addr + reg);
+}
+#define er32(reg)	E1000_READ_REG(hw, E1000_##reg)
+#define ew32(reg,val)	E1000_WRITE_REG(hw, E1000_##reg, (val))
+#define e1e_flush()	er32(STATUS)
+
+#endif /* _IGBVF_H_ */
diff -Npur igbvf-0.5.2/src/kcompat.c igbvf-0.5.2.orig/src/kcompat.c
--- igbvf-0.5.2/src/kcompat.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/kcompat.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,417 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+
+
+
+
+#include "igbvf.h"
+
+
+
+#include "kcompat.h"
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,13) )
+
+/**************************************/
+/* PCI DMA MAPPING */
+
+#if defined(CONFIG_HIGHMEM)
+
+#ifndef PCI_DRAM_OFFSET
+#define PCI_DRAM_OFFSET 0
+#endif
+
+u64
+_kc_pci_map_page(struct pci_dev *dev, struct page *page, unsigned long offset,
+                 size_t size, int direction)
+{
+	return (((u64) (page - mem_map) << PAGE_SHIFT) + offset +
+		PCI_DRAM_OFFSET);
+}
+
+#else /* CONFIG_HIGHMEM */
+
+u64
+_kc_pci_map_page(struct pci_dev *dev, struct page *page, unsigned long offset,
+                 size_t size, int direction)
+{
+	return pci_map_single(dev, (void *)page_address(page) + offset, size,
+			      direction);
+}
+
+#endif /* CONFIG_HIGHMEM */
+
+void
+_kc_pci_unmap_page(struct pci_dev *dev, u64 dma_addr, size_t size,
+                   int direction)
+{
+	return pci_unmap_single(dev, dma_addr, size, direction);
+}
+
+#endif /* 2.4.13 => 2.4.3 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,3) )
+
+/**************************************/
+/* PCI DRIVER API */
+
+int
+_kc_pci_set_dma_mask(struct pci_dev *dev, dma_addr_t mask)
+{
+	if (!pci_dma_supported(dev, mask))
+		return -EIO;
+	dev->dma_mask = mask;
+	return 0;
+}
+
+int
+_kc_pci_request_regions(struct pci_dev *dev, char *res_name)
+{
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		if (pci_resource_len(dev, i) == 0)
+			continue;
+
+		if (pci_resource_flags(dev, i) & IORESOURCE_IO) {
+			if (!request_region(pci_resource_start(dev, i), pci_resource_len(dev, i), res_name)) {
+				pci_release_regions(dev);
+				return -EBUSY;
+			}
+		} else if (pci_resource_flags(dev, i) & IORESOURCE_MEM) {
+			if (!request_mem_region(pci_resource_start(dev, i), pci_resource_len(dev, i), res_name)) {
+				pci_release_regions(dev);
+				return -EBUSY;
+			}
+		}
+	}
+	return 0;
+}
+
+void
+_kc_pci_release_regions(struct pci_dev *dev)
+{
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		if (pci_resource_len(dev, i) == 0)
+			continue;
+
+		if (pci_resource_flags(dev, i) & IORESOURCE_IO)
+			release_region(pci_resource_start(dev, i), pci_resource_len(dev, i));
+
+		else if (pci_resource_flags(dev, i) & IORESOURCE_MEM)
+			release_mem_region(pci_resource_start(dev, i), pci_resource_len(dev, i));
+	}
+}
+
+/**************************************/
+/* NETWORK DRIVER API */
+
+struct net_device *
+_kc_alloc_etherdev(int sizeof_priv)
+{
+	struct net_device *dev;
+	int alloc_size;
+
+	alloc_size = sizeof(*dev) + sizeof_priv + IFNAMSIZ + 31;
+	dev = kmalloc(alloc_size, GFP_KERNEL);
+	if (!dev)
+		return NULL;
+	memset(dev, 0, alloc_size);
+
+	if (sizeof_priv)
+		dev->priv = (void *) (((unsigned long)(dev + 1) + 31) & ~31);
+	dev->name[0] = '\0';
+	ether_setup(dev);
+
+	return dev;
+}
+
+int
+_kc_is_valid_ether_addr(u8 *addr)
+{
+	const char zaddr[6] = { 0, };
+
+	return !(addr[0] & 1) && memcmp(addr, zaddr, 6);
+}
+
+#endif /* 2.4.3 => 2.4.0 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,6) )
+
+int
+_kc_pci_set_power_state(struct pci_dev *dev, int state)
+{
+	return 0;
+}
+
+int
+_kc_pci_enable_wake(struct pci_dev *pdev, u32 state, int enable)
+{
+	return 0;
+}
+
+#endif /* 2.4.6 => 2.4.3 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0) )
+void _kc_skb_fill_page_desc(struct sk_buff *skb, int i, struct page *page,
+                            int off, int size)
+{
+	skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+	frag->page = page;
+	frag->page_offset = off;
+	frag->size = size;
+	skb_shinfo(skb)->nr_frags = i + 1;
+}
+
+/*
+ * Original Copyright:
+ * find_next_bit.c: fallback find next bit implementation
+ *
+ * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ */
+
+/**
+ * find_next_bit - find the next set bit in a memory region
+ * @addr: The address to base the search on
+ * @offset: The bitnumber to start searching at
+ * @size: The maximum size to search
+ */
+unsigned long find_next_bit(const unsigned long *addr, unsigned long size,
+                            unsigned long offset)
+{
+	const unsigned long *p = addr + BITOP_WORD(offset);
+	unsigned long result = offset & ~(BITS_PER_LONG-1);
+	unsigned long tmp;
+
+	if (offset >= size)
+		return size;
+	size -= result;
+	offset %= BITS_PER_LONG;
+	if (offset) {
+		tmp = *(p++);
+		tmp &= (~0UL << offset);
+		if (size < BITS_PER_LONG)
+			goto found_first;
+		if (tmp)
+			goto found_middle;
+		size -= BITS_PER_LONG;
+		result += BITS_PER_LONG;
+	}
+	while (size & ~(BITS_PER_LONG-1)) {
+		if ((tmp = *(p++)))
+			goto found_middle;
+		result += BITS_PER_LONG;
+		size -= BITS_PER_LONG;
+	}
+	if (!size)
+		return result;
+	tmp = *p;
+
+found_first:
+	tmp &= (~0UL >> (BITS_PER_LONG - size));
+	if (tmp == 0UL)		/* Are any bits set? */
+		return result + size;	/* Nope. */
+found_middle:
+	return result + ffs(tmp);
+}
+
+#endif /* 2.6.0 => 2.4.6 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,14) )
+void *_kc_kzalloc(size_t size, int flags)
+{
+	void *ret = kmalloc(size, flags);
+	if (ret)
+		memset(ret, 0, size);
+	return ret;
+}
+#endif /* <= 2.6.13 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18) )
+struct sk_buff *_kc_netdev_alloc_skb(struct net_device *dev,
+                                     unsigned int length)
+{
+	/* 16 == NET_PAD_SKB */
+	struct sk_buff *skb;
+	skb = alloc_skb(length + 16, GFP_ATOMIC);
+	if (likely(skb != NULL)) {
+		skb_reserve(skb, 16);
+		skb->dev = dev;
+	}
+	return skb;
+}
+#endif /* <= 2.6.17 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19) )
+int _kc_pci_save_state(struct pci_dev *pdev)
+{ 
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct adapter_struct *adapter = netdev_priv(netdev);
+	int size = PCI_CONFIG_SPACE_LEN, i;
+	u16 pcie_cap_offset = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	u16 pcie_link_status;
+
+	if (pcie_cap_offset) {
+		if (!pci_read_config_word(pdev,
+		                          pcie_cap_offset + PCIE_LINK_STATUS,
+		                          &pcie_link_status))
+		size = PCIE_CONFIG_SPACE_LEN;
+	}
+	pci_config_space_ich8lan();
+#ifdef HAVE_PCI_ERS 
+	if (adapter->config_space == NULL)
+#else
+	WARN_ON(adapter->config_space != NULL);
+#endif
+		adapter->config_space = kmalloc(size, GFP_KERNEL);
+	if (!adapter->config_space) {
+		printk(KERN_ERR "Out of memory in pci_save_state\n");
+		return -ENOMEM;
+	}
+	for (i = 0; i < (size / 4); i++)
+		pci_read_config_dword(pdev, i * 4, &adapter->config_space[i]);
+	return 0;
+}
+
+void _kc_pci_restore_state(struct pci_dev * pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct adapter_struct *adapter = netdev_priv(netdev);
+	int size = PCI_CONFIG_SPACE_LEN, i;
+	u16 pcie_cap_offset;
+	u16 pcie_link_status;
+
+	if (adapter->config_space != NULL) {
+		pcie_cap_offset = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+		if (pcie_cap_offset && 
+		    !pci_read_config_word(pdev,
+		                          pcie_cap_offset + PCIE_LINK_STATUS,
+		                          &pcie_link_status))
+			size = PCIE_CONFIG_SPACE_LEN;
+	
+		pci_config_space_ich8lan();
+		for (i = 0; i < (size / 4); i++)
+		pci_write_config_dword(pdev, i * 4, adapter->config_space[i]);
+#ifndef HAVE_PCI_ERS
+		kfree(adapter->config_space);
+		adapter->config_space = NULL;
+#endif
+	}
+}
+
+#ifdef HAVE_PCI_ERS
+void _kc_free_netdev(struct net_device *netdev)
+{
+	struct adapter_struct *adapter = netdev_priv(netdev);
+
+	if (adapter->config_space != NULL)
+		kfree(adapter->config_space);
+#ifdef CONFIG_SYSFS
+	if (netdev->reg_state == NETREG_UNINITIALIZED) {
+		kfree((char *)netdev - netdev->padded);
+	} else {
+		BUG_ON(netdev->reg_state != NETREG_UNREGISTERED);
+		netdev->reg_state = NETREG_RELEASED;
+		class_device_put(&netdev->class_dev);
+	}
+#else
+	kfree((char *)netdev - netdev->padded);
+#endif
+}
+#endif
+#endif /* <= 2.6.18 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23) )
+#endif /* < 2.6.23 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,24) )
+#ifndef ESX40
+#ifdef NAPI
+int __kc_adapter_clean(struct net_device *netdev, int *budget)
+{
+	int work_done;
+	int work_to_do = min(*budget, netdev->quota);
+	struct adapter_struct *adapter = netdev_priv(netdev);
+	struct napi_struct *napi = &adapter->napi;
+	work_done = napi->poll(napi, work_to_do);
+	*budget -= work_done;
+	netdev->quota -= work_done;
+	return work_done ? 1 : 0;
+}
+#endif /* NAPI */
+#endif /* ESX40 */
+#endif /* <= 2.6.24 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27) )
+#ifdef HAVE_TX_MQ
+void _kc_netif_tx_stop_all_queues(struct net_device *netdev)
+{
+	struct adapter_struct *adapter = netdev_priv(netdev);
+	int i;
+
+	netif_stop_queue(netdev);
+	if (netif_is_multiqueue(netdev))
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
+}
+void _kc_netif_tx_wake_all_queues(struct net_device *netdev)
+{
+	struct adapter_struct *adapter = netdev_priv(netdev);
+	int i;
+
+	netif_wake_queue(netdev);
+	if (netif_is_multiqueue(netdev))
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_wake_subqueue(netdev, i);
+}
+void _kc_netif_tx_start_all_queues(struct net_device *netdev)
+{
+	struct adapter_struct *adapter = netdev_priv(netdev);
+	int i;
+
+	netif_start_queue(netdev);
+	if (netif_is_multiqueue(netdev))
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_start_subqueue(netdev, i);
+}
+#endif /* HAVE_TX_MQ */
+#endif /* <= 2.6.27 */
diff -Npur igbvf-0.5.2/src/kcompat.h igbvf-0.5.2.orig/src/kcompat.h
--- igbvf-0.5.2/src/kcompat.h	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/kcompat.h	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,1668 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#ifndef _KCOMPAT_H_
+#define _KCOMPAT_H_
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/ioport.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/delay.h>
+#include <linux/sched.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/mii.h>
+#include <asm/io.h>
+
+#ifndef ESX35
+/* NAPI enable/disable flags here */
+
+
+#define CONFIG_IGBVF_NAPI
+#define NAPI
+
+#ifdef _E1000_H_
+#ifdef CONFIG_E1000_NAPI
+#define NAPI
+#endif
+#ifdef E1000_NAPI
+#undef NAPI
+#define NAPI
+#endif
+#ifdef E1000E_NAPI
+#undef NAPI
+#define NAPI
+#endif
+#ifdef E1000_NO_NAPI
+#undef NAPI
+#endif
+#ifdef E1000E_NO_NAPI
+#undef NAPI
+#endif
+#endif
+
+#ifdef _IGB_H_
+#define NAPI
+#endif
+
+
+
+
+#endif /* ESX35 */
+
+
+
+#define adapter_struct igbvf_adapter
+#define CONFIG_IGBVF_MSIX
+
+
+
+
+/* and finally set defines so that the code sees the changes */
+#ifdef NAPI
+#ifndef CONFIG_E1000_NAPI
+#define CONFIG_E1000_NAPI
+#endif
+#ifndef CONFIG_E1000E_NAPI
+#define CONFIG_E1000E_NAPI
+#endif
+#else
+#undef CONFIG_E1000_NAPI
+#undef CONFIG_E1000E_NAPI
+#undef CONFIG_IXGB_NAPI
+#endif
+
+/* packet split disable/enable */
+#ifdef DISABLE_PACKET_SPLIT
+#undef CONFIG_E1000_DISABLE_PACKET_SPLIT
+#define CONFIG_E1000_DISABLE_PACKET_SPLIT
+#undef CONFIG_IGB_DISABLE_PACKET_SPLIT
+#define CONFIG_IGB_DISABLE_PACKET_SPLIT
+#endif
+
+/* MSI compatibility code for all kernels and drivers */
+#ifdef DISABLE_PCI_MSI
+#undef CONFIG_PCI_MSI
+#endif
+#ifndef CONFIG_PCI_MSI
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,8) )
+struct msix_entry {
+	u16 vector; /* kernel uses to write allocated vector */
+	u16 entry;  /* driver uses to specify entry, OS writes */
+};
+#endif
+#define pci_enable_msi(a) -ENOTSUPP
+#define pci_disable_msi(a) do {} while (0)
+#define pci_enable_msix(a, b, c) -ENOTSUPP
+#define pci_disable_msix(a) do {} while (0)
+#define msi_remove_pci_irq_vectors(a) do {} while (0)
+#endif /* CONFIG_PCI_MSI */
+#ifdef DISABLE_PM
+#undef CONFIG_PM
+#endif
+
+#ifdef DISABLE_NET_POLL_CONTROLLER
+#undef CONFIG_NET_POLL_CONTROLLER
+#endif
+
+#ifndef PMSG_SUSPEND
+#define PMSG_SUSPEND 3
+#endif
+
+#ifdef ESX35
+#endif
+
+/* generic boolean compatibility */
+#undef TRUE
+#undef FALSE
+#define TRUE true
+#define FALSE false
+#ifdef GCC_VERSION
+#if ( GCC_VERSION < 3000 )
+#define _Bool char
+#endif
+#endif
+#ifndef bool
+#define bool _Bool
+#define true 1
+#define false 0
+#endif
+
+
+#ifndef module_param
+#define module_param(v,t,p) MODULE_PARM(v, "i");
+#endif
+
+#ifndef DMA_64BIT_MASK
+#define DMA_64BIT_MASK  0xffffffffffffffffULL
+#endif
+
+#ifndef DMA_32BIT_MASK
+#define DMA_32BIT_MASK  0x00000000ffffffffULL
+#endif
+
+#ifndef PCI_CAP_ID_EXP
+#define PCI_CAP_ID_EXP 0x10
+#endif
+
+#ifndef PCIE_LINK_STATE_L0S
+#define PCIE_LINK_STATE_L0S 1
+#endif
+
+#ifndef mmiowb
+#ifdef CONFIG_IA64
+#define mmiowb() asm volatile ("mf.a" ::: "memory")
+#else
+#define mmiowb()
+#endif
+#endif
+
+#ifndef IRQ_HANDLED
+#define irqreturn_t void
+#define IRQ_HANDLED
+#define IRQ_NONE
+#endif
+
+#ifndef SET_NETDEV_DEV
+#define SET_NETDEV_DEV(net, pdev)
+#endif
+
+#ifndef HAVE_FREE_NETDEV
+#define free_netdev(x)	kfree(x)
+#endif
+
+#ifdef HAVE_POLL_CONTROLLER
+#define CONFIG_NET_POLL_CONTROLLER
+#endif
+
+#ifndef NETDEV_TX_OK
+#define NETDEV_TX_OK 0
+#endif
+
+#ifndef NETDEV_TX_BUSY
+#define NETDEV_TX_BUSY 1
+#endif
+
+#ifndef NETDEV_TX_LOCKED
+#define NETDEV_TX_LOCKED -1
+#endif
+
+#ifndef SKB_DATAREF_SHIFT
+/* if we do not have the infrastructure to detect if skb_header is cloned
+   just return false in all cases */
+#define skb_header_cloned(x) 0
+#endif
+
+#ifndef NETIF_F_GSO
+#define gso_size tso_size
+#define gso_segs tso_segs
+#endif
+
+#ifndef CHECKSUM_PARTIAL
+#define CHECKSUM_PARTIAL CHECKSUM_HW
+#define CHECKSUM_COMPLETE CHECKSUM_HW
+#endif
+
+#ifndef __read_mostly
+#define __read_mostly
+#endif
+
+#ifndef HAVE_NETIF_MSG
+#define HAVE_NETIF_MSG 1
+enum {
+	NETIF_MSG_DRV		= 0x0001,
+	NETIF_MSG_PROBE		= 0x0002,
+	NETIF_MSG_LINK		= 0x0004,
+	NETIF_MSG_TIMER		= 0x0008,
+	NETIF_MSG_IFDOWN	= 0x0010,
+	NETIF_MSG_IFUP		= 0x0020,
+	NETIF_MSG_RX_ERR	= 0x0040,
+	NETIF_MSG_TX_ERR	= 0x0080,
+	NETIF_MSG_TX_QUEUED	= 0x0100,
+	NETIF_MSG_INTR		= 0x0200,
+	NETIF_MSG_TX_DONE	= 0x0400,
+	NETIF_MSG_RX_STATUS	= 0x0800,
+	NETIF_MSG_PKTDATA	= 0x1000,
+	NETIF_MSG_HW		= 0x2000,
+	NETIF_MSG_WOL		= 0x4000,
+};
+
+#else
+#define NETIF_MSG_HW	0x2000
+#define NETIF_MSG_WOL	0x4000
+#endif /* HAVE_NETIF_MSG */
+
+#ifndef MII_RESV1
+#define MII_RESV1		0x17		/* Reserved...		*/
+#endif
+
+#ifndef unlikely
+#define unlikely(_x) _x
+#define likely(_x) _x
+#endif
+
+#ifndef WARN_ON
+#define WARN_ON(x)
+#endif
+
+#ifndef PCI_DEVICE
+#define PCI_DEVICE(vend,dev) \
+	.vendor = (vend), .device = (dev), \
+	.subvendor = PCI_ANY_ID, .subdevice = PCI_ANY_ID
+#endif
+
+#ifndef num_online_cpus
+#define num_online_cpus() smp_num_cpus
+#endif
+
+#ifndef _LINUX_RANDOM_H
+#include <linux/random.h>
+#endif
+
+#ifndef DECLARE_BITMAP
+#ifndef BITS_TO_LONGS
+#define BITS_TO_LONGS(bits) (((bits)+BITS_PER_LONG-1)/BITS_PER_LONG)
+#endif
+#define DECLARE_BITMAP(name,bits) long name[BITS_TO_LONGS(bits)]
+#endif
+
+#ifndef VLAN_HLEN
+#define VLAN_HLEN 4
+#endif
+
+#ifndef VLAN_ETH_HLEN
+#define VLAN_ETH_HLEN 18
+#endif
+
+#ifndef VLAN_ETH_FRAME_LEN
+#define VLAN_ETH_FRAME_LEN 1518
+#endif
+
+#ifndef DCA_GET_TAG_TWO_ARGS
+#define dca3_get_tag(a,b) dca_get_tag(b)
+#endif
+
+
+/*****************************************************************************/
+/* Installations with ethtool version without eeprom, adapter id, or statistics
+ * support */
+
+#ifndef ETH_GSTRING_LEN
+#define ETH_GSTRING_LEN 32
+#endif
+
+#ifndef ETHTOOL_GSTATS
+#define ETHTOOL_GSTATS 0x1d
+#undef ethtool_drvinfo
+#define ethtool_drvinfo k_ethtool_drvinfo
+struct k_ethtool_drvinfo {
+	u32 cmd;
+	char driver[32];
+	char version[32];
+	char fw_version[32];
+	char bus_info[32];
+	char reserved1[32];
+	char reserved2[16];
+	u32 n_stats;
+	u32 testinfo_len;
+	u32 eedump_len;
+	u32 regdump_len;
+};
+
+struct ethtool_stats {
+	u32 cmd;
+	u32 n_stats;
+	u64 data[0];
+};
+#endif /* ETHTOOL_GSTATS */
+
+#ifndef ETHTOOL_PHYS_ID
+#define ETHTOOL_PHYS_ID 0x1c
+#endif /* ETHTOOL_PHYS_ID */
+
+#ifndef ETHTOOL_GSTRINGS
+#define ETHTOOL_GSTRINGS 0x1b
+enum ethtool_stringset {
+	ETH_SS_TEST             = 0,
+	ETH_SS_STATS,
+};
+struct ethtool_gstrings {
+	u32 cmd;            /* ETHTOOL_GSTRINGS */
+	u32 string_set;     /* string set id e.c. ETH_SS_TEST, etc*/
+	u32 len;            /* number of strings in the string set */
+	u8 data[0];
+};
+#endif /* ETHTOOL_GSTRINGS */
+
+#ifndef ETHTOOL_TEST
+#define ETHTOOL_TEST 0x1a
+enum ethtool_test_flags {
+	ETH_TEST_FL_OFFLINE	= (1 << 0),
+	ETH_TEST_FL_FAILED	= (1 << 1),
+};
+struct ethtool_test {
+	u32 cmd;
+	u32 flags;
+	u32 reserved;
+	u32 len;
+	u64 data[0];
+};
+#endif /* ETHTOOL_TEST */
+
+#ifndef ETHTOOL_GEEPROM
+#define ETHTOOL_GEEPROM 0xb
+#undef ETHTOOL_GREGS
+struct ethtool_eeprom {
+	u32 cmd;
+	u32 magic;
+	u32 offset;
+	u32 len;
+	u8 data[0];
+};
+
+struct ethtool_value {
+	u32 cmd;
+	u32 data;
+};
+#endif /* ETHTOOL_GEEPROM */
+
+#ifndef ETHTOOL_GLINK
+#define ETHTOOL_GLINK 0xa
+#endif /* ETHTOOL_GLINK */
+
+#ifndef ETHTOOL_GREGS
+#define ETHTOOL_GREGS		0x00000004 /* Get NIC registers */
+#define ethtool_regs _kc_ethtool_regs
+/* for passing big chunks of data */
+struct _kc_ethtool_regs {
+	u32 cmd;
+	u32 version; /* driver-specific, indicates different chips/revs */
+	u32 len; /* bytes */
+	u8 data[0];
+};
+#endif /* ETHTOOL_GREGS */
+
+#ifndef ETHTOOL_GMSGLVL
+#define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
+#endif
+#ifndef ETHTOOL_SMSGLVL
+#define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level, priv. */
+#endif
+#ifndef ETHTOOL_NWAY_RST
+#define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation, priv */
+#endif
+#ifndef ETHTOOL_GLINK
+#define ETHTOOL_GLINK		0x0000000a /* Get link status */
+#endif
+#ifndef ETHTOOL_GEEPROM
+#define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
+#endif
+#ifndef ETHTOOL_SEEPROM
+#define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data */
+#endif
+#ifndef ETHTOOL_GCOALESCE
+#define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
+/* for configuring coalescing parameters of chip */
+#define ethtool_coalesce _kc_ethtool_coalesce
+struct _kc_ethtool_coalesce {
+	u32	cmd;	/* ETHTOOL_{G,S}COALESCE */
+
+	/* How many usecs to delay an RX interrupt after
+	 * a packet arrives.  If 0, only rx_max_coalesced_frames
+	 * is used.
+	 */
+	u32	rx_coalesce_usecs;
+
+	/* How many packets to delay an RX interrupt after
+	 * a packet arrives.  If 0, only rx_coalesce_usecs is
+	 * used.  It is illegal to set both usecs and max frames
+	 * to zero as this would cause RX interrupts to never be
+	 * generated.
+	 */
+	u32	rx_max_coalesced_frames;
+
+	/* Same as above two parameters, except that these values
+	 * apply while an IRQ is being serviced by the host.  Not
+	 * all cards support this feature and the values are ignored
+	 * in that case.
+	 */
+	u32	rx_coalesce_usecs_irq;
+	u32	rx_max_coalesced_frames_irq;
+
+	/* How many usecs to delay a TX interrupt after
+	 * a packet is sent.  If 0, only tx_max_coalesced_frames
+	 * is used.
+	 */
+	u32	tx_coalesce_usecs;
+
+	/* How many packets to delay a TX interrupt after
+	 * a packet is sent.  If 0, only tx_coalesce_usecs is
+	 * used.  It is illegal to set both usecs and max frames
+	 * to zero as this would cause TX interrupts to never be
+	 * generated.
+	 */
+	u32	tx_max_coalesced_frames;
+
+	/* Same as above two parameters, except that these values
+	 * apply while an IRQ is being serviced by the host.  Not
+	 * all cards support this feature and the values are ignored
+	 * in that case.
+	 */
+	u32	tx_coalesce_usecs_irq;
+	u32	tx_max_coalesced_frames_irq;
+
+	/* How many usecs to delay in-memory statistics
+	 * block updates.  Some drivers do not have an in-memory
+	 * statistic block, and in such cases this value is ignored.
+	 * This value must not be zero.
+	 */
+	u32	stats_block_coalesce_usecs;
+
+	/* Adaptive RX/TX coalescing is an algorithm implemented by
+	 * some drivers to improve latency under low packet rates and
+	 * improve throughput under high packet rates.  Some drivers
+	 * only implement one of RX or TX adaptive coalescing.  Anything
+	 * not implemented by the driver causes these values to be
+	 * silently ignored.
+	 */
+	u32	use_adaptive_rx_coalesce;
+	u32	use_adaptive_tx_coalesce;
+
+	/* When the packet rate (measured in packets per second)
+	 * is below pkt_rate_low, the {rx,tx}_*_low parameters are
+	 * used.
+	 */
+	u32	pkt_rate_low;
+	u32	rx_coalesce_usecs_low;
+	u32	rx_max_coalesced_frames_low;
+	u32	tx_coalesce_usecs_low;
+	u32	tx_max_coalesced_frames_low;
+
+	/* When the packet rate is below pkt_rate_high but above
+	 * pkt_rate_low (both measured in packets per second) the
+	 * normal {rx,tx}_* coalescing parameters are used.
+	 */
+
+	/* When the packet rate is (measured in packets per second)
+	 * is above pkt_rate_high, the {rx,tx}_*_high parameters are
+	 * used.
+	 */
+	u32	pkt_rate_high;
+	u32	rx_coalesce_usecs_high;
+	u32	rx_max_coalesced_frames_high;
+	u32	tx_coalesce_usecs_high;
+	u32	tx_max_coalesced_frames_high;
+
+	/* How often to do adaptive coalescing packet rate sampling,
+	 * measured in seconds.  Must not be zero.
+	 */
+	u32	rate_sample_interval;
+};
+#endif /* ETHTOOL_GCOALESCE */
+
+#ifndef ETHTOOL_SCOALESCE
+#define ETHTOOL_SCOALESCE	0x0000000f /* Set coalesce config. */
+#endif
+#ifndef ETHTOOL_GRINGPARAM
+#define ETHTOOL_GRINGPARAM	0x00000010 /* Get ring parameters */
+/* for configuring RX/TX ring parameters */
+#define ethtool_ringparam _kc_ethtool_ringparam
+struct _kc_ethtool_ringparam {
+	u32	cmd;	/* ETHTOOL_{G,S}RINGPARAM */
+
+	/* Read only attributes.  These indicate the maximum number
+	 * of pending RX/TX ring entries the driver will allow the
+	 * user to set.
+	 */
+	u32	rx_max_pending;
+	u32	rx_mini_max_pending;
+	u32	rx_jumbo_max_pending;
+	u32	tx_max_pending;
+
+	/* Values changeable by the user.  The valid values are
+	 * in the range 1 to the "*_max_pending" counterpart above.
+	 */
+	u32	rx_pending;
+	u32	rx_mini_pending;
+	u32	rx_jumbo_pending;
+	u32	tx_pending;
+};
+#endif /* ETHTOOL_GRINGPARAM */
+
+#ifndef ETHTOOL_SRINGPARAM
+#define ETHTOOL_SRINGPARAM	0x00000011 /* Set ring parameters, priv. */
+#endif
+#ifndef ETHTOOL_GPAUSEPARAM
+#define ETHTOOL_GPAUSEPARAM	0x00000012 /* Get pause parameters */
+/* for configuring link flow control parameters */
+#define ethtool_pauseparam _kc_ethtool_pauseparam
+struct _kc_ethtool_pauseparam {
+	u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
+
+	/* If the link is being auto-negotiated (via ethtool_cmd.autoneg
+	 * being true) the user may set 'autoneg' here non-zero to have the
+	 * pause parameters be auto-negotiated too.  In such a case, the
+	 * {rx,tx}_pause values below determine what capabilities are
+	 * advertised.
+	 *
+	 * If 'autoneg' is zero or the link is not being auto-negotiated,
+	 * then {rx,tx}_pause force the driver to use/not-use pause
+	 * flow control.
+	 */
+	u32	autoneg;
+	u32	rx_pause;
+	u32	tx_pause;
+};
+#endif /* ETHTOOL_GPAUSEPARAM */
+
+#ifndef ETHTOOL_SPAUSEPARAM
+#define ETHTOOL_SPAUSEPARAM	0x00000013 /* Set pause parameters. */
+#endif
+#ifndef ETHTOOL_GRXCSUM
+#define ETHTOOL_GRXCSUM		0x00000014 /* Get RX hw csum enable (ethtool_value) */
+#endif
+#ifndef ETHTOOL_SRXCSUM
+#define ETHTOOL_SRXCSUM		0x00000015 /* Set RX hw csum enable (ethtool_value) */
+#endif
+#ifndef ETHTOOL_GTXCSUM
+#define ETHTOOL_GTXCSUM		0x00000016 /* Get TX hw csum enable (ethtool_value) */
+#endif
+#ifndef ETHTOOL_STXCSUM
+#define ETHTOOL_STXCSUM		0x00000017 /* Set TX hw csum enable (ethtool_value) */
+#endif
+#ifndef ETHTOOL_GSG
+#define ETHTOOL_GSG		0x00000018 /* Get scatter-gather enable
+					    * (ethtool_value) */
+#endif
+#ifndef ETHTOOL_SSG
+#define ETHTOOL_SSG		0x00000019 /* Set scatter-gather enable
+					    * (ethtool_value). */
+#endif
+#ifndef ETHTOOL_TEST
+#define ETHTOOL_TEST		0x0000001a /* execute NIC self-test, priv. */
+#endif
+#ifndef ETHTOOL_GSTRINGS
+#define ETHTOOL_GSTRINGS	0x0000001b /* get specified string set */
+#endif
+#ifndef ETHTOOL_PHYS_ID
+#define ETHTOOL_PHYS_ID		0x0000001c /* identify the NIC */
+#endif
+#ifndef ETHTOOL_GSTATS
+#define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
+#endif
+#ifndef ETHTOOL_GTSO
+#define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
+#endif
+#ifndef ETHTOOL_STSO
+#define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
+#endif
+
+#ifndef ETHTOOL_BUSINFO_LEN
+#define ETHTOOL_BUSINFO_LEN	32
+#endif
+
+/*****************************************************************************/
+/* 2.4.3 => 2.4.0 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,3) )
+
+/**************************************/
+/* PCI DRIVER API */
+
+#ifndef pci_set_dma_mask
+#define pci_set_dma_mask _kc_pci_set_dma_mask
+extern int _kc_pci_set_dma_mask(struct pci_dev *dev, dma_addr_t mask);
+#endif
+
+#ifndef pci_request_regions
+#define pci_request_regions _kc_pci_request_regions
+extern int _kc_pci_request_regions(struct pci_dev *pdev, char *res_name);
+#endif
+
+#ifndef pci_release_regions
+#define pci_release_regions _kc_pci_release_regions
+extern void _kc_pci_release_regions(struct pci_dev *pdev);
+#endif
+
+/**************************************/
+/* NETWORK DRIVER API */
+
+#ifndef alloc_etherdev
+#define alloc_etherdev _kc_alloc_etherdev
+extern struct net_device * _kc_alloc_etherdev(int sizeof_priv);
+#endif
+
+#ifndef is_valid_ether_addr
+#define is_valid_ether_addr _kc_is_valid_ether_addr
+extern int _kc_is_valid_ether_addr(u8 *addr);
+#endif
+
+/**************************************/
+/* MISCELLANEOUS */
+
+#ifndef INIT_TQUEUE
+#define INIT_TQUEUE(_tq, _routine, _data)		\
+	do {						\
+		INIT_LIST_HEAD(&(_tq)->list);		\
+		(_tq)->sync = 0;			\
+		(_tq)->routine = _routine;		\
+		(_tq)->data = _data;			\
+	} while (0)
+#endif
+
+#endif /* 2.4.3 => 2.4.0 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,5) )
+/* Generic MII registers. */
+#define MII_BMCR            0x00        /* Basic mode control register */
+#define MII_BMSR            0x01        /* Basic mode status register  */
+#define MII_PHYSID1         0x02        /* PHYS ID 1                   */
+#define MII_PHYSID2         0x03        /* PHYS ID 2                   */
+#define MII_ADVERTISE       0x04        /* Advertisement control reg   */
+#define MII_LPA             0x05        /* Link partner ability reg    */
+#define MII_EXPANSION       0x06        /* Expansion register          */
+/* Basic mode control register. */
+#define BMCR_FULLDPLX           0x0100  /* Full duplex                 */
+#define BMCR_ANENABLE           0x1000  /* Enable auto negotiation     */
+/* Basic mode status register. */
+#define BMSR_ERCAP              0x0001  /* Ext-reg capability          */
+#define BMSR_ANEGCAPABLE        0x0008  /* Able to do auto-negotiation */
+#define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
+#define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
+#define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */
+#define BMSR_100FULL            0x4000  /* Can do 100mbps, full-duplex */
+/* Advertisement control register. */
+#define ADVERTISE_CSMA          0x0001  /* Only selector supported     */
+#define ADVERTISE_10HALF        0x0020  /* Try for 10mbps half-duplex  */
+#define ADVERTISE_10FULL        0x0040  /* Try for 10mbps full-duplex  */
+#define ADVERTISE_100HALF       0x0080  /* Try for 100mbps half-duplex */
+#define ADVERTISE_100FULL       0x0100  /* Try for 100mbps full-duplex */
+#define ADVERTISE_ALL (ADVERTISE_10HALF | ADVERTISE_10FULL | \
+                       ADVERTISE_100HALF | ADVERTISE_100FULL)
+/* Expansion register for auto-negotiation. */
+#define EXPANSION_ENABLENPAGE   0x0004  /* This enables npage words    */
+#endif
+
+/*****************************************************************************/
+/* 2.4.6 => 2.4.3 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,6) )
+
+#ifndef pci_set_power_state
+#define pci_set_power_state _kc_pci_set_power_state
+extern int _kc_pci_set_power_state(struct pci_dev *dev, int state);
+#endif
+
+#ifndef pci_enable_wake
+#define pci_enable_wake _kc_pci_enable_wake
+extern int _kc_pci_enable_wake(struct pci_dev *pdev, u32 state, int enable);
+#endif
+
+#ifndef pci_disable_device
+#define pci_disable_device _kc_pci_disable_device
+extern void _kc_pci_disable_device(struct pci_dev *pdev);
+#endif
+
+/* PCI PM entry point syntax changed, so don't support suspend/resume */
+#undef CONFIG_PM
+
+#endif /* 2.4.6 => 2.4.3 */
+
+#ifndef HAVE_PCI_SET_MWI
+#define pci_set_mwi(X) pci_write_config_word(X, \
+			       PCI_COMMAND, adapter->hw.bus.pci_cmd_word | \
+			       PCI_COMMAND_INVALIDATE);
+#define pci_clear_mwi(X) pci_write_config_word(X, \
+			       PCI_COMMAND, adapter->hw.bus.pci_cmd_word & \
+			       ~PCI_COMMAND_INVALIDATE);
+#endif
+
+/*****************************************************************************/
+/* 2.4.10 => 2.4.9 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,10) )
+
+/**************************************/
+/* MODULE API */
+
+#ifndef MODULE_LICENSE
+	#define MODULE_LICENSE(X)
+#endif
+
+/**************************************/
+/* OTHER */
+
+#undef min
+#define min(x,y) ({ \
+	const typeof(x) _x = (x);	\
+	const typeof(y) _y = (y);	\
+	(void) (&_x == &_y);		\
+	_x < _y ? _x : _y; })
+
+#undef max
+#define max(x,y) ({ \
+	const typeof(x) _x = (x);	\
+	const typeof(y) _y = (y);	\
+	(void) (&_x == &_y);		\
+	_x > _y ? _x : _y; })
+
+#ifndef list_for_each_safe
+#define list_for_each_safe(pos, n, head) \
+	for (pos = (head)->next, n = pos->next; pos != (head); \
+		pos = n, n = pos->next)
+#endif
+
+#endif /* 2.4.10 -> 2.4.6 */
+
+
+/*****************************************************************************/
+/* 2.4.13 => 2.4.10 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,13) )
+
+/**************************************/
+/* PCI DMA MAPPING */
+
+#ifndef virt_to_page
+	#define virt_to_page(v) (mem_map + (virt_to_phys(v) >> PAGE_SHIFT))
+#endif
+
+#ifndef pci_map_page
+#define pci_map_page _kc_pci_map_page
+extern u64 _kc_pci_map_page(struct pci_dev *dev, struct page *page, unsigned long offset, size_t size, int direction);
+#endif
+
+#ifndef pci_unmap_page
+#define pci_unmap_page _kc_pci_unmap_page
+extern void _kc_pci_unmap_page(struct pci_dev *dev, u64 dma_addr, size_t size, int direction);
+#endif
+
+/* pci_set_dma_mask takes dma_addr_t, which is only 32-bits prior to 2.4.13 */
+
+#undef DMA_32BIT_MASK
+#define DMA_32BIT_MASK	0xffffffff
+#undef DMA_64BIT_MASK
+#define DMA_64BIT_MASK	0xffffffff
+
+/**************************************/
+/* OTHER */
+
+#ifndef cpu_relax
+#define cpu_relax()	rep_nop()
+#endif
+
+#endif /* 2.4.13 => 2.4.10 */
+
+/*****************************************************************************/
+/* 2.4.17 => 2.4.12 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,17) )
+
+#ifndef __devexit_p
+	#define __devexit_p(x) &(x)
+#endif
+
+#endif /* 2.4.17 => 2.4.13 */
+
+/*****************************************************************************/
+/* 2.4.20 => 2.4.19 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,20) )
+
+/* we won't support NAPI on less than 2.4.20 */
+#ifdef NAPI
+#undef CONFIG_E1000_NAPI
+#undef CONFIG_E1000E_NAPI
+#undef CONFIG_IXGB_NAPI
+#endif
+
+#endif /* 2.4.20 => 2.4.19 */
+/*****************************************************************************/
+/* 2.4.22 => 2.4.17 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,22) )
+#define pci_name(x)	((x)->slot_name)
+#endif
+
+/*****************************************************************************/
+/* 2.4.22 => 2.4.17 */
+
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,22) )
+#endif
+
+/*****************************************************************************/
+/*****************************************************************************/
+/* 2.4.23 => 2.4.22 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,23) )
+/*****************************************************************************/
+#ifdef NAPI
+#ifndef netif_poll_disable
+#define netif_poll_disable(x) _kc_netif_poll_disable(x)
+static inline void _kc_netif_poll_disable(struct net_device *netdev)
+{
+	while (test_and_set_bit(__LINK_STATE_RX_SCHED, &netdev->state)) {
+		/* No hurry */
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(1);
+	}
+}
+#endif
+
+#ifndef netif_poll_enable
+#define netif_poll_enable(x) _kc_netif_poll_enable(x)
+static inline void _kc_netif_poll_enable(struct net_device *netdev)
+{
+	clear_bit(__LINK_STATE_RX_SCHED, &netdev->state);
+}
+#endif
+#endif /* NAPI */
+#ifndef netif_tx_disable
+#define netif_tx_disable(x) _kc_netif_tx_disable(x)
+static inline void _kc_netif_tx_disable(struct net_device *dev)
+{
+	spin_lock_bh(&dev->xmit_lock);
+	netif_stop_queue(dev);
+	spin_unlock_bh(&dev->xmit_lock);
+}
+#endif
+#endif /* 2.4.23 => 2.4.22 */
+
+/*****************************************************************************/
+/* 2.6.4 => 2.6.0 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,25) || \
+    ( LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0) && \
+      LINUX_VERSION_CODE < KERNEL_VERSION(2,6,4) ) )
+#define ETHTOOL_OPS_COMPAT
+#endif /* 2.6.4 => 2.6.0 */
+
+/*****************************************************************************/
+/* 2.5.71 => 2.4.x */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,5,71) )
+#include <net/sock.h>
+#define sk_protocol protocol
+
+#define pci_get_device pci_find_device
+#endif /* 2.5.70 => 2.4.x */
+
+/*****************************************************************************/
+/* < 2.4.27 or 2.6.0 <= 2.6.5 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,27) || \
+    ( LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0) && \
+      LINUX_VERSION_CODE < KERNEL_VERSION(2,6,5) ) )
+
+#ifndef netif_msg_init
+#define netif_msg_init _kc_netif_msg_init
+static inline u32 _kc_netif_msg_init(int debug_value, int default_msg_enable_bits)
+{
+	/* use default */
+	if (debug_value < 0 || debug_value >= (sizeof(u32) * 8))
+		return default_msg_enable_bits;
+	if (debug_value == 0) /* no output */
+		return 0;
+	/* set low N bits */
+	return (1 << debug_value) -1;
+}
+#endif
+
+#endif /* < 2.4.27 or 2.6.0 <= 2.6.5 */
+/*****************************************************************************/
+#if (( LINUX_VERSION_CODE < KERNEL_VERSION(2,4,27) ) || \
+     (( LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0) ) && \
+      ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,3) )))
+#define netdev_priv(x) x->priv
+#endif
+
+/*****************************************************************************/
+/* <= 2.5.0 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0) )
+#undef pci_register_driver
+#define pci_register_driver pci_module_init
+
+#define dev_err(__unused_dev, format, arg...)            \
+	printk(KERN_ERR "%s: " format, pci_name(adapter->pdev) , ## arg)
+#define dev_warn(__unused_dev, format, arg...)            \
+	printk(KERN_WARNING "%s: " format, pci_name(pdev) , ## arg)
+
+/* hlist_* code - double linked lists */
+struct hlist_head {
+	struct hlist_node *first;
+};
+
+struct hlist_node {
+	struct hlist_node *next, **pprev;
+};
+
+static inline void __hlist_del(struct hlist_node *n)
+{
+	struct hlist_node *next = n->next;
+	struct hlist_node **pprev = n->pprev;
+	*pprev = next;
+	if (next)
+	next->pprev = pprev;
+}
+
+static inline void hlist_del(struct hlist_node *n)
+{
+	__hlist_del(n);
+	n->next = NULL;
+	n->pprev = NULL;
+}
+
+static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
+{
+	struct hlist_node *first = h->first;
+	n->next = first;
+	if (first)
+		first->pprev = &n->next;
+	h->first = n;
+	n->pprev = &h->first;
+}
+
+static inline int hlist_empty(const struct hlist_head *h)
+{
+	return !h->first;
+}
+#define HLIST_HEAD_INIT { .first = NULL }
+#define HLIST_HEAD(name) struct hlist_head name = {  .first = NULL }
+#define INIT_HLIST_HEAD(ptr) ((ptr)->first = NULL)
+static inline void INIT_HLIST_NODE(struct hlist_node *h)
+{
+	h->next = NULL;
+	h->pprev = NULL;
+}
+#define hlist_entry(ptr, type, member) container_of(ptr,type,member)
+
+#define hlist_for_each_entry(tpos, pos, head, member)                    \
+	for (pos = (head)->first;                                        \
+	     pos && ({ prefetch(pos->next); 1;}) &&                      \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+#define hlist_for_each_entry_safe(tpos, pos, n, head, member)            \
+	for (pos = (head)->first;                                        \
+	     pos && ({ n = pos->next; 1; }) &&                           \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = n)
+
+/* we ignore GFP here */
+#define dma_alloc_coherent(dv, sz, dma, gfp) \
+	pci_alloc_consistent(pdev, (sz), (dma))
+#define dma_free_coherent(dv, sz, addr, dma_addr) \
+	pci_free_consistent(pdev, (sz), (addr), (dma_addr))
+
+#ifndef might_sleep
+#define might_sleep()
+#endif
+
+#ifndef NETREG_REGISTERED
+#define NETREG_REGISTERED 1
+#define reg_state deadbeaf
+#endif
+#endif /* <= 2.5.0 */
+
+/*****************************************************************************/
+/* 2.5.28 => 2.4.23 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,5,28) )
+
+static inline void _kc_synchronize_irq(void)
+{
+	synchronize_irq();
+}
+#undef synchronize_irq
+#define synchronize_irq(X) _kc_synchronize_irq()
+
+#include <linux/tqueue.h>
+#define work_struct tq_struct
+#undef INIT_WORK
+#define INIT_WORK(a,b) INIT_TQUEUE(a,(void (*)(void *))b,a)
+#undef container_of
+#define container_of list_entry
+#define schedule_work schedule_task
+#define flush_scheduled_work flush_scheduled_tasks
+#define cancel_work_sync(x) flush_scheduled_work()
+
+#endif /* 2.5.28 => 2.4.17 */
+
+/*****************************************************************************/
+/* 2.6.0 => 2.5.28 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0) )
+#define MODULE_INFO(version, _version)
+#ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
+#define CONFIG_E1000_DISABLE_PACKET_SPLIT 1
+#endif
+#ifndef CONFIG_IGB_DISABLE_PACKET_SPLIT
+#define CONFIG_IGB_DISABLE_PACKET_SPLIT 1
+#endif
+
+#define pci_set_consistent_dma_mask(dev,mask) 1
+
+#undef dev_put
+#define dev_put(dev) __dev_put(dev)
+
+#ifndef skb_fill_page_desc
+#define skb_fill_page_desc _kc_skb_fill_page_desc
+extern void _kc_skb_fill_page_desc(struct sk_buff *skb, int i, struct page *page, int off, int size);
+#endif
+
+#undef ALIGN
+#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
+
+#ifndef page_count
+#define page_count(p) atomic_read(&(p)->count)
+#endif
+
+/* find_first_bit and find_next bit are not defined for most
+ * 2.4 kernels (except for the redhat 2.4.21 kernels
+ */
+#include <linux/bitops.h>
+#define BITOP_WORD(nr)          ((nr) / BITS_PER_LONG)
+#undef find_next_bit
+#define find_next_bit _kc_find_next_bit
+extern unsigned long _kc_find_next_bit(const unsigned long *addr,
+                                       unsigned long size,
+                                       unsigned long offset);
+#define find_first_bit(addr, size) find_next_bit((addr), (size), 0)
+
+#endif /* 2.6.0 => 2.5.28 */
+
+/*****************************************************************************/
+/* 2.6.4 => 2.6.0 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,4) )
+#define MODULE_VERSION(_version) MODULE_INFO(version, _version)
+#endif /* 2.6.4 => 2.6.0 */
+
+/*****************************************************************************/
+/* 2.6.5 => 2.6.0 */
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,5) )
+#define pci_dma_sync_single_for_cpu	pci_dma_sync_single
+#define pci_dma_sync_single_for_device	pci_dma_sync_single_for_cpu
+#endif /* 2.6.5 => 2.6.0 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,6) )
+/* taken from 2.6 include/linux/bitmap.h */
+#undef bitmap_zero
+#define bitmap_zero _kc_bitmap_zero
+static inline void _kc_bitmap_zero(unsigned long *dst, int nbits)
+{
+        if (nbits <= BITS_PER_LONG)
+                *dst = 0UL;
+        else {
+                int len = BITS_TO_LONGS(nbits) * sizeof(unsigned long);
+                memset(dst, 0, len);
+        }
+}
+#endif /* < 2.6.6 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,7) )
+#undef if_mii
+#define if_mii _kc_if_mii
+static inline struct mii_ioctl_data *_kc_if_mii(struct ifreq *rq)
+{
+	return (struct mii_ioctl_data *) &rq->ifr_ifru;
+}
+#endif /* < 2.6.7 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,8) )
+#ifndef PCI_EXP_DEVCTL
+#define PCI_EXP_DEVCTL 8
+#endif
+#ifndef PCI_EXP_DEVCTL_CERE
+#define PCI_EXP_DEVCTL_CERE 0x0001
+#endif
+#define msleep(x)	do { set_current_state(TASK_UNINTERRUPTIBLE); \
+				schedule_timeout((x * HZ)/1000 + 2); \
+			} while (0)
+
+#endif /* < 2.6.8 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,9))
+#include <net/dsfield.h>
+#define __iomem
+
+#ifndef kcalloc
+#define kcalloc(n, size, flags) _kc_kzalloc(((n) * (size)), flags)
+extern void *_kc_kzalloc(size_t size, int flags);
+#endif
+#define MSEC_PER_SEC    1000L
+static inline unsigned int _kc_jiffies_to_msecs(const unsigned long j)
+{
+#if HZ <= MSEC_PER_SEC && !(MSEC_PER_SEC % HZ)
+	return (MSEC_PER_SEC / HZ) * j;
+#elif HZ > MSEC_PER_SEC && !(HZ % MSEC_PER_SEC)
+	return (j + (HZ / MSEC_PER_SEC) - 1)/(HZ / MSEC_PER_SEC);
+#else
+	return (j * MSEC_PER_SEC) / HZ;
+#endif
+}
+static inline unsigned long _kc_msecs_to_jiffies(const unsigned int m)
+{
+	if (m > _kc_jiffies_to_msecs(MAX_JIFFY_OFFSET))
+		return MAX_JIFFY_OFFSET;
+#if HZ <= MSEC_PER_SEC && !(MSEC_PER_SEC % HZ)
+	return (m + (MSEC_PER_SEC / HZ) - 1) / (MSEC_PER_SEC / HZ);
+#elif HZ > MSEC_PER_SEC && !(HZ % MSEC_PER_SEC)
+	return m * (HZ / MSEC_PER_SEC);
+#else
+	return (m * HZ + MSEC_PER_SEC - 1) / MSEC_PER_SEC;
+#endif
+}
+
+#define msleep_interruptible _kc_msleep_interruptible
+static inline unsigned long _kc_msleep_interruptible(unsigned int msecs)
+{
+	unsigned long timeout = _kc_msecs_to_jiffies(msecs) + 1;
+
+	while (timeout && !signal_pending(current)) {
+		__set_current_state(TASK_INTERRUPTIBLE);
+		timeout = schedule_timeout(timeout);
+	}
+	return _kc_jiffies_to_msecs(timeout);
+}
+
+/* Basic mode control register. */
+#define BMCR_SPEED1000		0x0040  /* MSB of Speed (1000)         */
+
+#ifndef __le16
+#define __le16 u16
+#endif
+#ifndef __le32
+#define __le32 u32
+#endif
+#ifndef __le64
+#define __le64 u64
+#endif
+
+#ifdef pci_dma_mapping_error
+#undef pci_dma_mapping_error
+#endif
+#define pci_dma_mapping_error _kc_pci_dma_mapping_error
+static inline int _kc_pci_dma_mapping_error(struct pci_dev *pdev,
+                                            dma_addr_t dma_addr)
+{
+	return dma_addr == 0;
+}
+
+#endif /* < 2.6.9 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10) )
+#ifdef module_param_array_named
+#undef module_param_array_named
+#define module_param_array_named(name, array, type, nump, perm)          \
+	static struct kparam_array __param_arr_##name                    \
+	= { ARRAY_SIZE(array), nump, param_set_##type, param_get_##type, \
+	    sizeof(array[0]), array };                                   \
+	module_param_call(name, param_array_set, param_array_get,        \
+			  &__param_arr_##name, perm)
+#endif /* module_param_array_named */
+#endif /* < 2.6.10 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11) )
+#define PCI_D0      0
+#define PCI_D1      1
+#define PCI_D2      2
+#define PCI_D3hot   3
+#define PCI_D3cold  4
+#define pci_choose_state(pdev,state) state
+#define PMSG_SUSPEND 3
+#define PCI_EXP_LNKCTL	16
+
+#undef NETIF_F_LLTX
+
+#ifndef ARCH_HAS_PREFETCH
+#define prefetch(X)
+#endif
+
+#ifndef NET_IP_ALIGN
+#define NET_IP_ALIGN 2
+#endif
+
+#define KC_USEC_PER_SEC	1000000L
+#define usecs_to_jiffies _kc_usecs_to_jiffies
+static inline unsigned int _kc_jiffies_to_usecs(const unsigned long j)
+{
+#if HZ <= KC_USEC_PER_SEC && !(KC_USEC_PER_SEC % HZ)
+	return (KC_USEC_PER_SEC / HZ) * j;
+#elif HZ > KC_USEC_PER_SEC && !(HZ % KC_USEC_PER_SEC)
+	return (j + (HZ / KC_USEC_PER_SEC) - 1)/(HZ / KC_USEC_PER_SEC);
+#else
+	return (j * KC_USEC_PER_SEC) / HZ;
+#endif
+}
+static inline unsigned long _kc_usecs_to_jiffies(const unsigned int m)
+{
+	if (m > _kc_jiffies_to_usecs(MAX_JIFFY_OFFSET))
+		return MAX_JIFFY_OFFSET;
+#if HZ <= KC_USEC_PER_SEC && !(KC_USEC_PER_SEC % HZ)
+	return (m + (KC_USEC_PER_SEC / HZ) - 1) / (KC_USEC_PER_SEC / HZ);
+#elif HZ > KC_USEC_PER_SEC && !(HZ % KC_USEC_PER_SEC)
+	return m * (HZ / KC_USEC_PER_SEC);
+#else
+	return (m * HZ + KC_USEC_PER_SEC - 1) / KC_USEC_PER_SEC;
+#endif
+}
+#endif /* < 2.6.11 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,12) )
+#include <linux/reboot.h>
+#define USE_REBOOT_NOTIFIER
+
+/* Generic MII registers. */
+#define MII_CTRL1000        0x09        /* 1000BASE-T control          */
+#define MII_STAT1000        0x0a        /* 1000BASE-T status           */
+/* Advertisement control register. */
+#define ADVERTISE_PAUSE_CAP     0x0400  /* Try for pause               */
+#define ADVERTISE_PAUSE_ASYM    0x0800  /* Try for asymmetric pause     */
+/* 1000BASE-T Control register */
+#define ADVERTISE_1000FULL      0x0200  /* Advertise 1000BASE-T full duplex */
+#endif
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,14) )
+#define pm_message_t u32
+#ifndef kzalloc
+#define kzalloc _kc_kzalloc
+extern void *_kc_kzalloc(size_t size, int flags);
+#endif
+
+/* Generic MII registers. */
+#define MII_ESTATUS	    0x0f	/* Extended Status */
+/* Basic mode status register. */
+#define BMSR_ESTATEN		0x0100	/* Extended Status in R15 */
+/* Extended status register. */
+#define ESTATUS_1000_TFULL	0x2000	/* Can do 1000BT Full */
+#define ESTATUS_1000_THALF	0x1000	/* Can do 1000BT Half */
+#endif
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,15) )
+#ifndef device_can_wakeup
+#define device_can_wakeup(dev)	(1)
+#endif
+#ifndef device_set_wakeup_enable
+#define device_set_wakeup_enable(dev, val)	do{}while(0)
+#endif
+#endif /* < 2.6.15 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,16) )
+#undef HAVE_PCI_ERS
+#else /* 2.6.16 and above */
+#undef HAVE_PCI_ERS
+#define HAVE_PCI_ERS
+#endif
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,18) )
+
+#ifndef IRQF_PROBE_SHARED
+#ifdef SA_PROBEIRQ
+#define IRQF_PROBE_SHARED SA_PROBEIRQ
+#else
+#define IRQF_PROBE_SHARED 0
+#endif
+#endif
+
+#ifndef IRQF_SHARED
+#define IRQF_SHARED SA_SHIRQ
+#endif
+
+#ifndef ARRAY_SIZE
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
+#endif
+
+#ifndef netdev_alloc_skb
+#define netdev_alloc_skb _kc_netdev_alloc_skb
+extern struct sk_buff *_kc_netdev_alloc_skb(struct net_device *dev,
+                                            unsigned int length);
+#endif
+
+#ifndef skb_is_gso
+#ifdef NETIF_F_TSO
+#define skb_is_gso _kc_skb_is_gso
+static inline int _kc_skb_is_gso(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_size;
+}
+#else
+#define skb_is_gso(a) 0
+#endif
+#endif
+
+#endif /* < 2.6.18 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19) )
+
+#ifndef DIV_ROUND_UP
+#define DIV_ROUND_UP(n,d) (((n) + (d) - 1) / (d))
+#endif
+#if ( LINUX_VERSION_CODE >= KERNEL_VERSION(2,5,0) )
+#ifndef RHEL_RELEASE_CODE
+#define RHEL_RELEASE_CODE 0
+#endif
+#ifndef RHEL_RELEASE_VERSION
+#define RHEL_RELEASE_VERSION(a,b) 0
+#endif
+#ifndef AX_RELEASE_CODE
+#define AX_RELEASE_CODE 0
+#endif
+#ifndef AX_RELEASE_VERSION
+#define AX_RELEASE_VERSION(a,b) 0
+#endif
+#if (!(( RHEL_RELEASE_CODE > RHEL_RELEASE_VERSION(4,4) ) && ( RHEL_RELEASE_CODE < RHEL_RELEASE_VERSION(5,0) ) || ( RHEL_RELEASE_CODE > RHEL_RELEASE_VERSION(5,0) ) || (AX_RELEASE_CODE > AX_RELEASE_VERSION(3,0))))
+typedef irqreturn_t (*irq_handler_t)(int, void*, struct pt_regs *);
+#endif
+typedef irqreturn_t (*new_handler_t)(int, void*);
+static inline irqreturn_t _kc_request_irq(unsigned int irq, new_handler_t handler, unsigned long flags, const char *devname, void *dev_id)
+#else /* 2.4.x */
+typedef void (*irq_handler_t)(int, void*, struct pt_regs *);
+typedef void (*new_handler_t)(int, void*);
+static inline int _kc_request_irq(unsigned int irq, new_handler_t handler, unsigned long flags, const char *devname, void *dev_id)
+#endif /* >= 2.5.x */
+{
+	irq_handler_t new_handler = (irq_handler_t) handler;
+	return request_irq(irq, new_handler, flags, devname, dev_id);
+}
+
+#undef request_irq
+#define request_irq(irq, handler, flags, devname, dev_id) _kc_request_irq((irq), (handler), (flags), (devname), (dev_id))
+
+#define irq_handler_t new_handler_t
+/* pci_restore_state and pci_save_state handles MSI/PCIE from 2.6.19 */
+#define PCIE_CONFIG_SPACE_LEN 256
+#define PCI_CONFIG_SPACE_LEN 64
+#define PCIE_LINK_STATUS 0x12
+#define pci_config_space_ich8lan() do {} while (0)
+#undef pci_save_state
+extern int _kc_pci_save_state(struct pci_dev *);
+#define pci_save_state(pdev) _kc_pci_save_state(pdev)
+#undef pci_restore_state
+extern void _kc_pci_restore_state(struct pci_dev *);
+#define pci_restore_state(pdev) _kc_pci_restore_state(pdev)
+#ifdef HAVE_PCI_ERS
+#ifndef ESX40
+#undef free_netdev
+extern void _kc_free_netdev(struct net_device *);
+#define free_netdev(netdev) _kc_free_netdev(netdev)
+#endif /* ESX40 */
+#endif
+#define pci_enable_pcie_error_reporting(dev) do {} while (0)
+#define pci_disable_pcie_error_reporting(dev) do {} while (0)
+#define pci_cleanup_aer_uncorrect_error_status(dev) do {} while (0)
+#else /* 2.6.19 */
+#include <linux/aer.h>
+#endif /* < 2.6.19 */
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,20) )
+#if ( LINUX_VERSION_CODE >= KERNEL_VERSION(2,5,28) )
+#ifndef ESX40
+#undef INIT_WORK
+#define INIT_WORK(_work, _func) \
+do { \
+	INIT_LIST_HEAD(&(_work)->entry); \
+	(_work)->pending = 0; \
+	(_work)->func = (void (*)(void *))_func; \
+	(_work)->data = _work; \
+	init_timer(&(_work)->timer); \
+} while (0)
+#endif /* ESX40 */
+#endif
+
+#ifndef PCI_VDEVICE
+#define PCI_VDEVICE(ven, dev)        \
+	PCI_VENDOR_ID_##ven, (dev),  \
+	PCI_ANY_ID, PCI_ANY_ID, 0, 0
+#endif
+
+#ifndef round_jiffies
+#define round_jiffies(x) x
+#endif
+
+#define csum_offset csum
+
+#endif /* < 2.6.20 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,21) )
+#define vlan_group_get_device(vg, id) (vg->vlan_devices[id])
+#define vlan_group_set_device(vg, id, dev) if (vg) vg->vlan_devices[id] = dev;
+#define pci_channel_offline(pdev) (pdev->error_state && \
+	pdev->error_state != pci_channel_io_normal)
+#define pci_request_selected_regions(pdev, bars, name) \
+        pci_request_regions(pdev, name)
+#define pci_release_selected_regions(pdev, bars) pci_release_regions(pdev);
+#endif /* < 2.6.21 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,22) )
+#define tcp_hdr(skb) (skb->h.th)
+#define tcp_hdrlen(skb) (skb->h.th->doff << 2)
+#define skb_transport_offset(skb) (skb->h.raw - skb->data)
+#define skb_transport_header(skb) (skb->h.raw)
+#define ipv6_hdr(skb) (skb->nh.ipv6h)
+#define ip_hdr(skb) (skb->nh.iph)
+#define skb_network_offset(skb) (skb->nh.raw - skb->data)
+#define skb_network_header(skb) (skb->nh.raw)
+#define skb_tail_pointer(skb) skb->tail
+#define skb_copy_to_linear_data_offset(skb, offset, from, len) \
+                                 memcpy(skb->data + offset, from, len)
+#define skb_network_header_len(skb) (skb->h.raw - skb->nh.raw)
+#define pci_register_driver pci_module_init
+#define skb_mac_header(skb) skb->mac.raw
+
+#ifdef NETIF_F_MULTI_QUEUE
+#ifndef alloc_etherdev_mq
+#define alloc_etherdev_mq(_a, _b) alloc_etherdev(_a)
+#endif
+#endif /* NETIF_F_MULTI_QUEUE */
+
+#ifndef ETH_FCS_LEN
+#define ETH_FCS_LEN 4
+#endif
+#define cancel_work_sync(x) flush_scheduled_work()
+#endif /* < 2.6.22 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE > KERNEL_VERSION(2,6,22) )
+#undef ETHTOOL_GPERMADDR
+#undef SET_MODULE_OWNER
+#define SET_MODULE_OWNER(dev) do { } while (0)
+#endif /* > 2.6.22 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,24) )
+#ifndef ESX40
+/* NAPI API changes in 2.6.24 break everything */
+struct napi_struct {
+	/* used to look up the real NAPI polling routine */
+	int (*poll)(struct napi_struct *, int);
+	struct net_device poll_dev;
+	int weight;
+};
+#ifdef NAPI
+extern int __kc_adapter_clean(struct net_device *, int *);
+#define netif_rx_complete(netdev, napi) netif_rx_complete(netdev)
+#define netif_rx_schedule_prep(netdev, napi) netif_rx_schedule_prep(netdev)
+#define netif_rx_schedule(netdev, napi) netif_rx_schedule(netdev)
+#define __netif_rx_schedule(netdev, napi) __netif_rx_schedule(netdev)
+#define napi_enable(napi) netif_poll_enable(adapter->netdev)
+#define napi_disable(napi) netif_poll_disable(adapter->netdev)
+#define netif_napi_add(_netdev, _napi, _poll, _weight) \
+	do { \
+		struct napi_struct *__napi = (_napi); \
+		_netdev->poll = &(__kc_adapter_clean); \
+		_netdev->weight = (_weight); \
+		__napi->poll = &(_poll); \
+		__napi->weight = (_weight); \
+		netif_poll_disable(_netdev); \
+	} while (0)
+#define netif_napi_del(_a) do {} while (0)
+#else /* NAPI */
+#define netif_napi_add(_netdev, _napi, _poll, _weight) \
+	do { \
+		struct napi_struct *__napi = _napi; \
+		_netdev->poll = &(_poll); \
+		_netdev->weight = (_weight); \
+		__napi->poll = &(_poll); \
+		__napi->weight = (_weight); \
+	} while (0)
+#define netif_napi_del(_a) do {} while (0)
+#endif /* NAPI */
+
+#undef dev_get_by_name
+#define dev_get_by_name(_a, _b) dev_get_by_name(_b)
+#define __netif_subqueue_stopped(_a, _b) netif_subqueue_stopped(_a, _b)
+#else
+#define netif_napi_del(_a) do {} while (0)
+#endif /* ESX40 */
+#endif /* < 2.6.24 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE > KERNEL_VERSION(2,6,24) )
+#include <linux/pm_qos_params.h>
+#endif /* > 2.6.24 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,25) )
+#define PM_QOS_CPU_DMA_LATENCY	1
+
+#if ( LINUX_VERSION_CODE > KERNEL_VERSION(2,6,18) )
+#include <linux/latency.h>
+#define PM_QOS_DEFAULT_VALUE	INFINITE_LATENCY
+#define pm_qos_add_requirement(pm_qos_class, name, value) \
+		set_acceptable_latency(name, value)
+#define pm_qos_remove_requirement(pm_qos_class, name) \
+		remove_acceptable_latency(name)
+#define pm_qos_update_requirement(pm_qos_class, name, value) \
+		modify_acceptable_latency(name, value)
+#else
+#define PM_QOS_DEFAULT_VALUE	-1
+#define pm_qos_add_requirement(pm_qos_class, name, value)
+#define pm_qos_remove_requirement(pm_qos_class, name)
+#define pm_qos_update_requirement(pm_qos_class, name, value) { \
+	if (value != PM_QOS_DEFAULT_VALUE) { \
+		printk(KERN_WARNING "%s: unable to set PM QoS requirement\n", \
+			pci_name(adapter->pdev)); \
+	} \
+}
+#endif /* > 2.6.18 */
+
+#define pci_enable_device_mem(pdev) pci_enable_device(pdev)
+
+#endif /* < 2.6.25 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,26) )
+#else /* < 2.6.26 */
+#include <linux/pci-aspm.h>
+#define HAVE_NETDEV_VLAN_FEATURES
+#endif /* < 2.6.26 */
+
+/*****************************************************************************/
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27) )
+#if ( LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,15) )
+#undef device_set_wakeup_enable
+#define device_set_wakeup_enable(dev, val) \
+	do { \
+		u16 pmc = 0; \
+		int pm = pci_find_capability(adapter->pdev, PCI_CAP_ID_PM); \
+		if (pm) { \
+			pci_read_config_word(adapter->pdev, pm + PCI_PM_PMC, \
+				&pmc); \
+		} \
+		if (val && (pmc >> 11)) \
+			(dev)->power.can_wakeup = !!(val); \
+		(dev)->power.should_wakeup = !!(val); \
+	} while (0)
+#endif /* 2.6.15 through 2.6.27 */
+
+#ifndef netif_napi_del
+#define netif_napi_del(_a) do {} while (0)
+#ifdef NAPI
+#ifdef CONFIG_NETPOLL
+#undef netif_napi_del
+#define netif_napi_del(_a) list_del(&(_a)->dev_list);
+#endif
+#endif
+#endif /* netif_napi_del */
+#ifndef pci_dma_mapping_error
+#define pci_dma_mapping_error(pdev, dma_addr) pci_dma_mapping_error(dma_addr)
+#endif
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+#endif
+
+#ifdef HAVE_TX_MQ
+extern void _kc_netif_tx_stop_all_queues(struct net_device *);
+extern void _kc_netif_tx_wake_all_queues(struct net_device *);
+extern void _kc_netif_tx_start_all_queues(struct net_device *);
+#define netif_tx_stop_all_queues(a) _kc_netif_tx_stop_all_queues(a)
+#define netif_tx_wake_all_queues(a) _kc_netif_tx_wake_all_queues(a)
+#define netif_tx_start_all_queues(a) _kc_netif_tx_start_all_queues(a)
+#undef netif_stop_subqueue
+#define netif_stop_subqueue(_ndev,_qi) do { \
+	if (netif_is_multiqueue((_ndev))) \
+		netif_stop_subqueue((_ndev), (_qi)); \
+	else \
+		netif_stop_queue((_ndev)); \
+	} while (0)
+#undef netif_start_subqueue
+#define netif_start_subqueue(_ndev,_qi) do { \
+	if (netif_is_multiqueue((_ndev))) \
+		netif_start_subqueue((_ndev), (_qi)); \
+	else \
+		netif_start_queue((_ndev)); \
+	} while (0)
+#else /* CONFIG_NETDEVICES_MULTIQUEUE */
+#define netif_tx_stop_all_queues(a) netif_stop_queue(a)
+#define netif_tx_wake_all_queues(a) netif_wake_queue(a)
+#define netif_tx_start_all_queues(a) netif_start_queue(a)
+#define netif_stop_subqueue(_ndev,_qi) netif_stop_queue((_ndev))
+#define netif_start_subqueue(_ndev,_qi) netif_start_queue((_ndev))
+#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
+#ifndef NETIF_F_MULTI_QUEUE
+#define NETIF_F_MULTI_QUEUE 0
+#define netif_is_multiqueue(a) 0
+#define netif_wake_subqueue(a, b)
+#endif /* NETIF_F_MULTI_QUEUE */
+#else /* < 2.6.27 */
+#define HAVE_TX_MQ
+#endif /* < 2.6.27 */
+
+#endif /* _KCOMPAT_H_ */
diff -Npur igbvf-0.5.2/src/kcompat_ethtool.c igbvf-0.5.2.orig/src/kcompat_ethtool.c
--- igbvf-0.5.2/src/kcompat_ethtool.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/kcompat_ethtool.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,1169 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+/*
+ * net/core/ethtool.c - Ethtool ioctl handler
+ * Copyright (c) 2003 Matthew Wilcox <matthew@wil.cx>
+ *
+ * This file is where we call all the ethtool_ops commands to get
+ * the information ethtool needs.  We fall back to calling do_ioctl()
+ * for drivers which haven't been converted to ethtool_ops yet.
+ *
+ * It's GPL, stupid.
+ *
+ * Modification by sfeldma@pobox.com to work as backward compat
+ * solution for pre-ethtool_ops kernels.
+ * 	- copied struct ethtool_ops from ethtool.h
+ * 	- defined SET_ETHTOOL_OPS
+ * 	- put in some #ifndef NETIF_F_xxx wrappers
+ * 	- changes refs to dev->ethtool_ops to ethtool_ops
+ * 	- changed dev_ethtool to ethtool_ioctl
+ *      - remove EXPORT_SYMBOL()s
+ *      - added _kc_ prefix in built-in ethtool_op_xxx ops.
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <asm/uaccess.h>
+
+#include "kcompat.h"
+
+#undef SUPPORTED_10000baseT_Full
+#define SUPPORTED_10000baseT_Full	(1 << 12)
+#undef ADVERTISED_10000baseT_Full
+#define ADVERTISED_10000baseT_Full	(1 << 12)
+#undef SPEED_10000
+#define SPEED_10000		10000
+
+#undef ethtool_ops
+#define ethtool_ops _kc_ethtool_ops
+
+struct _kc_ethtool_ops {
+	int  (*get_settings)(struct net_device *, struct ethtool_cmd *);
+	int  (*set_settings)(struct net_device *, struct ethtool_cmd *);
+	void (*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
+	int  (*get_regs_len)(struct net_device *);
+	void (*get_regs)(struct net_device *, struct ethtool_regs *, void *);
+	void (*get_wol)(struct net_device *, struct ethtool_wolinfo *);
+	int  (*set_wol)(struct net_device *, struct ethtool_wolinfo *);
+	u32  (*get_msglevel)(struct net_device *);
+	void (*set_msglevel)(struct net_device *, u32);
+	int  (*nway_reset)(struct net_device *);
+	u32  (*get_link)(struct net_device *);
+	int  (*get_eeprom_len)(struct net_device *);
+	int  (*get_eeprom)(struct net_device *, struct ethtool_eeprom *, u8 *);
+	int  (*set_eeprom)(struct net_device *, struct ethtool_eeprom *, u8 *);
+	int  (*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
+	int  (*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
+	void (*get_ringparam)(struct net_device *, struct ethtool_ringparam *);
+	int  (*set_ringparam)(struct net_device *, struct ethtool_ringparam *);
+	void (*get_pauseparam)(struct net_device *,
+	                       struct ethtool_pauseparam*);
+	int  (*set_pauseparam)(struct net_device *,
+	                       struct ethtool_pauseparam*);
+	u32  (*get_rx_csum)(struct net_device *);
+	int  (*set_rx_csum)(struct net_device *, u32);
+	u32  (*get_tx_csum)(struct net_device *);
+	int  (*set_tx_csum)(struct net_device *, u32);
+	u32  (*get_sg)(struct net_device *);
+	int  (*set_sg)(struct net_device *, u32);
+	u32  (*get_tso)(struct net_device *);
+	int  (*set_tso)(struct net_device *, u32);
+	int  (*self_test_count)(struct net_device *);
+	void (*self_test)(struct net_device *, struct ethtool_test *, u64 *);
+	void (*get_strings)(struct net_device *, u32 stringset, u8 *);
+	int  (*phys_id)(struct net_device *, u32);
+	int  (*get_stats_count)(struct net_device *);
+	void (*get_ethtool_stats)(struct net_device *, struct ethtool_stats *,
+	                          u64 *);
+} *ethtool_ops = NULL;
+
+#undef SET_ETHTOOL_OPS
+#define SET_ETHTOOL_OPS(netdev, ops) (ethtool_ops = (ops))
+
+/*
+ * Some useful ethtool_ops methods that are device independent. If we find that
+ * all drivers want to do the same thing here, we can turn these into dev_()
+ * function calls.
+ */
+
+#undef ethtool_op_get_link
+#define ethtool_op_get_link _kc_ethtool_op_get_link
+u32 _kc_ethtool_op_get_link(struct net_device *dev)
+{
+	return netif_carrier_ok(dev) ? 1 : 0;
+}
+
+#undef ethtool_op_get_tx_csum
+#define ethtool_op_get_tx_csum _kc_ethtool_op_get_tx_csum
+u32 _kc_ethtool_op_get_tx_csum(struct net_device *dev)
+{
+#ifdef NETIF_F_IP_CSUM
+	return (dev->features & NETIF_F_IP_CSUM) != 0;
+#else
+	return 0;
+#endif
+}
+
+#undef ethtool_op_set_tx_csum
+#define ethtool_op_set_tx_csum _kc_ethtool_op_set_tx_csum
+int _kc_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
+{
+#ifdef NETIF_F_IP_CSUM
+	if (data)
+#ifdef NETIF_F_IPV6_CSUM
+		dev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+	else
+		dev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+#else
+		dev->features |= NETIF_F_IP_CSUM;
+	else
+		dev->features &= ~NETIF_F_IP_CSUM;
+#endif
+#endif
+
+	return 0;
+}
+
+#undef ethtool_op_get_sg
+#define ethtool_op_get_sg _kc_ethtool_op_get_sg
+u32 _kc_ethtool_op_get_sg(struct net_device *dev)
+{
+#ifdef NETIF_F_SG
+	return (dev->features & NETIF_F_SG) != 0;
+#else
+	return 0;
+#endif
+}
+
+#undef ethtool_op_set_sg
+#define ethtool_op_set_sg _kc_ethtool_op_set_sg
+int _kc_ethtool_op_set_sg(struct net_device *dev, u32 data)
+{
+#ifdef NETIF_F_SG
+	if (data)
+		dev->features |= NETIF_F_SG;
+	else
+		dev->features &= ~NETIF_F_SG;
+#endif
+
+	return 0;
+}
+
+#undef ethtool_op_get_tso
+#define ethtool_op_get_tso _kc_ethtool_op_get_tso
+u32 _kc_ethtool_op_get_tso(struct net_device *dev)
+{
+#ifdef NETIF_F_TSO
+	return (dev->features & NETIF_F_TSO) != 0;
+#else
+	return 0;
+#endif
+}
+
+#undef ethtool_op_set_tso
+#define ethtool_op_set_tso _kc_ethtool_op_set_tso
+int _kc_ethtool_op_set_tso(struct net_device *dev, u32 data)
+{
+#ifdef NETIF_F_TSO
+	if (data)
+		dev->features |= NETIF_F_TSO;
+	else
+		dev->features &= ~NETIF_F_TSO;
+#endif
+
+	return 0;
+}
+
+/* Handlers for each ethtool command */
+
+static int ethtool_get_settings(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_cmd cmd = { ETHTOOL_GSET };
+	int err;
+
+	if (!ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	err = ethtool_ops->get_settings(dev, &cmd);
+	if (err < 0)
+		return err;
+
+	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_settings(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_cmd cmd;
+
+	if (!ethtool_ops->set_settings)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+
+	return ethtool_ops->set_settings(dev, &cmd);
+}
+
+static int ethtool_get_drvinfo(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_drvinfo info;
+	struct ethtool_ops *ops = ethtool_ops;
+
+	if (!ops->get_drvinfo)
+		return -EOPNOTSUPP;
+
+	memset(&info, 0, sizeof(info));
+	info.cmd = ETHTOOL_GDRVINFO;
+	ops->get_drvinfo(dev, &info);
+
+	if (ops->self_test_count)
+		info.testinfo_len = ops->self_test_count(dev);
+	if (ops->get_stats_count)
+		info.n_stats = ops->get_stats_count(dev);
+	if (ops->get_regs_len)
+		info.regdump_len = ops->get_regs_len(dev);
+	if (ops->get_eeprom_len)
+		info.eedump_len = ops->get_eeprom_len(dev);
+
+	if (copy_to_user(useraddr, &info, sizeof(info)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_get_regs(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_regs regs;
+	struct ethtool_ops *ops = ethtool_ops;
+	void *regbuf;
+	int reglen, ret;
+
+	if (!ops->get_regs || !ops->get_regs_len)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&regs, useraddr, sizeof(regs)))
+		return -EFAULT;
+
+	reglen = ops->get_regs_len(dev);
+	if (regs.len > reglen)
+		regs.len = reglen;
+
+	regbuf = kmalloc(reglen, GFP_USER);
+	if (!regbuf)
+		return -ENOMEM;
+
+	ops->get_regs(dev, &regs, regbuf);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &regs, sizeof(regs)))
+		goto out;
+	useraddr += offsetof(struct ethtool_regs, data);
+	if (copy_to_user(useraddr, regbuf, reglen))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(regbuf);
+	return ret;
+}
+
+static int ethtool_get_wol(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_wolinfo wol = { ETHTOOL_GWOL };
+
+	if (!ethtool_ops->get_wol)
+		return -EOPNOTSUPP;
+
+	ethtool_ops->get_wol(dev, &wol);
+
+	if (copy_to_user(useraddr, &wol, sizeof(wol)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_wol(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_wolinfo wol;
+
+	if (!ethtool_ops->set_wol)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&wol, useraddr, sizeof(wol)))
+		return -EFAULT;
+
+	return ethtool_ops->set_wol(dev, &wol);
+}
+
+static int ethtool_get_msglevel(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GMSGLVL };
+
+	if (!ethtool_ops->get_msglevel)
+		return -EOPNOTSUPP;
+
+	edata.data = ethtool_ops->get_msglevel(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_msglevel(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!ethtool_ops->set_msglevel)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	ethtool_ops->set_msglevel(dev, edata.data);
+	return 0;
+}
+
+static int ethtool_nway_reset(struct net_device *dev)
+{
+	if (!ethtool_ops->nway_reset)
+		return -EOPNOTSUPP;
+
+	return ethtool_ops->nway_reset(dev);
+}
+
+static int ethtool_get_link(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GLINK };
+
+	if (!ethtool_ops->get_link)
+		return -EOPNOTSUPP;
+
+	edata.data = ethtool_ops->get_link(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_get_eeprom(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_eeprom eeprom;
+	struct ethtool_ops *ops = ethtool_ops;
+	u8 *data;
+	int ret;
+
+	if (!ops->get_eeprom || !ops->get_eeprom_len)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
+		return -EFAULT;
+
+	/* Check for wrap and zero */
+	if (eeprom.offset + eeprom.len <= eeprom.offset)
+		return -EINVAL;
+
+	/* Check for exceeding total eeprom len */
+	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
+		return -EINVAL;
+
+	data = kmalloc(eeprom.len, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
+		goto out;
+
+	ret = ops->get_eeprom(dev, &eeprom, data);
+	if (ret)
+		goto out;
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &eeprom, sizeof(eeprom)))
+		goto out;
+	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(data);
+	return ret;
+}
+
+static int ethtool_set_eeprom(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_eeprom eeprom;
+	struct ethtool_ops *ops = ethtool_ops;
+	u8 *data;
+	int ret;
+
+	if (!ops->set_eeprom || !ops->get_eeprom_len)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&eeprom, useraddr, sizeof(eeprom)))
+		return -EFAULT;
+
+	/* Check for wrap and zero */
+	if (eeprom.offset + eeprom.len <= eeprom.offset)
+		return -EINVAL;
+
+	/* Check for exceeding total eeprom len */
+	if (eeprom.offset + eeprom.len > ops->get_eeprom_len(dev))
+		return -EINVAL;
+
+	data = kmalloc(eeprom.len, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	ret = -EFAULT;
+	if (copy_from_user(data, useraddr + sizeof(eeprom), eeprom.len))
+		goto out;
+
+	ret = ops->set_eeprom(dev, &eeprom, data);
+	if (ret)
+		goto out;
+
+	if (copy_to_user(useraddr + sizeof(eeprom), data, eeprom.len))
+		ret = -EFAULT;
+
+out:
+	kfree(data);
+	return ret;
+}
+
+static int ethtool_get_coalesce(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_coalesce coalesce = { ETHTOOL_GCOALESCE };
+
+	if (!ethtool_ops->get_coalesce)
+		return -EOPNOTSUPP;
+
+	ethtool_ops->get_coalesce(dev, &coalesce);
+
+	if (copy_to_user(useraddr, &coalesce, sizeof(coalesce)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_coalesce(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_coalesce coalesce;
+
+	if (!ethtool_ops->get_coalesce)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&coalesce, useraddr, sizeof(coalesce)))
+		return -EFAULT;
+
+	return ethtool_ops->set_coalesce(dev, &coalesce);
+}
+
+static int ethtool_get_ringparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_ringparam ringparam = { ETHTOOL_GRINGPARAM };
+
+	if (!ethtool_ops->get_ringparam)
+		return -EOPNOTSUPP;
+
+	ethtool_ops->get_ringparam(dev, &ringparam);
+
+	if (copy_to_user(useraddr, &ringparam, sizeof(ringparam)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_ringparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_ringparam ringparam;
+
+	if (!ethtool_ops->get_ringparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&ringparam, useraddr, sizeof(ringparam)))
+		return -EFAULT;
+
+	return ethtool_ops->set_ringparam(dev, &ringparam);
+}
+
+static int ethtool_get_pauseparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_pauseparam pauseparam = { ETHTOOL_GPAUSEPARAM };
+
+	if (!ethtool_ops->get_pauseparam)
+		return -EOPNOTSUPP;
+
+	ethtool_ops->get_pauseparam(dev, &pauseparam);
+
+	if (copy_to_user(useraddr, &pauseparam, sizeof(pauseparam)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_pauseparam(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_pauseparam pauseparam;
+
+	if (!ethtool_ops->get_pauseparam)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&pauseparam, useraddr, sizeof(pauseparam)))
+		return -EFAULT;
+
+	return ethtool_ops->set_pauseparam(dev, &pauseparam);
+}
+
+static int ethtool_get_rx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GRXCSUM };
+
+	if (!ethtool_ops->get_rx_csum)
+		return -EOPNOTSUPP;
+
+	edata.data = ethtool_ops->get_rx_csum(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_rx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!ethtool_ops->set_rx_csum)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	ethtool_ops->set_rx_csum(dev, edata.data);
+	return 0;
+}
+
+static int ethtool_get_tx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GTXCSUM };
+
+	if (!ethtool_ops->get_tx_csum)
+		return -EOPNOTSUPP;
+
+	edata.data = ethtool_ops->get_tx_csum(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_tx_csum(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!ethtool_ops->set_tx_csum)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return ethtool_ops->set_tx_csum(dev, edata.data);
+}
+
+static int ethtool_get_sg(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GSG };
+
+	if (!ethtool_ops->get_sg)
+		return -EOPNOTSUPP;
+
+	edata.data = ethtool_ops->get_sg(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_sg(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!ethtool_ops->set_sg)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return ethtool_ops->set_sg(dev, edata.data);
+}
+
+static int ethtool_get_tso(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GTSO };
+
+	if (!ethtool_ops->get_tso)
+		return -EOPNOTSUPP;
+
+	edata.data = ethtool_ops->get_tso(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_tso(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!ethtool_ops->set_tso)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	return ethtool_ops->set_tso(dev, edata.data);
+}
+
+static int ethtool_self_test(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_test test;
+	struct ethtool_ops *ops = ethtool_ops;
+	u64 *data;
+	int ret;
+
+	if (!ops->self_test || !ops->self_test_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&test, useraddr, sizeof(test)))
+		return -EFAULT;
+
+	test.len = ops->self_test_count(dev);
+	data = kmalloc(test.len * sizeof(u64), GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	ops->self_test(dev, &test, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &test, sizeof(test)))
+		goto out;
+	useraddr += sizeof(test);
+	if (copy_to_user(useraddr, data, test.len * sizeof(u64)))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(data);
+	return ret;
+}
+
+static int ethtool_get_strings(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_gstrings gstrings;
+	struct ethtool_ops *ops = ethtool_ops;
+	u8 *data;
+	int ret;
+
+	if (!ops->get_strings)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
+		return -EFAULT;
+
+	switch (gstrings.string_set) {
+	case ETH_SS_TEST:
+		if (!ops->self_test_count)
+			return -EOPNOTSUPP;
+		gstrings.len = ops->self_test_count(dev);
+		break;
+	case ETH_SS_STATS:
+		if (!ops->get_stats_count)
+			return -EOPNOTSUPP;
+		gstrings.len = ops->get_stats_count(dev);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	ops->get_strings(dev, gstrings.string_set, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
+		goto out;
+	useraddr += sizeof(gstrings);
+	if (copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(data);
+	return ret;
+}
+
+static int ethtool_phys_id(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_value id;
+
+	if (!ethtool_ops->phys_id)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&id, useraddr, sizeof(id)))
+		return -EFAULT;
+
+	return ethtool_ops->phys_id(dev, id.data);
+}
+
+static int ethtool_get_stats(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_stats stats;
+	struct ethtool_ops *ops = ethtool_ops;
+	u64 *data;
+	int ret;
+
+	if (!ops->get_ethtool_stats || !ops->get_stats_count)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&stats, useraddr, sizeof(stats)))
+		return -EFAULT;
+
+	stats.n_stats = ops->get_stats_count(dev);
+	data = kmalloc(stats.n_stats * sizeof(u64), GFP_USER);
+	if (!data)
+		return -ENOMEM;
+
+	ops->get_ethtool_stats(dev, &stats, data);
+
+	ret = -EFAULT;
+	if (copy_to_user(useraddr, &stats, sizeof(stats)))
+		goto out;
+	useraddr += sizeof(stats);
+	if (copy_to_user(useraddr, data, stats.n_stats * sizeof(u64)))
+		goto out;
+	ret = 0;
+
+out:
+	kfree(data);
+	return ret;
+}
+
+/* The main entry point in this file.  Called from net/core/dev.c */
+
+#define ETHTOOL_OPS_COMPAT
+int ethtool_ioctl(struct ifreq *ifr)
+{
+	struct net_device *dev = __dev_get_by_name(ifr->ifr_name);
+	void *useraddr = (void *) ifr->ifr_data;
+	u32 ethcmd;
+
+	/*
+	 * XXX: This can be pushed down into the ethtool_* handlers that
+	 * need it.  Keep existing behavior for the moment.
+	 */
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (!dev || !netif_device_present(dev))
+		return -ENODEV;
+
+	if (copy_from_user(&ethcmd, useraddr, sizeof (ethcmd)))
+		return -EFAULT;
+
+	switch (ethcmd) {
+	case ETHTOOL_GSET:
+		return ethtool_get_settings(dev, useraddr);
+	case ETHTOOL_SSET:
+		return ethtool_set_settings(dev, useraddr);
+	case ETHTOOL_GDRVINFO:
+		return ethtool_get_drvinfo(dev, useraddr);
+	case ETHTOOL_GREGS:
+		return ethtool_get_regs(dev, useraddr);
+	case ETHTOOL_GWOL:
+		return ethtool_get_wol(dev, useraddr);
+	case ETHTOOL_SWOL:
+		return ethtool_set_wol(dev, useraddr);
+	case ETHTOOL_GMSGLVL:
+		return ethtool_get_msglevel(dev, useraddr);
+	case ETHTOOL_SMSGLVL:
+		return ethtool_set_msglevel(dev, useraddr);
+	case ETHTOOL_NWAY_RST:
+		return ethtool_nway_reset(dev);
+	case ETHTOOL_GLINK:
+		return ethtool_get_link(dev, useraddr);
+	case ETHTOOL_GEEPROM:
+		return ethtool_get_eeprom(dev, useraddr);
+	case ETHTOOL_SEEPROM:
+		return ethtool_set_eeprom(dev, useraddr);
+	case ETHTOOL_GCOALESCE:
+		return ethtool_get_coalesce(dev, useraddr);
+	case ETHTOOL_SCOALESCE:
+		return ethtool_set_coalesce(dev, useraddr);
+	case ETHTOOL_GRINGPARAM:
+		return ethtool_get_ringparam(dev, useraddr);
+	case ETHTOOL_SRINGPARAM:
+		return ethtool_set_ringparam(dev, useraddr);
+	case ETHTOOL_GPAUSEPARAM:
+		return ethtool_get_pauseparam(dev, useraddr);
+	case ETHTOOL_SPAUSEPARAM:
+		return ethtool_set_pauseparam(dev, useraddr);
+	case ETHTOOL_GRXCSUM:
+		return ethtool_get_rx_csum(dev, useraddr);
+	case ETHTOOL_SRXCSUM:
+		return ethtool_set_rx_csum(dev, useraddr);
+	case ETHTOOL_GTXCSUM:
+		return ethtool_get_tx_csum(dev, useraddr);
+	case ETHTOOL_STXCSUM:
+		return ethtool_set_tx_csum(dev, useraddr);
+	case ETHTOOL_GSG:
+		return ethtool_get_sg(dev, useraddr);
+	case ETHTOOL_SSG:
+		return ethtool_set_sg(dev, useraddr);
+	case ETHTOOL_GTSO:
+		return ethtool_get_tso(dev, useraddr);
+	case ETHTOOL_STSO:
+		return ethtool_set_tso(dev, useraddr);
+	case ETHTOOL_TEST:
+		return ethtool_self_test(dev, useraddr);
+	case ETHTOOL_GSTRINGS:
+		return ethtool_get_strings(dev, useraddr);
+	case ETHTOOL_PHYS_ID:
+		return ethtool_phys_id(dev, useraddr);
+	case ETHTOOL_GSTATS:
+		return ethtool_get_stats(dev, useraddr);
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+#define mii_if_info _kc_mii_if_info
+struct _kc_mii_if_info {
+	int phy_id;
+	int advertising;
+	int phy_id_mask;
+	int reg_num_mask;
+
+	unsigned int full_duplex : 1;	/* is full duplex? */
+	unsigned int force_media : 1;	/* is autoneg. disabled? */
+
+	struct net_device *dev;
+	int (*mdio_read) (struct net_device *dev, int phy_id, int location);
+	void (*mdio_write) (struct net_device *dev, int phy_id, int location, int val);
+};
+
+struct ethtool_cmd;
+struct mii_ioctl_data;
+
+#undef mii_link_ok
+#define mii_link_ok _kc_mii_link_ok
+#undef mii_nway_restart
+#define mii_nway_restart _kc_mii_nway_restart
+#undef mii_ethtool_gset
+#define mii_ethtool_gset _kc_mii_ethtool_gset
+#undef mii_ethtool_sset
+#define mii_ethtool_sset _kc_mii_ethtool_sset
+#undef mii_check_link
+#define mii_check_link _kc_mii_check_link
+#undef generic_mii_ioctl
+#define generic_mii_ioctl _kc_generic_mii_ioctl
+extern int _kc_mii_link_ok (struct mii_if_info *mii);
+extern int _kc_mii_nway_restart (struct mii_if_info *mii);
+extern int _kc_mii_ethtool_gset(struct mii_if_info *mii,
+                                struct ethtool_cmd *ecmd);
+extern int _kc_mii_ethtool_sset(struct mii_if_info *mii,
+                                struct ethtool_cmd *ecmd);
+extern void _kc_mii_check_link (struct mii_if_info *mii);
+extern int _kc_generic_mii_ioctl(struct mii_if_info *mii_if,
+                                 struct mii_ioctl_data *mii_data, int cmd,
+                                 unsigned int *duplex_changed);
+
+
+struct _kc_pci_dev_ext {
+	struct pci_dev *dev;
+	void *pci_drvdata;
+	struct pci_driver *driver;
+};
+
+struct _kc_net_dev_ext {
+	struct net_device *dev;
+	unsigned int carrier;
+};
+
+
+/**************************************/
+/* mii support */
+
+int _kc_mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
+{
+	struct net_device *dev = mii->dev;
+	u32 advert, bmcr, lpa, nego;
+
+	ecmd->supported =
+	    (SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+	     SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
+	     SUPPORTED_Autoneg | SUPPORTED_TP | SUPPORTED_MII);
+
+	/* only supports twisted-pair */
+	ecmd->port = PORT_MII;
+
+	/* only supports internal transceiver */
+	ecmd->transceiver = XCVR_INTERNAL;
+
+	/* this isn't fully supported at higher layers */
+	ecmd->phy_address = mii->phy_id;
+
+	ecmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
+	advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
+	if (advert & ADVERTISE_10HALF)
+		ecmd->advertising |= ADVERTISED_10baseT_Half;
+	if (advert & ADVERTISE_10FULL)
+		ecmd->advertising |= ADVERTISED_10baseT_Full;
+	if (advert & ADVERTISE_100HALF)
+		ecmd->advertising |= ADVERTISED_100baseT_Half;
+	if (advert & ADVERTISE_100FULL)
+		ecmd->advertising |= ADVERTISED_100baseT_Full;
+
+	bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
+	lpa = mii->mdio_read(dev, mii->phy_id, MII_LPA);
+	if (bmcr & BMCR_ANENABLE) {
+		ecmd->advertising |= ADVERTISED_Autoneg;
+		ecmd->autoneg = AUTONEG_ENABLE;
+		
+		nego = mii_nway_result(advert & lpa);
+		if (nego == LPA_100FULL || nego == LPA_100HALF)
+			ecmd->speed = SPEED_100;
+		else
+			ecmd->speed = SPEED_10;
+		if (nego == LPA_100FULL || nego == LPA_10FULL) {
+			ecmd->duplex = DUPLEX_FULL;
+			mii->full_duplex = 1;
+		} else {
+			ecmd->duplex = DUPLEX_HALF;
+			mii->full_duplex = 0;
+		}
+	} else {
+		ecmd->autoneg = AUTONEG_DISABLE;
+
+		ecmd->speed = (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10;
+		ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
+	}
+
+	/* ignore maxtxpkt, maxrxpkt for now */
+
+	return 0;
+}
+
+int _kc_mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
+{
+	struct net_device *dev = mii->dev;
+
+	if (ecmd->speed != SPEED_10 && ecmd->speed != SPEED_100)
+		return -EINVAL;
+	if (ecmd->duplex != DUPLEX_HALF && ecmd->duplex != DUPLEX_FULL)
+		return -EINVAL;
+	if (ecmd->port != PORT_MII)
+		return -EINVAL;
+	if (ecmd->transceiver != XCVR_INTERNAL)
+		return -EINVAL;
+	if (ecmd->phy_address != mii->phy_id)
+		return -EINVAL;
+	if (ecmd->autoneg != AUTONEG_DISABLE && ecmd->autoneg != AUTONEG_ENABLE)
+		return -EINVAL;
+				  
+	/* ignore supported, maxtxpkt, maxrxpkt */
+	
+	if (ecmd->autoneg == AUTONEG_ENABLE) {
+		u32 bmcr, advert, tmp;
+
+		if ((ecmd->advertising & (ADVERTISED_10baseT_Half |
+					  ADVERTISED_10baseT_Full |
+					  ADVERTISED_100baseT_Half |
+					  ADVERTISED_100baseT_Full)) == 0)
+			return -EINVAL;
+
+		/* advertise only what has been requested */
+		advert = mii->mdio_read(dev, mii->phy_id, MII_ADVERTISE);
+		tmp = advert & ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
+		if (ADVERTISED_10baseT_Half)
+			tmp |= ADVERTISE_10HALF;
+		if (ADVERTISED_10baseT_Full)
+			tmp |= ADVERTISE_10FULL;
+		if (ADVERTISED_100baseT_Half)
+			tmp |= ADVERTISE_100HALF;
+		if (ADVERTISED_100baseT_Full)
+			tmp |= ADVERTISE_100FULL;
+		if (advert != tmp) {
+			mii->mdio_write(dev, mii->phy_id, MII_ADVERTISE, tmp);
+			mii->advertising = tmp;
+		}
+		
+		/* turn on autonegotiation, and force a renegotiate */
+		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
+		bmcr |= (BMCR_ANENABLE | BMCR_ANRESTART);
+		mii->mdio_write(dev, mii->phy_id, MII_BMCR, bmcr);
+
+		mii->force_media = 0;
+	} else {
+		u32 bmcr, tmp;
+
+		/* turn off auto negotiation, set speed and duplexity */
+		bmcr = mii->mdio_read(dev, mii->phy_id, MII_BMCR);
+		tmp = bmcr & ~(BMCR_ANENABLE | BMCR_SPEED100 | BMCR_FULLDPLX);
+		if (ecmd->speed == SPEED_100)
+			tmp |= BMCR_SPEED100;
+		if (ecmd->duplex == DUPLEX_FULL) {
+			tmp |= BMCR_FULLDPLX;
+			mii->full_duplex = 1;
+		} else
+			mii->full_duplex = 0;
+		if (bmcr != tmp)
+			mii->mdio_write(dev, mii->phy_id, MII_BMCR, tmp);
+
+		mii->force_media = 1;
+	}
+	return 0;
+}
+
+int _kc_mii_link_ok (struct mii_if_info *mii)
+{
+	/* first, a dummy read, needed to latch some MII phys */
+	mii->mdio_read(mii->dev, mii->phy_id, MII_BMSR);
+	if (mii->mdio_read(mii->dev, mii->phy_id, MII_BMSR) & BMSR_LSTATUS)
+		return 1;
+	return 0;
+}
+
+int _kc_mii_nway_restart (struct mii_if_info *mii)
+{
+	int bmcr;
+	int r = -EINVAL;
+
+	/* if autoneg is off, it's an error */
+	bmcr = mii->mdio_read(mii->dev, mii->phy_id, MII_BMCR);
+
+	if (bmcr & BMCR_ANENABLE) {
+		bmcr |= BMCR_ANRESTART;
+		mii->mdio_write(mii->dev, mii->phy_id, MII_BMCR, bmcr);
+		r = 0;
+	}
+
+	return r;
+}
+
+void _kc_mii_check_link (struct mii_if_info *mii)
+{
+	int cur_link = mii_link_ok(mii);
+	int prev_link = netif_carrier_ok(mii->dev);
+
+	if (cur_link && !prev_link)
+		netif_carrier_on(mii->dev);
+	else if (prev_link && !cur_link)
+		netif_carrier_off(mii->dev);
+}
+
+int _kc_generic_mii_ioctl(struct mii_if_info *mii_if,
+                          struct mii_ioctl_data *mii_data, int cmd,
+                          unsigned int *duplex_chg_out)
+{
+	int rc = 0;
+	unsigned int duplex_changed = 0;
+
+	if (duplex_chg_out)
+		*duplex_chg_out = 0;
+
+	mii_data->phy_id &= mii_if->phy_id_mask;
+	mii_data->reg_num &= mii_if->reg_num_mask;
+
+	switch(cmd) {
+	case SIOCDEVPRIVATE:	/* binary compat, remove in 2.5 */
+	case SIOCGMIIPHY:
+		mii_data->phy_id = mii_if->phy_id;
+		/* fall through */
+
+	case SIOCDEVPRIVATE + 1:/* binary compat, remove in 2.5 */
+	case SIOCGMIIREG:
+		mii_data->val_out =
+			mii_if->mdio_read(mii_if->dev, mii_data->phy_id,
+					  mii_data->reg_num);
+		break;
+
+	case SIOCDEVPRIVATE + 2:/* binary compat, remove in 2.5 */
+	case SIOCSMIIREG: {
+		u16 val = mii_data->val_in;
+
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (mii_data->phy_id == mii_if->phy_id) {
+			switch(mii_data->reg_num) {
+			case MII_BMCR: {
+				unsigned int new_duplex = 0;
+				if (val & (BMCR_RESET|BMCR_ANENABLE))
+					mii_if->force_media = 0;
+				else
+					mii_if->force_media = 1;
+				if (mii_if->force_media &&
+				    (val & BMCR_FULLDPLX))
+					new_duplex = 1;
+				if (mii_if->full_duplex != new_duplex) {
+					duplex_changed = 1;
+					mii_if->full_duplex = new_duplex;
+				}
+				break;
+			}
+			case MII_ADVERTISE:
+				mii_if->advertising = val;
+				break;
+			default:
+				/* do nothing */
+				break;
+			}
+		}
+
+		mii_if->mdio_write(mii_if->dev, mii_data->phy_id,
+				   mii_data->reg_num, val);
+		break;
+	}
+
+	default:
+		rc = -EOPNOTSUPP;
+		break;
+	}
+
+	if ((rc == 0) && (duplex_chg_out) && (duplex_changed))
+		*duplex_chg_out = 1;
+
+	return rc;
+}
+
diff -Npur igbvf-0.5.2/src/netdev.c igbvf-0.5.2.orig/src/netdev.c
--- igbvf-0.5.2/src/netdev.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/netdev.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,3372 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/pci.h>
+#include <linux/vmalloc.h>
+#include <linux/pagemap.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/tcp.h>
+#include <linux/ipv6.h>
+#ifdef NETIF_F_TSO
+#include <net/checksum.h>
+#ifdef NETIF_F_TSO6
+#include <net/ip6_checksum.h>
+#endif
+#endif
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+
+#include "igbvf.h"
+
+#include "e1000_82575.h"
+
+#define DRV_DEBUG ""
+
+#define DRV_VERSION "0.5.2" DRV_DEBUG
+char igbvf_driver_name[] = "igbvf";
+const char igbvf_driver_version[] = DRV_VERSION;
+
+extern void      e1000_init_function_pointers_vf(struct e1000_hw *hw);
+extern s32       e1000_init_phy_params_vf(struct e1000_hw *hw);
+extern s32       e1000_init_nvm_params_vf(struct e1000_hw *hw);
+extern s32       e1000_init_mac_params_vf(struct e1000_hw *hw);
+
+void igbvf_dump_interrupt_registers(struct igbvf_adapter *adapter);
+
+static s32 igbvf_get_variants_vf(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	e1000_init_mac_ops_generic(hw);
+	e1000_init_nvm_ops_generic(hw);
+	e1000_init_phy_ops_generic(hw);
+
+	hw->mac.ops.shutdown_serdes = &e1000_null_mac_generic;
+	hw->mac.ops.config_collision_dist = &e1000_null_mac_generic;
+	hw->mac.ops.validate_mdi_setting = &e1000_null_ops_generic;
+
+	return 0;
+}
+
+static struct igbvf_info igbvf_vf_info = {
+	.mac			= e1000_vfadapt,
+	.flags			= FLAG_HAS_JUMBO_FRAMES
+	                          | FLAG_RX_CSUM_ENABLED,
+	.pba			= 10,
+	.init_ops		= e1000_init_function_pointers_vf,
+	.get_variants		= igbvf_get_variants_vf,
+};
+
+static const struct igbvf_info *igbvf_info_tbl[] = {
+	[board_vf]              = &igbvf_vf_info,
+};
+
+void e1000_read_pci_cfg(struct e1000_hw *hw, u32 reg, u16 *value)
+{
+	struct igbvf_adapter *adapter = hw->back;
+
+	pci_read_config_word(adapter->pdev, reg, value);
+}
+
+s32 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
+{
+	struct igbvf_adapter *adapter = hw->back;
+	u16 cap_offset;
+
+	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	if (!cap_offset)
+		return -E1000_ERR_CONFIG;
+
+	pci_read_config_word(adapter->pdev, cap_offset + reg, value);
+
+	return E1000_SUCCESS;
+}
+
+static int igbvf_get_pf_msg_ack(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	return e1000_check_for_pf_ack_vf(hw);
+}
+
+static bool igbvf_poll_for_msg_from_pf(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 reg_data;
+
+	reg_data  = E1000_READ_REG(hw, E1000_V2PMAILBOX(0));
+
+	return ((reg_data & E1000_V2PMAILBOX_PFSTS) != 0);
+}
+
+static void igbvf_rcv_msg_from_pf(struct igbvf_adapter *adapter, u32 *msgbuf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	e1000_receive_mail_from_pf_vf(hw, msgbuf, 16);
+}
+
+static int igbvf_poll_for_msg(struct igbvf_adapter *adapter, u32 *msgbuf)
+{
+	int countdown = 200;
+	while (!(igbvf_poll_for_msg_from_pf(adapter))) {
+		msleep(5);
+		countdown--;
+		if (!countdown) {
+			printk(KERN_ERR "No Mesg received\n");
+			break;
+		}
+	}
+	if (countdown)
+		igbvf_rcv_msg_from_pf(adapter, msgbuf);
+
+	return countdown;
+}
+
+static void igbvf_send_msg_to_pf(struct igbvf_adapter *adapter, u32 *msgbuf)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	e1000_send_mail_to_pf_vf(hw, msgbuf, 16);
+}
+
+static void igbvf_msg_handler_task(struct work_struct *work)
+{
+	u32 msgbuf[E1000_VFMAILBOX_SIZE];
+	struct igbvf_adapter *adapter = container_of(work,
+					struct igbvf_adapter, msg_handler_task);
+
+	printk("\nOff Msg Handler: Processing a Msg from the PF\n");
+
+	igbvf_rcv_msg_from_pf(adapter, msgbuf);
+	printk("Message is %8.8x\n\n", msgbuf[0]);
+	switch(msgbuf[0]) {
+	case E1000_PF_MSGTYPE_RESET:
+		printk("PF is resetting\n");
+		netif_carrier_off(adapter->netdev);
+		break;
+	case E1000_PF_MSGTYPE_LSC:
+		/* This may not be necessary */
+		/* indicate LS to upper layers */
+		break;
+	default:
+		break;
+	}
+}
+
+/**
+ * igbvf_desc_unused - calculate if we have unused descriptors
+ **/
+static int igbvf_desc_unused(struct igbvf_ring *ring)
+{
+	if (ring->next_to_clean > ring->next_to_use)
+		return ring->next_to_clean - ring->next_to_use - 1;
+
+	return ring->count + ring->next_to_clean - ring->next_to_use - 1;
+}
+
+/**
+ * igbvf_receive_skb - helper function to handle Rx indications
+ * @adapter: board private structure
+ * @status: descriptor status field as written by hardware
+ * @vlan: descriptor vlan field as written by hardware (no le/be conversion)
+ * @skb: pointer to sk_buff to be indicated to stack
+ **/
+static void igbvf_receive_skb(struct igbvf_adapter *adapter,
+			      struct net_device *netdev,
+			      struct sk_buff *skb,
+			      u32 status, u16 vlan)
+{
+	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
+		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
+					 le16_to_cpu(vlan) &
+					 E1000_RXD_SPC_VLAN_MASK);
+	else
+		netif_receive_skb(skb);
+
+	netdev->last_rx = jiffies;
+}
+
+static inline void igbvf_rx_checksum_adv(struct igbvf_adapter *adapter,
+					 u32 status_err, struct sk_buff *skb)
+{
+	skb->ip_summed = CHECKSUM_NONE;
+
+	/* Ignore Checksum bit is set or checksum is disabled through ethtool */
+	if ((status_err & E1000_RXD_STAT_IXSM))
+		return;
+	/* TCP/UDP checksum error bit is set */
+	if (status_err &
+	    (E1000_RXDEXT_STATERR_TCPE | E1000_RXDEXT_STATERR_IPE)) {
+		/* let the stack verify checksum errors */
+		adapter->hw_csum_err++;
+		return;
+	}
+	/* It must be a TCP or UDP packet with a valid checksum */
+	if (status_err & (E1000_RXD_STAT_TCPCS | E1000_RXD_STAT_UDPCS))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	adapter->hw_csum_good++;
+}
+
+/**
+ * igbvf_alloc_rx_buffers - Replace used receive buffers; packet split
+ * @adapter: address of board private structure
+ **/
+
+static void igbvf_alloc_rx_buffers(struct igbvf_adapter *adapter,
+				   int cleaned_count)
+{
+	struct igbvf_ring *rx_ring = &adapter->rx_ring[0];
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	union e1000_adv_rx_desc *rx_desc;
+	struct igbvf_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	int bufsz;
+
+	i = rx_ring->next_to_use;
+	buffer_info = &rx_ring->buffer_info[i];
+
+	if (adapter->rx_ps_hdr_size)
+		bufsz = adapter->rx_ps_hdr_size;
+	else
+		bufsz = adapter->rx_buffer_len;
+	bufsz += NET_IP_ALIGN;
+
+	while (cleaned_count--) {
+		rx_desc = IGBVF_RX_DESC_ADV(*rx_ring, i);
+
+		if (adapter->rx_ps_hdr_size && !buffer_info->page_dma) {
+			if (!buffer_info->page) {
+				buffer_info->page = alloc_page(GFP_ATOMIC);
+				if (!buffer_info->page) {
+					adapter->alloc_rx_buff_failed++;
+					goto no_buffers;
+				}
+				buffer_info->page_offset = 0;
+			} else {
+				buffer_info->page_offset ^= PAGE_SIZE / 2;
+			}
+			buffer_info->page_dma =
+				pci_map_page(pdev, buffer_info->page,
+				             buffer_info->page_offset,
+				             PAGE_SIZE / 2,
+				             PCI_DMA_FROMDEVICE);
+		}
+
+		if (!buffer_info->skb) {
+			skb = netdev_alloc_skb(netdev, bufsz);
+			if (!skb) {
+				adapter->alloc_rx_buff_failed++;
+				goto no_buffers;
+			}
+
+			/* Make buffer alignment 2 beyond a 16 byte boundary
+			 * this will result in a 16 byte aligned IP header after
+			 * the 14 byte MAC header is removed
+			 */
+			skb_reserve(skb, NET_IP_ALIGN);
+
+			buffer_info->skb = skb;
+			buffer_info->dma = pci_map_single(pdev, skb->data,
+			                                  bufsz,
+			                                  PCI_DMA_FROMDEVICE);
+		}
+		/* Refresh the desc even if buffer_addrs didn't change because
+		 * each write-back erases this info. */
+		if (adapter->rx_ps_hdr_size) {
+			rx_desc->read.pkt_addr =
+			     cpu_to_le64(buffer_info->page_dma);
+			rx_desc->read.hdr_addr = cpu_to_le64(buffer_info->dma);
+		} else {
+			rx_desc->read.pkt_addr =
+			     cpu_to_le64(buffer_info->dma);
+			rx_desc->read.hdr_addr = 0;
+		}
+
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+		buffer_info = &rx_ring->buffer_info[i];
+	}
+
+no_buffers:
+	if (rx_ring->next_to_use != i) {
+		rx_ring->next_to_use = i;
+		if (i == 0)
+			i = (rx_ring->count - 1);
+		else
+			i--;
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64). */
+		wmb();
+		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+	}
+}
+
+/**
+ * igbvf_clean_rx_irq - Send received data up the network stack; legacy
+ * @adapter: board private structure
+ *
+ * the return value indicates whether actual cleaning was done, there
+ * is no guarantee that everything was cleaned
+ **/
+static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
+			       int *work_done, int work_to_do)
+{
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	union e1000_adv_rx_desc *rx_desc, *next_rxd;
+	struct igbvf_buffer *buffer_info, *next_buffer;
+	struct sk_buff *skb;
+	bool cleaned = FALSE;
+	int cleaned_count = 0;
+	unsigned int total_bytes = 0, total_packets = 0;
+	unsigned int i;
+	u32 length, hlen, staterr;
+
+	i = rx_ring->next_to_clean;
+	rx_desc = IGBVF_RX_DESC_ADV(*rx_ring, i);
+	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+
+	while (staterr & E1000_RXD_STAT_DD) {
+		if (*work_done >= work_to_do)
+			break;
+		(*work_done)++;
+
+		buffer_info = &rx_ring->buffer_info[i];
+
+		/* HW will not DMA in data larger than the given buffer, even
+		 * if it parses the (NFS, of course) header to be larger.  In
+		 * that case, it fills the header buffer and spills the rest
+		 * into the page.
+		 */
+		hlen = adapter->rx_ps_hdr_size;
+
+		length = le16_to_cpu(rx_desc->wb.upper.length);
+		cleaned = TRUE;
+		cleaned_count++;
+
+		skb = buffer_info->skb;
+		prefetch(skb->data - NET_IP_ALIGN);
+		buffer_info->skb = NULL;
+		if (!adapter->rx_ps_hdr_size) {
+			pci_unmap_single(pdev, buffer_info->dma,
+					 adapter->rx_buffer_len,
+					 PCI_DMA_FROMDEVICE);
+			buffer_info->dma = 0;
+			skb_put(skb, length);
+			goto send_up;
+		}
+
+		if (!skb_shinfo(skb)->nr_frags) {
+			pci_unmap_single(pdev, buffer_info->dma,
+					 adapter->rx_ps_hdr_size + NET_IP_ALIGN,
+					 PCI_DMA_FROMDEVICE);
+			skb_put(skb, hlen);
+		}
+
+		if (length) {
+			pci_unmap_page(pdev, buffer_info->page_dma,
+			               PAGE_SIZE / 2,
+			               PCI_DMA_FROMDEVICE);
+			buffer_info->page_dma = 0;
+
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			                   buffer_info->page,
+			                   buffer_info->page_offset,
+			                   length);
+
+			if ((adapter->rx_buffer_len > (PAGE_SIZE / 2)) ||
+			    (page_count(buffer_info->page) != 1))
+				buffer_info->page = NULL;
+			else
+				get_page(buffer_info->page);
+
+			skb->len += length;
+			skb->data_len += length;
+			skb->truesize += length;
+		}
+send_up:
+		i++;
+		if (i == rx_ring->count)
+			i = 0;
+		next_rxd = IGBVF_RX_DESC_ADV(*rx_ring, i);
+		prefetch(next_rxd);
+		next_buffer = &rx_ring->buffer_info[i];
+
+		if (!(staterr & E1000_RXD_STAT_EOP)) {
+			buffer_info->skb = next_buffer->skb;
+			buffer_info->dma = next_buffer->dma;
+			next_buffer->skb = skb;
+			next_buffer->dma = 0;
+			goto next_desc;
+		}
+
+		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
+			dev_kfree_skb_irq(skb);
+			goto next_desc;
+		}
+
+		total_bytes += skb->len;
+		total_packets++;
+
+		igbvf_rx_checksum_adv(adapter, staterr, skb);
+
+		skb->protocol = eth_type_trans(skb, netdev);
+
+		igbvf_receive_skb(adapter, netdev, skb, staterr, 0);
+
+		netdev->last_rx = jiffies;
+
+next_desc:
+		rx_desc->wb.upper.status_error = 0;
+
+		/* return some buffers to hardware, one at a time is too slow */
+		if (cleaned_count >= IGBVF_RX_BUFFER_WRITE) {
+			igbvf_alloc_rx_buffers(adapter, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		/* use prefetched values */
+		rx_desc = next_rxd;
+		buffer_info = next_buffer;
+
+		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+	}
+
+	rx_ring->next_to_clean = i;
+	cleaned_count = igbvf_desc_unused(rx_ring);
+
+	if (cleaned_count)
+		igbvf_alloc_rx_buffers(adapter, cleaned_count);
+
+	adapter->total_rx_packets += total_packets;
+	adapter->total_rx_bytes += total_bytes;
+	adapter->net_stats.rx_bytes += total_bytes;
+	adapter->net_stats.rx_packets += total_packets;
+	return cleaned;
+}
+
+static void igbvf_put_txbuf(struct igbvf_adapter *adapter,
+			     struct igbvf_buffer *buffer_info)
+{
+	if (buffer_info->dma) {
+		pci_unmap_page(adapter->pdev, buffer_info->dma,
+			       buffer_info->length, PCI_DMA_TODEVICE);
+		buffer_info->dma = 0;
+	}
+	if (buffer_info->skb) {
+		dev_kfree_skb_any(buffer_info->skb);
+		buffer_info->skb = NULL;
+	}
+	buffer_info->time_stamp = 0;
+}
+
+static void igbvf_print_tx_hang(struct igbvf_adapter *adapter)
+{
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	unsigned int i = tx_ring->next_to_clean;
+	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
+	union e1000_adv_tx_desc *eop_desc = IGBVF_TX_DESC_ADV(*tx_ring, eop);
+
+	/* detected Tx unit hang */
+	e_err("Detected Tx Unit Hang:\n"
+	      "  TDH                  <%x>\n"
+	      "  TDT                  <%x>\n"
+	      "  next_to_use          <%x>\n"
+	      "  next_to_clean        <%x>\n"
+	      "buffer_info[next_to_clean]:\n"
+	      "  time_stamp           <%lx>\n"
+	      "  next_to_watch        <%x>\n"
+	      "  jiffies              <%lx>\n"
+	      "  next_to_watch.status <%x>\n",
+	      readl(adapter->hw.hw_addr + tx_ring->head),
+	      readl(adapter->hw.hw_addr + tx_ring->tail),
+	      tx_ring->next_to_use,
+	      tx_ring->next_to_clean,
+	      tx_ring->buffer_info[eop].time_stamp,
+	      eop,
+	      jiffies,
+	      eop_desc->wb.status);
+
+	igbvf_dump_interrupt_registers(adapter);
+}
+
+/**
+ * igbvf_alloc_ring_dma - allocate memory for a ring structure
+ **/
+static int igbvf_alloc_ring_dma(struct igbvf_adapter *adapter,
+				struct igbvf_ring *ring)
+{
+	struct pci_dev *pdev = adapter->pdev;
+
+	ring->desc = dma_alloc_coherent(&pdev->dev, (ring->size + sizeof(u32)), &ring->dma,
+					GFP_KERNEL);
+	if (!ring->desc)
+		return -ENOMEM;
+
+	return 0;
+}
+
+/**
+ * igbvf_setup_tx_resources - allocate Tx resources (Descriptors)
+ * @adapter: board private structure
+ *
+ * Return 0 on success, negative on failure
+ **/
+int igbvf_setup_tx_resources(struct igbvf_adapter *adapter)
+{
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	int err = -ENOMEM, size;
+
+	size = sizeof(struct igbvf_buffer) * tx_ring->count;
+	tx_ring->buffer_info = vmalloc(size);
+	if (!tx_ring->buffer_info)
+		goto err;
+	memset(tx_ring->buffer_info, 0, size);
+
+	/* round up to nearest 4K */
+	tx_ring->size = tx_ring->count * sizeof(union e1000_adv_tx_desc);
+	tx_ring->size = ALIGN(tx_ring->size, 4096);
+
+	err = igbvf_alloc_ring_dma(adapter, tx_ring);
+	if (err)
+		goto err;
+
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+	spin_lock_init(&adapter->tx_queue_lock);
+
+	return 0;
+err:
+	vfree(tx_ring->buffer_info);
+	e_err("Unable to allocate memory for the transmit descriptor ring\n");
+	return err;
+}
+
+/**
+ * igbvf_setup_rx_resources - allocate Rx resources (Descriptors)
+ * @adapter: board private structure
+ *
+ * Returns 0 on success, negative on failure
+ **/
+int igbvf_setup_rx_resources(struct igbvf_adapter *adapter)
+{
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+	struct pci_dev *pdev = adapter->pdev;
+	int size, desc_len;
+
+	size = sizeof(struct igbvf_buffer) * rx_ring->count;
+	rx_ring->buffer_info = vmalloc(size);
+	if (!rx_ring->buffer_info)
+		goto err;
+	memset(rx_ring->buffer_info, 0, size);
+
+	desc_len = sizeof(union e1000_adv_rx_desc);
+
+	/* Round up to nearest 4K */
+	rx_ring->size = rx_ring->count * desc_len;
+	rx_ring->size = ALIGN(rx_ring->size, 4096);
+
+	rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
+	                                     &rx_ring->dma);
+
+	if (!rx_ring->desc)
+		goto err;
+
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+
+	return 0;
+
+err:
+	vfree(rx_ring->buffer_info);
+	rx_ring->buffer_info = NULL;
+	e_err("Unable to allocate memory for the receive descriptor ring\n");
+	return -ENOMEM;
+}
+
+/**
+ * igbvf_clean_tx_ring - Free Tx Buffers
+ * @adapter: board private structure
+ **/
+static void igbvf_clean_tx_ring(struct igbvf_adapter *adapter)
+{
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	struct igbvf_buffer *buffer_info;
+	unsigned long size;
+	unsigned int i;
+
+	for (i = 0; i < tx_ring->count; i++) {
+		buffer_info = &tx_ring->buffer_info[i];
+		igbvf_put_txbuf(adapter, buffer_info);
+	}
+
+	size = sizeof(struct igbvf_buffer) * tx_ring->count;
+	memset(tx_ring->buffer_info, 0, size);
+
+	memset(tx_ring->desc, 0, tx_ring->size);
+
+	tx_ring->next_to_use = 0;
+	tx_ring->next_to_clean = 0;
+
+	writel(0, adapter->hw.hw_addr + tx_ring->head);
+	writel(0, adapter->hw.hw_addr + tx_ring->tail);
+}
+
+/**
+ * igbvf_free_tx_resources - Free Tx Resources per Queue
+ * @adapter: board private structure
+ *
+ * Free all transmit software resources
+ **/
+void igbvf_free_tx_resources(struct igbvf_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+
+	igbvf_clean_tx_ring(adapter);
+
+	vfree(tx_ring->buffer_info);
+	tx_ring->buffer_info = NULL;
+
+	dma_free_coherent(&pdev->dev, (tx_ring->size + sizeof(u32)), tx_ring->desc,
+			  tx_ring->dma);
+	tx_ring->desc = NULL;
+}
+
+/**
+ * igbvf_clean_rx_ring - Free Rx Buffers per Queue
+ * @adapter: board private structure
+ **/
+static void igbvf_clean_rx_ring(struct igbvf_adapter *adapter)
+{
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+	struct igbvf_buffer *buffer_info;
+	struct pci_dev *pdev = adapter->pdev;
+	unsigned int i;
+
+	/* Free all the Rx ring sk_buffs */
+	for (i = 0; i < rx_ring->count; i++) {
+		buffer_info = &rx_ring->buffer_info[i];
+		if (buffer_info->dma) {
+			if (adapter->rx_ps_hdr_size){
+				pci_unmap_single(pdev, buffer_info->dma,
+				                 adapter->rx_ps_hdr_size,
+				                 PCI_DMA_FROMDEVICE);
+			} else {
+				pci_unmap_single(pdev, buffer_info->dma,
+				                 adapter->rx_buffer_len,
+				                 PCI_DMA_FROMDEVICE);
+			}
+			buffer_info->dma = 0;
+		}
+
+		if (buffer_info->skb) {
+			dev_kfree_skb(buffer_info->skb);
+			buffer_info->skb = NULL;
+		}
+
+		if (buffer_info->page) {
+			if (buffer_info->page_dma)
+				pci_unmap_page(pdev, buffer_info->page_dma,
+				               PAGE_SIZE / 2,
+				               PCI_DMA_FROMDEVICE);
+			put_page(buffer_info->page);
+			buffer_info->page = NULL;
+			buffer_info->page_dma = 0;
+			buffer_info->page_offset = 0;
+		}
+	}
+
+	/* Zero out the descriptor ring */
+	memset(rx_ring->desc, 0, rx_ring->size);
+
+	rx_ring->next_to_clean = 0;
+	rx_ring->next_to_use = 0;
+
+	writel(0, adapter->hw.hw_addr + rx_ring->head);
+	writel(0, adapter->hw.hw_addr + rx_ring->tail);
+}
+
+/**
+ * igbvf_free_rx_resources - Free Rx Resources
+ * @adapter: board private structure
+ *
+ * Free all receive software resources
+ **/
+
+void igbvf_free_rx_resources(struct igbvf_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+
+	igbvf_clean_rx_ring(adapter);
+
+	vfree(rx_ring->buffer_info);
+	rx_ring->buffer_info = NULL;
+
+	dma_free_coherent(&pdev->dev, rx_ring->size, rx_ring->desc,
+			  rx_ring->dma);
+	rx_ring->desc = NULL;
+}
+
+/**
+ * igbvf_update_itr - update the dynamic ITR value based on statistics
+ * @adapter: pointer to adapter
+ * @itr_setting: current adapter->itr
+ * @packets: the number of packets during this measurement interval
+ * @bytes: the number of bytes during this measurement interval
+ *
+ *      Stores a new ITR value based on packets and byte
+ *      counts during the last interrupt.  The advantage of per interrupt
+ *      computation is faster updates and more accurate ITR for the current
+ *      traffic pattern.  Constants in this function were computed
+ *      based on theoretical maximum wire speed and thresholds were set based
+ *      on testing data as well as attempting to minimize response time
+ *      while increasing bulk throughput.  This functionality is controlled
+ *      by the InterruptThrottleRate module parameter.
+ **/
+static unsigned int igbvf_update_itr(struct igbvf_adapter *adapter,
+				     u16 itr_setting, int packets,
+				     int bytes)
+{
+	unsigned int retval = itr_setting;
+
+	if (packets == 0)
+		goto update_itr_done;
+
+	switch (itr_setting) {
+	case lowest_latency:
+		/* handle TSO and jumbo frames */
+		if (bytes/packets > 8000)
+			retval = bulk_latency;
+		else if ((packets < 5) && (bytes > 512)) {
+			retval = low_latency;
+		}
+		break;
+	case low_latency:  /* 50 usec aka 20000 ints/s */
+		if (bytes > 10000) {
+			/* this if handles the TSO accounting */
+			if (bytes/packets > 8000) {
+				retval = bulk_latency;
+			} else if ((packets < 10) || ((bytes/packets) > 1200)) {
+				retval = bulk_latency;
+			} else if ((packets > 35)) {
+				retval = lowest_latency;
+			}
+		} else if (bytes/packets > 2000) {
+			retval = bulk_latency;
+		} else if (packets <= 2 && bytes < 512) {
+			retval = lowest_latency;
+		}
+		break;
+	case bulk_latency: /* 250 usec aka 4000 ints/s */
+		if (bytes > 25000) {
+			if (packets > 35) {
+				retval = low_latency;
+			}
+		} else if (bytes < 6000) {
+			retval = low_latency;
+		}
+		break;
+	}
+
+update_itr_done:
+	return retval;
+}
+
+static void igbvf_set_itr(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u16 current_itr;
+	u32 new_itr = adapter->itr;
+
+	adapter->tx_itr = igbvf_update_itr(adapter,
+				    adapter->tx_itr,
+				    adapter->total_tx_packets,
+				    adapter->total_tx_bytes);
+	/* conservative mode (itr 3) eliminates the lowest_latency setting */
+	if (adapter->itr_setting == 3 && adapter->tx_itr == lowest_latency)
+		adapter->tx_itr = low_latency;
+
+	adapter->rx_itr = igbvf_update_itr(adapter,
+				    adapter->rx_itr,
+				    adapter->total_rx_packets,
+				    adapter->total_rx_bytes);
+	/* conservative mode (itr 3) eliminates the lowest_latency setting */
+	if (adapter->itr_setting == 3 && adapter->rx_itr == lowest_latency)
+		adapter->rx_itr = low_latency;
+
+	current_itr = max(adapter->rx_itr, adapter->tx_itr);
+
+	switch (current_itr) {
+	/* counts and packets in update_itr are dependent on these numbers */
+	case lowest_latency:
+		new_itr = 70000;
+		break;
+	case low_latency:
+		new_itr = 20000; /* aka hwitr = ~200 */
+		break;
+	case bulk_latency:
+		new_itr = 4000;
+		break;
+	default:
+		break;
+	}
+
+	if (new_itr != adapter->itr) {
+		/*
+		 * this attempts to bias the interrupt rate towards Bulk
+		 * by adding intermediate steps when interrupt rate is
+		 * increasing
+		 */
+		new_itr = new_itr > adapter->itr ?
+			     min(adapter->itr + (new_itr >> 2), new_itr) :
+			     new_itr;
+		adapter->itr = new_itr;
+		adapter->rx_ring->itr_val = 1952;
+		if (adapter->msix_entries)
+			adapter->rx_ring->set_itr = 1;
+		else
+			ew32(ITR, 1952);
+	}
+}
+
+/**
+ * igbvf_clean_tx_irq - Reclaim resources after transmit completes
+ * @adapter: board private structure
+ * returns TRUE if ring is completely cleaned
+ **/
+static bool igbvf_clean_tx_irq(struct igbvf_adapter *adapter)
+{
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	union e1000_adv_tx_desc *tx_desc;
+	struct igbvf_buffer *buffer_info;
+	struct sk_buff *skb;
+	unsigned int i;
+	u32 head, oldhead;
+	unsigned int count = 0;
+	unsigned int total_bytes = 0, total_packets = 0;
+	bool retval = TRUE;
+
+	rmb();
+	head = *(volatile u32 *)
+		((struct e1000_tx_desc *)tx_ring->desc + tx_ring->count);
+	head = le32_to_cpu(head);
+
+	i = tx_ring->next_to_clean;
+
+	while (1) {
+		while (i != head) {
+			tx_desc = IGBVF_TX_DESC_ADV(*tx_ring, i);
+			buffer_info = &tx_ring->buffer_info[i];
+			skb = buffer_info->skb;
+
+			if (skb) {
+#ifdef NETIF_F_TSO
+				unsigned int segs, bytecount;
+
+				/* gso_segs is currently only valid for tcp */
+				segs = skb_shinfo(skb)->gso_segs ?: 1;
+				/* multiply data chunks by size of headers */
+				bytecount = ((segs - 1) * skb_headlen(skb)) +
+				            skb->len;
+				total_packets += segs;
+				total_bytes += bytecount;
+#else
+				total_packets++;
+				total_bytes += skb->len;
+#endif
+			}
+
+			igbvf_put_txbuf(adapter, buffer_info);
+
+			i++;
+			if (i == tx_ring->count)
+				i = 0;
+
+			count++;
+			if (count == tx_ring->count) {
+				retval = FALSE;
+				goto done_cleaning;
+			}
+		}
+		oldhead = head;
+		rmb();
+		head = *(volatile u32 *)((struct e1000_tx_desc *)tx_ring->desc +
+		                         tx_ring->count);
+		head = le32_to_cpu(head);
+		if (head == oldhead)
+			goto done_cleaning;
+	}  /* while (1) */
+
+done_cleaning:
+
+	tx_ring->next_to_clean = i;
+
+	if (adapter->detect_tx_hung) {
+		/* Detect a transmit hang in hardware, this serializes the
+		 * check with the clearing of time_stamp and movement of i */
+		adapter->detect_tx_hung = FALSE;
+		if (tx_ring->buffer_info[i].time_stamp &&
+		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp +
+		               (adapter->tx_timeout_factor * HZ))
+		    && !(E1000_READ_REG(hw, E1000_STATUS) &
+		         E1000_STATUS_TXOFF)) {
+
+			tx_desc = IGBVF_TX_DESC_ADV(*tx_ring, i);
+			/* detected Tx unit hang */
+			igbvf_print_tx_hang(adapter);
+
+			netif_stop_queue(netdev);
+		}
+	}
+	adapter->net_stats.tx_bytes += total_bytes;
+	adapter->net_stats.tx_packets += total_packets;
+	return retval;
+}
+
+static irqreturn_t igbvf_msix_other(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	adapter->int_counter1++;
+
+	if (e1000_check_for_pf_mail_vf(hw, &adapter->vf_mb_val)) {
+		schedule_work(&adapter->msg_handler_task);
+		goto no_link_interrupt;
+	}
+
+	hw->mac.get_link_status = 1;
+	/* guard against interrupt when we're going down */
+	if (!test_bit(__IGBVF_DOWN, &adapter->state))
+		mod_timer(&adapter->watchdog_timer, jiffies + 1);
+
+no_link_interrupt:
+
+	ew32(EIMS, adapter->eims_other);
+
+	return IRQ_HANDLED;
+}
+
+
+static irqreturn_t igbvf_intr_msix_rx(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	adapter->int_counter0++;
+
+	/* Write the ITR value calculated at the end of the
+	 * previous interrupt.
+	 */
+	if (adapter->rx_ring->set_itr) {
+		writel(adapter->rx_ring->itr_val,
+		       adapter->hw.hw_addr + adapter->rx_ring->itr_register);
+		adapter->rx_ring->set_itr = 0;
+	}
+
+	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+		adapter->total_rx_bytes = 0;
+		adapter->total_rx_packets = 0;
+		adapter->total_tx_bytes = 0;
+		adapter->total_tx_packets = 0;
+		__netif_rx_schedule(netdev, &adapter->napi);
+	}
+
+	return IRQ_HANDLED;
+}
+
+#define IGBVF_NO_QUEUE -1
+
+static void igbvf_assign_vector(struct igbvf_adapter *adapter, int rx_queue,
+                              int tx_queue, int msix_vector)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ivar, index;
+	u32 rbase_offset = 0;
+
+	/* 82576 uses a table-based method for assigning vectors.
+	   Each queue has a single entry in the table to which we write
+	   a vector number along with a "valid" bit.  Sadly, the layout
+	   of the table is somewhat counterintuitive. */
+	if (rx_queue > IGBVF_NO_QUEUE) {
+		index = ((rx_queue + rbase_offset) & 0x7);
+		ivar = E1000_READ_REG_ARRAY(hw, E1000_IVAR0, index);
+		if ((rx_queue + rbase_offset) < 8) {
+			/* vector goes into low byte of register */
+			ivar = ivar & 0xFFFFFF00;
+			ivar |= msix_vector | E1000_IVAR_VALID;
+		} else {
+			/* vector goes into third byte of register */
+			ivar = ivar & 0xFF00FFFF;
+			ivar |= (msix_vector | E1000_IVAR_VALID) << 16;
+		}
+		adapter->rx_ring[rx_queue].eims_value = 1 << msix_vector;
+		E1000_WRITE_REG_ARRAY(hw, E1000_IVAR0, index, ivar);
+	}
+	if (tx_queue > IGBVF_NO_QUEUE) {
+		index = ((tx_queue + rbase_offset) & 0x7);
+		ivar = E1000_READ_REG_ARRAY(hw, E1000_IVAR0, index);
+		if ((tx_queue + rbase_offset) < 8) {
+			/* vector goes into second byte of register */
+			ivar = ivar & 0xFFFF00FF;
+			ivar |= (msix_vector | E1000_IVAR_VALID) << 8;
+		} else {
+			/* vector goes into high byte of register */
+			ivar = ivar & 0x00FFFFFF;
+			ivar |= (msix_vector | E1000_IVAR_VALID) << 24;
+		}
+		adapter->tx_ring[tx_queue].eims_value = 1 << msix_vector;
+		E1000_WRITE_REG_ARRAY(hw, E1000_IVAR0, index, ivar);
+	}
+}
+
+/**
+ * igbvf_configure_msix - Configure MSI-X hardware
+ *
+ * igbvf_configure_msix sets up the hardware to properly
+ * generate MSI-X interrupts.
+ **/
+static void igbvf_configure_msix(struct igbvf_adapter *adapter)
+{
+	u32 tmp;
+	int i, vector = 0;
+	struct e1000_hw *hw = &adapter->hw;
+
+	adapter->eims_enable_mask = 0;
+
+	for (i = 0; i < 1; i++) {
+		struct igbvf_ring *rx_ring = &adapter->rx_ring[i];
+		igbvf_assign_vector(adapter, i, i, vector++);
+		rx_ring->eims_value |= adapter->tx_ring[i].eims_value;
+		adapter->eims_enable_mask |= rx_ring->eims_value;
+		if (rx_ring->itr_val)
+			writel(rx_ring->itr_val,
+			       hw->hw_addr + rx_ring->itr_register);
+		else
+			writel(1952, hw->hw_addr + rx_ring->itr_register);
+	}
+
+	/* set vector for other causes, i.e. link changes */
+
+	tmp = (vector++ | E1000_IVAR_VALID);
+
+	E1000_WRITE_REG(hw, E1000_IVAR_MISC, tmp);
+
+	adapter->eims_enable_mask = (1 << (vector)) - 1;
+	adapter->eims_other = 1 << (vector - 1);
+	E1000_WRITE_FLUSH(hw);
+}
+
+void igbvf_reset_interrupt_capability(struct igbvf_adapter *adapter)
+{
+	if (adapter->msix_entries) {
+		pci_disable_msix(adapter->pdev);
+		kfree(adapter->msix_entries);
+		adapter->msix_entries = NULL;
+	} else if (adapter->flags & FLAG_MSI_ENABLED) {
+		pci_disable_msi(adapter->pdev);
+		adapter->flags &= ~FLAG_MSI_ENABLED;
+	}
+
+	return;
+}
+
+/**
+ * igbvf_set_interrupt_capability - set MSI or MSI-X if supported
+ *
+ * Attempt to configure interrupts using the best available
+ * capabilities of the hardware and kernel.
+ **/
+void igbvf_set_interrupt_capability(struct igbvf_adapter *adapter)
+{
+	int err;
+	int numvecs, i;
+
+	numvecs = 2;
+	adapter->msix_entries = kcalloc(numvecs,
+					sizeof(struct msix_entry),
+					GFP_KERNEL);
+	if (adapter->msix_entries) {
+		for (i=0; i < numvecs; i++)
+			adapter->msix_entries[i].entry = i;
+
+		err = pci_enable_msix(adapter->pdev,
+				      adapter->msix_entries, numvecs);
+		if (err == 0) {
+			goto msix_enabled;
+		}
+	}
+	/* MSI-X failed - we're screwed */
+	printk(KERN_ERR "Failed to initialize MSI-X interrupts.\n");
+	igbvf_reset_interrupt_capability(adapter);
+
+msix_enabled:
+
+	return;
+}
+
+/**
+ * igbvf_request_msix - Initialize MSI-X interrupts
+ *
+ * igbvf_request_msix allocates MSI-X vectors and requests interrupts from the
+ * kernel.
+ **/
+static int igbvf_request_msix(struct igbvf_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	int err = 0, vector = 0;
+
+	if (strlen(netdev->name) < (IFNAMSIZ - 5))
+		sprintf(adapter->rx_ring->name, "%s-Q0", netdev->name);
+	else
+		memcpy(adapter->rx_ring->name, netdev->name, IFNAMSIZ);
+	err = request_irq(adapter->msix_entries[vector].vector,
+			  &igbvf_intr_msix_rx, 0, adapter->rx_ring->name,
+	                  netdev);
+	if (err)
+		goto out;
+	adapter->rx_ring->itr_register = E1000_EITR(vector);
+	adapter->rx_ring->itr_val = 1952;
+	vector++;
+
+	err = request_irq(adapter->msix_entries[vector].vector,
+	                  &igbvf_msix_other, 0, netdev->name, netdev);
+	if (err)
+		goto out;
+
+	igbvf_configure_msix(adapter);
+	return 0;
+out:
+	return err;
+}
+
+/**
+ * igbvf_alloc_queues - Allocate memory for all rings
+ * @adapter: board private structure to initialize
+ **/
+static int __devinit igbvf_alloc_queues(struct igbvf_adapter *adapter)
+{
+	adapter->tx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
+	if (!adapter->tx_ring)
+		goto err;
+
+	adapter->rx_ring = kzalloc(sizeof(struct igbvf_ring), GFP_KERNEL);
+	if (!adapter->rx_ring)
+		goto err;
+
+	return 0;
+err:
+	e_err("Unable to allocate memory for queues\n");
+	kfree(adapter->rx_ring);
+	kfree(adapter->tx_ring);
+	return -ENOMEM;
+}
+
+/**
+ * igbvf_request_irq - initialize interrupts
+ *
+ * Attempts to configure interrupts using the best available
+ * capabilities of the hardware and kernel.
+ **/
+static int igbvf_request_irq(struct igbvf_adapter *adapter)
+{
+	int err = -1;
+
+	if (adapter->msix_entries) {
+		err = igbvf_request_msix(adapter);
+		if (!err)
+			return err;
+		else
+			e_err("Unable to allocate interrupt, Error: %d\n", err);
+	}
+
+	e_err("MSI-X Allocation failed, Error: %d\n", err);
+
+	return err;
+}
+
+static void igbvf_free_irq(struct igbvf_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	if (adapter->msix_entries) {
+		int vector = 0;
+
+		free_irq(adapter->msix_entries[vector].vector, netdev);
+		vector++;
+
+		/* Other Causes interrupt vector */
+		free_irq(adapter->msix_entries[vector].vector, netdev);
+		return;
+	}
+}
+
+/**
+ * igbvf_irq_disable - Mask off interrupt generation on the NIC
+ **/
+static void igbvf_irq_disable(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	ew32(EIMC, ~0);
+
+	if (adapter->msix_entries) {
+		ew32(EIAC, 0);
+	}
+}
+
+/**
+ * igbvf_irq_enable - Enable default interrupt generation settings
+ **/
+static void igbvf_irq_enable(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	ew32(EIAC, adapter->eims_enable_mask);
+	ew32(EIAM, adapter->eims_enable_mask);
+	ew32(EIMS, adapter->eims_enable_mask);
+}
+
+/**
+ * igbvf_poll - NAPI Rx polling callback
+ * @napi: struct associated with this polling callback
+ * @budget: amount of packets driver is allowed to process this poll
+ **/
+static int igbvf_poll(struct napi_struct *napi, int budget)
+{
+	struct igbvf_adapter *adapter = container_of(napi, struct igbvf_adapter,
+						     napi);
+	struct net_device *netdev = adapter->netdev;
+	int tx_clean_complete = 1, work_done = 0;
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (adapter->msix_entries &&
+	    !(adapter->rx_ring->eims_value & adapter->tx_ring->eims_value))
+		goto clean_rx;
+
+
+	/*
+	 * igbvf_poll is called per-cpu.  This lock protects
+	 * tx_ring from being cleaned by multiple cpus
+	 * simultaneously.  A failure obtaining the lock means
+	 * tx_ring is currently being cleaned anyway.
+	 */
+	if (spin_trylock(&adapter->tx_queue_lock)) {
+		tx_clean_complete &= igbvf_clean_tx_irq(adapter);
+		spin_unlock(&adapter->tx_queue_lock);
+	}
+
+clean_rx:
+	adapter->clean_rx(adapter, &work_done, budget);
+
+	/* If no Tx and not enough Rx work done, exit the polling mode */
+	if ((tx_clean_complete && (work_done == 0)) || !netif_running(netdev)) {
+		netif_rx_complete(netdev, napi);
+		if (adapter->itr_setting & 3)
+			igbvf_set_itr(adapter);
+		if (!test_bit(__IGBVF_DOWN, &adapter->state)) {
+			if (adapter->msix_entries)
+				ew32(EIMS, adapter->rx_ring->eims_value);
+			else
+				igbvf_irq_enable(adapter);
+		}
+		return 0;
+	}
+
+	if (!tx_clean_complete)
+		work_done = budget;
+
+	return work_done;
+}
+
+static void igbvf_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct net_device *v_netdev;
+	u32 msgbuf[E1000_VFMAILBOX_SIZE];
+
+	msgbuf[0] = E1000_VF_SET_VLAN;
+	msgbuf[1] = vid;
+	/* Setting the 8 bit field MSG INFO to TRUE indicates "add"
+	 * VLAN ID
+	 */
+	msgbuf[1] |= TRUE << E1000_VT_MSGINFO_SHIFT;
+
+	igbvf_send_msg_to_pf(adapter, msgbuf);
+
+	/*
+	 * Copy feature flags from netdev to the vlan netdev for this vid.
+	 * This allows things like TSO to bubble down to our vlan device.
+	 */
+	v_netdev = vlan_group_get_device(adapter->vlgrp, vid);
+	v_netdev->features |= adapter->netdev->features;
+	vlan_group_set_device(adapter->vlgrp, vid, v_netdev);
+}
+
+static void igbvf_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	u32 msgbuf[E1000_VFMAILBOX_SIZE];
+
+	if (!test_bit(__IGBVF_DOWN, &adapter->state))
+		igbvf_irq_disable(adapter);
+	vlan_group_set_device(adapter->vlgrp, vid, NULL);
+	if (!test_bit(__IGBVF_DOWN, &adapter->state))
+		igbvf_irq_enable(adapter);
+
+	msgbuf[0] = E1000_VF_SET_VLAN;
+	msgbuf[1] = vid;
+	/* Leaving the 8 bit field MSG INFO zero (FALSE) indicates "remove"
+	 * VLAN ID
+	 */
+
+	igbvf_send_msg_to_pf(adapter, msgbuf);
+}
+
+static void igbvf_vlan_rx_register(struct net_device *netdev,
+				   struct vlan_group *grp)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	/* not really all that much for a virtual device to
+	 * do here
+	 */
+	adapter->vlgrp = grp;
+}
+
+static void igbvf_restore_vlan(struct igbvf_adapter *adapter)
+{
+	u16 vid;
+
+	igbvf_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+
+	if (!adapter->vlgrp)
+		return;
+
+	for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		if (!vlan_group_get_device(adapter->vlgrp, vid))
+			continue;
+		igbvf_vlan_rx_add_vid(adapter->netdev, vid);
+	}
+}
+
+/**
+ * igbvf_configure_tx - Configure Transmit Unit after Reset
+ * @adapter: board private structure
+ *
+ * Configure the Tx unit of the MAC after a reset.
+ **/
+static void igbvf_configure_tx(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	u64 tdba;
+	u32 tdlen;
+	u32 txdctl = er32(TXDCTL(0));
+
+	/* merge this change in later */
+	/* set up some performance related parameters to encourage the
+	 * hardware to use the bus more efficiently in bursts, depends
+	 * on the tx_int_delay to be enabled
+	 * BEWARE: this seems to work but should be considered first if
+	 * there are tx hangs or other tx related bugs */
+	txdctl |= 0x00010000;
+	ew32(TXDCTL(0), txdctl);
+
+	/* Setup the HW Tx Head and Tail descriptor pointers */
+	tdba = tx_ring->dma;
+	tdlen = tx_ring->count * sizeof(union e1000_adv_tx_desc);
+	ew32(TDBAL(0), (tdba & DMA_32BIT_MASK));
+	ew32(TDBAH(0), (tdba >> 32));
+	ew32(TDLEN(0), tdlen);
+	ew32(TDH(0), 0);
+	ew32(TDT(0), 0);
+	tx_ring->head = E1000_TDH(0);
+	tx_ring->tail = E1000_TDT(0);
+
+	hw->mac.ops.config_collision_dist(hw);
+
+	/* Setup Transmit Descriptor Settings for eop descriptor */
+	adapter->txd_cmd = E1000_ADVTXD_DCMD_EOP | E1000_ADVTXD_DCMD_IFCS;
+
+	/* enable Report Status bit */
+	adapter->txd_cmd |= E1000_ADVTXD_DCMD_RS;
+
+	adapter->tx_queue_len = adapter->netdev->tx_queue_len;
+}
+
+/**
+ * igbvf_setup_srrctl - configure the receive control registers
+ * @adapter: Board private structure
+ **/
+#define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
+			   (((S) & (PAGE_SIZE - 1)) ? 1 : 0))
+static void igbvf_setup_srrctl(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 srrctl;
+
+	srrctl = er32(SRRCTL(0));
+
+	srrctl &= ~(E1000_SRRCTL_DESCTYPE_MASK |
+		    E1000_SRRCTL_BSIZEHDR_MASK |
+		    E1000_SRRCTL_BSIZEPKT_MASK);
+	srrctl |= 0x80000000; /* Enable queue drop to avoid head of line blocking */
+	adapter->rx_ps_hdr_size = 0;
+
+	/* Setup buffer sizes */
+
+	switch (adapter->rx_buffer_len) {
+	case 1024:
+		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
+		srrctl |= 1;
+		break;
+	case 2048:
+	default:
+		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
+		srrctl |= 2;
+		break;
+	case 4096:
+		if (adapter->jumbo_frames_enabled) {
+			adapter->rx_ps_hdr_size = 128;
+			srrctl |= adapter->rx_ps_hdr_size <<
+				E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
+			srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+			srrctl |= 4;
+		}
+		break;
+	case 8192:
+		if (adapter->jumbo_frames_enabled) {
+			adapter->rx_ps_hdr_size = 128;
+			srrctl |= adapter->rx_ps_hdr_size <<
+				E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
+			srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+			srrctl |= 8;
+		}
+		break;
+	case 16384:
+		if (adapter->jumbo_frames_enabled) {
+			adapter->rx_ps_hdr_size = 128;
+			srrctl |= adapter->rx_ps_hdr_size <<
+				E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
+			srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+			srrctl |= 16;
+		}
+		break;
+	}
+
+	ew32(SRRCTL(0), srrctl);
+	/* just started the receive unit, no need to restart */
+	adapter->flags &= ~FLAG_RX_RESTART_NOW;
+}
+
+/**
+ * igbvf_configure_rx - Configure Receive Unit after Reset
+ * @adapter: board private structure
+ *
+ * Configure the Rx unit of the MAC after a reset.
+ **/
+static void igbvf_configure_rx(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+	u64 rdba;
+	u32 rdlen, rctl;
+
+	rdlen = rx_ring->count * sizeof(struct e1000_rx_desc);
+	adapter->clean_rx = igbvf_clean_rx_irq;
+	adapter->alloc_rx_buf = igbvf_alloc_rx_buffers;
+
+	rctl = er32(RXDCTL(0));
+	rctl &= 0x02000000;
+	ew32(RXDCTL(0), rctl);
+
+	msleep(10);
+
+	/*
+	 * Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
+	rdba = rx_ring->dma;
+	ew32(RDBAL(0), (rdba & DMA_32BIT_MASK));
+	ew32(RDBAH(0), (rdba >> 32));
+	ew32(RDLEN(0), rdlen);
+	ew32(RDH(0), 0);
+	ew32(RDT(0), 0);
+	rx_ring->head = E1000_RDH(0);
+	rx_ring->tail = E1000_RDT(0);
+}
+
+/**
+ * igbvf_set_multi - Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ *
+ * The set_multi entry point is called whenever the multicast address
+ * list or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper multicast,
+ * promiscuous mode, and all-multi behavior.
+ **/
+static void igbvf_set_multi(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	struct dev_mc_list *mc_ptr;
+	u8  *mta_list;
+	int i;
+
+	if (netdev->mc_count) {
+		mta_list = kmalloc(netdev->mc_count * 6, GFP_ATOMIC);
+		if (!mta_list)
+			return;
+
+		/* prepare a packed array of only addresses. */
+		mc_ptr = netdev->mc_list;
+
+		for (i = 0; i < netdev->mc_count; i++) {
+			if (!mc_ptr)
+				break;
+			memcpy(mta_list + (i*ETH_ALEN), mc_ptr->dmi_addr,
+			       ETH_ALEN);
+			mc_ptr = mc_ptr->next;
+		}
+
+		hw->mac.ops.update_mc_addr_list(hw, mta_list, i, 1, 0);
+		kfree(mta_list);
+	} else {
+		/*
+		 * if we're called from probe, we might not have
+		 * anything to do here, so clear out the list
+		 */
+		hw->mac.ops.update_mc_addr_list(hw, NULL, 0, 1, 0);
+	}
+}
+
+/**
+ * igbvf_configure - configure the hardware for Rx and Tx
+ * @adapter: private board structure
+ **/
+static void igbvf_configure(struct igbvf_adapter *adapter)
+{
+	igbvf_set_multi(adapter->netdev);
+
+	igbvf_restore_vlan(adapter);
+
+	igbvf_configure_tx(adapter);
+	igbvf_setup_srrctl(adapter);
+	igbvf_configure_rx(adapter);
+	adapter->alloc_rx_buf(adapter, igbvf_desc_unused(adapter->rx_ring));
+}
+
+/* igbvf_reset - bring the hardware into a known good state
+ *
+ * This function boots the hardware and enables some settings that
+ * require a configuration cycle of the hardware - those cannot be
+ * set/changed during runtime. After reset the device needs to be
+ * properly configured for Rx, Tx etc.
+ */
+void igbvf_reset(struct igbvf_adapter *adapter)
+{
+	struct e1000_mac_info *mac = &adapter->hw.mac;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 pf_vf_msgbuf[E1000_VFMAILBOX_SIZE];
+
+	/* Allow time for pending master requests to run */
+	mac->ops.reset_hw(hw);
+
+	if (mac->ops.init_hw(hw))
+		e_err("Hardware Error\n");
+
+	memset(pf_vf_msgbuf, '\0', 64);
+	pf_vf_msgbuf[0] = E1000_VF_MSGTYPE_VFLR;
+	igbvf_send_msg_to_pf(adapter, pf_vf_msgbuf);
+	igbvf_get_pf_msg_ack(adapter);
+}
+
+static void igbvf_enable_vf_queues(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	struct igbvf_ring *rx_ring = adapter->rx_ring;
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	u64 rdba;
+	u32 rdlen, rctl;
+	u64 tdba, tdwba;
+	u32 tdlen;
+	u32 tctl, txctrl;
+	int i = 0;
+
+	tctl = E1000_READ_REG(hw, E1000_TXDCTL(0));
+	tctl |= E1000_TXDCTL_QUEUE_ENABLE;
+	E1000_WRITE_REG(hw, E1000_TXDCTL(0), tctl);
+	tctl = E1000_READ_REG(hw, E1000_TXDCTL(0));
+
+	while ((tctl & E1000_TXDCTL_QUEUE_ENABLE) == 0) {
+		msleep(2);
+		i++;
+		if (i > 5000)
+			break;
+		tctl = E1000_READ_REG(hw, E1000_TXDCTL(0));
+	}
+
+	/* Setup the HW Tx Head and Tail descriptor pointers */
+	tdba = tx_ring->dma;
+	tdlen = tx_ring->count * sizeof(union e1000_adv_tx_desc);
+	ew32(TDBAL(0), (tdba & DMA_32BIT_MASK));
+	ew32(TDBAH(0), (tdba >> 32));
+	ew32(TDLEN(0), tdlen);
+
+	tdwba = tx_ring->dma + tx_ring->count * sizeof(struct e1000_tx_desc);
+	tdwba |= 1; /* enable head wb */
+	E1000_WRITE_REG(hw, E1000_TDWBAL(0),
+			tdwba & 0x00000000ffffffffULL);
+	E1000_WRITE_REG(hw, E1000_TDWBAH(0), tdwba >> 32);
+
+	/* Turn off Relaxed Ordering on head write-backs.  The writebacks
+	 * MUST be delivered in order or it will completely screw up
+	 * our bookeeping.
+	 */
+	txctrl = E1000_READ_REG(hw, E1000_DCA_TXCTRL(0));
+	txctrl &= ~E1000_DCA_TXCTRL_TX_WB_RO_EN;
+	E1000_WRITE_REG(hw, E1000_DCA_TXCTRL(0), txctrl);
+
+	writel(tx_ring->next_to_clean, adapter->hw.hw_addr + tx_ring->head);
+	writel(tx_ring->next_to_use, adapter->hw.hw_addr + tx_ring->tail);
+
+	rctl = er32(RXDCTL(0));
+	rctl |= 0x02000000;
+	ew32(RXDCTL(0), rctl);
+
+	/*
+	 * Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
+	rdlen = rx_ring->count * sizeof(struct e1000_rx_desc);
+	rdba = rx_ring->dma;
+	ew32(RDBAL(0), (rdba & DMA_32BIT_MASK));
+	ew32(RDBAH(0), (rdba >> 32));
+	ew32(RDLEN(0), rdlen);
+	writel(rx_ring->next_to_clean, adapter->hw.hw_addr + rx_ring->head);
+	writel(rx_ring->next_to_use - 1, adapter->hw.hw_addr + rx_ring->tail);
+}
+
+int igbvf_up(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	/* hardware has been reset, we need to reload some things */
+	igbvf_configure(adapter);
+
+	clear_bit(__IGBVF_DOWN, &adapter->state);
+
+	napi_enable(&adapter->napi);
+
+	igbvf_enable_vf_queues(adapter);
+
+	if (adapter->msix_entries)
+		igbvf_configure_msix(adapter);
+	igbvf_irq_enable(adapter);
+
+	/* fire a link change interrupt to start the watchdog */
+	ew32(EICS, adapter->eims_other);
+
+	return 0;
+}
+
+void igbvf_down(struct igbvf_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	/*
+	 * signal that we're down so the interrupt handler does not
+	 * reschedule our watchdog timer
+	 */
+	set_bit(__IGBVF_DOWN, &adapter->state);
+
+	netif_stop_queue(netdev);
+
+	/* FIX ME!!!! */
+	/* need to disable local queue transmit and receive */
+
+	msleep(10);
+
+	napi_disable(&adapter->napi);
+
+	igbvf_irq_disable(adapter);
+
+	del_timer_sync(&adapter->watchdog_timer);
+	del_timer_sync(&adapter->phy_info_timer);
+
+	netdev->tx_queue_len = adapter->tx_queue_len;
+	netif_carrier_off(netdev);
+	adapter->link_speed = 0;
+	adapter->link_duplex = 0;
+
+	igbvf_reset(adapter);
+	igbvf_clean_tx_ring(adapter);
+	igbvf_clean_rx_ring(adapter);
+}
+
+void igbvf_reinit_locked(struct igbvf_adapter *adapter)
+{
+	might_sleep();
+	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
+		msleep(1);
+	igbvf_down(adapter);
+	igbvf_up(adapter);
+	clear_bit(__IGBVF_RESETTING, &adapter->state);
+}
+
+/**
+ * igbvf_sw_init - Initialize general software structures (struct igbvf_adapter)
+ * @adapter: board private structure to initialize
+ *
+ * igbvf_sw_init initializes the Adapter private data structure.
+ * Fields are initialized based on PCI device information and
+ * OS network device settings (MTU size).
+ **/
+static int __devinit igbvf_sw_init(struct igbvf_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	s32 rc;
+
+	adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN;
+	adapter->rx_ps_hdr_size = 0;
+	adapter->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	adapter->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
+
+	/* Set various function pointers */
+	adapter->ei->init_ops(&adapter->hw);
+
+	rc = adapter->hw.mac.ops.init_params(&adapter->hw);
+	if (rc)
+		return rc;
+
+	rc = adapter->hw.nvm.ops.init_params(&adapter->hw);
+	if (rc)
+		return rc;
+
+	rc = adapter->hw.phy.ops.init_params(&adapter->hw);
+	if (rc)
+		return rc;
+
+
+	igbvf_set_interrupt_capability(adapter);
+
+	if (igbvf_alloc_queues(adapter))
+		return -ENOMEM;
+
+	spin_lock_init(&adapter->tx_queue_lock);
+
+	/* Explicitly disable IRQ since the NIC can be in any state. */
+	igbvf_irq_disable(adapter);
+
+	spin_lock_init(&adapter->stats_lock);
+
+	set_bit(__IGBVF_DOWN, &adapter->state);
+	return 0;
+}
+
+void igbvf_dump_interrupt_registers(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	int i;
+	u32 rbase_offset = 0;
+#define NUM_REGS 14 /* 1 based count */
+	u32 regs[NUM_REGS];
+	u32 *regs_buff = regs;
+
+	char *reg_name[] = {
+	"CTRL",  "STATUS",
+	"RDLEN", "RDH", "RDT",
+	"TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
+	"TXDCTL", "RXDCTL",
+	"RDBAL", "RDBAH",
+	};
+
+	printk("\nTx/Rx interrupts : %d\n", adapter->int_counter0);
+	printk("Other interrupts : %d\n", adapter->int_counter1);
+
+	printk("EICR : %8.8x\n", E1000_READ_REG(hw, E1000_EICR));
+	printk("EIMS : %8.8x\n", E1000_READ_REG(hw, E1000_EIMS));
+	printk("EIAC : %8.8x\n", E1000_READ_REG(hw, E1000_EIAC));
+	printk("MISC : %8.8x\n", E1000_READ_REG(hw, E1000_IVAR_MISC));
+	for(i = 0; i < 1; i++) {
+		printk("IVAR%d : %8.8x\n", i,
+		       E1000_READ_REG_ARRAY(hw, E1000_IVAR0, i));
+	}
+	for(i = 0; i < 1; i++) {
+		printk("VTEITR %d: %8.8x\n", i,
+		       E1000_READ_REG(hw, (0x01680 + (i * 4))));
+	}
+
+	regs_buff[0]  = E1000_READ_REG(hw, E1000_CTRL);
+	regs_buff[1]  = E1000_READ_REG(hw, E1000_STATUS);
+
+	regs_buff[2]  = E1000_READ_REG(hw, E1000_RDLEN(rbase_offset));
+	regs_buff[3]  = E1000_READ_REG(hw, E1000_RDH(rbase_offset));
+	regs_buff[4]  = E1000_READ_REG(hw, E1000_RDT(rbase_offset));
+
+	regs_buff[5]  = E1000_READ_REG(hw, E1000_TDBAL(rbase_offset));
+	regs_buff[6]  = E1000_READ_REG(hw, E1000_TDBAH(rbase_offset));
+	regs_buff[7] = E1000_READ_REG(hw, E1000_TDLEN(rbase_offset));
+	regs_buff[8] = E1000_READ_REG(hw, E1000_TDH(rbase_offset));
+	regs_buff[9] = E1000_READ_REG(hw, E1000_TDT(rbase_offset));
+	regs_buff[10] = E1000_READ_REG(hw, E1000_TXDCTL(rbase_offset));
+	regs_buff[11] = E1000_READ_REG(hw, E1000_RXDCTL(rbase_offset));
+	regs_buff[12] = E1000_READ_REG(hw, E1000_RDBAL(rbase_offset));
+	regs_buff[13] = E1000_READ_REG(hw, E1000_RDBAH(rbase_offset));
+
+	printk("Register dump\n");
+	for (i = 0; i < NUM_REGS; i++) {
+		printk("%-15s  %08x\n",
+		reg_name[i], regs_buff[i]);
+	}
+
+	printk("SRRCTL = %8.8x\n", E1000_READ_REG(hw, E1000_SRRCTL(0)));
+}
+
+static void igbvf_initialize_last_counter_stats(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	adapter->stats.last_gprc = er32(VFGPRC);
+	adapter->stats.last_gorc = er32(VFGORC);
+	adapter->stats.last_gptc = er32(VFGPTC);
+	adapter->stats.last_gotc = er32(VFGOTC);
+	adapter->stats.last_mprc = er32(VFMPRC);
+	adapter->stats.last_gotlbc = er32(VFGOTLBC);
+	adapter->stats.last_gptlbc = er32(VFGPTLBC);
+	adapter->stats.last_gorlbc = er32(VFGORLBC);
+	adapter->stats.last_gprlbc = er32(VFGPRLBC);
+
+	adapter->stats.base_gprc = er32(VFGPRC);
+	adapter->stats.base_gorc = er32(VFGORC);
+	adapter->stats.base_gptc = er32(VFGPTC);
+	adapter->stats.base_gotc = er32(VFGOTC);
+	adapter->stats.base_mprc = er32(VFMPRC);
+	adapter->stats.base_gotlbc = er32(VFGOTLBC);
+	adapter->stats.base_gptlbc = er32(VFGPTLBC);
+	adapter->stats.base_gorlbc = er32(VFGORLBC);
+	adapter->stats.base_gprlbc = er32(VFGPRLBC);
+}
+
+/**
+ * igbvf_open - Called when a network interface is made active
+ * @netdev: network interface device structure
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ * The open entry point is called when a network interface is made
+ * active by the system (IFF_UP).  At this point all resources needed
+ * for transmit and receive operations are allocated, the interrupt
+ * handler is registered with the OS, the watchdog timer is started,
+ * and the stack is notified that the interface is ready.
+ **/
+static int igbvf_open(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int err;
+
+	/* disallow open during test */
+	if (test_bit(__IGBVF_TESTING, &adapter->state))
+		return -EBUSY;
+
+	/* allocate transmit descriptors */
+	err = igbvf_setup_tx_resources(adapter);
+	if (err)
+		goto err_setup_tx;
+
+	/* allocate receive descriptors */
+	err = igbvf_setup_rx_resources(adapter);
+	if (err)
+		goto err_setup_rx;
+
+	/*
+	 * before we allocate an interrupt, we must be ready to handle it.
+	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
+	 * as soon as we call pci_request_irq, so we have to setup our
+	 * clean_rx handler before we do so.
+	 */
+	igbvf_configure(adapter);
+
+	err = igbvf_request_irq(adapter);
+	if (err)
+		goto err_req_irq;
+
+	/* From here on the code is the same as igbvf_up() */
+	clear_bit(__IGBVF_DOWN, &adapter->state);
+
+	napi_enable(&adapter->napi);
+
+	igbvf_enable_vf_queues(adapter);
+
+	/* clear any pending interrupts */
+	er32(EICR);
+
+	igbvf_irq_enable(adapter);
+
+	igbvf_dump_interrupt_registers(adapter);
+	/* fire a link status change interrupt to start the watchdog */
+	hw->mac.get_link_status = 1;
+	ew32(EICS, adapter->eims_other);
+
+	return 0;
+
+err_req_irq:
+	if (!adapter->wol && hw->phy.ops.power_down)
+		hw->phy.ops.power_down(hw);
+	igbvf_free_rx_resources(adapter);
+err_setup_rx:
+	igbvf_free_tx_resources(adapter);
+err_setup_tx:
+	igbvf_reset(adapter);
+
+	return err;
+}
+
+/**
+ * igbvf_close - Disables a network interface
+ * @netdev: network interface device structure
+ *
+ * Returns 0, this is not allowed to fail
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ **/
+static int igbvf_close(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	WARN_ON(test_bit(__IGBVF_RESETTING, &adapter->state));
+	igbvf_down(adapter);
+
+	igbvf_free_irq(adapter);
+
+	igbvf_free_tx_resources(adapter);
+	igbvf_free_rx_resources(adapter);
+
+	return 0;
+}
+/**
+ * igbvf_set_mac - Change the Ethernet Address of the NIC
+ * @netdev: network interface device structure
+ * @p: pointer to an address structure
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int igbvf_set_mac(struct net_device *netdev, void *p)
+{
+	return -EOPNOTSUPP;
+}
+
+/**
+ * Need to wait a few seconds after link up to get diagnostic information from
+ * the phy
+ **/
+static void igbvf_update_phy_info(unsigned long data)
+{
+	struct igbvf_adapter *adapter = (struct igbvf_adapter *) data;
+	if (adapter->hw.phy.ops.get_info)
+		adapter->hw.phy.ops.get_info(&adapter->hw);
+}
+
+#define UPDATE_VF_COUNTER(reg, last_counter, counter)	\
+	{						\
+		u32 current_counter = er32(reg);	\
+		if (current_counter < last_counter)	\
+			counter += 0x100000000LL;	\
+		last_counter = current_counter;		\
+		counter &= 0xFFFFFFFF00000000LL;	\
+		counter |= current_counter;		\
+	}
+
+/**
+ * igbvf_update_stats - Update the board statistics counters
+ * @adapter: board private structure 
+**/
+void igbvf_update_stats(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+#ifdef HAVE_PCI_ERS
+	struct pci_dev *pdev = adapter->pdev;
+#endif
+
+	/*
+	 * Prevent stats update while adapter is being reset, link is down
+	 * or if the pci connection is down.
+	 */
+	if (adapter->link_speed == 0)
+		return;
+
+	if (test_bit(__IGBVF_RESETTING, &adapter->state))
+		return;
+
+#ifdef HAVE_PCI_ERS
+	if (pci_channel_offline(pdev))
+		return;
+#endif
+
+	UPDATE_VF_COUNTER(VFGPRC, adapter->stats.last_gprc, adapter->stats.gprc);
+	UPDATE_VF_COUNTER(VFGORC, adapter->stats.last_gorc, adapter->stats.gorc);
+	UPDATE_VF_COUNTER(VFGPTC, adapter->stats.last_gptc, adapter->stats.gptc);
+	UPDATE_VF_COUNTER(VFGOTC, adapter->stats.last_gotc, adapter->stats.gotc);
+	UPDATE_VF_COUNTER(VFMPRC, adapter->stats.last_mprc, adapter->stats.mprc);
+	UPDATE_VF_COUNTER(VFGOTLBC, adapter->stats.last_gotlbc, adapter->stats.gotlbc);
+	UPDATE_VF_COUNTER(VFGPTLBC, adapter->stats.last_gptlbc, adapter->stats.gptlbc);
+	UPDATE_VF_COUNTER(VFGORLBC, adapter->stats.last_gorlbc, adapter->stats.gorlbc);
+	UPDATE_VF_COUNTER(VFGPRLBC, adapter->stats.last_gprlbc, adapter->stats.gprlbc);
+
+	/* Fill out the OS statistics structure */
+	adapter->net_stats.multicast = adapter->stats.mprc;
+}
+
+static void igbvf_print_link_info(struct igbvf_adapter *adapter)
+{
+	e_info("Link is Up %d Mbps %s\n",
+	       adapter->link_speed,
+	       ((adapter->link_duplex == FULL_DUPLEX) ?
+		"Full Duplex" : "Half Duplex"));
+}
+
+static bool igbvf_has_link(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	bool link_active = 0;
+
+	link_active = (((er32(STATUS)) & 0x2) != 0);
+
+	return link_active;
+}
+
+static void igbvf_enable_receives(struct igbvf_adapter *adapter)
+{
+#if 0
+	/* FIX ME!!! */
+	/* make sure the receive unit is started */
+	if ((adapter->flags & FLAG_RX_NEEDS_RESTART) &&
+	    (adapter->flags & FLAG_RX_RESTART_NOW)) {
+		struct e1000_hw *hw = &adapter->hw;
+		u32 rctl = er32(RCTL);
+		ew32(RCTL, rctl | E1000_RCTL_EN);
+		adapter->flags &= ~FLAG_RX_RESTART_NOW;
+	}
+#endif
+}
+
+/**
+ * igbvf_watchdog - Timer Call-back
+ * @data: pointer to adapter cast into an unsigned long
+ **/
+static void igbvf_watchdog(unsigned long data)
+{
+	struct igbvf_adapter *adapter = (struct igbvf_adapter *) data;
+
+	/* Do the rest outside of interrupt context */
+	schedule_work(&adapter->watchdog_task);
+
+	/* TODO: make this use queue_delayed_work() */
+}
+
+static void igbvf_watchdog_task(struct work_struct *work)
+{
+	struct igbvf_adapter *adapter = container_of(work,
+					struct igbvf_adapter, watchdog_task);
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_mac_info *mac = &adapter->hw.mac;
+	struct igbvf_ring *tx_ring = adapter->tx_ring;
+	struct e1000_hw *hw = &adapter->hw;
+	u32 link;
+	int tx_pending = 0;
+
+	link = igbvf_has_link(adapter);
+
+	if ((netif_carrier_ok(netdev)) && link) {
+		igbvf_enable_receives(adapter);
+		goto link_up;
+	}
+
+	if (link) {
+		if (!netif_carrier_ok(netdev)) {
+			bool txb2b = 1;
+
+			mac->ops.get_link_up_info(&adapter->hw,
+						   &adapter->link_speed,
+						   &adapter->link_duplex);
+			igbvf_print_link_info(adapter);
+
+			/*
+			 * tweak tx_queue_len according to speed/duplex
+			 * and adjust the timeout factor
+			 */
+			netdev->tx_queue_len = adapter->tx_queue_len;
+			adapter->tx_timeout_factor = 1;
+			switch (adapter->link_speed) {
+			case SPEED_10:
+				txb2b = 0;
+				netdev->tx_queue_len = 10;
+				adapter->tx_timeout_factor = 16;
+				break;
+			case SPEED_100:
+				txb2b = 0;
+				netdev->tx_queue_len = 100;
+				/* maybe add some timeout factor ? */
+				break;
+			}
+
+			netif_carrier_on(netdev);
+			netif_wake_queue(netdev);
+
+			if (!test_bit(__IGBVF_DOWN, &adapter->state))
+				mod_timer(&adapter->phy_info_timer,
+					  round_jiffies(jiffies + 2 * HZ));
+		}
+	} else {
+		if (netif_carrier_ok(netdev)) {
+			adapter->link_speed = 0;
+			adapter->link_duplex = 0;
+			e_info("Link is Down\n");
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+			if (!test_bit(__IGBVF_DOWN, &adapter->state))
+				mod_timer(&adapter->phy_info_timer,
+					  round_jiffies(jiffies + 2 * HZ));
+
+			if (adapter->flags & FLAG_RX_NEEDS_RESTART)
+				schedule_work(&adapter->reset_task);
+		}
+	}
+
+link_up:
+	igbvf_update_stats(adapter);
+
+	if (!netif_carrier_ok(netdev)) {
+		tx_pending = (igbvf_desc_unused(tx_ring) + 1 <
+			       tx_ring->count);
+		if (tx_pending) {
+			/*
+			 * We've lost link, so the controller stops DMA,
+			 * but we've got queued Tx work that's never going
+			 * to get done, so reset controller to flush Tx.
+			 * (Do the reset outside of interrupt context).
+			 */
+			adapter->tx_timeout_count++;
+			schedule_work(&adapter->reset_task);
+		}
+	}
+
+	/* Cause software interrupt to ensure Rx ring is cleaned */
+	ew32(EICS, 1);
+
+	/* Force detection of hung controller every watchdog period */
+	adapter->detect_tx_hung = 1;
+
+	/* Reset the timer */
+	if (!test_bit(__IGBVF_DOWN, &adapter->state))
+		mod_timer(&adapter->watchdog_timer,
+			  round_jiffies(jiffies + (2 * HZ)));
+}
+
+#define IGBVF_TX_FLAGS_CSUM		0x00000001
+#define IGBVF_TX_FLAGS_VLAN		0x00000002
+#define IGBVF_TX_FLAGS_TSO		0x00000004
+#define IGBVF_TX_FLAGS_IPV4		0x00000008
+#define IGBVF_TX_FLAGS_VLAN_MASK	0xffff0000
+#define IGBVF_TX_FLAGS_VLAN_SHIFT	16
+
+static int igbvf_tso(struct igbvf_adapter *adapter,
+		     struct igbvf_ring *tx_ring,
+		     struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+{
+#ifdef NETIF_F_TSO
+	struct e1000_adv_tx_context_desc *context_desc;
+	unsigned int i;
+	int err;
+	struct igbvf_buffer *buffer_info;
+	u32 info = 0, tu_cmd = 0;
+	u32 mss_l4len_idx, l4len;
+	*hdr_len = 0;
+
+	if (skb_header_cloned(skb)) {
+		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (err) {
+			printk("igbvf_tso returning an error\n");
+			return err;
+		}
+	}
+
+	l4len = tcp_hdrlen(skb);
+	*hdr_len += l4len;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		struct iphdr *iph = ip_hdr(skb);
+		iph->tot_len = 0;
+		iph->check = 0;
+		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
+							 iph->daddr, 0,
+							 IPPROTO_TCP,
+							 0);
+#ifdef NETIF_F_TSO6
+	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
+		ipv6_hdr(skb)->payload_len = 0;
+		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
+						       &ipv6_hdr(skb)->daddr,
+						       0, IPPROTO_TCP, 0);
+#endif
+	}
+
+	i = tx_ring->next_to_use;
+
+	buffer_info = &tx_ring->buffer_info[i];
+	context_desc = IGBVF_TX_CTXTDESC_ADV(*tx_ring, i);
+	/* VLAN MACLEN IPLEN */
+	if (tx_flags & IGBVF_TX_FLAGS_VLAN)
+		info |= (tx_flags & IGBVF_TX_FLAGS_VLAN_MASK);
+	info |= (skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT);
+	*hdr_len += skb_network_offset(skb);
+	info |= (skb_transport_header(skb) - skb_network_header(skb));
+	*hdr_len += (skb_transport_header(skb) - skb_network_header(skb));
+	context_desc->vlan_macip_lens = cpu_to_le32(info);
+
+	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
+	tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
+
+	if (skb->protocol == htons(ETH_P_IP))
+		tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
+	tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+
+	context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
+
+	/* MSS L4LEN IDX */
+	mss_l4len_idx = (skb_shinfo(skb)->gso_size << E1000_ADVTXD_MSS_SHIFT);
+	mss_l4len_idx |= (l4len << E1000_ADVTXD_L4LEN_SHIFT);
+
+	context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
+	context_desc->seqnum_seed = 0;
+
+	buffer_info->time_stamp = jiffies;
+	buffer_info->dma = 0;
+	i++;
+	if (i == tx_ring->count)
+		i = 0;
+
+	tx_ring->next_to_use = i;
+
+	return TRUE;
+#else
+	return FALSE;
+#endif  /* NETIF_F_TSO */
+}
+
+static inline bool igbvf_tx_csum(struct igbvf_adapter *adapter,
+				 struct igbvf_ring *tx_ring,
+				 struct sk_buff *skb, u32 tx_flags)
+{
+	struct e1000_adv_tx_context_desc *context_desc;
+	unsigned int i;
+	struct igbvf_buffer *buffer_info;
+	u32 info = 0, tu_cmd = 0;
+
+	if ((skb->ip_summed == CHECKSUM_PARTIAL) ||
+	    (tx_flags & IGBVF_TX_FLAGS_VLAN)) {
+		i = tx_ring->next_to_use;
+		buffer_info = &tx_ring->buffer_info[i];
+		context_desc = IGBVF_TX_CTXTDESC_ADV(*tx_ring, i);
+
+		if (tx_flags & IGBVF_TX_FLAGS_VLAN)
+			info |= (tx_flags & IGBVF_TX_FLAGS_VLAN_MASK);
+
+		info |= (skb_network_offset(skb) << E1000_ADVTXD_MACLEN_SHIFT);
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			info |= (skb_transport_header(skb) -
+			         skb_network_header(skb));
+
+
+		context_desc->vlan_macip_lens = cpu_to_le32(info);
+
+		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			switch (skb->protocol) {
+			case __constant_htons(ETH_P_IP):
+				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
+				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				break;
+#ifdef NETIF_F_IPV6_CSUM
+			case __constant_htons(ETH_P_IPV6):
+				/* XXX what about other V6 headers?? */
+				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+					tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
+				break;
+#endif
+			default:
+				break;
+			}
+		}
+
+		context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
+		context_desc->seqnum_seed = 0;
+		context_desc->mss_l4len_idx = 0;
+
+		buffer_info->time_stamp = jiffies;
+		buffer_info->dma = 0;
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+		tx_ring->next_to_use = i;
+
+		return TRUE;
+	}
+
+	return FALSE;
+}
+
+static int igbvf_maybe_stop_tx(struct net_device *netdev, int size)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	int descriptors_unused;
+
+	if ((descriptors_unused = igbvf_desc_unused(adapter->tx_ring)) >= size)
+		return 0;
+	return descriptors_unused;
+}
+
+#define IGBVF_MAX_TXD_PWR	16
+#define IGBVF_MAX_DATA_PER_TXD	(1 << IGBVF_MAX_TXD_PWR)
+
+static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
+				   struct igbvf_ring *tx_ring,
+				   struct sk_buff *skb)
+{
+	struct igbvf_buffer *buffer_info;
+	unsigned int len = skb_headlen(skb);
+	unsigned int count = 0, i;
+	unsigned int f;
+
+	i = tx_ring->next_to_use;
+
+	buffer_info = &tx_ring->buffer_info[i];
+	BUG_ON(len >= IGBVF_MAX_DATA_PER_TXD);
+	buffer_info->length = len;
+	/* set time_stamp *before* dma to help avoid a possible race */
+	buffer_info->time_stamp = jiffies;
+
+	buffer_info->dma =
+	        pci_map_single(adapter->pdev, skb->data, len,
+	                                  PCI_DMA_TODEVICE);
+
+	count++;
+	i++;
+	if (i == tx_ring->count)
+		i = 0;
+
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
+		struct skb_frag_struct *frag;
+
+		frag = &skb_shinfo(skb)->frags[f];
+		len = frag->size;
+
+		buffer_info = &tx_ring->buffer_info[i];
+		BUG_ON(len >= IGBVF_MAX_DATA_PER_TXD);
+		buffer_info->length = len;
+		buffer_info->time_stamp = jiffies;
+		buffer_info->dma =
+			pci_map_page(adapter->pdev,
+		                                frag->page,
+		                                frag->page_offset,
+		                                len,
+		                                PCI_DMA_TODEVICE);
+		count++;
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+	}
+
+	i = (i == 0) ? tx_ring->count - 1 : i - 1;
+	tx_ring->buffer_info[i].skb = skb;
+
+	return count;
+}
+
+static inline void igbvf_tx_queue_adv(struct igbvf_adapter *adapter,
+				      struct igbvf_ring *tx_ring,
+				      int tx_flags, int count, u32 paylen,
+				      u8 hdr_len)
+{
+	union e1000_adv_tx_desc *tx_desc = NULL;
+	struct igbvf_buffer *buffer_info;
+	u32 olinfo_status = 0, cmd_type_len;
+	unsigned int i;
+
+	cmd_type_len = (E1000_ADVTXD_DTYP_DATA | E1000_ADVTXD_DCMD_IFCS |
+	                E1000_ADVTXD_DCMD_DEXT);
+
+	if (tx_flags & IGBVF_TX_FLAGS_VLAN)
+		cmd_type_len |= E1000_ADVTXD_DCMD_VLE;
+
+	if (tx_flags & IGBVF_TX_FLAGS_TSO) {
+		cmd_type_len |= E1000_ADVTXD_DCMD_TSE;
+
+		/* insert tcp checksum */
+		olinfo_status |= E1000_TXD_POPTS_TXSM << 8;
+
+		/* insert ip checksum */
+		if (tx_flags & IGBVF_TX_FLAGS_IPV4)
+			olinfo_status |= E1000_TXD_POPTS_IXSM << 8;
+
+	} else if (tx_flags & IGBVF_TX_FLAGS_CSUM) {
+		olinfo_status |= E1000_TXD_POPTS_TXSM << 8;
+	}
+
+	olinfo_status |= ((paylen - hdr_len) << E1000_ADVTXD_PAYLEN_SHIFT);
+
+	i = tx_ring->next_to_use;
+	while (count--) {
+		buffer_info = &tx_ring->buffer_info[i];
+		tx_desc = IGBVF_TX_DESC_ADV(*tx_ring, i);
+		tx_desc->read.buffer_addr = cpu_to_le64(buffer_info->dma);
+		tx_desc->read.cmd_type_len =
+			cpu_to_le32(cmd_type_len | buffer_info->length);
+		tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+	}
+
+	tx_desc->read.cmd_type_len |= cpu_to_le32(adapter->txd_cmd);
+	/* Force memory writes to complete before letting h/w
+	 * know there are new descriptors to fetch.  (Only
+	 * applicable for weak-ordered memory model archs,
+	 * such as IA-64). */
+	wmb();
+
+	tx_ring->next_to_use = i;
+	writel(i, adapter->hw.hw_addr + tx_ring->tail);
+	/* we need this if more than one processor can write to our tail
+	 * at a time, it syncronizes IO on IA64/Altix systems */
+	mmiowb();
+}
+
+#define TXD_USE_COUNT(S) (((S) >> (IGBVF_MAX_TXD_PWR)) + 1)
+
+static int igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
+                                   struct net_device *netdev,
+                                   struct igbvf_ring *tx_ring)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	unsigned int tx_flags = 0;
+	unsigned int len;
+	u8 hdr_len = 0;
+	int tso = 0;
+	int count = 0;
+	int nr_frags;
+	int f;
+
+	len = skb_headlen(skb);
+
+	if (test_bit(__IGBVF_DOWN, &adapter->state)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (skb->len <= 0) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	count += TXD_USE_COUNT(len);
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+	for (f = 0; f < nr_frags; f++)
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
+
+	/*
+	 * need: count + 4 desc gap to keep tail from touching
+         *       + 2 desc gap to keep tail from touching head,
+         *       + 1 desc for skb->data,
+         *       + 1 desc for context descriptor,
+	 * head, otherwise try next time
+	 */
+	if (igbvf_maybe_stop_tx(netdev, count + 4)) {
+		return NETDEV_TX_BUSY;
+	}
+
+	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		printk("Using VLAN\n");
+		tx_flags |= IGBVF_TX_FLAGS_VLAN;
+		tx_flags |= (vlan_tx_tag_get(skb) << IGBVF_TX_FLAGS_VLAN_SHIFT);
+	}
+
+	if (skb->protocol == htons(ETH_P_IP))
+		tx_flags |= IGBVF_TX_FLAGS_IPV4;
+
+	tso = skb_is_gso(skb) ?
+		igbvf_tso(adapter, tx_ring, skb, tx_flags, &hdr_len) : 0;
+	if (unlikely(tso < 0)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (tso) {
+		tx_flags |= IGBVF_TX_FLAGS_TSO;
+	}
+	else if (igbvf_tx_csum(adapter, tx_ring, skb, tx_flags))
+			if (skb->ip_summed == CHECKSUM_PARTIAL)
+				tx_flags |= IGBVF_TX_FLAGS_CSUM;
+
+	igbvf_tx_queue_adv(adapter, tx_ring, tx_flags,
+			   igbvf_tx_map_adv(adapter, tx_ring, skb),
+			   skb->len, hdr_len);
+
+	netdev->trans_start = jiffies;
+
+	return NETDEV_TX_OK;
+}
+
+static int igbvf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct igbvf_ring *tx_ring;
+	int retval;
+
+	if (test_bit(__IGBVF_RESETTING, &adapter->state))
+		return NETDEV_TX_BUSY;
+
+	tx_ring = &adapter->tx_ring[0];
+
+	retval = igbvf_xmit_frame_ring_adv(skb, netdev, tx_ring);
+
+	return retval;
+}
+
+/**
+ * igbvf_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ **/
+static void igbvf_tx_timeout(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	/* Do the reset outside of interrupt context */
+	adapter->tx_timeout_count++;
+	schedule_work(&adapter->reset_task);
+}
+
+static void igbvf_pf_has_reset_task(struct work_struct *work)
+{
+	struct igbvf_adapter *adapter;
+	int err;
+
+	adapter = container_of(work, struct igbvf_adapter, pf_has_reset_task);
+
+	igbvf_down(adapter);
+
+	igbvf_free_irq(adapter);
+
+	kfree(adapter->msix_entries);
+
+	igbvf_free_tx_resources(adapter);
+	igbvf_free_rx_resources(adapter);
+
+	/* Re-initialize our statistics */
+	igbvf_initialize_last_counter_stats(adapter);
+	adapter->int_counter0 = 0;
+	adapter->int_counter1 = 0;
+	adapter->hw_csum_err  = 0;
+	adapter->hw_csum_good = 0;
+
+	/* allocate transmit descriptors */
+	err = igbvf_setup_tx_resources(adapter);
+	//	if (err)
+	//goto err_setup_tx;
+
+	/* allocate receive descriptors */
+	err = igbvf_setup_rx_resources(adapter);
+	//	if (err)
+	//goto err_setup_rx;
+
+	err = igbvf_request_irq(adapter);
+
+	pci_set_master(adapter->pdev);
+
+	igbvf_up(adapter);
+}
+
+static void igbvf_reset_task(struct work_struct *work)
+{
+	struct igbvf_adapter *adapter;
+	adapter = container_of(work, struct igbvf_adapter, reset_task);
+
+	igbvf_reinit_locked(adapter);
+}
+
+/**
+ * igbvf_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ *
+ * Returns the address of the device statistics structure.
+ * The statistics are actually updated from the timer callback.
+ **/
+static struct net_device_stats *igbvf_get_stats(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	/* only return the current stats */
+	return &adapter->net_stats;
+}
+
+/**
+ * igbvf_change_mtu - Change the Maximum Transfer Unit
+ * @netdev: network interface device structure
+ * @new_mtu: new value for maximum frame size
+ *
+ * Returns 0 on success, negative on failure
+ **/
+static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	u32 msgbuf[E1000_VFMAILBOX_SIZE];
+
+	if ((new_mtu < 68) || (max_frame > MAX_JUMBO_FRAME_SIZE)) {
+		e_err("Invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	/* Jumbo frame size limits */
+	if (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) {
+		if (!(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
+			e_err("Jumbo Frames not supported.\n");
+			return -EINVAL;
+		}
+	}
+
+#define MAX_STD_JUMBO_FRAME_SIZE 9234
+	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
+		e_err("MTU > 9216 not supported.\n");
+		return -EINVAL;
+	}
+
+	adapter->jumbo_frames_enabled = FALSE;
+
+	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
+		msleep(1);
+	/* igbvf_down has a dependency on max_frame_size */
+	adapter->max_frame_size = max_frame;
+	if (netif_running(netdev))
+		igbvf_down(adapter);
+
+	/*
+	 * NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
+	 * means we reserve 2 more, this pushes us to allocate from the next
+	 * larger slab size.
+	 * i.e. RXBUFFER_2048 --> size-4096 slab
+	 * However with the new *_jumbo_rx* routines, jumbo receives will use
+	 * fragmented skbs
+	 */
+
+	if (max_frame <= 256)
+		adapter->rx_buffer_len = 256;
+	else if (max_frame <= 512)
+		adapter->rx_buffer_len = 512;
+	else if (max_frame <= 1024)
+		adapter->rx_buffer_len = 1024;
+	else if (max_frame <= 2048)
+		adapter->rx_buffer_len = 2048;
+	else
+#if (PAGE_SIZE / 2) > 16384
+		adapter->rx_buffer_len = 16384;
+#else
+		adapter->rx_buffer_len = PAGE_SIZE / 2;
+#endif
+
+
+	/* adjust allocation if LPE protects us, and we aren't using SBP */
+	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
+	     (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
+		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN
+					 + ETH_FCS_LEN;
+
+	e_info("changing MTU from %d to %d\n", netdev->mtu, new_mtu);
+	netdev->mtu = new_mtu;
+
+	if (max_frame > 2048)
+		adapter->jumbo_frames_enabled = TRUE;
+
+	if (netif_running(netdev))
+		igbvf_up(adapter);
+	else
+		igbvf_reset(adapter);
+
+	clear_bit(__IGBVF_RESETTING, &adapter->state);
+
+	if (max_frame > 2048) {
+		memset(msgbuf, '\0', 64);
+		msgbuf[0] = E1000_VF_SET_LPE;
+		igbvf_send_msg_to_pf(adapter, msgbuf);
+		igbvf_get_pf_msg_ack(adapter);
+	}
+
+	return 0;
+}
+
+static int igbvf_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+#ifdef ETHTOOL_OPS_COMPAT
+	case SIOCETHTOOL:
+		return ethtool_ioctl(ifr);
+#endif
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int igbvf_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_PM
+	int retval = 0;
+#endif
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev)) {
+		WARN_ON(test_bit(__IGBVF_RESETTING, &adapter->state));
+		igbvf_down(adapter);
+		igbvf_free_irq(adapter);
+	}
+
+#ifdef CONFIG_PM
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
+#endif
+
+	pci_disable_device(pdev);
+
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int igbvf_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	u32 err;
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(&pdev->dev,
+			"Cannot enable PCI device from suspend\n");
+		return err;
+	}
+
+	pci_set_master(pdev);
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	if (netif_running(netdev)) {
+		err = igbvf_request_irq(adapter);
+		if (err)
+			return err;
+	}
+
+	igbvf_reset(adapter);
+
+	if (netif_running(netdev))
+		igbvf_up(adapter);
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+#endif
+
+#ifndef USE_REBOOT_NOTIFIER
+static void igbvf_shutdown(struct pci_dev *pdev)
+{
+	igbvf_suspend(pdev, PMSG_SUSPEND);
+}
+#else
+static struct pci_driver igbvf_driver;
+static int igbvf_notify_reboot(struct notifier_block *nb, unsigned long event,
+			       void *ptr)
+{
+	struct pci_dev *pdev = NULL;
+
+	switch (event) {
+	case SYS_DOWN:
+	case SYS_HALT:
+	case SYS_POWER_OFF:
+		while ((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
+			if (pci_dev_driver(pdev) == &igbvf_driver)
+				igbvf_suspend(pdev, PMSG_SUSPEND);
+		}
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block igbvf_notifier_reboot = {
+	.notifier_call	= igbvf_notify_reboot,
+	.next		= NULL,
+	.priority	= 0
+};
+#endif
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void igbvf_netpoll(struct net_device *netdev)
+{
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	disable_irq(adapter->pdev->irq);
+
+	igbvf_clean_tx_irq(adapter);
+
+	enable_irq(adapter->pdev->irq);
+}
+#endif
+
+#ifdef HAVE_PCI_ERS
+/**
+ * igbvf_io_error_detected - called when PCI error is detected
+ * @pdev: Pointer to PCI device
+ * @state: The current pci connection state
+ *
+ * This function is called after a PCI bus error affecting
+ * this device has been detected.
+ */
+static pci_ers_result_t igbvf_io_error_detected(struct pci_dev *pdev,
+						pci_channel_state_t state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev))
+		igbvf_down(adapter);
+	pci_disable_device(pdev);
+
+	/* Request a slot slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * igbvf_io_slot_reset - called after the pci bus has been reset.
+ * @pdev: Pointer to PCI device
+ *
+ * Restart the card from scratch, as if from a cold-boot. Implementation
+ * resembles the first-half of the igbvf_resume routine.
+ */
+static pci_ers_result_t igbvf_io_slot_reset(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	if (pci_enable_device(pdev)) {
+		dev_err(&pdev->dev,
+			"Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	pci_set_master(pdev);
+
+	pci_enable_wake(pdev, PCI_D3hot, 0);
+	pci_enable_wake(pdev, PCI_D3cold, 0);
+
+	igbvf_reset(adapter);
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * igbvf_io_resume - called when traffic can start flowing again.
+ * @pdev: Pointer to PCI device
+ *
+ * This callback is called when the error recovery driver tells us that
+ * its OK to resume normal operation. Implementation resembles the
+ * second-half of the igbvf_resume routine.
+ */
+static void igbvf_io_resume(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+
+	if (netif_running(netdev)) {
+		if (igbvf_up(adapter)) {
+			dev_err(&pdev->dev,
+				"can't bring device back up after reset\n");
+			return;
+		}
+	}
+
+	netif_device_attach(netdev);
+}
+#endif /* HAVE_PCI_ERS */
+
+static void igbvf_print_device_info(struct igbvf_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	struct net_device *netdev = adapter->netdev;
+	u32 pba_num;
+
+	/* print bus type/speed/width info */
+	e_info("(PCI Express:2.5GB/s:%s) %02x:%02x:%02x:%02x:%02x:%02x\n",
+	       /* bus width */
+	      ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
+	       "Width x1"),
+	       /* MAC address */
+	       netdev->dev_addr[0], netdev->dev_addr[1],
+	       netdev->dev_addr[2], netdev->dev_addr[3],
+	       netdev->dev_addr[4], netdev->dev_addr[5]);
+	e_info("Intel(R) 82576 Virtual Function\n");
+	e1000_read_pba_num_generic(hw, &pba_num);
+	e_info("MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
+	       hw->mac.type, hw->phy.type,
+	       (pba_num >> 8), (pba_num & 0xff));
+}
+
+/**
+ * igbvf_probe - Device Initialization Routine
+ * @pdev: PCI device information struct
+ * @ent: entry in igbvf_pci_tbl
+ *
+ * Returns 0 on success, negative on failure
+ *
+ * igbvf_probe initializes an adapter identified by a pci_dev structure.
+ * The OS initialization, configuring of the adapter private structure,
+ * and a hardware reset occur.
+ **/
+static int __devinit igbvf_probe(struct pci_dev *pdev,
+				 const struct pci_device_id *ent)
+{
+	struct net_device *netdev;
+	struct igbvf_adapter *adapter;
+	struct e1000_hw *hw;
+	const struct igbvf_info *ei = igbvf_info_tbl[ent->driver_data];
+
+	static int cards_found;
+	int err, pci_using_dac;
+	u32 pf_vf_msgbuf[E1000_VFMAILBOX_SIZE];
+
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
+
+	pci_using_dac = 0;
+	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	if (!err) {
+		err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK);
+		if (!err)
+			pci_using_dac = 1;
+	} else {
+		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (err) {
+			err = pci_set_consistent_dma_mask(pdev,
+							  DMA_32BIT_MASK);
+			if (err) {
+				printk(KERN_ERR "%s: No usable DMA "
+				       "configuration, aborting\n",
+				       pci_name(pdev));
+				goto err_dma;
+			}
+		}
+	}
+
+	err = pci_request_regions(pdev, igbvf_driver_name);
+	if (err)
+		goto err_pci_reg;
+
+	pci_set_master(pdev);
+
+	err = -ENOMEM;
+	netdev = alloc_etherdev(sizeof(struct igbvf_adapter));
+	if (!netdev)
+		goto err_alloc_etherdev;
+
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	pci_set_drvdata(pdev, netdev);
+	adapter = netdev_priv(netdev);
+	hw = &adapter->hw;
+	adapter->netdev = netdev;
+	adapter->pdev = pdev;
+	adapter->ei = ei;
+	adapter->pba = ei->pba;
+	adapter->flags = ei->flags;
+	adapter->hw.back = adapter;
+	adapter->hw.mac.type = ei->mac;
+	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+
+	/* PCI config space info */
+
+	hw->vendor_id = pdev->vendor;
+	hw->device_id = pdev->device;
+	hw->subsystem_vendor_id = pdev->subsystem_vendor;
+	hw->subsystem_device_id = pdev->subsystem_device;
+
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
+	pci_read_config_word(pdev, PCI_COMMAND, &hw->bus.pci_cmd_word);
+
+	err = -EIO;
+	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, 0),
+				      pci_resource_len(pdev, 0));
+
+	if (!adapter->hw.hw_addr)
+		goto err_ioremap;
+
+	igbvf_check_options(adapter);
+
+	if (ei->get_variants) {
+		err = ei->get_variants(adapter);
+		if (err)
+			goto err_hw_init;
+	}
+
+	/* setup adapter struct */
+	err = igbvf_sw_init(adapter);
+	if (err)
+		goto err_sw_init;
+
+	/* construct the net_device struct */
+	netdev->open			= &igbvf_open;
+	netdev->stop			= &igbvf_close;
+	netdev->hard_start_xmit		= &igbvf_xmit_frame;
+	netdev->get_stats		= &igbvf_get_stats;
+	netdev->set_multicast_list	= &igbvf_set_multi;
+	netdev->set_mac_address		= &igbvf_set_mac;
+	netdev->change_mtu		= &igbvf_change_mtu;
+	netdev->do_ioctl		= &igbvf_ioctl;
+	igbvf_set_ethtool_ops(netdev);
+	netdev->tx_timeout		= &igbvf_tx_timeout;
+	netdev->watchdog_timeo		= 5 * HZ;
+	netif_napi_add(netdev, &adapter->napi, igbvf_poll, 64);
+	netdev->vlan_rx_register	= igbvf_vlan_rx_register;
+	netdev->vlan_rx_add_vid		= igbvf_vlan_rx_add_vid;
+	netdev->vlan_rx_kill_vid	= igbvf_vlan_rx_kill_vid;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	netdev->poll_controller		= igbvf_netpoll;
+#endif
+	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
+
+	adapter->bd_number = cards_found++;
+
+	hw->mac.ops.get_bus_info(&adapter->hw);
+
+	adapter->hw.phy.autoneg_wait_to_complete = 0;
+
+	/* Copper options */
+	if (adapter->hw.phy.media_type == e1000_media_type_copper) {
+		adapter->hw.phy.mdix = AUTO_ALL_MODES;
+		adapter->hw.phy.disable_polarity_correction = 0;
+		adapter->hw.phy.ms_type = e1000_ms_hw_default;
+	}
+
+	if (hw->phy.ops.check_reset_block &&
+	    hw->phy.ops.check_reset_block(hw))
+		e_info("PHY reset is blocked due to SOL/IDER session.\n");
+
+	netdev->features = NETIF_F_SG |
+			   NETIF_F_HW_CSUM |
+			   NETIF_F_HW_VLAN_TX |
+			   NETIF_F_HW_VLAN_RX;
+
+	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
+		netdev->features |= NETIF_F_HW_VLAN_FILTER;
+
+#ifdef NETIF_F_TSO
+	netdev->features |= NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+	netdev->features |= NETIF_F_TSO6;
+#endif
+#endif
+
+	if (pci_using_dac)
+		netdev->features |= NETIF_F_HIGHDMA;
+
+#ifdef NETIF_F_LLTX
+	/*
+	 * We should not be using LLTX anymore, but we are still Tx faster with
+	 * it.
+	 */
+	netdev->features |= NETIF_F_LLTX;
+#endif
+
+	/*
+	 * before reading the NVM, reset the controller to
+	 * put the device in a known good starting state
+	 */
+	adapter->hw.mac.ops.reset_hw(&adapter->hw);
+	adapter->hw.mac.ops.init_hw(&adapter->hw);
+
+	memset(pf_vf_msgbuf, '\0', 64);
+	pf_vf_msgbuf[0] = E1000_VF_MSGTYPE_REQ_MAC;
+	igbvf_send_msg_to_pf(adapter, pf_vf_msgbuf);
+	if (igbvf_poll_for_msg(adapter, pf_vf_msgbuf) != 0) {
+		u8 *p = (u8 *)(&pf_vf_msgbuf[1]);
+		memcpy(adapter->hw.mac.addr, p, 6);
+	}
+	igbvf_get_pf_msg_ack(adapter);
+
+	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
+#ifdef ETHTOOL_GPERMADDR
+	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
+
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
+#else
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
+#endif
+		e_err("Invalid MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
+		      netdev->dev_addr[0], netdev->dev_addr[1],
+		      netdev->dev_addr[2], netdev->dev_addr[3],
+		      netdev->dev_addr[4], netdev->dev_addr[5]);
+		err = -EIO;
+		goto err_eeprom;
+	}
+
+	init_timer(&adapter->watchdog_timer);
+	adapter->watchdog_timer.function = &igbvf_watchdog;
+	adapter->watchdog_timer.data = (unsigned long) adapter;
+
+	init_timer(&adapter->phy_info_timer);
+	adapter->phy_info_timer.function = &igbvf_update_phy_info;
+	adapter->phy_info_timer.data = (unsigned long) adapter;
+
+	INIT_WORK(&adapter->reset_task, igbvf_reset_task);
+	INIT_WORK(&adapter->pf_has_reset_task, igbvf_pf_has_reset_task);
+	INIT_WORK(&adapter->watchdog_task, igbvf_watchdog_task);
+	INIT_WORK(&adapter->msg_handler_task, igbvf_msg_handler_task);
+
+	igbvf_check_options(adapter);
+
+	/* Initialize link parameters. User can change them with ethtool */
+	adapter->hw.mac.autoneg = 0;
+	adapter->fc_autoneg = 0;
+	adapter->hw.phy.autoneg_advertised = 0x00;
+
+	/* ring size defaults */
+	adapter->rx_ring->count = 1024;
+	adapter->tx_ring->count = 1024;
+
+	/* reset the hardware with the new settings */
+	igbvf_reset(adapter);
+
+	/* tell the stack to leave us alone until igbvf_open() is called */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	strcpy(netdev->name, "eth%d");
+	err = register_netdev(netdev);
+	if (err)
+		goto err_register;
+
+	igbvf_print_device_info(adapter);
+
+	igbvf_initialize_last_counter_stats(adapter);
+
+	return 0;
+
+err_register:
+err_eeprom:
+	if (hw->phy.ops.check_reset_block &&
+	    !hw->phy.ops.check_reset_block(hw))
+		hw->phy.ops.reset(hw);
+err_hw_init:
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+err_sw_init:
+	iounmap(adapter->hw.hw_addr);
+err_ioremap:
+	free_netdev(netdev);
+err_alloc_etherdev:
+	pci_release_regions(pdev);
+err_pci_reg:
+err_dma:
+	pci_disable_device(pdev);
+	return err;
+}
+
+/**
+ * igbvf_remove - Device Removal Routine
+ * @pdev: PCI device information struct
+ *
+ * igbvf_remove is called by the PCI subsystem to alert the driver
+ * that it should release a PCI device.  The could be caused by a
+ * Hot-Plug event, or because the driver is going to be removed from
+ * memory.
+ **/
+static void __devexit igbvf_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct igbvf_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+
+	/*
+	 * flush_scheduled work may reschedule our watchdog task, so
+	 * explicitly disable watchdog tasks from being rescheduled
+	 */
+	set_bit(__IGBVF_DOWN, &adapter->state);
+	del_timer_sync(&adapter->watchdog_timer);
+	del_timer_sync(&adapter->phy_info_timer);
+
+	flush_scheduled_work();
+
+	unregister_netdev(netdev);
+
+	if (hw->phy.ops.check_reset_block &&
+	    !hw->phy.ops.check_reset_block(hw))
+		hw->phy.ops.reset(hw);
+
+	igbvf_reset_interrupt_capability(adapter);
+	kfree(adapter->tx_ring);
+	kfree(adapter->rx_ring);
+
+	iounmap(adapter->hw.hw_addr);
+	if (adapter->hw.flash_address)
+		iounmap(adapter->hw.flash_address);
+	pci_release_regions(pdev);
+
+	free_netdev(netdev);
+
+	pci_disable_device(pdev);
+}
+
+#ifdef HAVE_PCI_ERS
+/* PCI Error Recovery (ERS) */
+static struct pci_error_handlers igbvf_err_handler = {
+	.error_detected = igbvf_io_error_detected,
+	.slot_reset = igbvf_io_slot_reset,
+	.resume = igbvf_io_resume,
+};
+#endif
+
+static struct pci_device_id igbvf_pci_tbl[] = {
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_VF), board_vf },
+	{ }	/* terminate list */
+};
+MODULE_DEVICE_TABLE(pci, igbvf_pci_tbl);
+
+/* PCI Device API Driver */
+static struct pci_driver igbvf_driver = {
+	.name     = igbvf_driver_name,
+	.id_table = igbvf_pci_tbl,
+	.probe    = igbvf_probe,
+	.remove   = __devexit_p(igbvf_remove),
+#ifdef CONFIG_PM
+	/* Power Management Hooks */
+	.suspend  = igbvf_suspend,
+	.resume   = igbvf_resume,
+#endif
+#ifndef USE_REBOOT_NOTIFIER
+	.shutdown = igbvf_shutdown,
+#endif
+#ifdef HAVE_PCI_ERS
+	.err_handler = &igbvf_err_handler
+#endif
+};
+
+/**
+ * igbvf_init_module - Driver Registration Routine
+ *
+ * igbvf_init_module is the first routine called when the driver is * loaded. All it does is register with the PCI subsystem.
+ **/
+static int __init igbvf_init_module(void)
+{
+	int ret;
+	printk(KERN_INFO "%s: Intel(R) 82576 Virtual Function - %s\n",
+	       igbvf_driver_name, igbvf_driver_version);
+	printk(KERN_INFO "%s: Copyright (c) 1999-2008 Intel Corporation.\n",
+	       igbvf_driver_name);
+	ret = pci_register_driver(&igbvf_driver);
+	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, igbvf_driver_name,
+			       PM_QOS_DEFAULT_VALUE);
+#ifdef USE_REBOOT_NOTIFIER
+	if (ret >= 0)
+		register_reboot_notifier(&igbvf_notifier_reboot);
+#endif
+				
+	return ret;
+}
+module_init(igbvf_init_module);
+
+/**
+ * igbvf_exit_module - Driver Exit Cleanup Routine
+ *
+ * igbvf_exit_module is called just before the driver is removed
+ * from memory.
+ **/
+static void __exit igbvf_exit_module(void)
+{
+#ifdef USE_REBOOT_NOTIFIER
+	unregister_reboot_notifier(&igbvf_notifier_reboot);
+#endif
+	pci_unregister_driver(&igbvf_driver);
+	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY, igbvf_driver_name);
+}
+module_exit(igbvf_exit_module);
+
+
+MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
+MODULE_DESCRIPTION("Intel(R) 82576 Virtual Function");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+/* netdev.c */
diff -Npur igbvf-0.5.2/src/param.c igbvf-0.5.2.orig/src/param.c
--- igbvf-0.5.2/src/param.c	1970-01-01 08:00:00.000000000 +0800
+++ igbvf-0.5.2.orig/src/param.c	2008-11-26 02:08:28.000000000 +0800
@@ -0,0 +1,351 @@
+/*******************************************************************************
+
+  Intel(R) 82576 Virtual Function Linux driver
+  Copyright(c) 1999 - 2008 Intel Corporation.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Contact Information:
+  Linux NICS <linux.nics@intel.com>
+  e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+*******************************************************************************/
+
+#include <linux/netdevice.h>
+
+#include "igbvf.h"
+
+/*
+ * This is the only thing that needs to be changed to adjust the
+ * maximum number of ports that the driver can manage.
+ */
+
+#define IGBVF_MAX_NIC 7
+
+#define OPTION_UNSET   -1
+#define OPTION_DISABLED 0
+#define OPTION_ENABLED  1
+
+#define COPYBREAK_DEFAULT 256
+unsigned int copybreak = COPYBREAK_DEFAULT;
+module_param(copybreak, uint, 0644);
+MODULE_PARM_DESC(copybreak,
+	"Maximum size of packet that is copied to a new buffer on receive");
+
+/*
+ * All parameters are treated the same, as an integer array of values.
+ * This macro just reduces the need to repeat the same declaration code
+ * over and over (plus this helps to avoid typo bugs).
+ */
+
+#define IGBVF_PARAM_INIT { [0 ... IGBVF_MAX_NIC] = OPTION_UNSET }
+#ifndef module_param_array
+/* Module Parameters are always initialized to -1, so that the driver
+ * can tell the difference between no user specified value or the
+ * user asking for the default value.
+ * The true default values are loaded in when igbvf_check_options is called.
+ *
+ * This is a GCC extension to ANSI C.
+ * See the item "Labeled Elements in Initializers" in the section
+ * "Extensions to the C Language Family" of the GCC documentation.
+ */
+#define IGBVF_PARAM(X, desc) \
+	static const int __devinitdata X[IGBVF_MAX_NIC+1] = IGBVF_PARAM_INIT; \
+	static unsigned int num_##X;				 \
+	MODULE_PARM(X, "1-" __MODULE_STRING(IGBVF_MAX_NIC) "i"); \
+	MODULE_PARM_DESC(X, desc);
+#else
+#define IGBVF_PARAM(X, desc)					\
+	static int __devinitdata X[IGBVF_MAX_NIC+1]		\
+		= IGBVF_PARAM_INIT;				\
+	static unsigned int num_##X;				\
+	module_param_array_named(X, X, int, &num_##X, 0);	\
+	MODULE_PARM_DESC(X, desc);
+#endif
+
+/*
+ * Transmit Interrupt Delay in units of 1.024 microseconds
+ * Tx interrupt delay needs to typically be set to something non zero
+ *
+ * Valid Range: 0-65535
+ */
+IGBVF_PARAM(TxIntDelay, "Transmit Interrupt Delay");
+#define DEFAULT_TIDV 8
+#define MAX_TXDELAY 0xFFFF
+#define MIN_TXDELAY 0
+
+/*
+ * Transmit Absolute Interrupt Delay in units of 1.024 microseconds
+ *
+ * Valid Range: 0-65535
+ */
+IGBVF_PARAM(TxAbsIntDelay, "Transmit Absolute Interrupt Delay");
+#define DEFAULT_TADV 32
+#define MAX_TXABSDELAY 0xFFFF
+#define MIN_TXABSDELAY 0
+
+/*
+ * Receive Interrupt Delay in units of 1.024 microseconds
+ * hardware will likely hang if you set this to anything but zero.
+ *
+ * Valid Range: 0-65535
+ */
+IGBVF_PARAM(RxIntDelay, "Receive Interrupt Delay");
+#define DEFAULT_RDTR 0
+#define MAX_RXDELAY 0xFFFF
+#define MIN_RXDELAY 0
+
+/*
+ * Receive Absolute Interrupt Delay in units of 1.024 microseconds
+ *
+ * Valid Range: 0-65535
+ */
+IGBVF_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
+#define DEFAULT_RADV 8
+#define MAX_RXABSDELAY 0xFFFF
+#define MIN_RXABSDELAY 0
+
+/*
+ * Interrupt Throttle Rate (interrupts/sec)
+ *
+ * Valid Range: 100-100000 (0=off, 1=dynamic, 3=dynamic conservative)
+ */
+IGBVF_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
+#define DEFAULT_ITR 3
+#define MAX_ITR 100000
+#define MIN_ITR 100
+
+/* IntMode (Interrupt Mode)
+ *
+ * Valid Range: 0 - 2
+ *
+ * Default Value: 2 (MSI-X)
+ */
+IGBVF_PARAM(IntMode, "Interrupt Mode");
+
+#define DEFAULT_INTMODE	2
+#define MAX_INTMODE	2
+#define MIN_INTMODE	0
+
+
+struct igbvf_option {
+	enum { enable_option, range_option, list_option } type;
+	const char *name;
+	const char *err;
+	int def;
+	union {
+		struct { /* range_option info */
+			int min;
+			int max;
+		} r;
+		struct { /* list_option info */
+			int nr;
+			struct igbvf_opt_list { int i; char *str; } *p;
+		} l;
+	} arg;
+};
+
+static int __devinit igbvf_validate_option(unsigned int *value,
+					   const struct igbvf_option *opt,
+					   struct igbvf_adapter *adapter)
+{
+	if (*value == OPTION_UNSET) {
+		*value = opt->def;
+		return 0;
+	}
+
+	switch (opt->type) {
+	case enable_option:
+		switch (*value) {
+		case OPTION_ENABLED:
+			e_info("%s Enabled\n", opt->name);
+			return 0;
+		case OPTION_DISABLED:
+			e_info("%s Disabled\n", opt->name);
+			return 0;
+		}
+		break;
+	case range_option:
+		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
+			e_info("%s set to %i\n", opt->name, *value);
+			return 0;
+		}
+		break;
+	case list_option: {
+		int i;
+		struct igbvf_opt_list *ent;
+
+		for (i = 0; i < opt->arg.l.nr; i++) {
+			ent = &opt->arg.l.p[i];
+			if (*value == ent->i) {
+				if (ent->str[0] != '\0')
+					e_info("%s\n", ent->str);
+				return 0;
+			}
+		}
+	}
+		break;
+	default:
+		BUG();
+	}
+
+	e_info("Invalid %s value specified (%i) %s\n", opt->name, *value,
+	       opt->err);
+	*value = opt->def;
+	return -1;
+}
+
+/**
+ * igbvf_check_options - Range Checking for Command Line Parameters
+ * @adapter: board private structure
+ *
+ * This routine checks all command line parameters for valid user
+ * input.  If an invalid value is given, or if no user specified
+ * value exists, a default value is used.  The final value is stored
+ * in a variable in the adapter structure.
+ **/
+void __devinit igbvf_check_options(struct igbvf_adapter *adapter)
+{
+	int bd = adapter->bd_number;
+
+	if (bd >= IGBVF_MAX_NIC) {
+		e_notice("Warning: no configuration for board #%i\n", bd);
+		e_notice("Using defaults for all values\n");
+	}
+
+	{ /* Transmit Interrupt Delay */
+		const struct igbvf_option opt = {
+			.type = range_option,
+			.name = "Transmit Interrupt Delay",
+			.err  = "using default of "
+				__MODULE_STRING(DEFAULT_TIDV),
+			.def  = DEFAULT_TIDV,
+			.arg  = { .r = { .min = MIN_TXDELAY,
+					 .max = MAX_TXDELAY } }
+		};
+
+		if (num_TxIntDelay > bd) {
+			adapter->tx_int_delay = TxIntDelay[bd];
+			igbvf_validate_option(&adapter->tx_int_delay, &opt,
+					      adapter);
+		} else {
+			adapter->tx_int_delay = opt.def;
+		}
+	}
+	{ /* Transmit Absolute Interrupt Delay */
+		const struct igbvf_option opt = {
+			.type = range_option,
+			.name = "Transmit Absolute Interrupt Delay",
+			.err  = "using default of "
+				__MODULE_STRING(DEFAULT_TADV),
+			.def  = DEFAULT_TADV,
+			.arg  = { .r = { .min = MIN_TXABSDELAY,
+					 .max = MAX_TXABSDELAY } }
+		};
+
+		if (num_TxAbsIntDelay > bd) {
+			adapter->tx_abs_int_delay = TxAbsIntDelay[bd];
+			igbvf_validate_option(&adapter->tx_abs_int_delay, &opt,
+					      adapter);
+		} else {
+			adapter->tx_abs_int_delay = opt.def;
+		}
+	}
+	{ /* Receive Interrupt Delay */
+		struct igbvf_option opt = {
+			.type = range_option,
+			.name = "Receive Interrupt Delay",
+			.err  = "using default of "
+				__MODULE_STRING(DEFAULT_RDTR),
+			.def  = DEFAULT_RDTR,
+			.arg  = { .r = { .min = MIN_RXDELAY,
+					 .max = MAX_RXDELAY } }
+		};
+
+		if (num_RxIntDelay > bd) {
+			adapter->rx_int_delay = RxIntDelay[bd];
+			igbvf_validate_option(&adapter->rx_int_delay, &opt,
+					      adapter);
+		} else {
+			adapter->rx_int_delay = opt.def;
+		}
+	}
+	{ /* Receive Absolute Interrupt Delay */
+		const struct igbvf_option opt = {
+			.type = range_option,
+			.name = "Receive Absolute Interrupt Delay",
+			.err  = "using default of "
+				__MODULE_STRING(DEFAULT_RADV),
+			.def  = DEFAULT_RADV,
+			.arg  = { .r = { .min = MIN_RXABSDELAY,
+					 .max = MAX_RXABSDELAY } }
+		};
+
+		if (num_RxAbsIntDelay > bd) {
+			adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
+			igbvf_validate_option(&adapter->rx_abs_int_delay, &opt,
+					      adapter);
+		} else {
+			adapter->rx_abs_int_delay = opt.def;
+		}
+	}
+	{ /* Interrupt Throttling Rate */
+		const struct igbvf_option opt = {
+			.type = range_option,
+			.name = "Interrupt Throttling Rate (ints/sec)",
+			.err  = "using default of "
+				__MODULE_STRING(DEFAULT_ITR),
+			.def  = DEFAULT_ITR,
+			.arg  = { .r = { .min = MIN_ITR,
+					 .max = MAX_ITR } }
+		};
+
+		if (num_InterruptThrottleRate > bd) {
+			adapter->itr = InterruptThrottleRate[bd];
+			switch (adapter->itr) {
+			case 0:
+				e_info("%s turned off\n", opt.name);
+				break;
+			case 1:
+				e_info("%s set to dynamic mode\n", opt.name);
+				adapter->itr_setting = adapter->itr;
+				adapter->itr = 20000;
+				break;
+			case 3:
+				e_info("%s set to dynamic conservative mode\n",
+					opt.name);
+				adapter->itr_setting = adapter->itr;
+				adapter->itr = 20000;
+				break;
+			default:
+				igbvf_validate_option(&adapter->itr, &opt,
+					adapter);
+				/*
+				 * save the setting, because the dynamic bits
+				 * change itr. clear the lower two bits
+				 * because they are used as control
+				 */
+				adapter->itr_setting = adapter->itr & ~3;
+				break;
+			}
+		} else {
+			adapter->itr_setting = opt.def;
+			adapter->itr = 20000;
+		}
+	}
+}

--0F1p//8PRICkK4MW
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/virtualization
--0F1p//8PRICkK4MW--
