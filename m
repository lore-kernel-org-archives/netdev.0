From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH v2 net-next] packet: fix using smp_processor_id() in
 preemptible code
Date: Thu, 12 Dec 2013 08:19:51 +0100
Message-ID: <20131212081951.23e3f9ea@redhat.com>
References: <1386828604.2584.13.camel@ThinkPad-T5421>
	<52A83699.9010504@redhat.com>
	<1386888664.2586.3.camel@ThinkPad-T5421>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	NetDev <netdev@vger.kernel.org>, brouer@redhat.com,
	davem@davemloft.net
To: Li Zhong <zhong@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab3LLHT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 02:19:59 -0500
In-Reply-To: <1386888664.2586.3.camel@ThinkPad-T5421>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Dec 2013 06:51:04 +0800
Li Zhong <zhong@linux.vnet.ibm.com> wrote:

> This patches tries to fix the following warning on next-1211 by
> replacing smp_processor_id() with raw_smp_processor_id(). 
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
> ---
> v2: as Daniel suggested, removed the part about setting queue_mapping 

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
