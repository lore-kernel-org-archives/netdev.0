From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp:elapsed variable calculated twice while
 keepalive working
Date: Fri, 09 Aug 2013 14:06:39 -0700
Message-ID: <1376082399.20509.12.camel@edumazet-glaptop>
References: <1375792738-19099-1-git-send-email-tingw.liu@gmail.com>
	 <20130809.111229.1955078847385749897.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tingw.liu@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:48140 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031125Ab3HIVGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 17:06:42 -0400
Received: by mail-oa0-f51.google.com with SMTP id h1so7387081oag.38
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 14:06:41 -0700 (PDT)
In-Reply-To: <20130809.111229.1955078847385749897.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 11:12 -0700, David Miller wrote:
> From: Tingwei Liu <tingw.liu@gmail.com>
> Date: Tue,  6 Aug 2013 20:38:58 +0800
> 
> > When tcp keepalive working elapsed calculated twice while the first time is not needed!
> > 
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > Signed-off-by: Tingwei Liu <tingw.liu@gmail.com>
> 
> 
> Please put a space after "tcp:" in your Subject line prefixes, it looks
> awful the way you've done it here.
> 
> > @@ -591,11 +591,11 @@ static void tcp_keepalive_timer (unsigned long data)
> >  	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
> >  		goto out;
> >  
> > -	elapsed = keepalive_time_when(tp);
> > -
> >  	/* It is alive without keepalive 8) */
> > -	if (tp->packets_out || tcp_send_head(sk))
> > +	if (tp->packets_out || tcp_send_head(sk)) {
> > +		elapsed = keepalive_time_when(tp);
> >  		goto resched;
> > +	}
> >  
> >  	elapsed = keepalive_time_elapsed(tp);
> 
> This is overkill, just delete the second assignment.  Your version makes
> the code look less elegant and also makes it harder to audit.
> --

As a matter of fact, 
keepalive_time_when(tp) and keepalive_time_elapsed(tp) are different ;)

This is very slow path in TCP stack, so it should not matter a lot.

 
