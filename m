From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next] netif_receive_skb performance
Date: Wed, 29 Apr 2015 15:20:13 -0700
Message-ID: <5541591D.3070505@plumgrid.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com> <5540A665.7030406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34258 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbD2WUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:20:16 -0400
Received: by pdbqa5 with SMTP id qa5so40726865pdb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:20:16 -0700 (PDT)
In-Reply-To: <5540A665.7030406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/29/15 2:37 AM, Daniel Borkmann wrote:
>
> Is the below the case where the conntracker has always a miss and thus
> each time needs to create new entries, iow pktgen DoS with random IPs?

not really. As far as I understand it's not doing much, just being
invoked as part of default code path. Not sure. This was a default
number on my setup with all modules loaded. I have empty
iptables/nat/ct rules. I mentioned it, since that is what most linux
users will see by default from their distro.

>> Few other numbers for comparison with dmac == eth0 mac:
>> no qdisc, with conntrack and empty iptables - 2.2 Mpps
>>     7.65%  kpktgend_0   [nf_conntrack]    [k] nf_conntrack_in
>>     7.62%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
>>     5.44%  kpktgend_0   [kernel.vmlinux]  [k] __call_rcu.constprop.63
>>     3.71%  kpktgend_0   [kernel.vmlinux]  [k] nf_iterate
>>     3.59%  kpktgend_0   [ip_tables]       [k] ipt_do_table
>>
>> no qdisc, unload conntrack, keep empty iptables - 5.4 Mpps
>>    18.17%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
>>     8.31%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>>     7.97%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>>     7.53%  kpktgend_0   [ip_tables]       [k] ipt_do_table
>>
>> no qdisc, unload conntrack, unload iptables - 6.5 Mpps
>>    21.97%  kpktgend_0   [kernel.vmlinux]  [k] fib_table_lookup
>>     9.64%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>>     8.44%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>>     7.19%  kpktgend_0   [kernel.vmlinux]  [k] __skb_clone
>>     6.89%  kpktgend_0   [kernel.vmlinux]  [k] fib_validate_source
