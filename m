From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net] net_sched: prio: insure proper transactional behavior
Date: Mon, 13 Jun 2016 14:21:17 -0700
Message-ID: <CAM_iQpX3OsM8nX-GG1KFCii8Ad5RsuuoZ159fEBYp6sshp1FHg@mail.gmail.com>
References: <1465773707.7945.133.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXY0Ce5hbXYGOcd-N1tb9BH33JYXFQdmWEbsc5SWYsV8A@mail.gmail.com>
 <1465792157.7945.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <1465794231.7945.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWWLTMRUNUeS9=6B3KqA6Tyu0qaUYSRw_PFYFK_mo7Urw@mail.gmail.com>
 <1465838004.7945.167.camel@edumazet-glaptop3.roam.corp.google.com>
 <1465838879.7945.168.camel@edumazet-glaptop3.roam.corp.google.com> <1465842812.7945.175.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35768 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423303AbcFMVVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:21:37 -0400
Received: by mail-yw0-f196.google.com with SMTP id v137so9521089ywa.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:21:37 -0700 (PDT)
In-Reply-To: <1465842812.7945.175.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 11:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Now prio_init() can return -ENOMEM, it also has to make sure
> any allocated qdiscs are freed, since the caller (qdisc_create()) wont
> call ->destroy() handler for us.
>
> More generally, we want a transactional behavior for "tc qdisc
> change ...", so prio_tune() should not make modifications if
> any error is returned.
>
> It means that we must validate parameters and allocate missing qdisc(s)
> before taking root qdisc lock exactly once, to not leave the prio qdisc
> in an intermediate state.
>
> Fixes: cbdf45116478 ("net_sched: prio: properly report out of memory errors")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>

Looks good to me,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
