From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Tue, 31 Jan 2017 15:11:27 -0700
Message-ID: <4c761626-b127-4419-55e4-902b03532507@cumulusnetworks.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35124 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdAaWL3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 17:11:29 -0500
Received: by mail-pf0-f171.google.com with SMTP id f144so112068969pfa.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 14:11:29 -0800 (PST)
In-Reply-To: <1485401274-2836524-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/25/17 8:27 PM, Alexei Starovoitov wrote:
> in cases where bpf programs are looking at sockets and packets
> that belong to different netns, it could be useful to read netns inode,
> so that programs can make intelligent decisions.
> For example to disallow raw sockets in all non-init netns the program can do:
> if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
>   return 0;
> where 0xf0000075 inode comes from /proc/pid/ns/net
> 
> Similarly TC cls_bpf/act_bpf and socket filters can do
> if (skb->netns_inum == expected_inode)
> 
> The lack of netns awareness was a concern even for socket filters,
> since the application can attach the same bpf program to sockets
> in a different netns. Just like tc cls_bpf program can work in
> different netns as well, so it has to be addressed uniformly
> across all types of bpf programs.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> ---
> with corresponding change in 'ip vrf' that David Ahern is working on,
> this will address 'malfunction' concern that Andy discovered in 'ip vrf',
> hence this fix is needed for 'net'.

FWIW, the iproute2 patch (along with a few other namespace related fixups) can be found here:

    https://github.com/dsahern/iproute2

vrf/ip-vrf branch.
