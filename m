From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: eBPF - little-endian load instructions?
Date: Tue, 11 Apr 2017 13:06:55 +0200
Message-ID: <58ECB8CF.8040409@iogearbox.net>
References: <1491907114.31620.18.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34977 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753444AbdDKLHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:07:05 -0400
In-Reply-To: <1491907114.31620.18.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 12:38 PM, Johannes Berg wrote:
> Hi,
>
> Looking at (e)BPF for wifi, I notice that everything is big endian in
> loads from the frame - and wifi is all little endian.
>
> Obviously, this can be worked around by doing byte-loads and swapping
> in the program, but it'll be more efficient to not do that.
>
> Do you think it's possible to add little-endian load instructions? Or
> perhaps there should be a conversion function from BE to LE?

Are you working with an skb at that point in time in wifi? There are
3 different ways of accessing skb data, see [1] slide 7 - 10. The BPF
LD_ABS/IND instructions were carried over from cBPF and are the only
ones that convert to host endianess. It can be used in eBPF as well,
but there are more efficient ways like 'direct packet access' or
helpers such as bpf_skb_load_bytes() that load the raw buffers as-is,
which is probably what you want if I understand you correctly.

There are instructions to convert endianess, see __bpf_prog_run(), the
ALU_END_TO_BE, ALU_END_TO_LE labels for details. There's a BPF_ENDIAN()
macro used in the test suite and other places.

   [1] http://netdevconf.org/1.2/slides/oct7/07_advanced_programmability_and_recent_updates_with_tc_cls_bpf.pdf
