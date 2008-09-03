From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Wed, 03 Sep 2008 08:39:18 +0300
Message-ID: <48BE2306.8070101@iki.fi>
References: <E1KakUR-0001xp-00@gondolin.me.apana.org.au> <48BE1B95.8000508@iki.fi> <20080903052329.GA8134@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:8712 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108AbYICFjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 01:39:12 -0400
Received: by ey-out-2122.google.com with SMTP id 6so1327959eyi.37
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2008 22:39:10 -0700 (PDT)
In-Reply-To: <20080903052329.GA8134@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Wed, Sep 03, 2008 at 08:07:33AM +0300, Timo Ter=E4s wrote:
>> But then caller of xfrm_state_walk() can be still holding a
>> reference to the entry and dumping of the whole chain fails,
>> because the entry is no longer part of the chain when dumping
>> continues later.
>>
>> The walking coding skips entries which are dead so the
>> entry is only kept temporarily to make a full traversal of
>> the list.
>=20
> Ah I see your point now.
>=20
> Actually another thing we should do is to postpone the unlinking
> into the GC process.  This doesn't really need to be immediate.

Yes, might be a good idea.

> And here is a patch to fix a couple of changes in user-behaviour.
>=20
> ipsec: Restore larval states and socket policies in dump
>=20
> The commit commit 4c563f7669c10a12354b72b518c2287ffc6ebfb3 ("[XFRM]:
> Speed up xfrm_policy and xfrm_state walking") inadvertently removed
> larval states and socket policies from netlink dumps.  This patch
> restores them.

Oh, I seemed to have missed that there was multiple places where
the list insertion happens. Would it make sense to make function
for inserting the entries in the lists?

- Timo
