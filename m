From: Toyo Abe <tabe@miraclelinux.com>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for linklocal
 is completed.
Date: Tue, 20 May 2008 21:35:05 +0900
Message-ID: <4832C579.2040800@miraclelinux.com>
References: <48324792.5070309@miraclelinux.com> <20080520.173353.128167700.yoshfuji@linux-ipv6.org> <4832C3CC.5070609@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:12440 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765900AbYETMfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 08:35:07 -0400
In-Reply-To: <4832C3CC.5070609@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for lack of explanation.

 > But then, many other test scenarios in TAHI test suite went to FAIL.=
=20
It was because
 > the tester node send RA with prefix option to the host right after i=
t=20
receives DAD NS
 > from the host, which is obviously in autoconfiguration process for=20
linklocal address.

And the tester node never accepts RS(es) from the host after sending th=
e=20
RA. The tester
node determine FAIL unless it doesn't receive DAD NS for corresponding=20
global address
from the host.

-toyo

Toyo Abe wrote:
> Yoshifuji-san,
>
> Thanks for your response.
>
> > Why don't we just ignore RA until DAD for link-local
> > address has been successfully completed?
> I was also thinking so. And I tried it at first.
> But then, many other test scenarios in TAHI test suite went to FAIL.=20
> It was because
> the tester node send RA with prefix option to the host right after it=
=20
> receives DAD NS
> from the host, which is obviously in autoconfiguration process for=20
> linklocal address.
>
> Besides, RFC4862 section 4(protocol overview) says;
> ---
> To speed the autoconfiguration process, a host may generate its link-
> local address (and verify its uniqueness) in parallel with waiting
> for a Router Advertisement. Because a router may delay responding to
> a Router Solicitation for a few seconds, the total time needed to
> complete autoconfiguration can be significantly longer if the two
> steps are done serially.
> ---
>
> The  text indicates that a host *may* accept RA including prefix=20
> option even before
> completion of DAD for linklocal address.
> Since current addrconf code actually accepts RA including prefix=20
> option while DAD for
> linklocal address is processing, changes of the behaviour looks like =
a=20
> degradation for me.
> Hence, I chose to accept RA at that moment and defer sending DAD NS=20
> for global addresses.
>
> Thanks,
> -toyo
>
> YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>> In article <48324792.5070309@miraclelinux.com> (at Tue, 20 May 2008=20
>> 12:37:54 +0900), Toyo Abe <tabe@miraclelinux.com> says:
>>
>>> This patch fixes the problem by deferring DAD initiation for global=
=20
>>> address until
>>> DAD for linklocal address is completed. Now the failed test=20
>>> scenarios noted above
>>> are all passed.
>>
>> Why don't we just ignore RA until DAD for link-local
>> address has been successfully completed?
>>
>> --yoshfuji
>>
>>
>
>

