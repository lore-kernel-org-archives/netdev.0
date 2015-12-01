From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Increasing skb->mark size
Date: Tue, 01 Dec 2015 11:13:29 -0800
Message-ID: <87610ivv6u.fsf@tassilo.jf.intel.com>
References: <1448397144.14854.27.camel@mattb-dl>
	<CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	davem@davemloft.net
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52355 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbbLATNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 14:13:31 -0500
In-Reply-To: <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
	(Lorenzo Colitti's message of "Sun, 29 Nov 2015 17:37:11 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo Colitti <lorenzo@google.com> writes:

> On Wed, Nov 25, 2015 at 5:32 AM, Matt Bennett
> <Matt.Bennett@alliedtelesis.co.nz> wrote:
>> I'm emailing this list for feedback on the feasibility of increasing
>> skb->mark or adding a new field for marking. Perhaps this extension
>> could be done under a new CONFIG option.
>
> 64-bit marks (both skb->mark and sk->sk_mark) would be useful for
> hosts doing complex policy routing as well. Current Android releases
> use 20 of the 32 bits. If the mark were 64 bits, we could put the UID
> in it, and stop using ip rules to implement per-UID routing.

This would be be great. I've recently ran into some issues with
the overhead of the Android firewall setup.

So basically you need 4 extra bytes in sk_buff. How about:

- shrinking skb->priority to 2 byte
- skb_iff is either skb->dev->iff or 0. so it could be replaced with a
single bit flag for the 0 case.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
