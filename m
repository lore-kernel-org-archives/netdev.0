From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on
 opening /dev/ppp
Date: Mon, 20 Jun 2016 08:47:12 +0200
Message-ID: <57679170.5030406@nod.at>
References: <44A9BDB8-754B-4402-BD09-6381229C07C5@tuna.tsinghua.edu.cn>
 <87wplkihbp.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Guillaume Nault <g.nault@alphalink.fr>,
	Miao Wang <shankerwangmiao@gmail.com>
To: Andi Kleen <andi@firstfloor.org>,
	Shanker Wang <shanker@tuna.tsinghua.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:44723 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752192AbcFTGsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2016 02:48:08 -0400
In-Reply-To: <87wplkihbp.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.06.2016 um 07:02 schrieb Andi Kleen:
> Shanker Wang <shanker@tuna.tsinghua.edu.cn> writes:
> 
>> This patch removes the check for CAP_NET_ADMIN in the initial namespace
>> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the user
>> namespace the net namespace was created so that /dev/ppp cat get opened
>> in a unprivileged container.
> 
> Seems dangerous. From a quick look at the PPP ioctl there is no limit
> how many PPP devices this can create. So a container having access to
> this would be able to fill all kernel memory. Probably needs more
> auditing and hardening first.
> 
> In general there seems to be a lot of attack surface for root
> in PPP.

You are right.
Shanker Wang, I had also another at the open function, it is more complicated
than I thought. Please see how ppp_unattached_ioctl() is called.
Before we give containers access to it the use of nsproxy has to be removed.
Not sure how easy this will be, especially since you cannot break existing users.

Thanks,
//richard
