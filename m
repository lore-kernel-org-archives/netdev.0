From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation with hrtimers
Date: Thu, 5 Feb 2009 01:24:05 +0200
Message-ID: <200902050124.05969.denys@visp.net.lb>
References: <200902021926.17768.denys@visp.net.lb> <200902050026.46603.denys@visp.net.lb> <20090204224929.GB2828@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:47063 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbZBDXZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 18:25:13 -0500
In-Reply-To: <20090204224929.GB2828@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 05 February 2009 00:49:29 Jarek Poplawski wrote:
> On Thu, Feb 05, 2009 at 12:26:46AM +0200, Denys Fedoryschenko wrote:
> ...
>
> > Maybe we can put note in documentation or even htb help output, that user
> > can increase precision with hrtimers enabled, by setting HZ variable?
>
> Hmm... I rather meant using burst and cburst params. But hrtimers are
> very hardware dependent, so it's hard to advise anything.
>
> Jarek P.

By default burst/cburst calculated depends on timer resolution, as i 
understood, by taking 4th parameter of /proc/net/psched, which as i 
understood - precision of hrtimer .

With hrtimers it is nanosecond resolution, precision is very high, but 
overhead too high too. And as i understand, maybe it can be problem, that htb 
still uses HZ variable in some cases like:
	return q->now + 2 * PSCHED_TICKS_PER_SEC / HZ;


