From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net v2] ipv6: fix a potential deadlock in
 do_ipv6_setsockopt()
Date: Thu, 20 Oct 2016 15:10:58 -0700
Message-ID: <1477001458.7065.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476945312-15572-1-git-send-email-xiyou.wangcong@gmail.com>
         <1476971226.7065.5.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUvU8dZPquAgtcZASO6jhjtoYQ2nc8EBceqZmSHg4ZSsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Baozeng Ding <sploving1@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36225 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753598AbcJTWLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 18:11:00 -0400
Received: by mail-pf0-f196.google.com with SMTP id r16so6626747pfg.3
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 15:11:00 -0700 (PDT)
In-Reply-To: <CAM_iQpUvU8dZPquAgtcZASO6jhjtoYQ2nc8EBceqZmSHg4ZSsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-20 at 14:35 -0700, Cong Wang wrote:
> On Thu, Oct 20, 2016 at 6:47 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2016-10-19 at 23:35 -0700, Cong Wang wrote:
> >> Baozeng reported this deadlock case:
> >
> > ...
> >
> >> +
> >> +void ipv6_sock_mc_close(struct sock *sk)
> >> +{
> >> +     struct ipv6_pinfo *np = inet6_sk(sk);
> >> +
> >> +     if (!rcu_access_pointer(np->ipv6_mc_list))
> >> +             return;
> >
> > I wonder if rcu_dereference_protected(..., lockdep_sock_is_held(sk))
> > could be used instead, to get lockdep support ?
> 
> Maybe, but this "problem" exists without my patch too, right?

I used 'I wonder if' to say that we might have some better way to code
this test nowadays, but this can be done in a separate patch of course.
