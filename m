From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 5/5] s390/bpf: recache skb->data/hlen for
 skb_vlan_push/pop
Date: Tue, 28 Jul 2015 10:19:28 -0700
Message-ID: <55B7B9A0.5060606@plumgrid.com>
References: <1438092600-16221-1-git-send-email-holzheu@linux.vnet.ibm.com>
 <1438092600-16221-6-git-send-email-holzheu@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33346 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbbG1RTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 13:19:31 -0400
Received: by pdbnt7 with SMTP id nt7so73854403pdb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 10:19:31 -0700 (PDT)
In-Reply-To: <1438092600-16221-6-git-send-email-holzheu@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/15 7:10 AM, Michael Holzheu wrote:
> Allow eBPF programs attached to TC qdiscs call skb_vlan_push/pop
> via helper functions. These functions may change skb->data/hlen.
> This data is cached by s390 JIT to improve performance of ld_abs/ld_ind
> instructions. Therefore after a change we have to reload the data.
>
> In case of usage of skb_vlan_push/pop, in the prologue we store
> the SKB pointer on the stack and restore it after BPF_JMP_CALL
> to skb_vlan_push/pop.
>
> Signed-off-by: Michael Holzheu<holzheu@linux.vnet.ibm.com>

Thanks!
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
