From: Nicolas Iooss <nicolas.iooss_linux@m4x.org>
Subject: qla3xxx: u32 constant overflow in fm93c56a_select()
Date: Sun, 15 Jan 2017 13:03:45 +0100
Message-ID: <67b57b66-2231-6605-4388-75507001a79e@m4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

In drivers/net/ethernet/qlogic/qla3xxx.c, fm93c56a_select() currently calls:

  ql_write_nvram_reg(qdev, spir,
    ((ISP_NVRAM_MASK << 16) | qdev->eeprom_cmd_data));

and ISP_NVRAM_MASK is defined as (0x000F << 16).

ql_write_nvram_reg() writes a 32-bit value but (ISP_NVRAM_MASK << 16)
expands to ((0x000F << 16) << 16) = 0xF << 32, which overflows the u32
type. This means the above call is equivalent to:

  ql_write_nvram_reg(qdev, spir, qdev->eeprom_cmd_data);

Is this something normal, in which case (ISP_NVRAM_MASK << 16) would be
removed, or a bug?

Thanks,
Nicolas
