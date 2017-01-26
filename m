From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Thu, 26 Jan 2017 14:00:55 +0800
Message-ID: <1d949c6b-43cc-f5d0-8448-b9f2f5a00c88@windriver.com>
References: <1485401274-2836524-1-git-send-email-ast@fb.com>
 <87efzq8jbi.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
To: <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37657 "EHLO
        mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752448AbdAZGBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 01:01:20 -0500
In-Reply-To: <87efzq8jbi.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tetst teste tetet tetest tetetttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt

On 01/26/2017 01:46 PM, Eric W. Biederman wrote:
> Alexei Starovoitov <ast@fb.com> writes:
> 
>> in cases where bpf programs are looking at sockets and packets
>> that belong to different netns, it could be useful to read netns inode,
>> so that programs can make intelligent decisions.
>> For example to disallow raw sockets in all non-init netns the program can do:
>> if (sk->type == SOCK_RAW && sk->netns_inum != 0xf0000075)
>>   return 0;
>> where 0xf0000075 inode comes from /proc/pid/ns/net
>>
>> Similarly TC cls_bpf/act_bpf and socket filters can do
>> if (skb->netns_inum == expected_inode)
> 
> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Particularly you need to compare more than the inode number.
> Further I have never guaranteed there will be exactly one inode
> per network namespace, just that if the device number and the inode
> number pair match they are the same.
> 
> Beyond that the entire concept is complete rubbish.
> 
> The only sane thing is to interpret whatever your bpf program in the
> context of the program which installs it.
> 
> If you can't do that you have a very broken piece of userspace
> interface.  Which appears to be the case here.
> 
> Eric
> 
