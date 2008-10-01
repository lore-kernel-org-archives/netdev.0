From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH,RESEND] XFRM,IPv6: initialize ip6_dst_blackhole_ops.kmem_cachep
Date: Wed, 01 Oct 2008 14:59:32 +0200
Message-ID: <87myhozd1n.fsf@natisbad.org>
References: <87prmuvnmt.fsf@natisbad.org>
	<939d53060809250221p171eb282v4451721464bd35a1@mail.gmail.com>
	<873ajg1xa0.fsf@natisbad.org>
	<20081001.023831.45381902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ben.thery@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:46440 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752550AbYJANBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 09:01:17 -0400
In-Reply-To: <20081001.023831.45381902.davem@davemloft.net> (David Miller's
	message of "Wed, 01 Oct 2008 02:38:31 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller <davem@davemloft.net> writes:

> From: arno@natisbad.org (Arnaud Ebalard)
> Date: Wed, 01 Oct 2008 11:26:31 +0200
>
>> With the switch to a default value of 1 for xfrm_larval_drop in commit
>> 28faa979746b2352cd78a376bf9f52db953bda46 (ipsec: Make xfrm_larval_drop
>> default to 1), what seems to be a bug manage to surface on one of my
>> test box running today's net-next (*).
>> 
>> When xfrm_tmpl_resolve() returns -EAGAIN in __xfrm_lookup(), the caller
>> is returned -EREMOTE and is expected to install a blackhole route. For
>> IPv6, the call to dst_alloc(&ip6_dst_blackhole_ops) performed by
>> ip6_dst_blackhole() produces the error provided below, because
>> kmem_cachep attribute seems to be uninitialized. This does not happen
>> when xfrm_larval_drop is set to 0.
>> 
>> The patch below against today's net-next. Benjamin (in CC) reported on
>> the introduction of the bug (f2fc6a54585a1be6669613a31fbaba2ecbadcd36)
>> while adding network namespaces support to ipv6 routes.
>
> Applied to net-2.6, thanks Arnaud!

Can you queue it for -stable (2.6.26) too, if not already done?

a+
