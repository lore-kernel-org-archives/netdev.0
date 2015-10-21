From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: Fw: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 11:49:06 +0100
Message-ID: <56276DA2.8010905@oracle.com>
References: <20151019095938.72ea48e6@xeon-e3>	 <1445297584.30896.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <562594E1.8040403@oracle.com>	 <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>	 <56261092.7080003@oracle.com>	 <1445347173.22974.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <56264596.90104@oracle.com> <1445355027.22974.22.camel@edumazet-glaptop2.roam.corp.google.com> <5626887D.5050308@oracle.com> <063D6719AE5E284EB5DD2968C1650D6D1CBBD206@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34544 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbJUKtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 06:49:20 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBBD206@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/10/2015 11:25, David Laight wrote:

>> The problem with poll() is that it returns immediately when passed a FD
>> that is in the listening state. rather than waiting until there's an
>> incoming connection to handle. As I said, that means you can't use
>> poll() to multiplex between read/write/accept sockets.
>
> That seems to work for me...

In my test case I was setting all the available event bits in 
pollfd.events to see what came back. With poll() on a listen() socket 
you get an immediate return with bits set in revents indicating the 
socket is available for output, which of course it isn't. Indeed an 
attempt to write to it fails. If you remove the output event bits in 
pollfd.events then the poll() waits as expected until there's an 
incoming connection on the socket.

I suppose one answer is "Well, don't do that then" but returning an 
output indication on a socket that's in listen() seems rather odd.

With POLLOUT|POLLWRNORM|POLLWRBAND:

main: polling #1
[returns immediately]
main: poll #1: Success
poll fd: 0 revents: POLLOUT POLLWRBAND
main: write #1: Transport endpoint is not connected

Without POLLOUT|POLLWRNORM|POLLWRBAND:

main: polling #1
[waits for connection]
main: poll #1: Success
poll fd: 0 revents: POLLIN POLLRDNORM

-- 
Alan Burlison
--
