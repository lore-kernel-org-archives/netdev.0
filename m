From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 05:17:50 +0100
Message-ID: <5628636E.1020107@oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>	<5627A37B.4090208@oracle.com>	<20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org,
	casper.dik@oracle.com
To: David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49399 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbJVER7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 00:17:59 -0400
In-Reply-To: <20151021.182955.1434243485706993231.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/2015 02:29, David Miller wrote:

> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Wed, 21 Oct 2015 19:51:04 +0100
>
>> Sure, but the upkeep of data structures it would need is there
>> whether you actually end up triggering it or not.  Both in
>> memory footprint and in cacheline pingpong...
>
> +1

It's been said that the current mechanisms in Linux & some BSD variants 
can be subject to races, and the behaviour exhibited doesn't conform to 
POSIX, for example requiring the use of shutdown() on unconnected 
sockets because close() doesn't kick off other threads accept()ing on 
the same fd. I'd be interested to hear if there's a better and more 
performant way of handling the situation that doesn't involve doing the 
sort of bookkeeping Casper described,.

To quote one of my colleague's favourite sayings: Performance is a goal, 
correctness is a constraint.

-- 
Alan Burlison
--
