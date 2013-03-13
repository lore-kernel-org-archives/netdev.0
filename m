From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Trying to implement secondary loopback
Date: Wed, 13 Mar 2013 13:46:07 -0700
Message-ID: <87r4jjav00.fsf@xmission.com>
References: <513F1A17.1000809@hhi.fraunhofer.de>
	<CAFLxGvxcyDVwC-iys6UdKMBB6u3UQx6s7-mwm5caoNu=N7rmeA@mail.gmail.com>
	<3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"edumazet\@google.com" <edumazet@google.com>,
	"herbert\@gondor.apana.org.au" <herbert@gondor.apana.org.au>
To: "Martitz\, Thomas" <thomas.martitz@hhi.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:40921 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934255Ab3CMUqU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 16:46:20 -0400
In-Reply-To: <3D7E565A361FB844A410A5EFCDD7BA4002ECF5@MXSRV3.fe.hhi.de> (Thomas
	Martitz's message of "Wed, 13 Mar 2013 20:38:08 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Martitz, Thomas" <thomas.martitz@hhi.fraunhofer.de> writes:

>>
>> ________________________________________
>> Von: richard -rw- weinberger [richard.weinberger@gmail.com]
>> Gesendet: Mittwoch, 13. M=C3=A4rz 2013 12:13
>> An: Martitz, Thomas
>> Cc: netdev@vger.kernel.org; davem@davemloft.net; edumazet@google.com=
; herbert@gondor.apana.org.au; ebiederm@xmission.com
>> Betreff: Re: Trying to implement secondary loopback
>>
>> >
>> > So my questions are:
>> > * Is this on purpose/expected?
>> > * Is there anyway around it so that I can have a custom loopback i=
nterface
>> > without touching lo's functionality.
>> > * Generally, what's the proper way (if any) implement a secondary =
loopback
>> > interface?
>>
>> The only really question that matters is, why do you need a second
>> loopback interface?
>> Why can't you use any other pseudo interface?
>>
>
> What pseudo interface do you mean? I'm not aware of alternative pseud=
o interfaces.
>
> I'm developing a NIC and a driver for it. Thus I'm implementing the i=
nterface. I'm trying to implement an interface that does exactly do wha=
t loopback does except that I want to extend the loopback path to PCIe.=
 This is for testing & validation purposes.
>
> I tried to implement an interface that's doesn't advertise as
> such. But the data transfer didn't go through my code. My test app is
> a simple client/server setup in a single process that sends/receive
> data to/on 127.0.0.1.

The easy solution is to setup two network namespaces and two nics.
And transmit data from one network namespace to another, through your
nics.

Eric
