From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/7] xfrm: remove policy lock when accessing policy->walk.dead
Date: Tue, 30 Mar 2010 18:36:37 +0300
Message-ID: <4BB21A85.2030203@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi> <1269871964-5412-2-git-send-email-timo.teras@iki.fi> <20100329144339.GA26214@gondor.apana.org.au> <4BB1842B.9010704@iki.fi> <20100330115351.GA5731@gondor.apana.org.au> <4BB1E8B1.4030604@iki.fi> <4BB2044B.5080704@iki.fi> <20100330142914.GA6840@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:55554 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab0C3Pgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 11:36:39 -0400
Received: by ewy20 with SMTP id 20so1381240ewy.1
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 08:36:38 -0700 (PDT)
In-Reply-To: <20100330142914.GA6840@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Mar 30, 2010 at 05:01:47PM +0300, Timo Ter=E4s wrote:
>> Since the exported function xfrm_policy_byid() can result in deletio=
n
>> of socket policy, it's safer to leave this change in. This is can be
>> even triggered via xfrm_user since it does not check 'dir' for the
>> policy expired message it handles. Any custom module could do simila=
r
>> harm.
>=20
> That's a bug.  Socket policies should never be deleted by anyone
> other than the socket owner through a setsockopt.

Ok. I can remove the change to xfrm_sk_policy_insert() if you want.

I only added it because it's non-trivial to figure out if there's
any code path that could race. It's a great help for reader of the
code to see that it's correct even if it's not strictly needed.
My initial feeling is that the change produces better code as the
original 'old_pol' does not have to get stored and restored.

I'm fine either way.

I will also include a patch to fix the missing 'dir' check in
xfrm_user.
