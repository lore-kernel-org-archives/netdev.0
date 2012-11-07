From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: tc filter u32 match
Date: Thu, 08 Nov 2012 00:36:38 +0100
Message-ID: <c3bfe7201cd3e7ecc751139ec32ada2e@justnet.pl>
References: <32a6182e71dd565206cf39d4cad3f984@justnet.pl>
 <1337853878.3513.11.camel@mojatatu>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:32778 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754186Ab2KGXg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 18:36:58 -0500
In-Reply-To: <1337853878.3513.11.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 24.05.2012 12:04, Jamal Hadi Salim napisa=C5=82(a):

> On Tue, 2012-05-22 at 15:42 +0200, Nie=C5=9Bcierowicz Adam wrote:
>
>> Hello, I'm in the process of building a new shaper, when adding=20
>> support
>> for 802.1q vlan noticed that u32 can catch network traffic without
>> giving 4 bytes offset. How is this possible?
>
> Because we look at where the network header starts?
> Why do you expect 4 bytes to be counted?
>
>> My environment: eth2 - network card eth2.200 - vlan /sbin/tc filter=20
>> add
>> dev eth2 parent 1:0 prio 5 handle 35: protocol ip u32 divisor 256
>> /sbin/tc filter add dev eth2 protocol ip parent 1:0 prio 5 u32 ht=20
>> 800::
>> match ip dst 31.41.208.32/27 hashkey mask 0x000000ff at 16 link 35:
>> /sbin/tc filter add dev eth2 protocol ip parent 1: prio 1 u32 ht=20
>> 35:24:
>> match ip dst 31.41.208.36 flowid 1:2e5 Here you can see the hits in=20
>> the
>> rule filter parent 1: protocol ip pref 5 u32 fh 35:24:800 order 2048
>> key ht 35 bkt 24 flowid 1:2e5 (rule hit 44037 success 44037) match
>> 1f29d024/ffffffff at 16 (success 44037 )
>
> I dont see an issue. This looks correct.
>
>>> I found a similar question here
>>
>
http://serverfault.com/questions/370795/tc-u32-how-to-match-l2-protocol=
s-in-recent-kernels
>>
>
> There may have been bugs in the past that someone missed or didnt
> report here (likely around the time there was a lot of changes
> happening with vlan offloading). Try the latest kernel and
> if it behaves badly, send a report and a reproducible test case.

Hello Again,

I changed the kernel to 3.6.0 and ip traffic classification on the
interface and vlan works fine.
Unfortunately I am not able to classify
PPPoE traffic, I checked filters with offset: 16, 20, 24, 28

Is it possible to classify PPPoE traffic on the main interface as it=20
was in previous kernels?
