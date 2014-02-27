From: Nikolay Aleksandrov <naleksan@redhat.com>
Subject: Re: Possible fix
Date: Thu, 27 Feb 2014 12:05:05 -0500 (EST)
Message-ID: <1131077681.5664574.1393520705411.JavaMail.zimbra@redhat.com>
References: <20140227151954.GA30946@redhat.com> <1393517857-11842-1-git-send-email-nikolay@redhat.com> <530F66BE.4010401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Fan Du <fan.du@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:54948 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbaB0RFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 12:05:11 -0500
In-Reply-To: <530F66BE.4010401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
From: "Nikolay Aleksandrov" <nikolay@redhat.com>
To: netdev@vger.kernel.org
Cc: "Nikolay Aleksandrov" <nikolay@redhat.com>, "Dave Jones" <davej@redhat.com>, "Steffen Klassert" <steffen.klassert@secunet.com>, "Fan Du" <fan.du@windriver.com>, "David S. Miller" <davem@davemloft.net>
Sent: Thursday, February 27, 2014 5:24:30 PM
Subject: Re: Possible fix

On 02/27/2014 05:17 PM, Nikolay Aleksandrov wrote:
> Hi,
> I'm not familiar with the code but happened to see the bug, could you
> try the following patch, I believe it should fix the issue.
> 
> Thanks,
>  Nik
> 
> [PATCH net] net: af_key: fix sleeping under rcu
> 
> There's a kmalloc with GFP_KERNEL in a helper
> (pfkey_sadb2xfrm_user_sec_ctx) used in pfkey_compile_policy which is
> called under rcu_read_lock. Adjust pfkey_sadb2xfrm_user_sec_ctx to have
> a gfp argument and adjust the users.
> 
> CC: Dave Jones <davej@redhat.com>
> CC: Steffen Klassert <steffen.klassert@secunet.com>
> CC: Fan Du <fan.du@windriver.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> I'm not familiar with this code, but just happen to see the bug. I believe
> this patch should take care of it.
> I've left the already very long lines.
> 
>Actually there isn't a check if uctx is NULL upon return which can happen.
>This is only a test patch and that check should be added as well.
>
>Nik
Had a quick look and I think that should be okay, there isn't a need to check.

Sent from my phone
