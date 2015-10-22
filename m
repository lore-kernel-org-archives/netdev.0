From: Casper.Dik@oracle.com
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for sockets in accept(3)
Date: Thu, 22 Oct 2015 21:51:05 +0200
Message-ID: <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <20151022060304.GQ22011@ZenIV.linux.org.uk> <201510220634.t9M6YJLD017883@room101.nl.oracle.com> <20151022172146.GS22011@ZenIV.linux.org.uk> <201510221824.t9MIOp6n003978@room101.nl.oracle.com> <20151022190701.GV22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:51021 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965337AbbJVUHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 16:07:08 -0400
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t9MK77kh029202
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 20:07:07 GMT
Received: from room101.nl.oracle.com (room101.nl.oracle.com [10.161.249.34])
	by aserv0021.oracle.com (8.13.8/8.13.8) with ESMTP id t9MJsG7O001210
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 20:07:06 GMT
In-Reply-To: <20151022190701.GV22011@ZenIV.linux.org.uk> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>On Thu, Oct 22, 2015 at 08:24:51PM +0200, Casper.Dik@oracle.com wrote:
>
>> The external behaviour atomic; you cannot distinguish the order
>> between the closing of the original file (and waking up other threads
>> waiting for a record lock) or changing the file referenced by that newfd.
>> 
>> But this not include a global or process specific lock.
>
>Interesting...  Do you mean that decriptor-to-file lookup blocks until that
>rundown finishes?

For that particular file descriptor, yes.  (I'm assuming you mean the 
Solaris kernel running down all lwps who have a system in progress on that 
particular file descriptor).  All other fd to file lookups are not blocked 
at all by this locking.

It should be clear that any such occurrences are application errors and 
should be hardly ever seen in practice.  It is also known when this is 
needed so it is hardly even attempted.

Casper
