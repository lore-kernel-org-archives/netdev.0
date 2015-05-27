From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 14:05:31 -0700
Message-ID: <1432760731.4060.427.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	 <1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
	 <1432733597.4060.375.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432734319.4060.383.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFDu+76vYJwwXf+0Kc3YBK6VHL224v_u=HTf-RZ7dGN6qQ@mail.gmail.com>
	 <1432749433.4060.416.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432749732.4060.418.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CABK1yFBZWms=ojvzA8YvB=GY7m5jJCk7-d+jf7s8PQNdmhRauQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34870 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272AbbE0VFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 17:05:33 -0400
Received: by iesa3 with SMTP id a3so23697396ies.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 14:05:32 -0700 (PDT)
In-Reply-To: <CABK1yFBZWms=ojvzA8YvB=GY7m5jJCk7-d+jf7s8PQNdmhRauQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 11:15 -0700, Gopakumar Choorakkot Edakkunni wrote:
> Doesnt seem so. This is the output from one of the servers I have
> where I periodically hit this TSval != TSecr condition.
> 
> ubuntu@server:~$ sudo su
> root@server:/home/ubuntu# sysctl net.ipv4.tcp_tw_recycle
> net.ipv4.tcp_tw_recycle = 0
> root@server:/home/ubuntu#  sysctl net.ipv4.tcp_tw_reuse
> net.ipv4.tcp_tw_reuse = 0
> 
> Also I dont think your theory about port-reuse is what is happening
> either - because as I mentioned, its a very very lightly loaded
> server, and the client is also very very light weight in terms of tcp
> connections (makes one connection every 30 seconds to this one server
> and no one else). But the reason I mentioned the SYN-ACK-lost +
> SYN-retry theory is because the client<-->server is over internet via
> standard broadband links shared across multiple people and hence can
> be quite lossy.
> 
> At any rate, whatever is the cause behind this, I guess what you
> mentioned still holds good - that the tcp stack needs to update the
> saved TSval to that of the latest SYN, right ?

Well, considering ISN is the same, I really doubt these are different
sessions.

tcpdump traces were taken on the server ?

So far, nothing really calls for SYNACK rtx carrying different TSecr,
RFC says nothing about this case, so either choice is valid.
