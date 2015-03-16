From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH iproute2 -next 2/2] tc: add eBPF support to f_bpf
Date: Mon, 16 Mar 2015 10:45:35 -0700
Message-ID: <550716BF.9030607@plumgrid.com>
References: <cover.1426525312.git.daniel@iogearbox.net> <f7e40a542ad415742037bab62ed2348f07ba4c94.1426525312.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37364 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbCPRpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:45:39 -0400
Received: by igcqo1 with SMTP id qo1so49422363igc.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 10:45:38 -0700 (PDT)
In-Reply-To: <f7e40a542ad415742037bab62ed2348f07ba4c94.1426525312.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/16/15 10:10 AM, Daniel Borkmann wrote:

> +
> +/* ELF section names, etc (ABI) */
> +#define ELF_SECTION_LICENSE	"license"
> +#define ELF_SECTION_MAPS	"maps"
> +#define ELF_SECTION_CLASSIFIER	"classifier"
> +#define ELF_SECTION_ACTION	"action"
> +
> +#define ELF_MAX_MAPS		64
> +#define ELF_MAX_LICENSE_LEN	128
> +
> +/* ELF map definition (ABI) */
> +struct bpf_elf_map {
> +	__u32 type;
> +	__u32 size_key;
> +	__u32 size_value;
> +	__u32 max_elem;
> +};

I think people might freak out that the above section names and
the struct are a kernel ABI. It's obviously not.
Would be good to say that this is a present convention between
C program that describes tc classifier and tc elf reader
and it can change in the future.
