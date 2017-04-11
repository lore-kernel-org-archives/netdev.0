From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Tue, 11 Apr 2017 13:22:40 +0200
Message-ID: <58ECBC80.1050009@iogearbox.net>
References: <1491907114.31620.18.camel@sipsolutions.net>         <58ECB8CF.8040409@iogearbox.net> <1491909330.31620.21.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37610 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751921AbdDKLWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:22:42 -0400
In-Reply-To: <1491909330.31620.21.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 01:15 PM, Johannes Berg wrote:
>
>> Are you working with an skb at that point in time in wifi?
>
> Yes.
>
>> There are
>> 3 different ways of accessing skb data, see [1] slide 7 - 10. The BPF
>> LD_ABS/IND instructions were carried over from cBPF and are the only
>> ones that convert to host endianess. It can be used in eBPF as well,
>> but there are more efficient ways like 'direct packet access' or
>> helpers such as bpf_skb_load_bytes() that load the raw buffers as-is,
>> which is probably what you want if I understand you correctly.
>
> Sounds like, yeah.
>
>> There are instructions to convert endianess, see __bpf_prog_run(),
>> the ALU_END_TO_BE, ALU_END_TO_LE labels for details. There's a
>> BPF_ENDIAN() macro used in the test suite and other places.
>
> Ok, thanks! :)
>
> So sounds like I don't need anything special - should have a patch to
> hook up the wifi stuff soon.

Yeah, you shouldn't need anything special. In case the wifi progs have
their own BPF program type, I wouldn't even add it to may_access_skb()
to not further encourage LD_ABS/IND usage. F.e. lwt BPF programs are not
hooked up there either.

Thanks,
Daniel
