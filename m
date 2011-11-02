From: =?UTF-8?B?RGF2aWQgVMOkaHQ=?= <dave.taht@gmail.com>
Subject: Re: Quick Fair Queue scheduler maturity and examples
Date: Wed, 02 Nov 2011 12:31:22 +0100
Message-ID: <4EB12A0A.3010602@gmail.com>
References: <CAN==1RowdZ094pkOA3vbs-fd3g-NSABqaGC3WXSPL8Y0Lqg+fQ@mail.gmail.com>  <1319716772.2601.26.camel@edumazet-laptop>  <CAN==1Rq+WEcezLPNPNug2V11nftDkm2=aRKw95u_R8OPGxG72g@mail.gmail.com>  <1319731732.2601.40.camel@edumazet-laptop>  <1319732832.2601.43.camel@edumazet-laptop>  <CAN==1Ro3Va7JHfOoENu=gJqfaktrqLvpo3NWV8=ZB9OKtyfeYQ@mail.gmail.com>  <4EB115F7.5070203@gmail.com> <1320229869.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090108080902090602060606"
Cc: Karel Rericha <karel@maxtel.cz>, netdev@vger.kernel.org,
	bloat <bloat@lists.bufferbloat.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:43212 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab1KBLb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 07:31:27 -0400
Received: by wwf22 with SMTP id 22so4424266wwf.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 04:31:26 -0700 (PDT)
In-Reply-To: <1320229869.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090108080902090602060606
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 11/02/2011 11:31 AM, Eric Dumazet wrote:
> Le mercredi 02 novembre 2011 à 11:05 +0100, David Täht a écrit :
>> (Example elided, see thread on netdev)
>>
>> On 11/02/2011 10:36 AM, Karel Rericha wrote:
>>> 2011/10/27 Eric Dumazet<eric.dumazet@gmail.com>:
>>> Thanks for example Eric. But it only added more confusion to me now
>>> :-) I was under impression (and read somewhere) that QFQ is non work
>>> conserving scheduler so I can use it more or less like HTB or HFSC to
>>> set bandwidth constraints to flows. But from this example (and from
>>> sources/patches/papers I try not to pretend I fully understand) it
>>> looks to me like some multiqueue scheduler with arbitrary number of
>>> queues and ability to arbitrary assign flows to this queues. So some
>>> sort of fair division of available bandwidth to flows without
>>> arbitrary bandwidth caps to these flows.
>> This is what I want! It may not be what you want...
>>> I really dont see what is non work conserving here :-S Please save my
>>> soul and enlighten me because I am at dead end now :-)
>> I initially had great hope for QFQ as I've been saying (mostly
>> privately) that "PFIFO_FAST must die" for over a year now. What to
>> replace it with is a rather large question, but I felt a start would be
>> to adopt some FQ algorithm. Over the last couple weeks I read all the
>> papers regarding DRR and QFQ and also poked into the source code and
>> like you, am seriously un-enlightened.
>>
>> I think eric's example is misleading as he divided up the queues by
>> bandwidth, rather than flow, in the first tier of his tc hierarchy.
>> useful as a test...
> It seems there is a bit of misunderstanding here.
>
> QFQ is not a 'all is included' in one qdisc, like SFQ
I grok. (or rather, I did after some reading last week)
>
> You really need to setup qfq classes, and describe how packets are
> mapped to qfq classes (this is done by an external flow classifier)

It would be mildly better (in the case of wireless) to be able to do
flow classification based on the nexthop mac, which while introducing an
extra routing table lookup, would improve packet aggregation
probabilities in the multiple ip or multi-hop wireless case.

I don't know if a route lookup of dest mac could be correctly done at 
this layer.

> It also has no internal (default) flow classifier like SFQ did.
>
> It has of course no bandwidth constraints. If you need to shape and use
> QFQ, you'll have to use QFQ + a shaping qdisc. (This is why I used HTB
> in my script because I wanted to shape)

I just want FQ... for now.

> If you dont need to shape, you still need to describe/setup qfq classes
> and chose appropriate flow classifier.
>

Trying for two levels of flow classification here, which I still doubt I
can do here... hmm, perhaps with ifb...

don't want to shape, want to ultimately apply some level of a post-RED 
AQM to the overall flows
>


-- 
Dave Täht


--------------090108080902090602060606
Content-Type: text/x-vcard; charset=utf-8;
 name="dave_taht.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="dave_taht.vcf"

YmVnaW46dmNhcmQNCmZuO3F1b3RlZC1wcmludGFibGU6RGF2ZSBUPUMzPUE0aHQNCm47cXVv
dGVkLXByaW50YWJsZTpUPUMzPUE0aHQ7RGF2ZQ0KZW1haWw7aW50ZXJuZXQ6ZGF2ZS50YWh0
QGdtYWlsLmNvbQ0KdGVsO2hvbWU6MS0yMzktODI5LTU2MDgNCnRlbDtjZWxsOjA2Mzg2NDUz
NzQNCngtbW96aWxsYS1odG1sOkZBTFNFDQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJkDQoNCg==
--------------090108080902090602060606--
