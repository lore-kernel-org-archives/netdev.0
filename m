From: "Predrag Hodoba" <predrag.hodoba@gmail.com>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Sat, 31 Mar 2007 08:25:09 +0200
Message-ID: <46d726f90703302325k3473ff1fy86e732d657f671b@mail.gmail.com>
References: <20070327214754.GA11677@dag-work>
	 <20070327.153025.45876618.davem@davemloft.net>
	 <46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com>
	 <20070329.114139.55510589.davem@davemloft.net>
	 <460C6348.5030904@osdl.org>
	 <46d726f90703300810q619e8bbmb5b15a58ff37bbed@mail.gmail.com>
	 <460D57FC.6080007@linux-foundation.org>
	 <46d726f90703301209o1147385fx9151c10f95e16684@mail.gmail.com>
	 <460D7722.8030403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, dagriego@gmail.com,
	netdev@vger.kernel.org
To: "Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:40355 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbXCaGZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 02:25:10 -0400
Received: by nz-out-0506.google.com with SMTP id s1so611847nze
        for <netdev@vger.kernel.org>; Fri, 30 Mar 2007 23:25:10 -0700 (PDT)
In-Reply-To: <460D7722.8030403@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/03/07, Rick Jones <rick.jones2@hp.com> wrote:
> If the switchover from active to standby is "commanded" then there is
> the opportunity to "tell" the applications on the server to close their
> connections - either explicitly with some sort of defined interface, or
> implicitly by killing the processes.  Then the IP can be brought-up on
> the standby and processes started/enabled/whatever and the clients can
> establish their new connections.  The ioctl here (at least if it is like
> the tcp_discon options in HP-UX/Solaris) wouldn't be any better than
> just killing the process in so far as what happens on the network - in
> fact, it could be worse since the RST will not be retransmitted if lost,
> but FINs would.  So, the ioctl could still leave clients twisting in the
> ether waiting for their application-level heartbeats to kick-in anyway.
>   Heck, depending on their heartbeat lengths, even the FIN stuff if lost
> could leave them depending on their heartbeats.
>
> If the switchover from active to standby is "uncommanded" it probably
> means the primary went belly-up which means you don't have the
> opportunity to make an ioctl call anyway, and you are back to the
> heartbeats.
>
> rick jones

What I meant is - it could be used on ***client***. Because clients
are left stranded with invalid connections when a primary fails (your
"uncommanded" switchover scenario). If you wait for them to timeout,
that will indeed happen, but it takes time and you are not back online
as fast as you would like. If cluster's services running on a client
already know about the failover (by means of "heartbeat" and observing
change in cluster membership), then they can propagate that knowledge
to all processes uneccessarily blocked in their socket calls towards
the failed IP address. If these connections are forcibly disconnected,
the respective sockets' calls would return with error code and their
processes can reconnect in few seconds after the failure and continue
to do what they are meant to do.

predrag
