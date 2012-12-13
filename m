From: Paul Chavent <Paul.Chavent@onera.fr>
Subject: Re: [RFC] net : add tx timestamp to packet mmap.
Date: Thu, 13 Dec 2012 08:13:04 +0100
Message-ID: <50C98000.8040108@onera.fr>
References: <1355326165-12277-1-git-send-email-paul.chavent@onera.fr> <20121212.142327.2290797438095968580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, daniel.borkmann@tik.ee.ethz.ch,
	xemul@parallels.com, ebiederm@xmission.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from briaree.onecert.fr ([134.212.190.4]:59346 "EHLO
	briaree.onecert.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab2LMHPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 02:15:38 -0500
In-Reply-To: <20121212.142327.2290797438095968580.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After a sendmsg, we have to call recvmsg on the ERRQUEUE to get 
timestamp. I find that unfortunate indeed...

So this patch fix the tx timestamping (that take place in sendmsg), in 
order to be able to get timestamp (via recvmsg).

This seems suboptimal to me, that why i also ask if it wouldn't be 
possible to put the timestamp in the ring buffer frame before give it 
back to user.

Thanks for your reading.


On 12/12/2012 08:23 PM, David Miller wrote:
>
> You're changing the code that handles sendmsg() and then wondering why
> a recvmsg() call doesn't provide a timestamp.
>
