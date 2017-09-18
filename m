From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [REGRESSION] Warning in tcp_fastretrans_alert() of net/ipv4/tcp_input.c
Date: Mon, 18 Sep 2017 19:59:54 +0200
Message-ID: <40697505.YK5nrFG7Le@natalenko.name>
References: <10035198.1vE6NFrMDO@natalenko.name> <CAK6E8=fF0hMmQ+m4JZPWFFJixYa3Vp5WrQapYu4zq9Zc5eMe_w@mail.gmail.com> <CAK6E8=ekw7ybf6nwNy7S49ASZBsCS4c_7KR2Bcxq6WiXUKY56w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Neal Cardwell <ncardwell@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vulcan.natalenko.name ([104.207.131.136]:39922 "EHLO
        vulcan.natalenko.name" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdIRR74 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 13:59:56 -0400
In-Reply-To: <CAK6E8=ekw7ybf6nwNy7S49ASZBsCS4c_7KR2Bcxq6WiXUKY56w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK. Should I keep FACK disabled?

On pond=C4=9Bl=C3=AD 18. z=C3=A1=C5=99=C3=AD 2017 19:51:21 CEST Yuchung Che=
ng wrote:
> Can you try this patch to verify my theory with tcp_recovery=3D0 and 1? t=
hanks
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 5af2f04f8859..9253d9ee7d0e 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2381,6 +2381,7 @@ static void tcp_undo_cwnd_reduction(struct sock
> *sk, bool unmark_loss)
>         }
>         tp->snd_cwnd_stamp =3D tcp_time_stamp;
>         tp->undo_marker =3D 0;
> +       WARN_ON(tp->retrans_out);
>  }
