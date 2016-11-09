From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: net/sctp: null-ptr-deref in sctp_inet_listen
Date: Wed, 9 Nov 2016 20:24:20 +0100
Message-ID: <CAAeHK+x5tsuCjrxdj_AAedQEcii-H70ZbJpi6ZYzj0m4H-W1GQ@mail.gmail.com>
References: <CAAeHK+yCE-e2scjs=rUwr+XHmmCcd33P--7MVFmxrTQ_AFZcOA@mail.gmail.com>
 <CADvbK_eyG3pLMOws5wAOpvDUPUB2SknOCV5z6TLfJoKfj+Q27A@mail.gmail.com>
 <CAAeHK+yW+5qqPtiXt+5+HsDPj=czh2ppfcUi0qO0fEjGsaqFnQ@mail.gmail.com> <CADvbK_dswzCgnQXMSiTOsODXP19epKkQsoUgLmv8PORhfAzwFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: syzkaller <syzkaller@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_dswzCgnQXMSiTOsODXP19epKkQsoUgLmv8PORhfAzwFA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 9, 2016 at 4:32 AM, Xin Long <lucien.xin@gmail.com> wrote:
> this fix may break TYPE_SCTP_PRIMITIVE_SHUTDOWN statetable,
> could you give the following one a try ? thanks.

This one also works.

Thanks.

>
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4288,9 +4288,9 @@ static void sctp_shutdown(struct sock *sk, int how)
>                 return;
>
>         if (how & SEND_SHUTDOWN) {
> -               sk->sk_state = SCTP_SS_CLOSING;
>                 ep = sctp_sk(sk)->ep;
>                 if (!list_empty(&ep->asocs)) {
> +                       sk->sk_state = SCTP_SS_CLOSING;
>                         asoc = list_entry(ep->asocs.next,
>                                           struct sctp_association, asocs);
>                         sctp_primitive_SHUTDOWN(net, asoc, NULL);
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller+unsubscribe@googlegroups.com.
> For more options, visit https://groups.google.com/d/optout.
