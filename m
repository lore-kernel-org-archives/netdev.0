From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: regression due to "flush SAD/SPD generate false events"
Date: Thu, 18 Feb 2010 20:55:10 +0200
Message-ID: <20100218185510.GA18829@x200>
References: <20100217191718.GA5256@x200>
 <1266442972.17794.51.camel@bigi>
 <1266448038.17794.135.camel@bigi>
 <1266449529.17794.157.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.189]:3982 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755020Ab0BRTCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 14:02:06 -0500
Received: by gv-out-0910.google.com with SMTP id y18so270072gvf.37
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 11:02:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1266449529.17794.157.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2010 at 06:32:09PM -0500, jamal wrote:
> On Wed, 2010-02-17 at 18:07 -0500, jamal wrote:
> > When you flush
> > an empty table, the time goes up from about 1.5s
> > to 3 secs with pfkey. You also see the EAGAIN for
> > each flush ...
> > I am going to dig a little more ..
> 
> Here is a fix. The speed is restored (actually looks a little better
> now) - the only thing is if you try to flush an empty table we return
> -ESRCH; this seems reasonable, no? So a script like following 
> 
> ---
> #!/usr/sbin/setkey -f
> flush;
> spdflush;
> ----
> 
> will get:
> ---
> bigismall:~# time setkey -f ./setkey-sample
> The result of line 2: No such process.
> The result of line 3: No such process.

I'd expect flushing empty SAD/SPD to be exact nops. :^)
