From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Tue, 16 May 2017 11:16:09 -0700
Message-ID: <CAM_iQpVBKjwqmU1p-xLYwy=032fewdCfDetaSxC+aQoE=dgMfQ@mail.gmail.com>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com>
 <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
 <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg> <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
 <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg> <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
 <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg> <CAM_iQpWAjTJL54h_Pdg3DigjEK4kQdSz0pmAks6ByoP67ROOFg@mail.gmail.com>
 <alpine.LFD.2.20.1705160955310.1856@ja.home.ssi.bg> <CAM_iQpVuqBkQxq=g4n5t33Gv0mxR_S0iOtQxgBHKceam8pmwfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35945 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEPSQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 14:16:31 -0400
Received: by mail-wm0-f41.google.com with SMTP id u65so130379592wmu.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 11:16:30 -0700 (PDT)
In-Reply-To: <CAM_iQpVuqBkQxq=g4n5t33Gv0mxR_S0iOtQxgBHKceam8pmwfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 10:53 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> How about adding a check for ->fib_dead in these work's?
> If the last treeref is gone, probably it is no longer needed
> to continue to do the offloading work.

Hmm, this doesn't look correct either, we may miss an offloading work
if fib_release_info() comes first.
