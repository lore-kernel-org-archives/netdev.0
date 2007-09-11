From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] include listenq max backlog in /proc/net/tcp	and	include
 in tcp_info
Date: Tue, 11 Sep 2007 11:10:11 -0700
Message-ID: <46E6DA03.2040602@hp.com>
References: <200709102313.QAA01722@tardy.cup.hp.com>	<1189471180.11066.19.camel@w-sridhar2.beaverton.ibm.com>	<46E63121.5090607@cosmosbay.com> <46E6C9A5.8000008@hp.com>	<20070911191539.ff60362b.dada1@cosmosbay.com> <46E6D1E7.2060100@hp.com> <1189532811.19000.6.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:50985 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758181AbXIKSKs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 14:10:48 -0400
In-Reply-To: <1189532811.19000.6.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>BTW, what do people think about doing the same thing with the rxqueue 
>>>>and txqueue's of netstat output?
>>>>
>>>
>>>
>>>I dont understand this question, I thought your patch already handled this 
>>>(for the txqueue, since rxqueue is already there),  as netstat uses 
>>>/proc/net/tcp (unfortunatly)
>>
>>Well, it doesn't seem to be the case.  This is from the same system as 
>>the ss output above:
>>
>>hpcpc103:~# netstat -an | grep LISTEN
>>tcp        0      0 0.0.0.0:111          0.0.0.0:*               LISTEN
>>tcp        0      0 0.0.0.0:113          0.0.0.0:*               LISTEN
>>tcp        0      0 127.0.0.1:25         0.0.0.0:*               LISTEN
>>tcp        0      0 0.0.0.0:42137        0.0.0.0:*               LISTEN
>>tcp6       0      0 :::22                :::*                    LISTEN
>>unix  2    [ ACC ]     STREAM   LISTENING   5666  /var/run/acpid.socket
>>
>>I thought I saw some other code in there when I was stumbling around.
> 
> 
> Yes. netstat code seems to have a explicit check for TCP_LISTEN state
> and zeroing txq and rxq.
>>From tcp_do_one() in netstat.c
>     if (state == TCP_LISTEN) {
>         time_len = 0;
>         retr = 0L;
>         rxq = 0L;
>         txq = 0L;
>     }

How terribly cheeky of them.  I wonder why they were doing that?

> We should fix this. Also i think it is a good idea to update netstat to use 
> INET_DIAG_INFO instead of /proc/net/tcp.

Since that is user space I went ahead and sent the updated kernel patch 
in a fresh thread.

rick
