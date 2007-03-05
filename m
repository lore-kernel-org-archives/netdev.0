From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Extensible hashing and RCU
Date: Mon, 5 Mar 2007 11:02:23 +0100
Message-ID: <17899.60079.450134.412648@robur.slu.se>
References: <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
	<20070303104620.GD22557@2ka.mipt.ru>
	<f2b55d220703040202y7d6e5c72q8b5c8fd3d11fd06a@mail.gmail.com>
	<20070304.123658.104032879.davem@davemloft.net>
	<f2b55d220703042312q6a83e00el862e63fe03e5b7c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:49022 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933015AbXCEKDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 05:03:52 -0500
In-Reply-To: <f2b55d220703042312q6a83e00el862e63fe03e5b7c0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Michael K. Edwards writes:

 > This, incidentally, seems very similar to the process that Robert
 > Olsson and Stefan Nilsson have gone through with their trie/hash
 > project.  Although I haven't tried it out yet and don't have any basis
 > for an independent opinion, the data and analysis provided in their
 > paper are quite convincing. 

 I've info about this "process" :) Moved fib_trie.c to userland to extend 
 it longer an variable keylengths. Testprogram was doing insert/lookup/remove 
 with random data with blistering performance (very flat trees).

 So quite happy I moved this trie back to the kernel and started testing with
 "real data" - ip addresses and rDoS.  Result was disastrous.... very deep 
 trees and awful network performance. Random data is very different from 
 real data was the lesson learned again. Gave up. 

 A couple days later an idea came up. I'll remembered the poof from the
 LC-trie paper that length of key does not impact tree depth. So went 
 to Stefan, Can't we just fix up the data rather than fiddling with an 
 new improved algorithm? The result was this "hash" header to boost tree 
 compression.
 
 Cheers
					--ro

 
