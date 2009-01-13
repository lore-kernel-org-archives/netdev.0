From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Tue, 13 Jan 2009 12:37:02 -0800
Message-ID: <20090113123702.ad29cd13.akpm@linux-foundation.org>
References: <E1LKrp3-004Tub-IR@intern.SerNet.DE>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Steven French <sfrench@us.ibm.com>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: Volker.Lendecke@SerNet.DE
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40337 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752434AbZAMUh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 15:37:28 -0500
In-Reply-To: <E1LKrp3-004Tub-IR@intern.SerNet.DE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc's added)

On Thu, 8 Jan 2009 11:13:51 +0100
Volker Lendecke <Volker.Lendecke@SerNet.DE> wrote:

> Hi!
> 
> While implementing splice support in Samba for better
> performance I found it blocking when trying to pull data off
> tcp into a pipe when the recvq was full. Attached find a
> test program that shows this behaviour, on another host I
> started
> 
> netcat 192.168.19.10 4711 < /dev/zero
> 
> vlendec@lenny:~$ uname -a
> Linux lenny 2.6.28-06857-g5cbd04a #7 Wed Jan 7 10:10:42 CET 2009 x86_64 = GNU/Linux
> vlendec@lenny:~$ gcc -o splicetest /host/home/vlendec/splicetest.c -O3 -Wall
> vlendec@lenny:~$ ./splicetest out 65536 &
> [1] 697
> vlendec@lenny:~$ strace -p 697
> Process 697 attached - interrupt to quit
> splice(0x3, 0, 0x5, 0, 0x56a0, 0x1)     = 22176
> splice(0x7, 0, 0x4, 0, 0x10000, 0x1^C <unfinished ...>
> Process 697 detached
> vlendec@lenny:~$ netstat -nt | grep 4711
> tcp    69272      0 192.168.19.10:4711 192.168.19.1:33773 ESTABLISHED
> vlendec@lenny:~$
> 
> Interestingly, whenever I start the strace, it gets another
> chunk of data and then blocks in the next splice call.
> 
> If I start splicetest with a buffer size of 16384 instead of
> 65536, it does not block. I could not find a way to ask the
> kernel for the tipping point below which it does not block.
> 
> What is a safe buffer size to use with splice?
> 
> BTW, this kernel is from Steve French's linux-cifs.git repo.
> 
> Thanks,
> 
> Volker Lendecke
> 
> Samba Team
> 
> P.S: I'm not subscribed to linux-kernel, so if possible
> please CC me directly. If this is inappropriate behaviour,
> please give me a quick hint :-)
> 

