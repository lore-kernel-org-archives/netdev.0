From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] tests: Add few 'ip link' related tests
Date: Thu, 15 Jan 2015 18:59:22 +0200
Message-ID: <1421341162-6945-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:38178 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbbAORJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 12:09:54 -0500
Received: by mail-la0-f41.google.com with SMTP id hv19so14737237lab.0
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 09:09:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added two tests which checks the following fixed issues:

    1) Bug when not possible add new virtual interface via:

        $ ip link add dev XXX type

       It was fixed a few releases ago.

    2) Crash on older kernels when VF rate info does not exist:

        $ ip link show

       Used dump file from William Dauchy <william@gandi.net>:
           testsuite/tests/ip/link/dev_wo_vf_rate.nl

       So 'ip link show' replaced by 'ip -d monitor file ...' which does
       the same thing.

Also added new func in testsuite/lib/generic.sh to gen new random dev name.

Added 'clean' dependency on running all tests.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 testsuite/Makefile                            |   3 ++-
 testsuite/lib/generic.sh                      |   8 +++++++-
 testsuite/tests/ip/link/dev_wo_vf_rate.nl     | Bin 0 -> 14076 bytes
 testsuite/tests/ip/link/new_link.t            |  11 +++++++++++
 testsuite/tests/ip/link/show_dev_wo_vf_rate.t |   6 ++++++
 5 files changed, 26 insertions(+), 2 deletions(-)
 create mode 100644 testsuite/tests/ip/link/dev_wo_vf_rate.nl
 create mode 100755 testsuite/tests/ip/link/new_link.t
 create mode 100755 testsuite/tests/ip/link/show_dev_wo_vf_rate.t

diff --git a/testsuite/Makefile b/testsuite/Makefile
index 2ba9547..a2c8a2d 100644
--- a/testsuite/Makefile
+++ b/testsuite/Makefile
@@ -31,12 +31,13 @@ listtests:
 alltests: $(TESTS)
 
 clean:
+	@echo "Removing $(RESULTS_DIR) dir ..."
 	@rm -rf $(RESULTS_DIR)
 
 distclean: clean
 	echo "Entering iproute2" && cd iproute2 && $(MAKE) distclean && cd ..;
 
-$(TESTS):
+$(TESTS): clean
 	@mkdir -p $(RESULTS_DIR)
 	
 	@for d in $(TESTS_DIR); do \
diff --git a/testsuite/lib/generic.sh b/testsuite/lib/generic.sh
index 8f76e49..3473cc1 100644
--- a/testsuite/lib/generic.sh
+++ b/testsuite/lib/generic.sh
@@ -62,8 +62,9 @@ ts_ip()
 	TMP_OUT=`mktemp /tmp/tc_testsuite.XXXXXX` || exit
 
 	$IP $@ 2> $TMP_ERR > $TMP_OUT
+        RET=$?
 
-	if [ -s $TMP_ERR ]; then
+	if [ -s $TMP_ERR ] || [ "$RET" != "0" ]; then
 		ts_err "${SCRIPT}: ${DESC} failed:"
 		ts_err "command: $IP $@"
 		ts_err "stderr output:"
@@ -91,3 +92,8 @@ ts_qdisc_available()
 		return 1;
 	fi
 }
