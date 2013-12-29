From: Yasushi Asano <yazzep@gmail.com>
Subject: Re: [PATCH 1/1] ipv6 addrconf:fix preferred lifetime state-changing behavior while valid_lft is infinity
Date: Sun, 29 Dec 2013 21:04:27 +0900
Message-ID: <80E18547-1B36-4C8C-897F-601013A6E43C@gmail.com>
References: <1386843347-2725-1-git-send-email-yazzep@gmail.com> <1386956028-3463-1-git-send-email-yazzep@gmail.com> <20131214091917.GB23563@order.stressinduktion.org>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:47355 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724Ab3L2MEa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 07:04:30 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so8927488pab.9
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 04:04:30 -0800 (PST)
Received: from [192.168.10.68] (ntaich242095.aich.nt.ftth.ppp.infoweb.ne.jp. [125.3.97.95])
        by mx.google.com with ESMTPSA id oc9sm74550962pbb.10.2013.12.29.04.04.28
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Dec 2013 04:04:28 -0800 (PST)
In-Reply-To: <20131214091917.GB23563@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> Ditto, I do think we cannot remove this flag unconditionally.
> 
> Actually, I don't think it is the correct way to remove the IFA_F_PERMANENT
> here at all. We break the interaction with prefix routes and won't remove them
> at the time of address deletion any more. This is definitely a no-go, sorry.
> 
> The prefix was added by hand and should get removed immediately if a user
> removes the address (well actually it is an error we set up a prefix route in
> the first place, but it is how things are now).
> 
> IMHO, the changes need to be made in addrconf_verify so that the route does
> get marked as deprecated. Please check the places where we mark an interface
> address as deprecated.
> 
> Thanks,
> 
>  Hannes

Sorry about not getting back to you sooner.
I have been thinking and testing about the correct way of fixing the problem.
I understand it's not the correct way to remove the IFA_F_PERMANENT.
I agree with you that the changes need to be made in addrconf_verify.
and I think changes also need to be made in inet6_fill_ifaddr
so that the "preferred" is set INFINITY_LIFE_TIME unconditionally while ifa->flags is IFA_F_PERMANENT.
It means, "preferred" is set to INFINITY_LIFE_TIME when I set preferred_lft a value not zero or infinity, while valid_lft is infinity(0xffffffff)
I sent a new patch to netdev-ml today.
Your kind consideration of this matter would be sincerely appreciated.

Yasushi