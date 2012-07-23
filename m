From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Mon, 23 Jul 2012 17:53:34 -0300
Message-ID: <500DB9CE.5080100@linux.vnet.ibm.com>
References: <1342814143-5744-1-git-send-email-klebers@linux.vnet.ibm.com> <500BD558.2060803@mellanox.com> <20120722.171553.2139258607165498367.davem@davemloft.net> <500D4F31.9020408@linux.vnet.ibm.com> <500D556F.4000409@mellanox.com> <500D93F5.4090305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.co.il,
	cascardo@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	shlomop@mellanox.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:44271 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832Ab2GWUxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 16:53:45 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <klebers@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 17:53:43 -0300
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id D7E4C3520044
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 16:53:38 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6NKoBnm3178590
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 17:50:11 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6NIrZur012190
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 15:53:35 -0300
In-Reply-To: <500D93F5.4090305@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/23/2012 03:12 PM, Kleber Sacilotto de Souza wrote:

> On 07/23/2012 10:45 AM, Or Gerlitz wrote:
> 
>> On 7/23/2012 4:18 PM, Kleber Sacilotto de Souza wrote:
>>> Exactly. The callbacks implemented are from standard PCI error recovery
>>> (Documentation/PCI/pci-error-recovery.txt) and the changes doesn't
>>> assume any platform in specific. The code was tested only on powerpc
>>> systems [...]
>>
>> So how did you test that? using the kernel provided error injection
>> support and user space tool (which?) or in another way? we've trying
>> quickly here to inject errors using /sbin/ear-inject from
>> ras-utils-6.1-1.el6.x86_64 on a kernel built with
>>
>> CONFIG_PCIEAER=y
>> CONFIG_PCIEAER_INJECT=m
> 
> 
> For powerpc we have an IBM internal user space tool that injects the
> error on the bus with the aid of the system firmware. The kernel used
> was built with the option:
> 
> CONFIG_EEH=y
> 
> and without the AER options. I will run some more tests with the AER
> options activated.


I tested the powerpc error injection with

CONFIG_EEH=y
CONFIG_PCIEAER=y
CONFIG_PCIEAER_INJECT=m

and with the aer_inject module loaded and it didn't affect the EEH
recovery, the adapter recovered as expected.

> 
>>
>> and it failed to inject errors, SB details.
>>
>> Or.
>>> since I don't have any mlx4 card on other platforms, however,
>>> these changes shouldn't make the error recover any worse than the
>>> current state.
>>
>>> # lspci | grep 08.00.1
>>> 08:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit Network
>>> Connection (rev 02)
>>
>>> # cat /tmp/intel.aer
>>> AER
>>> BUS 8 DEV 0 FN 1
>>> COR_STATUS BAD_TLP
>>> HEADER_LOG 0 1 2 3
>>
>>> # /sbin/aer-inject < /tmp/intel.aer
>>> Error: Failed to write, Invalid argument
>>
>>
>>
>>> # strace -F -f /sbin/aer-inject < /tmp/intel.aer
>>> [...]
>>
>>> open("/dev/aer_inject", O_WRONLY)       = 3
>>> write(3, "\10\0\1\0\0\0\0\0@\0\0\0\0\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0",
>>> 28) = -1 EINVAL (Invalid argument)
>>> write(2, "Error: ", 7Error: )                  = 7
>>> write(2, "Failed to write", 15Failed to write)         = 15
>>> write(2, ", Invalid argument\n", 19, Invalid argument
>>> )    = 19
>>> exit_group(-1)                          = ?
>>
>>
>>
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 



-- 
Kleber Sacilotto de Souza
IBM Linux Technology Center
