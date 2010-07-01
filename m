From: Ivan Novick <novickivan@gmail.com>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 17:27:28 -0700
Message-ID: <AANLkTimL7_h4J46-WyUYfXYX87t6tQzIn1YRrvJletWB@mail.gmail.com>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com>
	<1277931829.4878.9.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jmatthews@greenplum.com,
	Tim Heath <theath@greenplum.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51844 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab0GAA13 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 20:27:29 -0400
Received: by vws5 with SMTP id 5so1657053vws.19
        for <netdev@vger.kernel.org>; Wed, 30 Jun 2010 17:27:28 -0700 (PDT)
In-Reply-To: <1277931829.4878.9.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 30, 2010 at 2:03 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2010-06-30 at 11:04 -0700, Ivan Novick wrote:
>> Hello all,
>>
>> Attached is a packet capture from my application that is running on
>> RedHat Enterprise Linux 5.4
>>
>> I am seeing a Retransmission timeout but I was hoping this case woul=
d
>> go into fast retransmit and not RTO.
>>
>> I am wondering why did the sender not send more data? =A0If the send=
er
>> was to send more data and extend the window then it would seem the
>> duplicate acks or SACKS should trigger fast retransmit.
> [...]
>
> In that packet capture I see TCP payload lengths which are 2, 3 and 4
> times the usual MSS of 1448 bytes, which implies that GRO or LRO is i=
n
> use. =A0In RHEL 5.4 the TCP stack does not ACK often enough in this c=
ase
> because it is missing this change:
>
> commit ff9b5e0f08cb650d113eef0c654f931c0a7ae730
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date: =A0 Thu Aug 31 15:11:02 2006 -0700
>
> =A0 =A0[TCP]: Fix rcv mss estimate for LRO

Wow, Thanks! Is this the patch you are talking about:
http://www.mail-archive.com/netdev@vger.kernel.org/msg21151.html  ?

It looks like a one liner.   I could apply it and rebuild my RHEL 5.4
to see if it helps.

Cheers,
Ivan Novick
