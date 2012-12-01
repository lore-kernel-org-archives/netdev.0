From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: [B.A.T.M.A.N.] [PATCH] net: fix possible deadlocks in
 rtnl_trylock/unlock
Date: Sat, 01 Dec 2012 11:44:34 -0800
Message-ID: <1354391074.20109.527.camel@edumazet-glaptop>
References: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de>
	 <1354386972.20109.523.camel@edumazet-glaptop>
	 <10264267.HX5FJDguj3@sven-laptop.home.narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	netdev@vger.kernel.org, davem@davemloft.net,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:50407 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab2LAToi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 14:44:38 -0500
Received: by mail-vb0-f46.google.com with SMTP id b13so512240vby.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 11:44:37 -0800 (PST)
In-Reply-To: <10264267.HX5FJDguj3@sven-laptop.home.narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-01 at 20:04 +0100, Sven Eckelmann wrote:
> On Saturday 01 December 2012 10:36:12 Eric Dumazet wrote:
>  
> > > diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> > > index c5c0593..c122782 100644
> > > --- a/net/bridge/br_sysfs_br.c
> > > +++ b/net/bridge/br_sysfs_br.c
> > > @@ -142,7 +142,7 @@ static ssize_t store_stp_state(struct device *d,
> > > 
> > >  	if (!rtnl_trylock())
> > >  	
> > >  		return restart_syscall();
> > >  	
> > >  	br_stp_set_enabled(br, val);
> > > 
> > > -	rtnl_unlock();
> > > +	__rtnl_unlock();
> > > 
> > >  	return len;
> > >  
> > >  }
> > 
> > I have no idea of why you believe there is a problem here.
> > 
> > Could you explain how net_todo_list could be not empty ?
> > 
> > As long as no device is unregistered between
> > rtnl_trylock()/rtnl_unlock(), there is no possible deadlock.
> 
> I am not sure what "here" means for your. At least batman-adv tries to 
> unregister a device -> problem [1]. I will not make any judgements about the 
> other uses in the kernel/other parts patched by Simon.
> 

I was reacting to the change in net/bridge/br_sysfs_br.c

rtnl_trylock() could set a boolean flag to explicitly WARN_ON()
in case we try to unregister a device.
