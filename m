From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net-next tree
Date: Mon, 20 Mar 2017 17:07:13 +1100
Message-ID: <20170320170713.71010326@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tomer Tayar <Tomer.Tayar@cavium.com>,
        Ram Amrani <Ram.Amrani@cavium.com>,
        Manish Rangankar <Manish.Rangankar@cavium.com>,
        Chad Dupuis <Chad.Dupuis@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
allyesconfig) produced thie warnings:

In file included from include/linux/byteorder/big_endian.h:4:0,
                 from arch/powerpc/include/uapi/asm/byteorder.h:13,
                 from include/linux/qed/common_hsi.h:36,
                 from drivers/scsi/qedf/drv_scsi_fw_funcs.h:10,
                 from drivers/scsi/qedf/drv_fcoe_fw_funcs.h:10,
                 from drivers/scsi/qedf/drv_fcoe_fw_funcs.c:8:
drivers/scsi/qedf/drv_fcoe_fw_funcs.c: In function 'init_initiator_rw_fcoe_task':
include/uapi/linux/byteorder/big_endian.h:32:26: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                          ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/scsi/qedf/drv_fcoe_fw_funcs.c:62:31: note: in expansion of macro 'cpu_to_le32'
  t_st_ctx->read_write.rx_id = cpu_to_le32(FCOE_RX_ID);
                               ^
drivers/scsi/qedf/drv_fcoe_fw_funcs.c: In function 'init_initiator_midpath_unsolicited_fcoe_task':
include/uapi/linux/byteorder/big_endian.h:32:26: warning: large integer implicitly truncated to unsigned type [-Woverflow]
 #define __cpu_to_le32(x) ((__force __le32)__swab32((x)))
                          ^
include/linux/byteorder/generic.h:87:21: note: in expansion of macro '__cpu_to_le32'
 #define cpu_to_le32 __cpu_to_le32
                     ^
drivers/scsi/qedf/drv_fcoe_fw_funcs.c:154:31: note: in expansion of macro 'cpu_to_le32'
  t_st_ctx->read_write.rx_id = cpu_to_le32(FCOE_RX_ID);
                               ^

Introduced by commit

  be086e7c53f1 ("qed*: Utilize Firmware 8.15.3.0")

-- 
Cheers,
Stephen Rothwell
