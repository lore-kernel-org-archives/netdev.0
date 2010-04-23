From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Fri, 23 Apr 2010 13:44:54 -0700 (PDT)
Message-ID: <20100423.134454.177103227.davem@davemloft.net>
References: <1271775421.7895.19.camel@edumazet-laptop>
	<20100420.144106.118596093.davem@davemloft.net>
	<g2m65634d661004211212t13714cccyd27936c520515684@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, franco@lastsummer.de, xiaosuo@gmail.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43652
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752159Ab0DWUot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 16:44:49 -0400
In-Reply-To: <g2m65634d661004211212t13714cccyd27936c520515684@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 21 Apr 2010 12:12:41 -0700

> On Tue, Apr 20, 2010 at 2:41 PM, David Miller <davem@davemloft.net> wrote:
>> Eric, do you remember that "TCP friends" rough patch I sent you last
>> year that essentailly made TCP sockets over loopback behave like
>> AF_UNIX ones and just queue the SKBs directly to the destination
>> socket without doing any protocol work?
>>
> 
> This is sounds very interesting!  Could you post a patch? :-)

I'll see if I can find it, I sent it to Eric more than a year
ago...

The basic scheme was pretty simple:

1) Add "struct sock *friend" to struct sk_buff

2) TCP initial handshake SYN and SYN+ACK transmits set "skb->friend =
   sk" and TCP receive path notices this and stores this 'friend'
   socket pointer locally in the newly created connection socket.

   The purpose of skb->friend is to let the receiving socket on
   loopback see that the other end is on the local system and
   can be directly communicated to.

3) TCP sendmsg queues data directly to sk->friend's receive queue
   instead sending TCP protocol packets.

The only complications come from making sendmsg and recvmsg not
try to do all of the sequence handling and checking, stuff like
that.  Also, URG would need to be dealt with somehow too.

I'm sure someone suitably motivated could get a working patch
going in no time :-)
