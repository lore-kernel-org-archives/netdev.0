From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Thu, 12 Jun 2014 07:32:57 -0700
Message-ID: <1402583577.3645.477.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539319F6.2090907@cogentembedded.com>
		<1402151680-11434-1-git-send-email-per.hurtig@kau.se>
		<1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
		<539413BA.7060903@kau.se>
	 <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
	 <5399B762.5090002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>,
	Per Hurtig <per.hurtig@kau.se>,
	Netdev <netdev@vger.kernel.org>,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	sergei.shtylyov@cogentembedded.com
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:45553 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933291AbaFLOc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 10:32:59 -0400
Received: by mail-pd0-f172.google.com with SMTP id fp1so1033072pdb.3
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 07:32:59 -0700 (PDT)
In-Reply-To: <5399B762.5090002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-12 at 22:21 +0800, Weiping Pan wrote:
> When we queue an out of order pure FIN packet, we do not check whether 
> it has data or not.
> tcp_rcv_established
> -->tcp_data_queue
> ---->tcp_data_queue_ofo
> 
> Then the pure FIN packet can generate SACK, which will trigger fast 
> recovery or early retransmit on the sender.
> >
> > If you have verified that a pure FIN does indeed trigger recovery, can
> > you tell me what part of the code makes that happen?
> Here is the patch I use, I think the original if statement is useless, 
> so I delete it.

Yes, this is exactly what we agreed, and what we tested as well here at
Google.

Per, can you submit an updated official version of the patch ?

Thanks
