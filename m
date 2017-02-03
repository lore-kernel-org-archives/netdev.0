From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix verifier issue at check_packet_ptr_add
Date: Fri, 03 Feb 2017 09:37:08 +0100
Message-ID: <58944134.6060107@iogearbox.net>
References: <1486065553-5074-1-git-send-email-u9012063@gmail.com> <5893C4DD.9000701@iogearbox.net> <CALDO+SZCn452+Tp6cBjMb_J9Mu=08Em=0+jsKpa31b3Eoy-0SQ@mail.gmail.com> <20170203034636.GA68213@ast-mbp.thefacebook.com> <CALDO+SZrm3KpDDRrC6H9jkaMVxiwUPEFp+1vBaZbSvTdH8=09w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59858 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751903AbdBCIhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 03:37:10 -0500
In-Reply-To: <CALDO+SZrm3KpDDRrC6H9jkaMVxiwUPEFp+1vBaZbSvTdH8=09w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 06:31 AM, William Tu wrote:
[...]
> Yes, this is auto-generated. We want to use P4 2016 as front end to
> generate ebpf for XDP.
>
[...]
> R2 is no longer pkt_end, it's R2 == R0 == 0
> 269: (bf) r2 = r0
> 270: (77) r2 >>= 3
> 271: (bf) r4 = r1
> 272: (0f) r4 += r2
>
> So at line 272, it's pkt_ptr = pkt_ptr + 0
> thus the following fix works for us.
> -               if (imm <= 0) {
> +               if (imm < 0) {

Okay, makes sense. I'll wait with ACK for your respin with kselftest
case.

Thanks,
Daniel
