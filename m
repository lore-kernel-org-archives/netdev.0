From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - panic and a fix
Date: Mon, 13 Sep 2004 01:15:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912231516.GA27299@electric-eye.fr.zoreil.com>
References: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au> <200409111147.24064.sriharivijayaraghavan@yahoo.com.au> <20040911121952.GA3134@electric-eye.fr.zoreil.com> <200409121832.57233.sriharivijayaraghavan@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Content-Disposition: inline
In-Reply-To: <200409121832.57233.sriharivijayaraghavan@yahoo.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au> :
[...]
> Kernel BUG at r8169:1702
> invalid operand: 0000 [1]
> CPU 0
> Modules linked in: r8169 af_packet ide_cd cdrom via_rhine mii crc32 floppy 
> radeon reiserfs dm_mod uhci_hcd ehci_hcd usbcorx
> Pid: 0, comm: swapper Not tainted 2.6.9-rc1-bk17-r8169-b
> RIP: 0010:[<ffffffffa00e9f24>] 
> <ffffffffa00e9f24>{:r8169:rtl8169_rx_interrupt+436}

0000000000001d70 <rtl8169_rx_interrupt>:
[...]
    1f0d:       b9 02 00 00 00          mov    $0x2,%ecx
    1f12:       ba 00 06 00 00          mov    $0x600,%edx
    1f17:       ff 54 24 08             callq  *0x8(%rsp)

-> pci_action(...)

    1f1b:       41 81 fc fc 05 00 00    cmp    $0x5fc,%r12d
    1f22:       7e 0c                   jle    1f30 <rtl8169_rx_interrupt+0x1c0>
    1f24:       0f 0b                   ud2a

-> BUG_ON(pkt_size > (RX_BUF_SIZE - 4));

> RSP: 0018:ffffffff8039bc38  EFLAGS: 00010206
> RAX: 0000000000000000 RBX: 0000000000000c00 RCX: 0000000000000000
> RDX: 0000000000000600 RSI: 000000003ef4d012 RDI: 00000100023c3070
> RBP: 0000010038ee4360 R08: 0000000000000000 R09: 0000000000000000
> R10: 000001003f614e28 R11: 000001003bacdda0 R12: 0000000000000bfc
                                                                ^^^
-> 3068.
   RX_BUF_SIZE*2 - 4 ?

/me scratches head

Can you #define RX_BUF_SIZE 3072 and run with r8169-dbg-b applied ?

--
Ueimor
