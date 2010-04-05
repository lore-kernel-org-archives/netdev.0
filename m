From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] rps: fixed missed rps_unlock
Date: Tue, 6 Apr 2010 06:23:57 +0800
Message-ID: <z2m412e6f7f1004051523p6198556ak3e2ab9a52a3167d4@mail.gmail.com>
References: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f191.google.com ([209.85.210.191]:39137 "EHLO
	mail-yx0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab0DEWYS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 18:24:18 -0400
Received: by yxe29 with SMTP id 29so2310000yxe.4
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 15:24:18 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1004051426140.22393@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 6, 2010 at 5:30 AM, Tom Herbert <therbert@google.com> wrote=
:
> Fix spin_unlock_irq which needs to be rps_unlock.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 2a9b7dd..74f77ca 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3120,7 +3120,7 @@ static int process_backlog(struct napi_struct *=
napi, int quota)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0skb =3D __skb_=
dequeue(&queue->input_pkt_queue);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!skb) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0__napi_complete(napi);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 spin_unlock_irq(&queue->input_pkt_queue.lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 rps_unlock(queue);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rps_unlock(que=
ue);

It seems that irq isn't enabled when breaking the loop. Please add
   local_irq_enable();
after rps_unlock(queue);



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
