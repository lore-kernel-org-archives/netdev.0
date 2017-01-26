From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 18:46:25 +1300
Message-ID: <87efzq8jbi.fsf@xmission.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51209 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdAZFuu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 00:50:50 -0500
In-Reply-To: <1485401274-2836524-1-git-send-email-ast@fb.com> (Alexei
        Starovoitov's message of "Wed, 25 Jan 2017 19:27:54 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <ast@fb.com> writes:

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

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Particularly you need to compare more than the inode number.
Further I have never guaranteed there will be exactly one inode
per network namespace, just that if the device number and the inode
number pair match they are the same.

Beyond that the entire concept is complete rubbish.

The only sane thing is to interpret whatever your bpf program in the
context of the program which installs it.

If you can't do that you have a very broken piece of userspace
interface.  Which appears to be the case here.

Eric
