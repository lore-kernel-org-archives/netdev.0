From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] llc: remove MOD_{INC,DEC}_USE_COUNT
Date: Sun, 27 Apr 2003 12:18:25 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030427151825.GD15637@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

	Please pull from:

bk://kernel.bkbits.net/acme/net-2.5

	Now there are three outstanding changesets in this tree.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1125, 2003-04-27 12:04:25-03:00, acme@conectiva.com.br
  o llc: remove MOD_{INC,DEC}_USE_COUNT
  
  Now the core networking infrastructure will (finally) do that for the net
  protocol families, its just a matter of setting the ->owner field in the
  registered struct net_proto_family to THIS_MODULE.


 llc_if.c   |    9 ++-------
 llc_main.c |    6 +-----
 2 files changed, 3 insertions(+), 12 deletions(-)


diff -Nru a/net/llc/llc_if.c b/net/llc/llc_if.c
--- a/net/llc/llc_if.c	Sun Apr 27 12:14:09 2003
+++ b/net/llc/llc_if.c	Sun Apr 27 12:14:09 2003
@@ -43,16 +43,15 @@
 	/* verify this SAP is not already open; if so, return error */
 	struct llc_sap *sap;
 
-	MOD_INC_USE_COUNT;
 	sap = llc_sap_find(lsap);
 	if (sap) { /* SAP already exists */
 		sap = NULL;
-		goto err;
+		goto out;
 	}
 	/* sap requested does not yet exist */
 	sap = llc_sap_alloc();
 	if (!sap)
-		goto err;
+		goto out;
 	/* allocated a SAP; initialize it and clear out its memory pool */
 	sap->laddr.lsap = lsap;
 	sap->rcv_func	= func;
@@ -61,9 +60,6 @@
 	llc_sap_save(sap);
 out:
 	return sap;
-err:
-	MOD_DEC_USE_COUNT;
-	goto out;
 }
 
 /**
@@ -76,7 +72,6 @@
 void llc_sap_close(struct llc_sap *sap)
 {
 	llc_free_sap(sap);
-	MOD_DEC_USE_COUNT;
 }
 
 /**
diff -Nru a/net/llc/llc_main.c b/net/llc/llc_main.c
--- a/net/llc/llc_main.c	Sun Apr 27 12:14:09 2003
+++ b/net/llc/llc_main.c	Sun Apr 27 12:14:09 2003
@@ -224,9 +224,8 @@
 {
 	struct sock *sk = sk_alloc(family, priority, 1, NULL);
 
-	MOD_INC_USE_COUNT;
 	if (!sk)
-		goto decmod;
+		goto out;
 	if (llc_sk_init(sk))
 		goto outsk;
 	sock_init_data(NULL, sk);
@@ -240,8 +239,6 @@
 outsk:
 	sk_free(sk);
 	sk = NULL;
-decmod:
-	MOD_DEC_USE_COUNT;
 	goto out;
 }
 
@@ -279,7 +276,6 @@
 	}
 #endif
 	sock_put(sk);
-	MOD_DEC_USE_COUNT;
 }
 
 /**

===================================================================


This BitKeeper patch contains the following changesets:
1.1125
## Wrapped with gzip_uu ##


M'XL( ,'SJSX  ^U674_;,!1]KG_%E7C9-)KZ,PF=BA@M&A4,$-#GRCA.FY'$
M*'%;L67_?4ZBL5'81E$?R8<M7=OG'ON>$V4')J4N^AVI,HUVX-B4MM]1)M?*
M)DOI*9-Y-X4;N#3&#?3F)M.]PY->KFV7>@*YD0MIU1R6NBC['>*QAXB]O]/]
MSN71Y\GIITN$!@,8SF4^TU?:PF" K"F6,HW* VGGJ<D]6\B\S+1M<E8/4RN*
M,76W( '#PJ^(CWE0*1(1(CG1$:8\]#FJZ1^LTWZ,PC"G >&8<58Q%HH0C8!X
MA% !F/4P[]$ ".UCWJ>BBUD?8W@6%3Y0Z&)T"-O=P1 I,)"FJ@^%SLQ2PY?S
MT?3[^&RX.SH:_IA.KHZFP_/)V;6;YYXSLP([UZ!,H<%58V6*VR2?09+'A2QM
ML5!VX49629K"NSC)99K>OX?(N$720FR*9K5;Z+#N"F.-,BG$,DO21)>[D-@2
MOBY*"Q(R::TNP,10:FOK'/7*[KY9Y2X<)SJ-7-8ZZ* */4M*-UU'T)*H4TR;
M!-,&_=X=&UP?CZ^F;GN3TR,/G0#CF!!T\5L?J+OAA1"6&.T_7[#*4>BY@ZW?
M:2:3W%-M300CF#%!><4HIZ0BD8QIC"-!@PA'FFX$U\I+8$YP)3@.Q8OH)/$S
M9,A>&%8J(M'-C8I\PC!3A&T ]B<5%O* -.Y;GUF;<)L$-P$C& O:M!5WQ<>-
M%2E>-R+!_S5B\&;$+1JQ$<LY=(M5\SAC73S1S2O,.>(^$#02V+7CINUT9HX)
MF(7]Z.*BB8OUN,^!H5&P!T\%W/KN91+>Q/)H*?.H<$4_6"I/+1?64]_^!D8(
M"2GEC+%*[#'JMR+V-Q4Q@:YX$_'V1-Q^?/\AXK:$KY$QK8M:=[4DQVWW2+%.
A#4!=%]):L[_^A-1<J]MRD0TPE[X*!$,_ <\0_E9V"0  
 
