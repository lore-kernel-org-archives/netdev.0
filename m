From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Mon, 23 Jul 2012 16:45:19 +0300
Message-ID: <500D556F.4000409@mellanox.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <500BD558.2060803@mellanox.com> <20120722.171553.2139258607165498367.davem@davemloft.net> <500D4F31.9020408@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jackm@dev.mellanox.co.il>, <yevgenyp@mellanox.co.il>,
	<cascardo@linux.vnet.ibm.com>, <brking@linux.vnet.ibm.com>,
	<shlomop@mellanox.com>
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu2sys200bog102.obsmtp.com ([207.126.150.230]:49393 "HELO
	eu2sys200bog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752046Ab2GWOBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 10:01:49 -0400
In-Reply-To: <500D4F31.9020408@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/23/2012 4:18 PM, Kleber Sacilotto de Souza wrote:
> Exactly. The callbacks implemented are from standard PCI error recovery
> (Documentation/PCI/pci-error-recovery.txt) and the changes doesn't
> assume any platform in specific. The code was tested only on powerpc
> systems [...]

So how did you test that? using the kernel provided error injection 
support and user space tool (which?) or in another way? we've trying 
quickly here to inject errors using /sbin/ear-inject from 
ras-utils-6.1-1.el6.x86_64 on a kernel built with

CONFIG_PCIEAER=y
CONFIG_PCIEAER_INJECT=m

and it failed to inject errors, SB details.

Or.
> since I don't have any mlx4 card on other platforms, however,
> these changes shouldn't make the error recover any worse than the
> current state.

> # lspci | grep 08.00.1
> 08:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit Network 
> Connection (rev 02)

> # cat /tmp/intel.aer
> AER
> BUS 8 DEV 0 FN 1
> COR_STATUS BAD_TLP
> HEADER_LOG 0 1 2 3

> # /sbin/aer-inject < /tmp/intel.aer
> Error: Failed to write, Invalid argument



> # strace -F -f /sbin/aer-inject < /tmp/intel.aer
> [...]

> open("/dev/aer_inject", O_WRONLY)       = 3
> write(3, "\10\0\1\0\0\0\0\0@\0\0\0\0\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0", 
> 28) = -1 EINVAL (Invalid argument)
> write(2, "Error: ", 7Error: )                  = 7
> write(2, "Failed to write", 15Failed to write)         = 15
> write(2, ", Invalid argument\n", 19, Invalid argument
> )    = 19
> exit_group(-1)                          = ?
