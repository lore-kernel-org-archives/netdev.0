From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/2] ebpf: add helper for obtaining current processor
 id
Date: Fri, 13 Mar 2015 10:06:59 -0700
Message-ID: <55031933.6010507@plumgrid.com>
References: <cover.1426249641.git.daniel@iogearbox.net> <870dce5d9b480d267c8b3de77bad1875adc6016c.1426249641.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:35838 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbbCMRMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 13:12:16 -0400
Received: by ieclw3 with SMTP id lw3so116083379iec.2
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 10:12:15 -0700 (PDT)
In-Reply-To: <870dce5d9b480d267c8b3de77bad1875adc6016c.1426249641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/15 6:22 AM, Daniel Borkmann wrote:
> This patch adds the possibility to obtain raw_smp_processor_id() in
> eBPF. Currently, this is only possible in classic BPF where commit
> da2033c28226 ("filter: add SKF_AD_RXHASH and SKF_AD_CPU") has added
> facilities for this.
>
> Single threaded packet socket applications (f.e. tcpdump, netsniff-ng)
> e.g. writing to pcap files and making use of eBPF can use this helper
> function to spread flows after RPS dispatch to several instances. It
> would also allow to track per CPU statistics (or data) with eBPF maps.

I'm not sure whether classic extension is still used by Eric as it was
envisioned in that old commit, but I do like addition of it for eBPF,
since it allows a poor men's per-cpu data structures via maps :)

> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 4efc41f..9080cf5 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -166,6 +166,7 @@ enum bpf_func_id {
>   	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
>   	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
>   	BPF_FUNC_random,	  /* prandom() as u32 or u64 */
> +	BPF_FUNC_cpu_id,	  /* raw_smp_processor_id() */

same comment as in other patch:
could you rename it to BPF_FUNC_get_smp_processor_id ?
