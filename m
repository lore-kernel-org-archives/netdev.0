From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] vlan: fix misunderstanding at struct packet_type initialization
Date: Tue, 29 Apr 2003 05:01:43 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429080142.GS25361@conectiva.com.br>
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

- Arnaldo

You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1148, 2003-04-29 04:48:17-03:00, acme@conectiva.com.br
  o vlan: fix misunderstanding at struct packet_type initialization
  
  packet_type->data != 0 means that the net family understand shared skbs and is
  fully multithreaded, so if vlan really is an "old one" it should set this to
  0, not to -1.


 vlan.c |    3 +--
 1 files changed, 1 insertion(+), 2 deletions(-)


diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	Tue Apr 29 04:57:16 2003
+++ b/net/8021q/vlan.c	Tue Apr 29 04:57:16 2003
@@ -66,9 +66,8 @@
 
 static struct packet_type vlan_packet_type = {
 	.type = __constant_htons(ETH_P_8021Q),
-	.dev =NULL,
 	.func = vlan_skb_recv, /* VLAN receive method */
-	.data = (void *)(-1),  /* Set here '(void *)1' when this code can SHARE SKBs */
+	.data = (void *)0,  /* Set here '(void *)1' when this code can SHARE SKBs */
 };
 
 /* End of global variables definitions. */

===================================================================


This BitKeeper patch contains the following changesets:
1.1148
## Wrapped with gzip_uu ##


M'XL( %PPKCX  ^U4WT_;,!!^KO^*&SRP,9J<$R=-(A7Q4V-BTE 1SY-Q7&*1
MQ"QVRYCRQ^_2:K"Q3M,F'I=8CNR[?/[N[CMOPY7373&2JM%L&\ZL\\5(V58K
M;Y8R4+8)KCLRS*PE0UC91H='YV&K_3@*$D:6"^E5!4O=N6+$@_AQQS_<Z6(T
M.WUW]>%PQMAT"L>5;&_TI?8PG3)ONZ6L2W<@?57;-O"=;%VC_>K,_M&UCQ C
M>A,^B3%)>YZBF/2*EYQ+P76)D<A2P0;Z!\]I_XP2HXAR3)(DSOLXXP+9"?" 
M<Y$!QB&*,,H!12&R@D_&&!>(L!$5WG(8(SN"EXW@F"FPL*QE6\#<?('&N$5;
M4E:];$O3WH#TX'RW4![NI+K5_M.08#"M\4;6YJOTQK:$0>,'^WB_E%["JRD@
M-)KX@:\(R%<:J(0PEXVI'^#I('"5[#1];J\=#&OC"'"^J,FK6=3>^*K3LM3E
M'C@+9KXB#+0U.)CA%]BR=0F4LRTPQ+BR"UHZ/9Q)=F\)#O>@M;1A8<P#=@YQ
M%HF<73SI@XW_\F$,);)]BIR4M[D>%&Z88<0_AP/E0#V6)2)E(/8\X7G2YSS7
M$YDK@6DN,.>;); 1;*VOB<@P[44:I]%*\\\]!^F_.$OF*MTT)!+='5A7UH'M
M;G['D6>DPQQ%+R9QE*Q[('G> 9C^L0.B_QWP<AVPULM'&'?WJT&*OOA%.O_0
M%2=I#IR=3#C-[U?S*%BE8PJOE]:4L/N&J$"X"\.M7.E.P\YW ]^!^TJW:];*
IEAH4Q79Y=C@[A<OS(P>[X=/UKRJM;MVBF<XQ4R5>I^P;*\\5\ED&    
 
