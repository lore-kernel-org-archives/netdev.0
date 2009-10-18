From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Question about IPV6 forwarding and proxy_ndp
Date: Sun, 18 Oct 2009 00:37:55 -0700
Message-ID: <55a4f86e0910180037vb40b588qb02a6438a57f9875@mail.gmail.com>
References: <55a4f86e0910180030s52484bffs4ca42eb1ff4d5131@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Networking <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:36502 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbZJRHhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 03:37:52 -0400
Received: by fxm18 with SMTP id 18so3900946fxm.37
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 00:37:55 -0700 (PDT)
In-Reply-To: <55a4f86e0910180030s52484bffs4ca42eb1ff4d5131@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a quick follow up.

The current logic for when to do proxy ndp seems to be:

network_device_is_forwarding && (global_proxy_ndp_is_on ||
network_device_is configured_for_proxy_ndp)

Maybe this should be:

(network_device_is_forwarding && global_proxy_ndp_is_on) ||
network_device_is configured_for_proxy_ndp

After all, if the admin has explicitly set proxy ndp on this specific
device, then maybe he knows best?

Alternatively it could also just be:

global_proxy_ndp_is_on || network_device_is configured_for_proxy_ndp

and not bother with checking forwarding at all.


[It should be pointed out that ipv6/conf/all/forwarding is a very
different beast than ipv6/conf/<device>/forwarding, the first globally
turns on ipv6 forwarding, the second switches a device between 'I am a
host' and 'I am a router' modes of operation]
