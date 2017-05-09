From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: mlx5 endpoint driver problem
Date: Tue, 9 May 2017 17:25:48 +0100
Message-ID: <f0b8881d-9aa3-8816-7ea6-daccc0e91262@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:35456 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbdEIQ0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 12:26:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am making tests with a Mellanox MLX5 Endpoint, and I am getting kernel hangs
when trying to enable the hca:

mlx5_core 0000:01:00.0: enabling device (0000 -> 0002)
mlx5_core 0000:01:00.0: Warning: couldn't set 64-bit PCI DMA mask
mlx5_core 0000:01:00.0: Warning: couldn't set 64-bit consistent PCI DMA mask
mlx5_core 0000:01:00.0: firmware version: 16.19.21102
INFO: task swapper:1 blocked for more than 10 seconds.
      Not tainted 4.11.0-BETAMSIX1 #51
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
swapper         D    0     1      0 0x00000000

Stack Trace:
  __switch_to+0x0/0x94
  __schedule+0x1da/0x8b0
  schedule+0x26/0x6c
  schedule_timeout+0x2da/0x380
  wait_for_completion+0x92/0x104
  mlx5_cmd_exec+0x70e/0xd60
  mlx5_load_one+0x1b4/0xad8
  init_one+0x404/0x600
  pci_device_probe+0x122/0x1f0
  really_probe+0x1ac/0x348
  __driver_attach+0xa8/0xd0
  bus_for_each_dev+0x3c/0x74
  bus_add_driver+0xc2/0x184
  driver_register+0x50/0xec
  init+0x40/0x60

(...)

Stack Trace:
  __switch_to+0x0/0x94
  __schedule+0x1da/0x8b0
  schedule+0x26/0x6c
  schedule_timeout+0x2da/0x380
  wait_for_completion+0x92/0x104
  mlx5_cmd_exec+0x70e/0xd60
  mlx5_load_one+0x1b4/0xad8
  init_one+0x404/0x600
  pci_device_probe+0x122/0x1f0
  really_probe+0x1ac/0x348
  __driver_attach+0xa8/0xd0
  bus_for_each_dev+0x3c/0x74
  bus_add_driver+0xc2/0x184
  driver_register+0x50/0xec
  init+0x40/0x60
mlx5_core 0000:01:00.0: wait_func:882:(pid 1): ENABLE_HCA(0x104) timeout. Will
cause a leak of a command resource
mlx5_core 0000:01:00.0: enable hca failed
mlx5_core 0000:01:00.0: mlx5_load_one failed with error code -110
mlx5_core: probe of 0000:01:00.0 failed with error -110

Could you give me a clue of what might be happennig?

Thanks,
Joao
