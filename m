From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Tue, 20 Jan 2015 11:14:37 -0800
Message-ID: <54BEA91D.1050001@hp.com>
References: <54B54C72.8060705@dev.mellanox.co.il> <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com> <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com> <54B590FB.5040805@dev.mellanox.co.il> <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com> <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com> <54BC286B.8000605@mellanox.com> <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com> <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com> <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:46115 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbbATTOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 14:14:41 -0500
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com [15.217.128.52])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 7031860DC0
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 19:14:40 +0000 (UTC)
In-Reply-To: <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Are you saying that at long last, delayed acks as we knew them are
>> dead, dead, dead?
>
> Sorry, I can not parse what you are saying.
>
> In case you missed it, it has nothing to do with delayed ACK but GRO on
> receiver.

Dave - assuming I've interpreted Eric's comments correctly, I believe 
the answer to your question is No.  Your desire for a world brimming 
with ack-every-other purity has not been fulfilled :)

However, the engineers formerly at Mentat are probably pleased that a 
functional near-equivalent to their ACK avoidance heuristic has ended-up 
being implemented and tacitly accepted, albeit by the back door :)


>>> DUMP_TCP_INFO=1 ./netperf -H remote -T2,2 -t TCP_STREAM -l 20
>>> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to remote () port 0 AF_INET : cpu bind
>>> rto=201000 ato=0 pmtu=1500 rcv_ssthresh=29200 rtt=67 rttvar=6 snd_ssthresh=263 cwnd=265 reordering=3 total_retrans=4569 ca_state=0
>>
>> The above statistics are not dumped by my netperf, and look extremely
>> desirable to capture in netperf-wrapper. This is a script parsing some
>> other kernel data at the conclusion of the run? or a better netperf?
>
> Thats a 3 lines patch in netperf actually.

More stuff to pull from a TCP_INFO call I presume?  Feel free to drop me 
a patch, though I'd probably want it to be in the guise of the omni 
output selectors.

happy benchmarking,

rick
