From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Wed, 8 Jan 2014 18:11:05 +0200
Message-ID: <52CD7899.5090707@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>	<CA+mtBx_UDWVP2KEB04d-kS4fB1DyYX4m-sC8YOZDy-Wty3cmtA@mail.gmail.com>	<CAJZOPZKecwB9S_+goH2SvcXS+03rYk=73eVNBUoEMz=M5484RA@mail.gmail.com> <CA+mtBx-HRi4ttijScF8DKtdooeOyjzPXwq7T69vNaPSodZh1dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	"Shlomo Pongratz" <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:38010 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755363AbaAHQSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 11:18:01 -0500
In-Reply-To: <CA+mtBx-HRi4ttijScF8DKtdooeOyjzPXwq7T69vNaPSodZh1dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 01:04, Tom Herbert wrote:
> On Tue, Jan 7, 2014 at 12:21 PM, Or Gerlitz<or.gerlitz@gmail.com>  wrote:
>> >On Tue, Jan 7, 2014 at 8:44 PM, Tom Herbert<therbert@google.com>  wrote:
>>> >>Or, thanks for posting the patches!
>>> >>
>>> >>We should also support the case where direct encapsulation is being
>>> >>done, that is there is no encapsulation header after UDP and the
>>> >>protocol of the encapsulated packet is inferred by the port number
>>> >>(e.g. GRE/UDP, TCP/UDP, SCTP/UDP, etc.). This is probably an
>>> >>additional field in net_offload struct for next protocol, a little
>>> >>more API, and pretty trivial handlers in UDP code.
>> >
>> >The way I have set that follows your guideline under which the
>> >encapsulating method is derived from the udp destination port in the
>> >sense that the encapsulating protocol can do what they want in the
>> >gro_receive/complete handlers entry they plant per that udp port,
>> >isn't that generic enough?
> Direct encapsulation of different protocols could be done using the
> same callback functions. Somehow, we just need to pass the protocol
> number (or more generally pass private data to the callbacks). In lieu
> adding this to net_offload, we could just make the net_offload an
> argument to the callbacks and use container_of to access a private structure.
>

Tom,

OK, so I understand that you want the infrastructure to allow for direct 
udp encapsulation in the sense that there is no specific encapsulation 
header following the udp header.

Take for example encapsulating TCP over UDP port X, the layer/driver 
that wants to enable gro for such traffic will register a udp gro 
handler for port X and in their gro receive/complete
callbacks would just assume that following the UDP header there's TCP 
header and they will then issue a lookup in the inet gro handlers array 
to get the TCP gro handler, problem solved, agree?

Or.
