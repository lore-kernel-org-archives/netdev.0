From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next] tc: built-in eBPF exec proxy
Date: Thu, 16 Apr 2015 19:59:45 +0200
Message-ID: <552FF891.80304@iogearbox.net>
References: <e970d60e68be0ac905542635cc28abb2bf1bebea.1429109269.git.daniel@iogearbox.net> <552FF5F7.2070108@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52093 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbbDPR7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 13:59:51 -0400
In-Reply-To: <552FF5F7.2070108@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2015 07:48 PM, Alexei Starovoitov wrote:
> On 4/15/15 7:52 AM, Daniel Borkmann wrote:
>>
>> File descriptors, based on their id, are being fetched from the same
>> unix domain socket as demonstrated in the bpf_agent, the shell spawned
>> via execvpe(2) and the map fds passed over the environment, and thus
>> are made available to applications in the fashion of std{in,out,err}
>> for read/write access, for example in case of iproute2's examples/bpf/:
>
> Amazing that it worked.
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
>> +static void bpf_map_set_env(int *tfd)
>> +{
>> +    char key[64], *val;
>> +    int i;
>> +    for (i = 0; i < BPF_MAP_ID_MAX; i++) {
>> +        memset(key, 0, sizeof(key));
>> +        snprintf(key, sizeof(key), "BPF_MAP%d", i);
>>
>> +        val = secure_getenv(key);
>> +        assert(val != NULL);
>
> everything looks good. My only nit is that the name of the function
> reads as this function is setting env vars, whereas it's actually
> reading them. I guess in your mind it fits with the rest of
> 'bpf_map_set_*' functions, but the name is still confusing.

Ok, since it's example code, I'll find a better function name for it,
keep yours and Hannes' tags and resubmit. Thanks!
