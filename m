From: Billy Shuman <wshuman3@gmail.com>
Subject: Re: [bisected] no traffic on ssl vpn with 3.19rc1 - 3.19rc3
Date: Thu, 22 Jan 2015 08:43:44 -0500
Message-ID: <CAHQNsod=pom3jeL1HvC-MV20xkfVrPZ-oKC3hNuKYZgcacHuXg@mail.gmail.com>
References: <CAHQNsofShzPsOgtEZw1HHpOvJW5fo+MQtO8Ys6Uqsc+SN_LaLA@mail.gmail.com>
	<20150108205745.GA13460@gondor.apana.org.au>
	<CAHQNsodDfSOgmxoSk6++OQXfJ7SHo+M=bmojfUqN1KFJHtfemg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:35275 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbbAVNnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 08:43:45 -0500
Received: by mail-yh0-f53.google.com with SMTP id v1so681002yhn.12
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 05:43:44 -0800 (PST)
In-Reply-To: <CAHQNsodDfSOgmxoSk6++OQXfJ7SHo+M=bmojfUqN1KFJHtfemg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch from net-next ended up resolving my issue:

>From 957f094f221f81e457133b1f4c4d95ffa49ff731 Mon Sep 17 00:00:00 2001
From: Alex Gartrell <agartrell@fb.com>
Date: Thu, 25 Dec 2014 23:22:49 -0800
Subject: tun: return proper error code from tun_do_read

Instead of -1 with EAGAIN, read on a O_NONBLOCK tun fd will return 0.  This
fixes this by properly returning the error code from __skb_recv_datagram.

On Fri, Jan 9, 2015 at 8:13 AM, Billy Shuman <wshuman3@gmail.com> wrote:
> Changeset 8c847d254146d32c86574a1b16923ff91bb784dd did not resolve the
> issue for me.
>
> Should I target any other specific changesets?
>
> Thanks,
> Billy
> William Shuman
> Tel: 260-316-9300
> Email: wshuman3@gmail.com
>
>
> On Thu, Jan 8, 2015 at 3:57 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> Billy Shuman <wshuman3@gmail.com> wrote:
>>>
>>> Since 3.19rc1 I get 100% packet loss through SSL vpn.  I bisected with
>>> the following result:
>>>
>>> 0b46d0ee9c240c7430a47e9b0365674d4a04522 is the first bad commit
>>> commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
>>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>>> Date:   Fri Nov 7 21:22:23 2014 +0800
>>>
>>>    tun: Use iovec iterators
>>>
>>>    This patch removes the use of skb_copy_datagram_const_iovec in
>>>    favour of the iovec iterator-based skb_copy_datagram_iter.
>>>
>>>
>>> https://bugzilla.kernel.org/show_bug.cgi?id=90901
>>
>> This changeset is known to be buggy.  However it was fixed ages
>> ago by changeset 8c847d254146d32c86574a1b16923ff91bb784dd.
>>
>> So please test that changeset to see if it works for you.  If it
>> does, then please do your bisection between that and the current
>> top of tree.
>>
>> Thanks,
>> --
>> Email: Herbert Xu <herbert@gondor.apana.org.au>
>> Home Page: http://gondor.apana.org.au/~herbert/
>> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
