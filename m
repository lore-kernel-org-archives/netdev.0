From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 3 Mar 2015 14:44:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAF3C48@AcuExch.aculab.com>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
 <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
 <54F5C51F.5020906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Daniel Borkmann' <daniel@iogearbox.net>,
	'Florian Westphal' <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:58279 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755668AbbCCOpv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:45:51 -0500
In-Reply-To: <54F5C51F.5020906@iogearbox.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann 
> On 03/03/2015 02:50 PM, David Laight wrote:
> ...
> >> +	BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
> >> +
> >
> > What about using something based on:
> > #define GET_CB(skb, type) ((type *)((skb)->cb + (sizeof (char[(sizeof (type) <= sizeof (skb->cb)) ? 1 : -1] - 1)))
> > to access skb->sb?
> 
> That would require to change all skb->cb[] call-sites everywhere.

Well, only once for each type.
As opposed to adding an open coded check at all of them.
Clearly if the majority of sites have been changed then the 'cb' field member can
be renamed to pick up the stragglers. I wouldn't suggest doing that immediately.

> Besides that, this macro is also buggy, my totally untrained lisp-eye tells
> me that you got your brackets wrong.

I did say 'based on'....
It is also probably possible to get the name of the type into the error message.
Although that might require it always be a 'struct'.

	David
