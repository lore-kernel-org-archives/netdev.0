From: Michael Chan <mchan@broadcom.com>
Subject: RE: randconfig build error with next-20140909, in
 drivers/net/ethernet/broadcom/cnic.c
Date: Tue, 9 Sep 2014 16:20:35 -0700
Message-ID: <1410304835.7520.27.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CA+r1ZhhZynUKSeZnya67z9sph4+tpjO4E7jLZKc0EG4azxFdYA@mail.gmail.com>
	 <525DB349B3FB5444AE057A887CB2A8D88E0BFB@nice.asicdesigners.com>
	 ,<1410295676.7520.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <525DB349B3FB5444AE057A887CB2A8D88E3CEC@nice.asicdesigners.com>
	 ,<540F8582.50703@infradead.org>
	 <525DB349B3FB5444AE057A887CB2A8D88E3E42@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@infradead.org>,
	"eddie.wai@broadcom.com" <eddie.wai@broadcom.com>,
	Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>
To: Anish Bhatt <anish@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525DB349B3FB5444AE057A887CB2A8D88E3E42@nice.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-09 at 23:16 +0000, Anish Bhatt wrote: 
> > It would be really good if SCSI_NETLINK depended on NET instead of selected NET.
> > We shouldn't have kconfig symbols that use 'select' on entire subsystems.
> 
> As a test, I was able to fix this by this approach : change SCSI_NETLINK to depend  
> on NET instead of selecting NET, and replacing 'select NETDEVICES ETHERNET 
> NET_VENDOR_BROADCOM CNIC' to 'depends on CNIC' in bnx2i & bnx2fc. (as CNIC 
> already has a dependency on those). This removes the need to check for IPV6 in 
> bnx2i/fc Kconfigs as well.
> 
> The side effect is that you won't see BNX2 drivers unless CNIC is selected, similar
> for SCSI_NETLINK as well, not sure if there are any other implications.

Right.  I think it is more user-friendly for BNX2I and BNX2FC to select
CNIC.  CNIC is not useful by itself and it makes more sense to select it
automatically when BNX2I/BNX2FC are enabled.
