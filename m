From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC 05/12] nfp: add BPF to NFP code translator
Date: Wed, 1 Jun 2016 13:09:17 -0700
Message-ID: <574F40ED.7060601@gmail.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-6-git-send-email-jakub.kicinski@netronome.com>
 <574F3F78.1010606@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, dinan.gunawardena@netronome.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35547 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbcFAUJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 16:09:33 -0400
Received: by mail-pf0-f195.google.com with SMTP id f144so5175968pfa.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 13:09:32 -0700 (PDT)
In-Reply-To: <574F3F78.1010606@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-01 01:03 PM, Daniel Borkmann wrote:
> On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
>> Add translator for JITing eBPF to operations which
>> can be executed on NFP's programmable engines.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> [...]
>> +int
>> +nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int
>> prog_start,
>> +        unsigned int tgt_out, unsigned int tgt_abort,
>> +        unsigned int prog_sz, struct nfp_bpf_result *res)
>> +{
>> +    struct nfp_prog *nfp_prog;
>> +    int ret;
>> +
>> +    /* TODO: maybe make this dependent on bpf_jit_enable? */
> 
> Probably makes sense to leave it independent from this.

Agreed we have an ethtool flag for the other offloads I think this
should just follow the same semantics and get offloaded if the flag
is set.

> 
> Maybe that would rather be an ethtool flag/setting?
> 

I would think using the same flag as we did for u32 and flower
should be fine.
