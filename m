From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,	comparing
 with 2.6.22
Date: Tue, 22 Jan 2008 08:13:12 +0100
Message-ID: <47959788.3000207@cosmosbay.com>
References: <478B9FE0.3040801@hp.com> <1200979482.3151.103.camel@ymzhang>	 <1200982039.3151.120.camel@ymzhang>	 <20080121.222214.184161381.davem@davemloft.net> <1200984664.3151.253.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:52511
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754178AbYAVHNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 02:13:17 -0500
In-Reply-To: <1200984664.3151.253.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin a =C3=A9crit :
> On Mon, 2008-01-21 at 22:22 -0800, David Miller wrote:
>> From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
>> Date: Tue, 22 Jan 2008 14:07:19 +0800
>>
>>> I am wondering if UDP stack in kernel has a bug.
>> If one server binds to INADDR_ANY with port N, then any other socket
>> can be bound to a specific IP address with port N.  When packets
>> come in destined for port N, the delivery will be prioritized
>> to whichever socket has the more specific and matching binding.
> What does 'more specific' mean here? I assume 127.0.0.1 should be
> prioritized before 0.0.0.0 which means packets should be queued to
> 127.0.0.1 firstly.

vi +278 net/ipv4/udp.c

                         int score =3D (sk->sk_family =3D=3D PF_INET ? =
1 : 0);
                         if (inet->rcv_saddr) {
                                 if (inet->rcv_saddr !=3D daddr)
                                         continue;
                                 score+=3D2;
                         }
                         if (inet->daddr) {
                                 if (inet->daddr !=3D saddr)
                                         continue;
                                 score+=3D2;
                         }
                         if (inet->dport) {
                                 if (inet->dport !=3D sport)
                                         continue;
                                 score+=3D2;
                         }
                         if (sk->sk_bound_dev_if) {
                                 if (sk->sk_bound_dev_if !=3D dif)
                                         continue;
                                 score+=3D2;
                         }

So in your case, socket bound to 127.0.0.1 should have a better score (=
+2)=20
than other one, unless the other one got an >=3D score because of anoth=
er match=20
(rcv_saddr set or bounded to an interface)





