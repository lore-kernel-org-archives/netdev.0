From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 0/3] bpf: share helpers between tracing and
 networking
Date: Tue, 16 Jun 2015 11:19:40 +0200
Message-ID: <557FEA2C.5080408@iogearbox.net>
References: <1434163154-5218-1-git-send-email-ast@plumgrid.com> <20150615.160130.583783771772303463.davem@davemloft.net> <557F97F3.6060400@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: luto@amacapital.net, mingo@kernel.org, rostedt@goodmis.org,
	wangnan0@huawei.com, lizefan@huawei.com,
	daniel.wagner@bmw-carit.de, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58137 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932872AbbFPJTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 05:19:54 -0400
In-Reply-To: <557F97F3.6060400@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2015 05:28 AM, Alexei Starovoitov wrote:
> On 6/15/15 4:01 PM, David Miller wrote:
>>
>> Although I agree with the sentiment that this thing can cause
>> surprising results and can be asking for trouble.
>>
>> If someone wants to filter traffic "by UID" they might make
>> a simple ingress TC ebpf program using these new interfaces
>> and expect it to work.
>>
>> But the UID their program will see will be the UID of whatever
>> randomly happened to be executing when the packet was received
>> and processed.
>
> yes, you're right. Such tc filters will be incorrect.
> Will send a partial revert disallowing them in tc.

Sorry for late reply [on vacation]; if you really want to, you
could go via skb->sk->sk_socket->file and then retrieve credentials
from there for egress side (you can have a look at xt_owner). You'd
need a different *_proto helper for tc in that case, which would
then map to BPF_FUNC_get_current_uid_gid, etc. But that doesn't work
for ingress however, even if you would have early demux, so you
would need to let the eBPF helper function return an error code in
that case.
