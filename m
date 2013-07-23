From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Question about default route handling/lookup in a custom table
Date: Tue, 23 Jul 2013 15:47:15 +0200
Message-ID: <20130723134715.GC32523@order.stressinduktion.org>
References: <CAKP4w2Q_5V=2CdyUpeXrHg=dTv1LNynp87gy6nrQYWYyBuA39A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: JP Abgrall <jpa@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:34299 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479Ab3GWNrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 09:47:16 -0400
Content-Disposition: inline
In-Reply-To: <CAKP4w2Q_5V=2CdyUpeXrHg=dTv1LNynp87gy6nrQYWYyBuA39A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Mon, Jul 22, 2013 at 06:20:18PM -0700, JP Abgrall wrote:
> The following sequence fails when adding the default route:
> (wlan0 is up, nothing is trying to manage,...)
> 
>        ip route flush dev wlan0 table all
>        ip route flush table 60
>        ip route add 1.1.1.1/32 dev wlan0 table 60

I am not sure but would have expected that you needed to add a rule e.g. ip
rule add oif wlan0 table 60 to successfully match the next route insertion.

>        ip route add default via 1.1.1.1 dev wlan0 table 60

Otherwise another rule lookup could alter the fib_lookup in such a way that the
nexthop is not resolveable and the routing table in its entirty could have
unresolveable holes.

I did not check the code, this is just my intuition.

Greetings,

  Hannes
