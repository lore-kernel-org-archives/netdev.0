From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add TCPMemoryPressuresChrono counter
Date: Wed, 07 Jun 2017 13:23:19 -0700
Message-ID: <1496866999.736.42.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1496776767.736.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170607.145448.152856288455996460.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36743 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdFGUX0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 16:23:26 -0400
Received: by mail-pf0-f196.google.com with SMTP id y7so2625370pfd.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 13:23:25 -0700 (PDT)
In-Reply-To: <20170607.145448.152856288455996460.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-07 at 14:54 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 06 Jun 2017 12:19:27 -0700
> 
> > @@ -320,18 +320,37 @@ struct tcp_splice_state {
> >   * All the __sk_mem_schedule() is of this nature: accounting
> >   * is strict, actions are advisory and have some latency.
> >   */
> > -int tcp_memory_pressure __read_mostly;
> > +unsigned long tcp_memory_pressure __read_mostly;
> >  EXPORT_SYMBOL(tcp_memory_pressure);
> 
> I know it is not strictly related to your change, but if you are
> adding new exports in this area let's do it properly.
> 
> The existing tcp_memory_pressure export, as well as these two:
> 
> ...
> >  EXPORT_SYMBOL(tcp_enter_memory_pressure);
> ...
> > +EXPORT_SYMBOL(tcp_leave_memory_pressure);
> 
> ought to be EXPORT_SYMBOL_GPL().  They are exported for the sake of
> ipv6 TCP support, and nothing else.
> 
> I'll apply this with that fixed.
> 
> Thanks Eric.

Sure, I will send a V2 with the two EXPORT_SYMBOL_GPL()

Thanks.