+
+rand_dev()
+{
+    echo "dev-$(tr -dc "[:alpha:]" < /dev/urandom | head -c 6)"
+}
diff --git a/testsuite/tests/ip/link/dev_wo_vf_rate.nl b/testsuite/tests/ip/link/dev_wo_vf_rate.nl
new file mode 100644
index 0000000000000000000000000000000000000000..40fa87ff1b158fb972e064efb38f76b0e9a56697
GIT binary patch
literal 14076
zcmeI2QD_`h6o$|4X4B1fZMT}ns!(GsCQqft8lx5o_Nk#2gn}Z4n3_#@VcVp2BSi%l
zK`m6<ASk{l3L;Xdtzh4LXw?UwEWQ;H>|<XAeW{rB{P)gj@7$T$&U9yYCpZUo?##V+
z&N*}MnQzaXnJq-Lk$)l|{C)nwxqpi^KR{HbES=`#u}x?l$YprDm#`&TM>(o55*6q!
zb)4tkkUXi*T+a%)Z-E|A^#$7Mln*Km1sYXlo*q(Vi3aKD;<4q*a)q|j2GuucGkCJq
zDyp+|k0Sdi@-ln2m0iT|)VKO4ZE=*})4fVJbioD$cFa;AC2zZuy`N6-ST&5X6EATo
z_D|Z(Qu>&6?e@!KMAvgf!`ULof*!D8j*?c3=uZxngEPAQq%()pN?GQnhhmRa(B~Ye
z(A8pTJ~c$m=QA9IL@)C6>*%|64N6VG20Ecbn#D)dZ_ng7{!(c-0=xKL9c<UZr)`+;
zOIvp4ZN_9&6znPMI2q#Etu(4TaUM8>c>-r(+vLpn!)W(%rl8In<u>%!oLR?bA34VJ
ztQhmlKitHza7C5aH$^e#k$UUmB_c2eF@vZ9V+O7g?SGr-@R?S2`HvUO)6{;^Q==<_
z>do$84D>@_0|GlJ{cNG$mN0hAbE5V)&o%c8v{}vJPc*{gl%a9wPJSu7_~x%4nmyh7
z_^&agr0#58Q&RsW`ra<_Op1tpM9YpZCUc_~rNvu9zm6*12K{mj{n*D3`lUV&UV1%g
zUn49sc-a(QK6ek%rHYrAh=1`}t|P~0gqN_`DKAAobcv6sGkGaYxZrel&nWIuE#r2B
zQ{U?X846^*F1%akI<{ai+lX9uP#2Sz_NB|1*yo1jC0w(3`6zUChnGJ%y!^2}FE4v}
zc^~`4;Y(kR5Iyaa-ff1{cPQW`^h00+0y_{tTe`))?Zm!YQ?#QXUVc;E_S@cCu&z#d
zdFYwH@;|S(*YAYC>a-Sl`4vy<)WPKPQdrOom<Gw1u9*`N(6<-W;%^Wy<vPl@;ic#a
z^4a92-ABg6uJ_|*!?T9Xs7xa3EEb&nass-*ORO!BU&22#zx<t34!`^o(_*e;p=TrK
zmrDz^g~i#0xmO#KXQCxokY`GMWapU}Yh3fbA)*<df$Jo112<(ZWn5tg;%7^@xVN3y
zcWa7v1a3kSlB1F2Xjs#Jeag!m#E{&^DDlH>((4>evgfMfjQGT^D3Lh0ZZ}AW9+z?D
zXmZ^_?wic9FI~pOJ~u3LVB2EOW6;%a=E$1Kk2%Oo5Afy_nE*KKh=T|@j8vM;k=z${
zAbz%Vi+kINeYd7)M@eSR)Y+6d(PlHaw}ia>H+p(HfVkbdu%FDqn$%*>E?h?+nbSm`
zBkLNQIT&+rc8UjWMkW9b#~|u?nxjWp4m*%2w(S1}t)aWyBr|8__2e=~QsrjA^hg|B
z>&K+}_#|!wF=yI2C&_CojH$(($KiG#nZwWRGbGPC{FsB(11wnSB6B3q5#~g(C2@gq
z?3E;$In!rS=EM~T5?gD9IZJ$x;_1w-ZxZl*frmMh7@s>~&a^sjlu+V*A;kT@P*nwP
z)ceBsZ)C3Q^FIF$JSm0-<Tq<ogf#>FzA%Z;a&|wPT;8nJIq$aL=Chozw)~#u`0)nM
z9;_Va3E1c>Z}z9W2|Le8=S_7_%A2rrnUsEU@uumM-{Ad<yx-r%Zw!`}57le0%+A%9
zs&lx0a0lY|{bktqR>%XRe18dh$aOw@YwX6@yD57x9$}<Rck}x;UXLEH%^$8L=H1oJ
z?~6wGmD=tEudl+4@&B<;T>LrV!yl{-g+KTPWWMs+?8L;AedW&T$F&Wg?nt>4HrA8Q
zozu*nt1D^V6Lvn6(yyD`DH+^Z&)jJouhr}PC3rvcoyj*o+V<UhDR;ugU(&g=%G@cv
PlX55Qd?uw|T-^B&_@nmR

literal 0
HcmV?d00001

diff --git a/testsuite/tests/ip/link/new_link.t b/testsuite/tests/ip/link/new_link.t
new file mode 100755
index 0000000..549ff25
--- /dev/null
+++ b/testsuite/tests/ip/link/new_link.t
@@ -0,0 +1,11 @@
+#!/bin/sh
+
+source lib/generic.sh
+
+ts_log "[Testing add/del virtual links]"
+
+NEW_DEV="$(rand_dev)"
+
+ts_ip "$0" "Add $NEW_DEV dummy interface"  link add dev $NEW_DEV type dummy
+ts_ip "$0" "Show $NEW_DEV dummy interface" link show dev $NEW_DEV
+ts_ip "$0" "Del $NEW_DEV dummy interface"  link del dev $NEW_DEV
diff --git a/testsuite/tests/ip/link/show_dev_wo_vf_rate.t b/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
new file mode 100755
index 0000000..a600ba6
--- /dev/null
+++ b/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
@@ -0,0 +1,6 @@
+#!/bin/sh
+
+source lib/generic.sh
+
+NL_FILE="tests/ip/link/dev_wo_vf_rate.nl"
+ts_ip "$0" "Show VF devices w/o VF rate info" -d monitor file $NL_FILE
-- 
2.1.3
