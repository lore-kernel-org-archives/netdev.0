From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Sat, 8 Mar 2014 09:34:26 +0100
Message-ID: <20140308083426.GC5493@order.stressinduktion.org>
References: <20140306095054.EEC5EE6E04@unicorn.suse.cz> <20140306.142425.1675660751208500651.davem@davemloft.net> <20140306200658.GA32699@unicorn.suse.cz> <20140307.155258.463380957582451300.davem@davemloft.net> <20140307213842.GA17583@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49759 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbaCHIe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 03:34:28 -0500
Content-Disposition: inline
In-Reply-To: <20140307213842.GA17583@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2014 at 10:38:42PM +0100, Michal Kubecek wrote:
> Today I also realized another problem with current code: if we already
> have inetpeer with metrics and use "ip route change" with metrics, e.g.
> 
>   ip route add fec0::1 dev eth0 rto_min 1000
>   ip route change fec0::1 dev eth0 hoplimit 10

Hmm, those routes seem to not have RTF_NONEXTHOP (no gateway). I am
a bit concerend that rt6_select returns !RTF_CACHE node and we do end
up doing the inetpeer lookup on every lookup on them. Maybe you have
already investigated?

Thanks,

  Hannes
