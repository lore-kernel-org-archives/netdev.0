From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: XDP question - how much can BPF change in xdp_buff?
Date: Mon, 31 Oct 2016 12:22:33 -0700
Message-ID: <581799F9.6060704@gmail.com>
References: <BY2PR07MB23090DE460B0AE6AA23CD7368DAE0@BY2PR07MB2309.namprd07.prod.outlook.com>
 <20161031.145734.1243544464767231445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33108 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945757AbcJaTWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:22:43 -0400
Received: by mail-pf0-f176.google.com with SMTP id d2so6224163pfd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 12:22:43 -0700 (PDT)
In-Reply-To: <20161031.145734.1243544464767231445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-31 11:57 AM, David Miller wrote:
> From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
> Date: Mon, 31 Oct 2016 18:31:30 +0000
> 
>> So I've [finally] started looking into implementing XDP
>> for qede, and there's one thing I feel like I'm missing in
>> regard to XDP_TX - what's the guarantee/requirement
>> that the bpf program isn't going to transmute some fields
>> of the rx packet in a way that would prevent the forwarding?
>>
>> E.g., can a BPF change the TCP payload of an incoming packet
>> without correcting its TCP checksum, and then expect the
>> driver to transmit it [via XDP_TX]? If not, how is this enforced [if at all]?
>>
>> [Looked at samples/bpf/xdp2_kern.c which manipulates the
>> UDP header; so I'm not certain what prevents it from doing
>> the same when checksum modifications would be required]
> 
> My understanding is that the eBPF program would be responsible
> for updating the checksum if it mangles the packet in such a
> way that such a fixup would be required.
> 

For XDP we will probably need to add support for at minimum the
following helpers,

	bpf_l3_csum_replace
	bpf_l4_csum_replace

Thanks,
John
