From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch iproute2 1/2] add support for extended ifa_flags
Date: Sat, 28 Dec 2013 11:21:47 -0800
Message-ID: <20131228112147.67756b9c@nehalam.linuxnetplumber.net>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
	<1386319587-2149-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:45813 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab3L1TVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 14:21:52 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so10263392pbc.12
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 11:21:52 -0800 (PST)
In-Reply-To: <1386319587-2149-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was about to apply this but found something while reviewing.

On Fri,  6 Dec 2013 09:46:26 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> +	req.ifa.ifa_flags = ifa_flags & 0xff;
> +	addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);

I don't like the mystery mask (0xff) here. I think this was to mask
off private flags. Perhaps a manifest constant should be added to if.h
lie IFA_F_RDONLY_MASK??

Plus from an API point of view, hard coding a value (even in #define)
seems like a problem when future values get added.
