From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel paging request at 00000000d8be176d
Date: Fri, 06 Jul 2012 08:53:07 +0200
Message-ID: <1341557587.3265.107.camel@edumazet-glaptop>
References: <20120706055859.GA27693@localhost>
	 <1341555227.3265.54.camel@edumazet-glaptop>
	 <1341556907.3265.93.camel@edumazet-glaptop>
	 <20120705.234413.823095842284954048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:41321 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607Ab2GFGxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 02:53:12 -0400
Received: by eaak11 with SMTP id k11so3489513eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 23:53:11 -0700 (PDT)
In-Reply-To: <20120705.234413.823095842284954048.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 23:44 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 06 Jul 2012 08:41:47 +0200
> 
> > David, what do you think if I submit a patch using following accessor ?
> > 
> > /* get a rt6_info given a dst_entry pointer */
> > static inline struct rt6_info *dst_rt6_info(struct dst_entry *dst)
> > {
> > 	return (struct rt6_info *)dst;
> > }
> 
> I'd rather we simply not use address-of pointers in our interfaces
> like we do now in some spots.
> 
> 99 times out of 100 it's a case where PTR_ERR() would do.
> 
> I spent a lot of time moving both ipv4 and ipv6 in this direction,
> we're almost there, and should simply finish off the remaining
> cases.

Not sure what you mean. I dont use address of pointer.

I suggested a type safe thing

ie change all

struct rt6_info *rt = (struct rt6_info *)dst;

by

struct rt6_info *rt = dst_rt6_info(dst);


same generated code, but we have compiler checks instead of a raw cast.
