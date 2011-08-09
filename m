From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Tue, 09 Aug 2011 10:29:00 +0200
Message-ID: <7f02f2970d225cddfad74ee660f39d1d@localhost>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
 <20110801181652.GB2732@nuttenaction>
 <1312223866.2719.3.camel@edumazet-laptop>
 <20110801.175705.2074393848482150971.davem@davemloft.net>
 <1312866027.2531.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <rui314@gmail.com>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:34020 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752373Ab1HII3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 04:29:03 -0400
In-Reply-To: <1312866027.2531.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 09 Aug 2011 07:00:27 +0200, Eric Dumazet wrote:



> I tried this idea since its already an enum and all enum values are

> handled in the switch, but all gcc versions I used still generate the

> useless compare and branch (always predicted by modern CPU, so harmless

> anyway ?)



Don't think so, the list is rather long - the CPU may not have any

indication. But strange that your gcc generate a conditional sequence of

cmp and conditional jump instruction instead of a jump table! Look at

commit 01f2f3f6ef4d076c, this is what I got after I refactored to an

_dense_ enum list.

 

> (But this would need to use a larger kernel_sock_filter with not an u16

> code, but the target address).



Not sure if the benefit is worth to try it. Can we avoid any cacheline

misses? I don't think so.





> +		switch ((enum bpf_inst)fentry->code) {



That should not differ! Eric, sure that this do the trick?





Hagen
