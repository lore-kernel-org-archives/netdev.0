From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 29 Apr 2009 15:53:53 +0200
Message-ID: <49F85BF1.1020501@cosmosbay.com>
References: <20090415.164248.188350673.davem@davemloft.net> <20090416085022.GA19731@gondor.apana.org.au> <49EE1C32.1060202@myri.com> <20090422104811.GA30981@gondor.apana.org.au> <49EF39B4.1040607@myri.com> <20090424054557.GA24575@gondor.apana.org.au> <49F1E5C8.7010303@myri.com> <20090427080501.GA21433@gondor.apana.org.au> <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au> <49F77134.9030907@myri.com> <49F85945.7030900@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35053 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbZD2Ny2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 09:54:28 -0400
In-Reply-To: <49F85945.7030900@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin a =E9crit :
> Andrew Gallatin wrote:
>> For variety, I grabbed a different "slow" receiver.  This is another
>> 2 CPU machine, but a dual-socket single-core opteron (Tyan S2895)
>>
>> processor       : 0
>> vendor_id       : AuthenticAMD
>> cpu family      : 15
>> model           : 37
>> model name      : AMD Opteron(tm) Processor 252
> <...>
>> The sender was an identical machine running an ancient RHEL4 kernel
>> (2.6.9-42.ELsmp) and our downloadable (backported) driver.
>> (http://www.myri.com/ftp/pub/Myri10GE/myri10ge-linux.1.4.4.tgz)
>> I disabled LRO, on the sender.
>>
>> Binding the IRQ to CPU0, and the netserver to CPU1 I see 8.1Gb/s wit=
h
>> LRO and 8.0Gb/s with GRO.
>=20
> With the recent patch to fix idle CPU time accounting from LKML appli=
ed,
> it is again possible to trust netperf's service demand (based on %CPU=
).
> So here is raw netperf output for LRO and GRO, bound as above.
>=20
> TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> hail1-m.sw.myri.com (10.0.130.167) port 0 AF_INET : cpu bind
> Recv   Send    Send                          Utilization       Servic=
e
> Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send  =
  Recv
> Size   Size    Size     Time     Throughput  local    remote   local =
remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB =
=20
> us/KB
>=20
> LRO:
>  87380  65536  65536    60.00      8279.36   8.10     77.55    0.160 =
1.535
> GRO:
>  87380  65536  65536    60.00      8053.19   7.86     85.47    0.160 =
1.739
>=20
> The difference is bigger if you disable TCP timestamps (and thus shri=
nk
> the packets headers down so they require fewer cachelines):
> LRO:
>  87380  65536  65536    60.02      7753.55   8.01     74.06    0.169 =
1.565
> GRO:
>  87380  65536  65536    60.02      7535.12   7.27     84.57    0.158 =
1.839
>=20
>=20
> As you can see, even though the raw bandwidth is very close, the
> service demand makes it clear that GRO is more expensive
> than LRO.  I just wish I understood why.
>=20

What are "vmstat 1" ouputs on both tests ? Any difference on say... con=
text switches ?


