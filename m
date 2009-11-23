From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: linux-next: manual merge of the net tree with the net-current
 tree
Date: Mon, 23 Nov 2009 12:09:10 -0600
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFE956C25@MNEXMB2.qlogic.org>
References: <20091123120043.24cf5c12.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091123120043.24cf5c12.sfr@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen

 This merge looks ok and I have tested it. 

Thanks
Amit Salecha

-----Original Message-----
From: Stephen Rothwell [mailto:sfr@canb.auug.org.au] 
Sent: Sunday, November 22, 2009 5:01 PM
To: David Miller; netdev@vger.kernel.org
Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; Amit Salecha
Subject: linux-next: manual merge of the net tree with the net-current tree

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/netxen/netxen_nic_init.c between commit
5d521fd36de4e61ab16a358df54c5babe153396c ("netxen: fix memory
initialization") from the net-current tree and commit
0be367bd5d10634c0836f57a684432fee935d929 ("netxen: reset sequence
changes") from the net tree.

Just context changes. I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/netxen/netxen_nic_init.c
index 8a09043,6ee27a6..0000000
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@@ -544,9 -528,8 +528,10 @@@ int netxen_pinit_from_rom(struct netxen
  				continue;
  			if (off == (ROMUSB_GLB + 0x1c)) /* MS clock */
  				continue;
 +			if ((off & 0x0ff00000) == NETXEN_CRB_DDR_NET)
 +				continue;
- 			if (off == (NETXEN_CRB_PEG_NET_1 + 0x18))
+ 			if (off == (NETXEN_CRB_PEG_NET_1 + 0x18) &&
+ 				!NX_IS_REVISION_P3P(adapter->ahw.revision_id))
  				buf[i].data = 0x1020;
  			/* skip the function enable register */
  			if (off == NETXEN_PCIE_REG(PCIE_SETUP_FUNCTION))
