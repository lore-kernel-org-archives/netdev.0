From: Jenny Lee <bodycare_5@live.com>
Subject: Which one does less damange? "tcp_tw_recycle" or
 "tcp_max_tw_buckets"
Date: Wed, 13 Jul 2011 12:55:08 +0000
Message-ID: <BAY163-w64D3075D20556F32880DE7CC470@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s11.bay0.hotmail.com ([65.54.190.22]:10112 "EHLO
	bay0-omc1-s11.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752611Ab1GMNAj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 09:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,
 
<apology>
 
I apologize if this is not the right place to post this. But I could not find linux-net mailing list mentioned on kernel.org website.
 
From: http://www.kernel.org/pub/linux/docs/lkml/ :
The linux-net@vger.kernel.org mailing list is for networking user questions.
 
Majordomo: >>>> subscribe linux-net **** subscribe: unknown list 'linux-net'.
 
Couldn't also get an answer on #kernel IRC channel. So I am posting here.
 
</apology>
 
 
I have a situation where I am running out of ephemeral ports.
 
* RHEL6 x64 Machine (kernel-2.6.32-71). 
* I have 64K available ports. 
* I am using squid.
* Client is using CONNECT (HTTP inside) through squid, doing 500 reqs/second. Squid has many parents.
* Squid outgoing IP is SNAT'ted to 1000 IPs. 
 
Persistent connections and all did not do any good for me. Squid developers were very helpful, implemented many improvements for me but still no use.
 
Apparently this 64K limit per tuple does not seem to work as intended. I have many IPs, yet all hell breaks loose when 64K ports are used up. The max amount of TIME_WAITs from a single IP I have seen is 15K, yet I run out of ports at 64K.
 
I have tried fiddling with all kinds of values (including tcp_tw_reuse with tcp timestamps), timeouts, etc. but nothing helped.
 
I have 2 solutions:
 
* tcp_tw_recycle: This solved all my issues. I have not experienced any visible problems. Client can do > 1000 reqs/sec.
* tcp_max_tw_buckets: Redhat default is 180K. Keeping this at 64K helps. Kernel emits "TIME_WAIT bucket overflow" occassionally. But everythign seem to be working.
 
My question:
 
Which one would be wiser to do: 
 
To keep "tcp_tw_recycle" on, or to keep "tcp_max_tw_buckets" at 64K where I will get bucket overflow errors once an hour for couple of seconds?
 
Thank you in advance.
 
Jenny
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  		 	   		  