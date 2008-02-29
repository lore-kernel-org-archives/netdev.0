From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [PATCH][ROSE][NETROM] display neigh instead of address
Date: Fri, 29 Feb 2008 23:45:03 +0100
Message-ID: <47C88AEF.4050504@free.fr>
References: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn>	<20080211124251.GB3597@ff.dom.local> <20080211.212659.228544422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050109020204070801010608"
Cc: netdev@vger.kernel.org, linux-hams <linux-hams@vger.kernel.org>
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080211.212659.228544422.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050109020204070801010608
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I submit the following patch against kernel 2.6.24.3 to replace
labels "addr" in /proc/net/rose_neigh and /proc/net/nr_neigh
by labels "neigh" for the display of neighbour numbers in the
first columns.

This makes the reading of proc more consistent with the labels of
/proc/net/rose_nodes and /proc/net/nr_nodes.
Finding the callsign of a given node neighbour number becomes easier.

Here are some examples of the new display :


/proc/net/rose_neigh
neigh callsign  dev  count use mode restart  t0  tf digipeaters
00012 F6BVP-7   ax0      2   0  DTE      no   0   0
00011 F6BVP-9   ax0      3   0  DTE      no   0   0

/proc/net/rose_nodes
address    mask n neigh neigh neigh
2080175502 0010 1 00001
2080175520 0010 2 00011 00012



/proc/net/nr_neigh NetRom neigh
neigh callsign  dev  qual lock count failed digipeaters
00013 K4GBB-14  ax0   255    0     1      0
00012 KD4YAL-5  ax0   255    0     2      0

/proc/net/nr_nodes NetRom nodes
callsign  mnemonic w n qual obs neigh qual obs neigh qual obs neigh
VK2AFY-0  AFYNOD   1 1  194   6 00005
F5KCK-13  LNXKCK   1 1  254   4 00003
KD4YAL-4  FBBYAL   1 2  254   6 00012  198   5 00005


73 de Bernard, f6bvp

----------------

--------------050109020204070801010608
Content-Type: text/x-patch;
 name="neigh_show_2.6.24.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="neigh_show_2.6.24.patch"

--- a/net/netrom/nr_route.c	2008-01-24 23:58:37.000000000 +0100
+++ b/net/netrom/nr_route.c	2008-02-29 20:29:48.000000000 +0100
@@ -982,7 +982,7 @@ static int nr_neigh_show(struct seq_file
 	int i;
 
 	if (v == SEQ_START_TOKEN)
-		seq_puts(seq, "addr  callsign  dev  qual lock count failed digipeaters\n");
+		seq_puts(seq, "neigh callsign  dev  qual lock count failed digipeaters\n");
 	else {
 		struct nr_neigh *nr_neigh = v;
 
--- a/net/rose/rose_route.c	2008-01-24 23:58:37.000000000 +0100
+++ b/net/rose/rose_route.c	2008-02-29 20:31:35.000000000 +0100
@@ -1178,7 +1178,7 @@ static int rose_neigh_show(struct seq_fi
 
 	if (v == SEQ_START_TOKEN)
 		seq_puts(seq,
-			 "addr  callsign  dev  count use mode restart  t0  tf digipeaters\n");
+			 "neigh callsign  dev  count use mode restart  t0  tf digipeaters\n");
 	else {
 		struct rose_neigh *rose_neigh = v;
 

--------------050109020204070801010608--
