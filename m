From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 3/3] x25: Prevent skb overreads when checking call user data
Date: Mon, 17 Oct 2011 21:28:24 +1100
Message-ID: <CADo0ohgNR4XGQM1BnfDgHX2v42ov-obhfQpc-vbDHZ4oABx5zA@mail.gmail.com>
References: <1318653905-13716-1-git-send-email-mattjd@gmail.com>
	<1318653905-13716-4-git-send-email-mattjd@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	stable <stable@kernel.org>
To: Matthew Daley <mattjd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36753 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab1JQK2Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 06:28:25 -0400
Received: by vws1 with SMTP id 1so2351912vws.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 03:28:24 -0700 (PDT)
In-Reply-To: <1318653905-13716-4-git-send-email-mattjd@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Andrew Hendry <andrew.hendry@gmail.com>

On Sat, Oct 15, 2011 at 3:45 PM, Matthew Daley <mattjd@gmail.com> wrote=
:
> x25_find_listener does not check that the amount of call user data gi=
ven
> in the skb is big enough in per-socket comparisons, hence buffer
> overreads may occur. =A0Fix this by adding a check.
>
> Signed-off-by: Matthew Daley <mattjd@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Andrew Hendry <andrew.hendry@gmail.com>
> Cc: stable <stable@kernel.org>
> ---
> =A0net/x25/af_x25.c | =A0 =A03 ++-
> =A01 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
> index aa567b0..5f03e4e 100644
> --- a/net/x25/af_x25.c
> +++ b/net/x25/af_x25.c
> @@ -295,7 +295,8 @@ static struct sock *x25_find_listener(struct x25_=
address *addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Found a listening s=
ocket, now check the incoming
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * call user data vs t=
his sockets call user data
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if(skb->len > 0 && x25_=
sk(s)->cudmatchlength > 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (x25_sk(s)->cudmatch=
length > 0 &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->le=
n >=3D x25_sk(s)->cudmatchlength) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if((me=
mcmp(x25_sk(s)->calluserdata.cuddata,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0skb->data,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0x25_sk(s)->cudmatchlength)) =3D=3D 0) {
> --
> 1.7.2.5
>
>
