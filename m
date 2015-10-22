From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 08:15:21 +0200
Message-ID: <201510220615.t9M6FL2d017592@room101.nl.oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan Burlison <Alan.Burlison@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45500 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbbJVGb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 02:31:27 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9M6VQ0Q000905
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 06:31:26 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t9M6IYvY001681
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 06:31:25 GMT
In-Reply-To: <5628636E.1020107@oracle.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>It's been said that the current mechanisms in Linux & some BSD variants 
>can be subject to races, and the behaviour exhibited doesn't conform to 
>POSIX, for example requiring the use of shutdown() on unconnected 
>sockets because close() doesn't kick off other threads accept()ing on 
>the same fd. I'd be interested to hear if there's a better and more 
>performant way of handling the situation that doesn't involve doing the 
>sort of bookkeeping Casper described,.

Of course, the implementation is now around 18 years old; clearly a lot of 
things have changed since then.

In the particular case of Linux close() on a socket, surely it must be 
possible to detect at close that it is a listening socket and that you are 
about to close the last reference; the kernel could then do the shutdown() 
all by itself.

Casper
