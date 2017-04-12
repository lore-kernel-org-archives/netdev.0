From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net 1/1] net: tcp: Increase TCPABORTONLINGER when send RST by linger2 in keepalive timer
Date: Thu, 13 Apr 2017 06:17:35 +0800
Message-ID: <001f01d2b3da$97282a40$c5787ec0$@foxmail.com>
References: <1491741881-28322-1-git-send-email-gfree.wind@foxmail.com> <20170412.132049.1340057228980086886.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>, <kaber@trash.net>,
        <ncardwell@google.com>, <netdev@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>, <gfree.wind@foxmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg64.qq.com ([103.7.28.238]:13819 "EHLO smtpbg64.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752031AbdDLWSd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 18:18:33 -0400
In-Reply-To: <20170412.132049.1340057228980086886.davem@davemloft.net>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 13, 2017 1:21 AM
> To: gfree.wind@foxmail.com
> Cc: kuznet@ms2.inr.ac.ru; jmorris@namei.org; kaber@trash.net;
> ncardwell@google.com; netdev@vger.kernel.org; fgao@ikuai8.com
> Subject: Re: [PATCH net 1/1] net: tcp: Increase TCPABORTONLINGER when send
> RST by linger2 in keepalive timer
> 
> From: gfree.wind@foxmail.com
> Date: Sun,  9 Apr 2017 20:44:41 +0800
> 
> > From: Gao Feng <fgao@ikuai8.com>
> >
> > It should increase TCPABORTONLINGER counter when send RST caused by
> > linger2 in keepalive timer.
> >
> > Signed-off-by: Gao Feng <fgao@ikuai8.com>
> > ---
> >  net/ipv4/tcp_timer.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c index
> > b2ab411..5c01f21 100644
> > --- a/net/ipv4/tcp_timer.c
> > +++ b/net/ipv4/tcp_timer.c
> > @@ -650,6 +650,8 @@ static void tcp_keepalive_timer (unsigned long data)
> >  				tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
> >  				goto out;
> >  			}
> > +		} else {
> > +			NET_INC_STATS(sock_net(sk),
LINUX_MIB_TCPABORTONLINGER);
> >  		}
> >  		tcp_send_active_reset(sk, GFP_ATOMIC);
> >  		goto death;
> 
> I think this else clause is completely unnecessary.  Just do it right
above the
> tcp_send_active_reset() call and at the same indentation level.
> 
> Alternatively, if you are trying to only bump the counter when tp->linger2
is
> >= 0, then you attached the else clause to the wrong if() test.
> 
> Thank you.

Actually I only want increase the TCPABORTONLINGER when linger2 is negative
which
means the timeout of FIN_WAIT2 is 0. We need to make socket state is closed
and send
one RST to peer.

Because tmo may be zero too, so increase this counter in the else block to
avoid it.

Best Regards
Feng
