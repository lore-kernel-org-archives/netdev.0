From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 22:59:43 +0300
Message-ID: <200808282259.43550.denys@visp.net.lb>
References: <21915755.1327801219904892242.JavaMail.root@ouachita> <200808281948.52608.denys@visp.net.lb> <20080828.123645.78561286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, jmalicki@metacarta.com, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:55239 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412AbYH1UBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 16:01:09 -0400
In-Reply-To: <20080828.123645.78561286.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008, David Miller wrote:
> From: Denys Fedoryshchenko <denys@visp.net.lb>
> Date: Thu, 28 Aug 2008 19:48:52 +0300
>
> > So there is few good solutions available (IMHO):
> > 1)Introduce some SO_REALTIMESTAMP (anyway even SO_TIMESTAMP not defined
> > in any standard) for banks and ntp folks, who need them. And even give
> > them timespec instead timeval, so they will be even more happy with
> > resolution. 2)Provide sysctl,kernel boot, or even "build time" option for
> > "banks" to have high resolution(and expensive) SO_TIMESTAMP.
>
> The performance hit hurts, but changing the default to lower
> resolution after it having been high resolution for 10+ years
> is a regression and something we really can't do.
Agree. Then maybe to add way to choose, because choice is high resolution vs 
performance. For example Intel dynamically throttling interrupts on e1000*, 
and it saves me in this case. They leave also option for users who wants low 
latency/high troughput.
So maybe there must be a way for specific functions who uses get(ns)timeofday  
to use specific timers (cheap and less precise), by option. Or to limit 
amount of calls to timer by them.
