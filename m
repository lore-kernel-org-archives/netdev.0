From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 23:28:34 +0100
Message-ID: <56281192.20606@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3> <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com> <562594E1.8040403@oracle.com> <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com> <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, dholland-tech@netbsd.org,
	Casper Dik <casper.dik@oracle.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26470 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663AbbJUW2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 18:28:44 -0400
In-Reply-To: <20151021185104.GM22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2015 19:51, Al Viro wrote:

> BTW, is SCM_RIGHTS outside of scope?  They do mention it in one place
> only:
> | Ancillary data is also possible at the socket level. The <sys/socket.h>
> | header shall define the following symbolic constant for use as the cmsg_type
> | value when cmsg_level is SOL_SOCKET:
> |
> | SCM_RIGHTS
> |     Indicates that the data array contains the access rights to be sent or
> | received.

That's still exactly the same in Issue 7, Technical Corrigenda 2 which 
is in final review at the moment.

>>> In other words, is that destruction of
>>> 	* any descriptor refering to this socket [utterly insane for obvious
>>> reasons]
>>> 	* the last descriptor refering to this socket (modulo descriptor
>>> passing, etc.) [a bitch to implement, unless we treat a syscall in progress
>>> as keeping the opened file open], or
>>> 	* _the_ descriptor used to issue accept(2) [a bitch to implement,
>>> with a lot of fun races in an already race-prone area]?
>>
>>  From reading the POSIX close() page I believe the second option is
>> the correct one.
>
> Er...  So fd2 = dup(fd);accept(fd)/close(fd) should *not* trigger that
> behaviour, in your opinion?  Because fd is sure as hell not the last
> descriptor refering to that socket - fd2 remains alive and well.
>
> Behaviour you describe below matches the _third_ option.

Ah, I wasn't 100% sure what the intended difference between #2 and #3 
was TBH, it does sound like I meant #3, yes :-)

-- 
Alan Burlison
--
