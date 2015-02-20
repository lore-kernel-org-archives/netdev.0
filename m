From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] rhashtable: better high order allocation
 attempts
Date: Fri, 20 Feb 2015 06:54:48 -0800
Message-ID: <1424444088.5565.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1424389682.git.daniel@iogearbox.net>
	 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
	 <1424439975.5565.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAE688E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:64475 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833AbbBTOyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:54:51 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so3539855igj.4
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 06:54:50 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE688E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-20 at 14:27 +0000, David Laight wrote:

> I presume this code is allocating very large arrays for the base of the hash lists.
> Since there is no absolute requirement for contiguous KVA (nothing
> sequentially accesses the entire array) it can be coded differently.

vmalloc() is the proper allocator for hash table, even very big ones.

So far, no user wants huge rhashtable that would not fit in vmalloc
reserved space.

$ grep Vmalloc /proc/meminfo 
VmallocTotal:   34359738367 kB
VmallocUsed:      377492 kB
VmallocChunk:   34359350872 kB

It seems we have some room.
