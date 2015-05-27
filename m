From: Gopakumar Choorakkot Edakkunni <gopakumar.c.e@gmail.com>
Subject: Re: Bug in tcp timestamp option ? TSecr in SYN-ACK != TSval in SYN
Date: Wed, 27 May 2015 11:15:37 -0700
Message-ID: <CABK1yFBZWms=ojvzA8YvB=GY7m5jJCk7-d+jf7s8PQNdmhRauQ@mail.gmail.com>
References: <CABK1yFBN7KgBxRRzx-Bmt86_L8PnbfgqNJr7Mc2o9usn=LKSTg@mail.gmail.com>
	<1432707139.4060.351.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432707810.4060.352.camel@edumazet-glaptop2.roam.corp.google.com>
	<CABK1yFDJNonOr0O7N3gjJw-AripeaRqC1Xi+sDt7i_s0gC+ZLQ@mail.gmail.com>
	<1432733597.4060.375.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432734319.4060.383.camel@edumazet-glaptop2.roam.corp.google.com>
	<CABK1yFDu+76vYJwwXf+0Kc3YBK6VHL224v_u=HTf-RZ7dGN6qQ@mail.gmail.com>
	<1432749433.4060.416.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432749732.4060.418.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33169 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbbE0SPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:15:38 -0400
Received: by igbpi8 with SMTP id pi8so93730770igb.0
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 11:15:37 -0700 (PDT)
In-Reply-To: <1432749732.4060.418.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doesnt seem so. This is the output from one of the servers I have
where I periodically hit this TSval != TSecr condition.

ubuntu@server:~$ sudo su
root@server:/home/ubuntu# sysctl net.ipv4.tcp_tw_recycle
net.ipv4.tcp_tw_recycle = 0
root@server:/home/ubuntu#  sysctl net.ipv4.tcp_tw_reuse
net.ipv4.tcp_tw_reuse = 0

Also I dont think your theory about port-reuse is what is happening
either - because as I mentioned, its a very very lightly loaded
server, and the client is also very very light weight in terms of tcp
connections (makes one connection every 30 seconds to this one server
and no one else). But the reason I mentioned the SYN-ACK-lost +
SYN-retry theory is because the client<-->server is over internet via
standard broadband links shared across multiple people and hence can
be quite lossy.

At any rate, whatever is the cause behind this, I guess what you
mentioned still holds good - that the tcp stack needs to update the
saved TSval to that of the latest SYN, right ?

Rgds,
Gopa.


On Wed, May 27, 2015 at 11:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2015-05-27 at 10:57 -0700, Eric Dumazet wrote:
>> On Wed, 2015-05-27 at 10:29 -0700, Gopakumar Choorakkot Edakkunni wrote:
>> > Thanks Eric. I will give this a spin. The issue doesnt happen all the
>> > time, I can keep the server running with this patch for a while and
>> > observe if the issue resurfaces or not
>>
>> Note that if the traffic on the server is low, you might want to keep a
>> tcpdump running (capturing only headers for TCP port 443) for further
>> analysis.
>
> We wonder if this could be a time-wait issue
>
> Could you check on the server :
>
> sysctl net.ipv4.tcp_tw_recycle
> sysctl net.ipv4.tcp_tw_reuse
>
> Thanks
>
>
