From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Thu, 18 Feb 2016 12:28:55 +1100
Message-ID: <20160218122855.55e3f09d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

In file included from drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:56:0,
                 from drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:30:
drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c: In function 'bnx2x_dcbx_get_ap_feature':
drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: error: 'DCBX_APP_SF_DEFAULT' undeclared (first use in this function)
           DCBX_APP_SF_DEFAULT) &&  
           ^
drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h:120:45: note: in definition of macro 'GET_FLAGS'
 #define GET_FLAGS(flags, bits)  ((flags) & (bits))
                                             ^
drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: note: each undeclared identifier is reported only once for each function it appears in
           DCBX_APP_SF_DEFAULT) &&  
           ^
drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h:120:45: note: in definition of macro 'GET_FLAGS'
 #define GET_FLAGS(flags, bits)  ((flags) & (bits))
                                             ^

Caused by commit

  e5d3a51cefbb ("This adds support for default application priority.")

This build is big endian.

I have used the net-next tree from next-20160217 for today.

-- 
Cheers,
Stephen Rothwell
