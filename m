From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC 05/12] nfp: add BPF to NFP code translator
Date: Thu, 2 Jun 2016 09:21:42 -0700
Message-ID: <57505D16.3030609@gmail.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-6-git-send-email-jakub.kicinski@netronome.com>
 <574F3F78.1010606@iogearbox.net>
 <20160601201546.GA22759@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org, ast@kernel.org,
	dinan.gunawardena@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:32810 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932149AbcFBQWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 12:22:00 -0400
Received: by mail-pa0-f66.google.com with SMTP id di3so3690519pab.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 09:21:59 -0700 (PDT)
In-Reply-To: <20160601201546.GA22759@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-01 01:15 PM, Alexei Starovoitov wrote:
> On Wed, Jun 01, 2016 at 10:03:04PM +0200, Daniel Borkmann wrote:
>> On 06/01/2016 06:50 PM, Jakub Kicinski wrote:
>>> Add translator for JITing eBPF to operations which
>>> can be executed on NFP's programmable engines.
>>>
>>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>>> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>>> Reviewed-by: Simon Horman <simon.horman@netronome.com>
>> [...]
>>> +int
>>> +nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
>>> +	    unsigned int tgt_out, unsigned int tgt_abort,
>>> +	    unsigned int prog_sz, struct nfp_bpf_result *res)
>>> +{
>>> +	struct nfp_prog *nfp_prog;
>>> +	int ret;
>>> +
>>> +	/* TODO: maybe make this dependent on bpf_jit_enable? */
>>
>> Probably makes sense to leave it independent from this.
>>
>> Maybe that would rather be an ethtool flag/setting?
> 
> Agree that it should be independent of bpf_jit_enable,
> since that's very different JIT. The whole point of hw offload
> is that bpf is translated into something hw understand natively.
> Gating it by sysctl or another flag doesn't make much sense to me.
> In this case the user will say 'do offload tc+cls_bpf into a nic'
> and nic should either do it or not. No need for ethtool flag either.
> One can argue that that bpf_jit_enable=2 was useful for debugging
> of JIT itself, but looks like it was only used by jit developers
> like us, but we would be fine with temp printk while debugging.
> At least there was never a case where jit had a bug and we would
> ask a person reporting a bug to send us back jit_enable=2 output.
> We cannot remove it now, but I wouldn't simply copy the behavior here.
> So I'm suggesting not to use bpf_jit_enable either 1 or 2 at all.
> 

In the default case (no flags to the tc command) the tc filter
tries to load itself in the hardware. The ethtool flag is there
to enable/disable this default behavior. The alternative to the
default load into hardware behavior is to specify it explicitly
via userspace using the 'do offload tc+cls_bpf' as you note. This
was the default behavior folks wanted at netdev conference so I
added it even though for many of my use cases users specify explicitly
if they want offload or not.

Thanks,
John
