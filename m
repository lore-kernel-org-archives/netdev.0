From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Tue, 21 Sep 2010 13:15:25 -0700
Message-ID: <4C99125D.6060106@hp.com>
References: <alpine.DEB.1.00.1009211154150.32565@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sridharr@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:9930 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777Ab0IUUP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 16:15:27 -0400
In-Reply-To: <alpine.DEB.1.00.1009211154150.32565@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Using recvmsg data in this manner is sort of a cheap way to get a
> "callback" for when a vmspliced buffer is consumed.  It will work
> well for a client where the response causes recvmsg to return.
> On the server side it works well if there are a sufficient
> number of requests coming on the connection (resorting to the
> timeout if necessary as described above).

If there is a recvmsg(), how often will the data received implicitly/explicitly 
tell the application how much of the previously sent data has been acked?  A 
subsequent request from the client in a persistent (but not pipelined) HTTP 
session implicitly says the data of the previous response was ACKed no?  Is that 
simply too rare to rely upon?

On the bulk side, an application filling the (fixed size at least) socket buffer 
will "know" that the bytes sent a "socket buffer size ago" were ACKed because 
that is what makes room in the socket buffer for data right?

rick jones

ftp://ftp.cup.hp.com/dist/networking/briefs/copyavoid.pdf
