From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] ipip: Add room for user-specified custom header
Date: Thu, 15 Aug 2013 08:11:25 +0200
Message-ID: <CAKfDRXggENSekGMKhr1bZfdhOagM6P0BuCYBX0euHccMUHohpQ@mail.gmail.com>
References: <1376296778-1983-1-git-send-email-kristian.evensen@gmail.com>
	<20130814.133929.975837205960955245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38009 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab3HOGL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 02:11:26 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so434386pdj.32
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 23:11:26 -0700 (PDT)
In-Reply-To: <20130814.133929.975837205960955245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 10:39 PM, David Miller <davem@davemloft.net> wrote:
>
> Sorry I'm not even going to consider applying this until you post
> use-cases for this feature, because right now it just looks like a
> random way to facilitate some third party proprietary kernel module
> or similar.

Thank you for your feedback and I agree, one challenge with this patch
is that it easy facilitates proprietary code.

My use-case when creating this patch was to simplify the
implementation of IP-in-UDP tunneling. I initially started out by
cloning IP-in-IP and managing a set of UDP-sockets (for the incoming
packets), but it seemed like overkill for something so simple.
Especially since UDP source ports are used on something that does not
need to be UDP sockets. So instead I made space between the IP headers
for the UDP header, and the UDP header was inserted using an xtables
extension. I was planning to post the xtables-module at the same time,
but some other things came in the way. There are only a few features
missing, so it will be out soon. I am aware that all of this could be
implemented in the xtables-module directly, but the additional
memmove() required has an impact on performance on the devices I am
working with.

Another, and perhaps more interesting, use-case is to ease development
and prototyping of new transport protocols on slower devices (for
example typical consumer routers). In the research lab I belong to, we
are currently looking into new protocols designed for mobile broadband
networks. In order to have the largest possible selection of test
applications and to avoid modifying client devices, we use existing
applications (or applications using existing protocols) and tunnel the
traffic through tunnels using our protocol. The devices we have are
too slow for user-space tunneling and the links are all connected to
the public internet. The protocol logic and header insertion is kept
in a separate xtables-module. Using this approach has improved the
speed at which we are able to prototype for example new flow or
congestion control algorithms, and given us sufficient networking
performance.

What is the recommended way forward for getting this patch considered?
Shall I focus on finishing the xtables example-module, or abandon this
patch and implement IP in UDP as a new tunneling protocol in the
kernel?

(Sorry about sending two emails, it was too early in the morning and I
forgot to enable plain-text)

-Kristian
