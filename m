From: David Miller <davem@davemloft.net>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 15:13:02 -0500 (EST)
Message-ID: <20141211.151302.686998496408277043.davem@davemloft.net>
References: <5489EE2F.6030502@ubuntu.com>
	<20141211.142355.854082841833367081.davem@davemloft.net>
	<5489F598.9020708@ubuntu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: psusi@ubuntu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56197 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758330AbaLKUNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:13:05 -0500
In-Reply-To: <5489F598.9020708@ubuntu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phillip Susi <psusi@ubuntu.com>
Date: Thu, 11 Dec 2014 14:50:48 -0500

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On 12/11/2014 2:23 PM, David Miller wrote:
>> From: Phillip Susi <psusi@ubuntu.com> Date: Thu, 11 Dec 2014
>> 14:19:11 -0500
>> 
>>> Attempting to establish a connection to a remote host using the
>>> same local port, but a different remote port as the previous
>>> connection ( that is still in TIME_WAIT ) results in bind()
>>> returning -EADDRINUSE. By changing the remote port, you avoid the
>>> conflict with the other connection that is in TIME_WAIT, but
>>> since the remote port is not known when bind() is called, it
>>> incorrectly returns -EADDRINUSE.  This check should not be done
>>> in bind(), but deferred until the remote port is known in the
>>> call to connect(), or listen().
>> 
>> Bind has to allocate and hold from everyone else on the system the 
>> local port at bind() time, so we cannot defer this decision.
> 
> What on earth for?  If two processes are going to connect to different
> remotes using the same source, that is perfectly fine.  The only
> contention is if two processes want to listen() with the same local
> addr and wildcard remote.

But you don't know ahead of time what the processes are going to
do, that's the problem.

You cannot leave the port available and pretend to another process
that he will be able to use it.

Port allocation failures must be signalled at bind() time.
