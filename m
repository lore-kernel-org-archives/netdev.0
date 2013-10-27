From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Sun, 27 Oct 2013 17:48:35 +0100
Message-ID: <20131027164835.GB4714@order.stressinduktion.org>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us> <CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com> <20131027132941.GA1443@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Vladislav Yasevich <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60302 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030Ab3J0Qsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 12:48:37 -0400
Content-Disposition: inline
In-Reply-To: <20131027132941.GA1443@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri!

On Sun, Oct 27, 2013 at 02:29:41PM +0100, Jiri Pirko wrote:
> The idea is to provide possibility to do address configuration not in
> kernel but rather in userspace (as it is done for example in NetworkManager)
> 
> Maybe I'm missing something, but why is it problem to have the
> possibility to set lifetime even for temporary prefix?

There is no problem setting the lifetime for a temporary prefix (in
contrary, it needs one) but the code paths designed for IFA_F_TEMPORARY
may not fiddle with it. This needs to be checked.

In this constellation addrconf_verify does not refresh the privacy
address when its preferred lifetime is expired, if you create the
address by only passing IFA_F_TEMPORARY to rtm_newaddr (as Vlad pointed
out). E.g. NetworkManager has to take care about that, then.

A temporary address is also bound to a non-privacy public address so
it's lifetime is determined by its lifetime (e.g. if you switch the
network and don't receive on-link information for that prefix any
more). NetworkManager would have to take care about that, too. It is
just a question of what NetworkManager wants to handle itself or lets
the kernel handle for it.

Greetings,

  Hannes
