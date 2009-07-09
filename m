From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Thu, 09 Jul 2009 22:34:17 +0200
Message-ID: <4A565449.4050403@itcare.pl>
References: <20090702060011.GB4954@ff.dom.local> <4A4FF34E.7080001@itcare.pl> <4A4FF40B.5090003@itcare.pl> <20090705162003.GA19477@ami.dom.local> <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local> <4A513D0D.5070204@itcare.pl> <20090706090207.GB3065@ami.dom.local> <4A53D28D.8060409@itcare.pl> <20090707235029.GA8207@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:38879 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754030AbZGIUeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 16:34:21 -0400
In-Reply-To: <20090707235029.GA8207@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski pisze:
> On Wed, Jul 08, 2009 at 12:56:13AM +0200, Pawe=B3 Staszewski wrote:
>  =20
>> Jarek Poplawski pisze:
>>    =20
> ...
>  =20
>>> ---> (synchronize take 9; apply on top of the 2.6.29.x with the las=
t
>>>   	all-in-one patch, or net-2.6)
>>>
>>>  =20
>>>      =20
>> Applied to 2.6.29.5 preempt/no-preempt and tested: - with preempt i =
make =20
>> only one test with sync_pages =3D 256 to check that is working :)
>>
>> So here are some tests for different sync_pages size.
>>    =20
> ...
>  =20
>> So i see in prev tests i make something wrong in time counting
>> So i modify test script and make tests again:
>>
>> echo 64 > /sys/module/fib_trie/parameters/sync_pages
>> Total size reach max in 13 sec
>>
>> echo 128 > /sys/module/fib_trie/parameters/sync_pages
>> Total size reach max in 10 sec
>>
>> echo 256 > /sys/module/fib_trie/parameters/sync_pages
>> Total size reach max in 10 sec
>>
>> And for sync_paqges >256 time for propagating routes is always 10sec=
=2E
>>    =20
>
> So this means sync_pages 128 or 256 is reasonable.
>
>  =20
>> Also today i have many messages in dmesg like this:
>> Fix inflate_threshold_root. Now=3D25 size=3D11 bits
>> :)
>>    =20
>
>  =20
> This is something new and a bit surprising to me: the same threshold
> in previous tests didn't generate this? Do you mean more than:=20
> "Fix inflate_threshold_root. Now=3D15 size=3D11 bits" before?
>
>  =20
Yes. Sorry for that - this info was not all the day but only 5 minutes=20
when i was making tests.
This info was reported only when all iBGP peers was down/up fast.

>> And after tune :
>> /sys/module/fib_trie/parameters/inflate_threshold_root
>> no more info :)
>>    =20
>
> With what value?
>
>  =20
When i set 35 as inflate_threshold_root there was no info even if all=20
iBGP peers was down/up.

But i start to search when i have info about "Fix inflate_threshold_roo=
t"
And i see that the best is set this to 20 for me i have no info then in=
=20
normal router operation / without down/up bgp peers many times in short=
=20
time.

> Pawel, let's say that current defaults are:
> inflate_threshold_root 25 sync_pages 256
>
> I'd like you to try to check if e.g.:
> inflate_threshold_root 15 sync_pages 256
> can give you any visible or subjective difference worth tweaking it
> at all? (These stats from the next messages don't show this enough.)
> You don't need to hurry with this...
>
>  =20
I will try to make more accurate tests in weekend.

Regards
Pawe=B3 Staszewski
> Thanks,
> Jarek P.
>
>
>  =20

