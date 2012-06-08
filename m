From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Fri, 08 Jun 2012 07:47:18 +0200
Message-ID: <1339134438.6001.13.camel@edumazet-glaptop>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
	 <20120607205356.GA2491@electric-eye.fr.zoreil.com>
	 <1339104606.6001.4.camel@edumazet-glaptop>
	 <20120607223752.GA4475@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120607223752.GA4475@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-06-08 at 00:37 +0200, Francois Romieu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
> > If LLTX is used, this means several cpus can execute this code at the
> > same time.
> > 
> > You need percpu stats, or use atomic primitives.
> 
> Would adding percpu stats not be frown upon ?
> 

I have no idea how many l2tp_eth devices are setup at once in typical
conf.

> As atomic will defeat the 64 bits stats on 32 bits, I should probably stick
> to plain bh disabling lock.
> 

Not sure what you mean by "atomic will defeat the 64 bits stats on 32
bits", since you also need atomic for "32 bits stats" or "64 bits stats
on 64 bit arches"

I personally would just use "unsigned long". If people want 64bit stats
for their l2tp_eth, they certainly can use a 64bit host.
