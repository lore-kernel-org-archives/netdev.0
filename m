From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: conntrack: remove the central spinlock
Date: Thu, 9 May 2013 07:46:52 +0000 (UTC)
Message-ID: <kmfk9c$7g6$1@ger.gmane.org>
References: <1368068665.13473.81.camel@edumazet-glaptop>
 <kmfd2s$e2m$1@ger.gmane.org> <1368079301.13473.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59276 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab3EIHrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 May 2013 03:47:10 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UaLZE-0001jS-FO
	for netdev@vger.kernel.org; Thu, 09 May 2013 09:47:08 +0200
Received: from 116.53.101.117 ([116.53.101.117])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 09:47:08 +0200
Received: from xiyou.wangcong by 116.53.101.117 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 09 May 2013 09:47:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 May 2013 at 06:01 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-05-09 at 05:43 +0000, Cong Wang wrote:
>> On Thu, 09 May 2013 at 03:04 GMT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >  
>> > +#if 0
>> > +	for (i = 0; i < ARRAY_SIZE(nf_conntrack_locks); i++)
>> > +		arch_spin_lock_init(&nf_conntrack_locks[i]);
>> > +#endif
>> > +
>> 
>> Is this intentional?
>
> What do you think ?
>
> Apparently arch_spin_lock_init() does not exist (but for ia64)
>

Either it is not expected to use arch_spin_lock directly, or it has to
provide a nop for non-IA64.
