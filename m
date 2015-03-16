From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next 2/2] tc: add eBPF support to f_bpf
Date: Mon, 16 Mar 2015 18:49:21 +0100
Message-ID: <550717A1.2040805@iogearbox.net>
References: <cover.1426525312.git.daniel@iogearbox.net> <f7e40a542ad415742037bab62ed2348f07ba4c94.1426525312.git.daniel@iogearbox.net> <550716BF.9030607@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jiri@resnulli.us, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39850 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797AbbCPRta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:49:30 -0400
In-Reply-To: <550716BF.9030607@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2015 06:45 PM, Alexei Starovoitov wrote:
> On 3/16/15 10:10 AM, Daniel Borkmann wrote:
>
>> +
>> +/* ELF section names, etc (ABI) */
>> +#define ELF_SECTION_LICENSE    "license"
>> +#define ELF_SECTION_MAPS    "maps"
>> +#define ELF_SECTION_CLASSIFIER    "classifier"
>> +#define ELF_SECTION_ACTION    "action"
>> +
>> +#define ELF_MAX_MAPS        64
>> +#define ELF_MAX_LICENSE_LEN    128
>> +
>> +/* ELF map definition (ABI) */
>> +struct bpf_elf_map {
>> +    __u32 type;
>> +    __u32 size_key;
>> +    __u32 size_value;
>> +    __u32 max_elem;
>> +};
>
> I think people might freak out that the above section names and
> the struct are a kernel ABI. It's obviously not.
> Would be good to say that this is a present convention between
> C program that describes tc classifier and tc elf reader
> and it can change in the future.

Ohh, well, it's not a kernel ABI. I actually don't intend to change
the section names either as we don't want to break tc users. I could
imagine aliases if truly necessary.

I guess, I'll elaborate on the comment, sure.
