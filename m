From: chris schlund <chrisschlund@gmx.de>
Subject: Re: Socket hangs in read() when putting interface down
Date: Wed, 06 Jun 2007 15:55:26 +0200
Message-ID: <4666BCCE.2020806@gmx.de>
References: <46657D21.3010203@gmx.de> <4665A05F.9080600@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:43722 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1760654AbXFFNoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 09:44:15 -0400
In-Reply-To: <4665A05F.9080600@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> This may be ok on a major interface like eth0 but it is a problem when
>> using a ppp interface via GSM data or GPRS connection.
>> Killing the pppd while the socket waits in read() produces the same
>> behaviour. Also a broken connection looks the same.
>> It is reproducable on several 2.6 kernel versions including the lastest
>> stable 2.6.21.
>>
>> On my understanding "ifconfig down" should lead into a read() error.
> 
> Why?  Can't traffic for the endpoint arrive via some other interface on
> the system?  I would think that getting out of a blocking read()
> requires the application to either have a timer running (and so get out
> of read() with EINTR) or to have keepalives enabled on the TCP
> connection (I'm assuming TCP for an AF_INET, SOCK_STREAM although I
> suppose it could be SCTP)
> 
> rick jones

Of course, you are right.
I am so focused to my small embedded world, that I simply have forgotten
how IP-traffic works in big systems (to clarify my first post: I'm using
TCP).

Your hint with the self produced signal to get out of read() was very
helpful for me. Thats what I was missing.

I also learned another think, while reading the list FAQ:
PEBCAC (=Problem exists between chair and computer)
Obviously, thats what best described me!

Thank you very much!

Chris Schlund



