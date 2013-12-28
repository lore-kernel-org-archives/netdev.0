From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/2] add support for extended ifa_flags
Date: Sat, 28 Dec 2013 22:20:18 +0100
Message-ID: <20131228212018.GA2447@minipsycho>
References: <1386319522-2102-1-git-send-email-jiri@resnulli.us>
 <1386319587-2149-1-git-send-email-jiri@resnulli.us>
 <20131228112147.67756b9c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, hannes@stressinduktion.org,
	vyasevich@gmail.com, dcbw@redhat.com, David.Laight@ACULAB.COM
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:39170 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab3L1VUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 16:20:23 -0500
Received: by mail-ea0-f172.google.com with SMTP id q10so3864123ead.17
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 13:20:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131228112147.67756b9c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 28, 2013 at 08:21:47PM CET, stephen@networkplumber.org wrote:
>Was about to apply this but found something while reviewing.
>
>On Fri,  6 Dec 2013 09:46:26 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> +	req.ifa.ifa_flags = ifa_flags & 0xff;
>> +	addattr32(&req.n, sizeof(req), IFA_FLAGS, ifa_flags);
>
>I don't like the mystery mask (0xff) here. I think this was to mask
>off private flags. Perhaps a manifest constant should be added to if.h
>lie IFA_F_RDONLY_MASK??

Hmm.. I wanted to emhasize that only 1 byte of value is taken.
But I think that simple "req.ifa.ifa_flags = ifa_flags" should be fine
here.

I will change this and repost.

Thanks!

>
>Plus from an API point of view, hard coding a value (even in #define)
>seems like a problem when future values get added.
>
