From: Alban Crequy <alban.crequy@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint trace_tcp_retransmit_synack()
Date: Fri, 27 Oct 2017 22:38:10 +0200
Message-ID: <CAMXgnP7y7Pi21aeFqsRntDakb2bj0ke+F9X54D84rjdLi+tryw@mail.gmail.com>
References: <20171024235709.2186047-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: alexei.starovoitov@gmail.com, kafai@fb.com, ast@fb.com,
        netdev@vger.kernel.org, liu.song.a23@gmail.com
To: Song Liu <songliubraving@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:57100 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbdJ0Uic (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 16:38:32 -0400
Received: by mail-yw0-f196.google.com with SMTP id l32so6764282ywh.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 13:38:31 -0700 (PDT)
In-Reply-To: <20171024235709.2186047-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 25 October 2017 at 01:57, Song Liu <songliubraving@fb.com> wrote:
> This tracepoint can be used to trace synack retransmits. It maintains
> pointer to struct request_sock.
>
> We cannot simply reuse trace_tcp_retransmit_skb() here, because the
> sk here is the LISTEN socket. The IP addresses and ports should be
> extracted from struct request_sock.
>
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
>  include/trace/events/tcp.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_output.c      |  1 +
>  2 files changed, 57 insertions(+)
>
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> index 03699ba..07cccca 100644
> --- a/include/trace/events/tcp.h
> +++ b/include/trace/events/tcp.h
> @@ -237,6 +237,62 @@ TRACE_EVENT(tcp_set_state,
>                   show_tcp_state_name(__entry->newstate))
>  );
>
> +TRACE_EVENT(tcp_retransmit_synack,
> +
> +       TP_PROTO(const struct sock *sk, const struct request_sock *req),
> +
> +       TP_ARGS(sk, req),
> +
> +       TP_STRUCT__entry(
> +               __field(const void *, skaddr)
> +               __field(const void *, req)
> +               __field(__u16, sport)
> +               __field(__u16, dport)
> +               __array(__u8, saddr, 4)
> +               __array(__u8, daddr, 4)
> +               __array(__u8, saddr_v6, 16)
> +               __array(__u8, daddr_v6, 16)

Would it make sense to add the inode of the network namespace that
owns the socket? (along with the major/minor of the nsfs)

If the kernel later gains tracepoints for TCP connect, accept, close
including the netns ino, then I might be able to replace some
ebpf-kprobes code by ebpf-tracepoints code :)

> [...]

Thanks,
Alban
