From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Tue, 06 Jun 2017 18:56:29 +0200
Message-ID: <5936DEBD.2050401@iogearbox.net>
References: <1496279760-20996-1-git-send-email-chenbofeng.kernel@gmail.com> <1496279760-20996-2-git-send-email-chenbofeng.kernel@gmail.com> <20170601234235.iwu55crijtxuq5mp@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58158 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdFFQ4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 12:56:32 -0400
In-Reply-To: <20170601234235.iwu55crijtxuq5mp@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2017 01:42 AM, Alexei Starovoitov wrote:
> On Wed, May 31, 2017 at 06:16:00PM -0700, Chenbo Feng wrote:
>> From: Chenbo Feng <fengc@google.com>
>>
>> Currently loading a cgroup skb eBPF program require a CAP_SYS_ADMIN
>> capability while attaching the program to a cgroup only requires the
>> user have CAP_NET_ADMIN privilege. We can escape the capability
>> check when load the program just like socket filter program to make
>> the capability requirement consistent.
>>
>> Change since v1:
>> Change the code style in order to be compliant with checkpatch.pl
>> preference
>>
>> Signed-off-by: Chenbo Feng <fengc@google.com>
>
> as far as I can see they're indeed the same as socket filters, so
> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
> but I don't quite understand how it helps, since as you said
> attaching such unpriv fd to cgroup still requires root.
> Do you have more patches to follow?

Hmm, when we relax this from capable(CAP_SYS_ADMIN) to unprivileged,
then we must at least also zero out the not-yet-initialized memory
for the mac header for egress case in __cgroup_bpf_run_filter_skb().
