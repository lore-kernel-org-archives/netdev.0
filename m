From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 22:20:55 +0100
Message-ID: <49CAA037.8060901@trash.net>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net> <49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com> <49CA7AD7.8040401@cosmosbay.com> <20090325191850.GA2928@ami.dom.local> <49CA8895.8020105@cosmosbay.com> <20090325195424.GB2928@ami.dom.local> <49CA93F5.0@cosmosbay.com> <20090325211202.GC2928@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40339 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbZCYVU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 17:20:59 -0400
In-Reply-To: <20090325211202.GC2928@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Mar 25, 2009 at 09:28:37PM +0100, Eric Dumazet wrote:
>  =20
>> Jarek Poplawski a =E9crit :
>>
>>    =20
>>> I guess you've considered the loopback too...
>>>
>>>      =20
>> I had for the first patch (carefuly avoiding loopback being not resp=
onsive) :
>> I was releasing dst only if enqueue() was called.
>>
>> You are right, loopback doesnt work anymore with last patch,
>> and I have no idea why...
>>
>> Do you know why ?
>>    =20
>
> Hmm.. isn't this test for dst =3D=3D NULL in ip_rcv_finish expected t=
o be
> negative for loopback source?

ip_route_input() doesn't accept loopback addresses, so loopback packets
already need to have a dst_entry attached.
