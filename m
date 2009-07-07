From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Wed, 8 Jul 2009 01:50:29 +0200
Message-ID: <20090707235029.GA8207@ami.dom.local>
References: <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local> <4A513D0D.5070204@itcare.pl> <20090706090207.GB3065@ami.dom.local> <4A53D28D.8060409@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:45195 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbZGGXuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 19:50:46 -0400
Received: by bwz25 with SMTP id 25so2441591bwz.37
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2009 16:50:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A53D28D.8060409@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2009 at 12:56:13AM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
=2E..
>> ---> (synchronize take 9; apply on top of the 2.6.29.x with the last
>>   	all-in-one patch, or net-2.6)
>>
>>  =20
>
> Applied to 2.6.29.5 preempt/no-preempt and tested: - with preempt i m=
ake =20
> only one test with sync_pages =3D 256 to check that is working :)
>
> So here are some tests for different sync_pages size.
=2E..
> So i see in prev tests i make something wrong in time counting
> So i modify test script and make tests again:
>
> echo 64 > /sys/module/fib_trie/parameters/sync_pages
> Total size reach max in 13 sec
>
> echo 128 > /sys/module/fib_trie/parameters/sync_pages
> Total size reach max in 10 sec
>
> echo 256 > /sys/module/fib_trie/parameters/sync_pages
> Total size reach max in 10 sec
>
> And for sync_paqges >256 time for propagating routes is always 10sec.

So this means sync_pages 128 or 256 is reasonable.

>
> Also today i have many messages in dmesg like this:
> Fix inflate_threshold_root. Now=3D25 size=3D11 bits
> :)

This is something new and a bit surprising to me: the same threshold
in previous tests didn't generate this? Do you mean more than:=20
"Fix inflate_threshold_root. Now=3D15 size=3D11 bits" before?

> And after tune :
> /sys/module/fib_trie/parameters/inflate_threshold_root
> no more info :)

With what value?

Pawel, let's say that current defaults are:
inflate_threshold_root 25 sync_pages 256

I'd like you to try to check if e.g.:
inflate_threshold_root 15 sync_pages 256
can give you any visible or subjective difference worth tweaking it
at all? (These stats from the next messages don't show this enough.)
You don't need to hurry with this...

Thanks,
Jarek P.
