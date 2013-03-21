From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH v2 1/4] tcp: fix too short FIN_WAIT2 time out
Date: Thu, 21 Mar 2013 20:45:17 +0900
Message-ID: <1363866317.3029.21.camel@ubuntu-vm-makita>
References: <1363610163.7121.2.camel@ubuntu-vm-makita>
	 <1363610344.7121.5.camel@ubuntu-vm-makita>
	 <20130319.093257.1744500513624729643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	makita.toshiaki@lab.ntt.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:40843 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756907Ab3CULp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 07:45:28 -0400
In-Reply-To: <20130319.093257.1744500513624729643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-19 at 09:32 -0400, David Miller wrote:
> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Date: Mon, 18 Mar 2013 21:39:04 +0900
> 
> >               if (tp->linger2 >= 0) {
> > -                     const int tmo = tcp_fin_time(sk) - TCP_TIMEWAIT_LEN;
> > -
> > -                     if (tmo > 0) {
> > -                             tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
> > -                             goto out;
> > -                     }
> > +                     tcp_time_wait(sk, TCP_FIN_WAIT2, TCP_TIMEWAIT_LEN);
> > +                     goto out;
> >               }
> 
> Well, now you're completely ignoring the user's linger setting.

If you mention TCP_LINGER2, I don't think I'm ignoring it.
It is taken into account in tcp_rcv_state_process() or tcp_close().
If I'm misunderstanding, I'd be glad if you could point out it.

> 
> I really can't take these patches seriously, and will not apply them,
> sorry.

I think, at least, too short timeout is harmful.
If tcp_fin_timeout is set to 61, it will expire in 2 seconds, which
cause peer to receive unexpected reset by sending fin.
Don't you think there is a problem?

Toshiaki Makita
