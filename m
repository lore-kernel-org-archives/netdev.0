From: "Glenn Griffin" <ggriffin.kernel@gmail.com>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 10:29:28 -0800
Message-ID: <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
	 <20080205155558.GA23145@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:26271 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbYBES3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 13:29:32 -0500
Received: by fk-out-0910.google.com with SMTP id z23so2392939fkz.5
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2008 10:29:28 -0800 (PST)
In-Reply-To: <20080205155558.GA23145@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Syncookies are discouraged these days. They disable too many
> valuable TCP features (window scaling, SACK) and even without them
> the kernel is usually strong enough to defend against syn floods
> and systems have much more memory than they used to be.
>
> So I don't think it makes much sense to add more code to it, sorry.

As you say the kernel is usually strong enough to defend against syn flood
attacks, but what about the situations where it isn't?  As valuable as the TCP
features are I would give them up if it means I'm able to connect to my sshd
port when I otherwise would be unable to.  While increased synq sizes, better
dropping algorithms, and minisocks are a great way to mitigate the attacks and
in most cases are enough, there are situations where syncookies are nice.

Regardless, I would say as long as ipv4 has syncookie support it will
accurately be viewed as a deficiency of ipv6 if it lacks support.  So perhaps
the discussion should be we whether all the other defenses are enough to
warrant the removal of syncookie support from ipv4.  That topic may bring in
more opinions.

> Besides you should really move it to the ipv6 module, right now the code
> would be always compiled in even for ipv4 only kernels.

That is correct.  I will gladly move it into it's own section within net/ipv6/.
Do you have any problem using the same CONFIG and sysctl variables as the ipv4
implementation?

Thanks

--Glenn
