From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] ipvlan: fix addr hash list corruption
Date: Thu, 26 Mar 2015 09:45:54 +0100
Message-ID: <20150326094554.292d3699@griffin>
References: <20150324180628.278017fb@griffin>
	<CAF2d9jh+VozezamrEK_6vfTvY8LZSzw9n-bJjSX3G11RXmfz3w@mail.gmail.com>
	<20150325095851.1d8d1622@griffin>
	<20150325.114622.1915164845375005128.davem@davemloft.net>
	<CAF2d9jh5WaNYsMxp29GY3LqM08jjVPwLd1BQ1HLFKMsKFda6zQ@mail.gmail.com>
	<20150326002154.3e179fec@griffin>
	<CAF2d9jj2cbDKXPnFUyVOJUVzrvb4CbK5ktbeW32N31xG0Hz63g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>, dcbw@redhat.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbbCZIqB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 04:46:01 -0400
In-Reply-To: <CAF2d9jj2cbDKXPnFUyVOJUVzrvb4CbK5ktbeW32N31xG0Hz63g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Mar 2015 19:15:55 -0700, Mahesh Bandewar wrote:
> I think you missed the point. Addition / deletion of addresses into
> the hash-table (always) happens in the control path while the cost of
> those decisions will be paid per packet in data-path; was the point I
> was trying to make.

I think you're trying to say "don't add addresses to the hash table
unless necessary". If so, we're not in argument here.

> > Basically, there are two (and only two) possible cases: 1. the
> > addresses should not be on the hash list when the interface is down,
> > and 2. there's no problem with the addresses being on the hash list
> > when the interface is down.
> >
> As I mentioned earlier in my previous reply; it does work and
> functionally same. However the decision to drop the packet will happen
> later in RX path when the interface is down.

Yes.

> The root cause of the issue is addition / deletion of duplicate
> entries into the hash-table and I think fixing it is better thing
> which is exactly what the fix I proposed do.

Except that it fixes only part of the bug, see below.

> Your first patch though
> fixes the symptoms, I believe it's not the correct fix

Could you please elaborate why it's not the correct fix? It ensures
that the addresses are on the hash list *iff* the interface is up. When
the interface is down, the addresses are not there. If it is up, they
are. My impression so far is this is exactly what you want. I don't see
why the patch is not correct.

> while your
> second patch does fix it but eliminates this optimization that is in
> place.

Agreed.

> Hence I suggested that  "though correct, I would not *prefer*
> it" for the said reasons. If the order in which user pushes config
> alters the hash-table entries, then that's unintended and need to be
> fixed.

Agreed.

> > ip l s ipvlan0 down
> > ip a a 1.2.3.4/24 dev ipvlan0
> > -> at this point, 1.2.3.4 is on the hash list
> >
> unintended behavior and need to be fixed.

Which is exactly what my first patch does. Could you please look at it
again, keeping also this scenario in mind?

Thanks,

 Jiri

-- 
Jiri Benc
