From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] af_pppox: return -EPROTONOSUPPORT if try_module_get fails at pppox_create
Date: Tue, 29 Apr 2003 06:02:15 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429090215.GY25361@conectiva.com.br>
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

	That changeset was properly removed with bk undo, thanks.

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1148, 2003-04-29 05:53:59-03:00, acme@conectiva.com.br
  o af_pppox: return -EPROTONOSUPPORT if try_module_get fails at pppox_create
  
  Thanks to Rusty for spotting this one, if the protocol module is not there
  anymore (or is going away at that time) it is not supported, not busy.


 pppox.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)


diff -Nru a/drivers/net/pppox.c b/drivers/net/pppox.c
--- a/drivers/net/pppox.c	Tue Apr 29 05:57:32 2003
+++ b/drivers/net/pppox.c	Tue Apr 29 05:57:32 2003
@@ -149,11 +149,8 @@
 		goto out;
 
 	rc = -EPROTONOSUPPORT;
-	if (!pppox_protos[protocol])
-		goto out;
-
-	rc = -EBUSY;
-	if (!try_module_get(pppox_protos[protocol]->owner))
+	if (!pppox_protos[protocol] ||
+	    !try_module_get(pppox_protos[protocol]->owner))
 		goto out;
 
 	rc = pppox_protos[protocol]->create(sock);

===================================================================


This BitKeeper patch contains the following changesets:
1.1148
## Wrapped with gzip_uu ##


M'XL( 'P^KCX  ^U474_;,!1]KG_%1;P4C:3^;--(18P/;1/36A5XFJ;*==TF
MHHDKVX55RH^?DPH8J(#&]CC'BI3<Z^-SK\_Q/EP[;=.65(5&^_#9.)^VE"FU
M\OFMC)4IXJD-@;$Q(=#)3*$[)Q>=4ON(Q@*%R$AZE<&MMBYMD9@]_/&;E4Y;
MX_-/UU\_CA$:#. TD^5"7VH/@P'RQM[*Y<P=2Y\M31E[*TM7:-_L63VD5A1C
M&AY!>@R+;D6ZF/<J16:$2$[T#%.>=#FJZ1\_I_T4A6%.^U@(P?H52PC'Z Q(
M3 A/ +,.YAW:!RQ2P5+1CS!+,8:=J/"!0(31"?S;"DZ1 @-R/EFM5N9G"E;[
MM2TA.A^-AU?#;\/+Z]%H.+Z"? [>;B:%F:V7>K((S9S+?.E >FA63I35TNN 
M%N95(''C E,8KYW?P-Q8<"OC?5XNP&>Y@U#<88.9:5A9XXTR2]B"0PB7QM<A
M6^/)<E,8JZ$=0$)H86H0>2<W]=X^JU]YH0\@]_<KW3HPLE[/#IO/Z=IM8G0!
M=?<I&CWJ 45_.!#"$J.C-XY@9O-:EK58.TUO8O7;8? @B4HPRG&E-66*3_LT
MD43/&=]]\"_A;865",9IQ5B7)XW8=R2_+?MW,W[! *\R#E:@O8H%P-[6"O2Y
M$3A]W0@4(O'?"']AA$8M0XCL73.#L$>[A/,.?YP104&@+T1T@:)6**R]MVU+
M4YS[?E_C#Z@JU((P]IZVL[T[/3HR=Z6V!P>/=[_*M+IQZV+ :2(TZ27H%\8=
&:E]6!@  
 
