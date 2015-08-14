From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/4] packet: add eBPF fanout mode
Date: Fri, 14 Aug 2015 21:01:37 +0200
Message-ID: <55CE3B11.40406@iogearbox.net>
References: <1439567427-19504-1-git-send-email-willemb@google.com> <1439567427-19504-3-git-send-email-willemb@google.com> <55CE1F54.7090109@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>, netdev@vger.kernel.org,
	davem@davemloft.net, edumazet@google.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48521 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbbHNTBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 15:01:40 -0400
In-Reply-To: <55CE1F54.7090109@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ @Willem: RH email doesn't exist anymore, I took it out, otherwise
   every reply gets a bounce. ;) ]

On 08/14/2015 07:03 PM, Alexei Starovoitov wrote:
> On 8/14/15 8:50 AM, Willem de Bruijn wrote:
...
> all looks great except in the above the check:
>          if (new->type != BPF_PROG_TYPE_SOCKET_FILTER) {
>                  bpf_prog_put(new);
>                  return -EINVAL;
>          }
> is missing. Otherwise user will be able to attach programs
> of wrong types to fanout.
>
> Also instead of:
>   #define PACKET_FANOUT_BPF        6
>   #define PACKET_FANOUT_EBPF        7
>
> I would call them FANOUT_CBPF and FANOUT_EBPF to be unambiguous.
> This is how bpf manpage distinguishes them.

We have SO_ATTACH_FILTER and SO_ATTACH_BPF, could also be
analogous for fanout, if we want to be consistent with the API?

But C/E prefix seems okay too, how you want ...

Btw, in case someone sets sock_flag(sk, SOCK_FILTER_LOCKED),
perhaps we should also apply it on fanout?

Thanks,
Daniel
