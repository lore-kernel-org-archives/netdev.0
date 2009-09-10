From: Brian Haley <brian.haley@hp.com>
Subject: Re: TCP kernel tables overflowing after sustained 1000 new connections
 per second
Date: Wed, 09 Sep 2009 20:26:01 -0400
Message-ID: <4AA84799.4070906@hp.com>
References: <c67e3dc60909091146j4aeaf422v4e0543eff87c7f9a@mail.gmail.com> <20090909.170824.141343404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	roque@di.fc.ul.pt, netdev@vger.kernel.org
To: paulsheer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:30228 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbZIJA0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 20:26:01 -0400
In-Reply-To: <20090909.170824.141343404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> The third problem seems to be connected to /proc/net/tcp6
>>
>> look at the output of the script
>>
>> while true ; do echo "`date`: `cat /proc/net/tcp6 | wc -l`  vs  `cat
>> /proc/net/tcp | wc -l`" ; sleep 1 ; done
>>
>> while I run my load test:
>>
>>
>>  Wed Sep  9 20:39:26 SAST 2009: 5  vs  20
>>  Wed Sep  9 20:39:27 SAST 2009: 5  vs  20
>>  Wed Sep  9 20:39:28 SAST 2009: 5  vs  20
>>  Wed Sep  9 20:39:29 SAST 2009: 5  vs  20
>>  Wed Sep  9 20:39:31 SAST 2009: 1233  vs  20
>>  Wed Sep  9 20:39:32 SAST 2009: 2640  vs  21
>>  Wed Sep  9 20:39:33 SAST 2009: 4190  vs  20
>>  Wed Sep  9 20:39:34 SAST 2009: 5813  vs  20
>>  Wed Sep  9 20:39:35 SAST 2009: 7527  vs  20
>>  Wed Sep  9 20:39:37 SAST 2009: 9568  vs  44
>>  Wed Sep  9 20:39:38 SAST 2009: 11819  vs  21
>>  Wed Sep  9 20:39:40 SAST 2009: 14510  vs  21
>>  Wed Sep  9 20:39:42 SAST 2009: 16971  vs  20
>>  Wed Sep  9 20:39:44 SAST 2009: 16971  vs  20
>>  Wed Sep  9 20:39:46 SAST 2009: 17013  vs  20
>>  Wed Sep  9 20:39:48 SAST 2009: 17013  vs  20
>>  Wed Sep  9 20:39:50 SAST 2009: 17013  vs  20
>>
>> So it is clear "something" is filling up in tcp_ipv6.c

By default, apache is going to open an IPv6 socket, so every connection,
even IPv4, will use an IPv6 socket with a mapped address:

# netstat -anp | grep apache
tcp6       0      0 :::80                   :::*                    LISTEN     27795/apache2       
tcp6       0      0 ::ffff:10.0.0.1:80   ::ffff:10.0.0.2:35271      ESTABLISHED27813/apache2

I'm guessing that 17013 is your 16384 plus a few in time-wait, right?

There's a way to change it to be IPv4-only in the conf file from what I remember.

-Brian

