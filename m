From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 3/3] samples: bpf: add userspace example for
 modifying sk_bound_dev_if
Date: Mon, 28 Nov 2016 13:47:13 -0700
Message-ID: <24cf4de5-1536-c659-88eb-5ceb6e8f34bd@cumulusnetworks.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
 <1480348130-31354-4-git-send-email-dsa@cumulusnetworks.com>
 <20161128203752.GC7634@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36232 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755042AbcK1UrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:47:16 -0500
Received: by mail-pg0-f45.google.com with SMTP id f188so60363823pgc.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 12:47:16 -0800 (PST)
In-Reply-To: <20161128203752.GC7634@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/16 1:37 PM, Alexei Starovoitov wrote:
> On Mon, Nov 28, 2016 at 07:48:50AM -0800, David Ahern wrote:
>> Add a simple program to demonstrate the ability to attach a bpf program
>> to a cgroup that sets sk_bound_dev_if for AF_INET{6} sockets when they
>> are created.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ...
>> +static int prog_load(int idx)
>> +{
>> +	struct bpf_insn prog[] = {
>> +		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
>> +		BPF_MOV64_IMM(BPF_REG_3, idx),
>> +		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, bound_dev_if)),
>> +		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, bound_dev_if)),
>> +		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
>> +		BPF_EXIT_INSN(),
>> +	};
>> +
>> +	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
>> +			     "GPL", 0);
>> +}
> 
> the program looks trivial enough :)
> 
> Could you integrate it into iproute2 as well ?

yes, that is the plan. iproute2 can be used for all things vrf. As infra goes into the kernel, support is added to iproute2

> Then the whole vrf management will be easier.
> The user wouldn't even need to be aware that iproute2 sets up
> this program. It will know ifindex and can delete
> the prog when vrf configs change and so on.
> 
> Also please convert this sample into automated test like samples/bpf/*.sh
> we're going to move all of them to tools/testing/selftests/ eventually.
> 

ok
