From: Michael Chan <mchan@broadcom.com>
Subject: RE: randconfig build error with next-20140909, in
 drivers/net/ethernet/broadcom/cnic.c
Date: Tue, 9 Sep 2014 13:47:56 -0700
Message-ID: <1410295676.7520.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CA+r1ZhhZynUKSeZnya67z9sph4+tpjO4E7jLZKc0EG4azxFdYA@mail.gmail.com>
	 <525DB349B3FB5444AE057A887CB2A8D88E0BFB@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Jim Davis <jim.epost@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Anish Bhatt <anish@chelsio.com>, <eddie.wai@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <525DB349B3FB5444AE057A887CB2A8D88E0BFB@nice.asicdesigners.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-09 at 20:24 +0000, Anish Bhatt wrote: 
> This is caused by c99d667e8527  ("cnic : Cleanup CONFIG_IPV6 & VLAN check")
> 
> So I'm not really sure what the fix for this is. CNIC will properly only support 
> [m] or [n] when IPV6 is compiled as a module, but if you set SCSI_BNX2X_FCOE or 
> SCSI_BNX2_ISCSI to be in built, there is a 'select CNIC' that forces CNIC to be 
> inbuilt, even though this is not supported by Kconfig. I was under the 
> assumption that select will not forcibly change m to inbuilt (or perhaps I'm 
> missing some syntax suboption ?)
> 
> This is still fixable in SCSI_BNX2_ISCSI using the same logic used in the above 
> mentioned commit, but not so in SCSI_BNX2X_FCOE where it causes a recursive 
> dependency error (thought it is fixing the issue nevertheless), and none of the 
>  other solutions I tried seemed to work either. 

Adding depends on IPV6 || IPV6=n doesn't work for SCSI_BNX2X_FCOE, but
works for SCSI_BNX2_ISCSI?
