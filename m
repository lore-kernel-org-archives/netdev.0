From: Li Zhong <zhong@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] packet: fix using smp_processor_id() in
 preemptible code
Date: Fri, 13 Dec 2013 09:50:45 +0800
Message-ID: <1386899445.3575.3.camel@ThinkPad-T5421>
References: <1386884395-12449-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:60746 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab3LMBuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 20:50:51 -0500
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zhong@linux.vnet.ibm.com>;
	Fri, 13 Dec 2013 07:20:49 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 2F225E0024
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 07:23:09 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBD1oeJk66060382
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 07:20:40 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBD1oljH019304
	for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 07:20:47 +0530
In-Reply-To: <1386884395-12449-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 22:39 +0100, Daniel Borkmann wrote:
> From: Li Zhong <zhong@linux.vnet.ibm.com>
> 
> This patches fixes the following warning by replacing smp_processor_id()
> with raw_smp_processor_id():
> 
> [   11.120893] BUG: using smp_processor_id() in preemptible [00000000] code: arping/3510
> [   11.120913] caller is .packet_sendmsg+0xc14/0xe68
> [   11.120920] CPU: 13 PID: 3510 Comm: arping Not tainted 3.13.0-rc3-next-20131211-dirty #1
> [   11.120926] Call Trace:
> [   11.120932] [c0000001f803f6f0] [c0000000000138dc] .show_stack+0x110/0x25c (unreliable)
> [   11.120942] [c0000001f803f7e0] [c00000000083dd24] .dump_stack+0xa0/0x37c
> [   11.120951] [c0000001f803f870] [c000000000493fd4] .debug_smp_processor_id+0xfc/0x12c
> [   11.120959] [c0000001f803f900] [c0000000007eba78] .packet_sendmsg+0xc14/0xe68
> [   11.120968] [c0000001f803fa80] [c000000000700968] .sock_sendmsg+0xa0/0xe0
> [   11.120975] [c0000001f803fbf0] [c0000000007014d8] .SyS_sendto+0x100/0x148
> [   11.120983] [c0000001f803fd60] [c0000000006fff10] .SyS_socketcall+0x1c4/0x2e8
> [   11.120990] [c0000001f803fe30] [c00000000000a1e4] syscall_exit+0x0/0x9c
> 
> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Just resending for Li with correct date.

Thank you
