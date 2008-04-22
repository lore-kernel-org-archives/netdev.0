From: Patrick McHardy <kaber@trash.net>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
 of Tomasz's patch set
Date: Tue, 22 Apr 2008 06:56:26 +0200
Message-ID: <480D6FFA.80205@trash.net>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <480C7E50.3050508@trash.net> <20080421131253.GB12221@ghostprotocols.net> <200804211817.01189.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58985 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbYDVE4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2008 00:56:32 -0400
In-Reply-To: <200804211817.01189.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomasz Grobelny wrote:
> Dnia Monday 21 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
>> Nod, if we don't need the space reserved for the lower layer protoco=
ls
>> in DCCP it is actually the best solution, as we don't need to zero t=
he
>> cb again before passing it to IP, it gets zeroed at alloc_skb time a=
nd
>> that is it. If we need the space, we have to pay the price of
>> memset before passing to IP.
>>
> Ok, so in this case the patch for DCCP could be reverted in test tree=
, is that=20
> right? Were these two deleted memsets zeroing all that was necessary =
or were=20
> there any other bugs fixed by the patch?

No, those two memsets became unnecessary by the addition
of the new cb members. If you want to remove them again,
you need to add those memsets back and additionally add
memsets that zero the first sizeof(inet_skb_parm)/
sizeof(inet6_skb_parm) bytes everywhere else where packets
are passed to IP(v6).
