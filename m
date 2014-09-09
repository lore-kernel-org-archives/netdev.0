From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: randconfig build error with next-20140909, in drivers/net/ethernet/broadcom/cnic.c
Date: Tue, 09 Sep 2014 15:56:02 -0700
Message-ID: <540F8582.50703@infradead.org>
References: <CA+r1ZhhZynUKSeZnya67z9sph4+tpjO4E7jLZKc0EG4azxFdYA@mail.gmail.com>	 <525DB349B3FB5444AE057A887CB2A8D88E0BFB@nice.asicdesigners.com>,<1410295676.7520.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com> <525DB349B3FB5444AE057A887CB2A8D88E3CEC@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>
To: Anish Bhatt <anish@chelsio.com>, Michael Chan <mchan@broadcom.com>,
	"eddie.wai@broadcom.com" <eddie.wai@broadcom.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <525DB349B3FB5444AE057A887CB2A8D88E3CEC@nice.asicdesigners.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/14 14:08, Anish Bhatt wrote:
> 
>> Adding depends on IPV6 || IPV6=n doesn't work for SCSI_BNX2X_FCOE, but
>> works for SCSI_BNX2_ISCSI?
> 
> It fixes the config issue for both, but with FCOE; make scripts will complain about recursive dependencies with the following :
> 
> scripts/kconfig/conf --silentoldconfig Kconfig
> net/Kconfig:5:error: recursive dependency detected!
> net/Kconfig:5:  symbol NET is selected by SCSI_NETLINK
> drivers/scsi/Kconfig:43:        symbol SCSI_NETLINK is selected by SCSI_FC_ATTRS
> drivers/scsi/Kconfig:258:       symbol SCSI_FC_ATTRS is selected by LIBFC
> drivers/scsi/Kconfig:586:       symbol LIBFC is selected by SCSI_BNX2X_FCOE
> drivers/scsi/bnx2fc/Kconfig:1:  symbol SCSI_BNX2X_FCOE depends on IPV6
> net/ipv6/Kconfig:6:     symbol IPV6 depends on NET

It would be really good if SCSI_NETLINK depended on NET instead of selected NET.
We shouldn't have kconfig symbols that use 'select' on entire subsystems.

-- 
~Randy
