From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] gro_cells: mark napi struct as not busy poll candidates
Date: Mon, 14 Nov 2016 21:21:28 -0800
Message-ID: <CAM_iQpWBATQUcTEg1o_mrA+zoH0KOh0Kpnmt+GgCLy+K3d=5_g@mail.gmail.com>
References: <CA+pO-2f+7QfsLiFwvGcNqTrQ0t8B5+w0vZHFrshWsSWgDE6iUg@mail.gmail.com>
 <CAM_iQpUNRyv3wHi3cJpcH6avo+D7Gxwqp+iybUxYc7PCo3WUPw@mail.gmail.com>
 <20161110212404.GB4127@linux.vnet.ibm.com> <CA+pO-2ddoJYvhVoV3Bo+-3K7V63eY9sbKzKwYrut65GZXs6_1g@mail.gmail.com>
 <20161112002347.GL4127@linux.vnet.ibm.com> <CAM_iQpUDnPfVayQv7Q+ZtC_2_ZbX9MRX=514gFpF3E6XY+GtSA@mail.gmail.com>
 <CAM_iQpUq14GsvGyz2xA1PkDq5YO743T68Zh2zm=NJZQ9S2Ahqg@mail.gmail.com>
 <20161114162417.GJ4127@linux.vnet.ibm.com> <CAM_iQpXL+JaVG86+h2ucYs4Dm0zJKHq+4Nm+gk75wESGOzTmJQ@mail.gmail.com>
 <20161114181425.GN4127@linux.vnet.ibm.com> <87y40lhfrt.fsf@xmission.com>
 <1479163571.8455.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <1479164967.8455.87.camel@edumazet-glaptop3.roam.corp.google.com> <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Justin Cormack <justin.cormack@docker.com>,
        Ian Campbell <ian.campbell@docker.com>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33431 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752777AbcKOFVt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 00:21:49 -0500
Received: by mail-it0-f66.google.com with SMTP id c20so17354369itb.0
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 21:21:49 -0800 (PST)
In-Reply-To: <1479169722.8455.108.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2016 at 4:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Rolf Neugebauer reported very long delays at netns dismantle.
>
> Eric W. Biederman was kind enough to look at this problem
> and noticed synchronize_net() occurring from netif_napi_del() that was
> added in linux-4.5
>
> Busy polling makes no sense for tunnels NAPI.
> If busy poll is used for sessions over tunnels, the poller will need to
> poll the physical device queue anyway.
>
> netif_tx_napi_add() could be used here, but function name is misleading,
> and renaming it is not stable material, so set NAPI_STATE_NO_BUSY_POLL
> bit directly.
>
> This will avoid inserting gro_cells napi structures in napi_hash[]
> and avoid the problematic synchronize_net() (per possible cpu) that
> Rolf reported.
>
> Fixes: 93d05d4a320c ("net: provide generic busy polling to all NAPI drivers")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
> Reported-by: Eric W. Biederman <ebiederm@xmission.com>


Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
