From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 14:47:35 -0400
Message-ID: <CA+FuTSfinkPAJKDZ9BmY_dLo60mdVFJ=B7xc4CN+SUwShoxFxg@mail.gmail.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
 <1439567427-19504-3-git-send-email-willemb@google.com> <55CE1F54.7090109@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35066 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbbHNSsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 14:48:05 -0400
Received: by ykbi184 with SMTP id i184so12313778ykb.2
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:48:04 -0700 (PDT)
In-Reply-To: <55CE1F54.7090109@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On 8/14/15 8:50 AM, Willem de Bruijn wrote:
>>
>> +static int fanout_set_data_ebpf(struct packet_fanout *f, char __user
>> *data,
>> +                               unsigned int len)
>> +{
>> +       struct bpf_prog *new;
>> +       u32 fd;
>> +
>> +       if (len != sizeof(fd))
>> +               return -EINVAL;
>> +       if (copy_from_user(&fd, data, len))
>> +               return -EFAULT;
>> +
>> +       new = bpf_prog_get(fd);
>> +       if (IS_ERR(new))
>> +               return PTR_ERR(new);
>> +
>> +       __fanout_set_data_bpf(f, new);
>> +       return 0;
>> +}
>
>
> all looks great except in the above the check:
>         if (new->type != BPF_PROG_TYPE_SOCKET_FILTER) {
>                 bpf_prog_put(new);
>                 return -EINVAL;
>         }
> is missing. Otherwise user will be able to attach programs
> of wrong types to fanout.

Ai, good point!

> Also instead of:
>  #define PACKET_FANOUT_BPF              6
>  #define PACKET_FANOUT_EBPF             7
>
> I would call them FANOUT_CBPF and FANOUT_EBPF to be unambiguous.
> This is how bpf manpage distinguishes them.
>

Sounds good. I'll make both changes in v2. Thanks for reviewing, Alexei.
