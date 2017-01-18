From: Eric Dumazet <edumazet@google.com>
Subject: Re: resend: tcp: performance issue with fastopen connections (mss > window)
Date: Wed, 18 Jan 2017 09:35:43 -0800
Message-ID: <CANn89iJn+fC-mMCskczXupj=yhvDijYEn-_NeCphuG8roNCygA@mail.gmail.com>
References: <30f38b3c-8c5c-7fab-e424-985e63ad900a@oracle.com>
 <1484321734.13165.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <22b07900-2151-a31f-34aa-7fb47c958423@oracle.com> <3dbbcda8-ce79-641c-cf3b-21f41c563939@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vasily Isaenko <vasily.isaenko@oracle.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:36225 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdARRfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 12:35:45 -0500
Received: by mail-it0-f42.google.com with SMTP id c7so122628400itd.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 09:35:45 -0800 (PST)
In-Reply-To: <3dbbcda8-ce79-641c-cf3b-21f41c563939@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 9:32 AM, Alexey Kodanev
<alexey.kodanev@oracle.com> wrote:
> Hi Eric,
>
> On 01/13/2017 08:07 PM, Alexey Kodanev wrote:
>

> Looks like max_window not correctly initialized for tfo sockets.
> On my test machine it has set to '5592320' in tcp_fastopen_create_child().
>
> This diff fixes the issue, the question: is this the right place to do it?
>
> diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> index 4e777a3..33ed508 100644
> --- a/net/ipv4/tcp_fastopen.c
> +++ b/net/ipv4/tcp_fastopen.c
> @@ -206,6 +206,8 @@ static struct sock *tcp_fastopen_create_child(struct
> sock *sk,
>          */
>         tp->snd_wnd = ntohs(tcp_hdr(skb)->window);
>
> +       tp->max_window = tp->snd_wnd;
> +

Excellent catch. Let me test our regression tests with this.

Thanks !
