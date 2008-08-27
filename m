From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Wed, 27 Aug 2008 23:32:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808272319520.4693@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080826181731.4581fd2c@tux> <Pine.LNX.4.64.0808271236080.1034@wrl-59.cs.helsinki.fi>
 <20080827165142.4bc7b70f@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-498208092-1219869154=:4693"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39123 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbYH0Ucg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 16:32:36 -0400
In-Reply-To: <20080827165142.4bc7b70f@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-498208092-1219869154=:4693
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 27 Aug 2008, Dâniel Fraga wrote:

> On Wed, 27 Aug 2008 13:22:22 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > ...thus there could be other ports that are related as well, do you 
> > remember what exactly started working in that particular case :-)?
> 
> > Which of the connections? Mail, nntp, ftp, or the etc.? :-) To the host ip 
> > which was given for the tcpdump filter, definately nothing was resumed.
> 
> 	Ok. Let's focus on mail:
> 
> 1) first, my client (Claws-mail -- but it happened with Outlook of
> other users too) is working perfectly. I can download new messages. It
> connects to port 995 on the server without problems.
> 
> 2) suddenly it gives me an error message, that it cannot authenticate
> anymore (sorry, I don't have the exact message).

The exact message is not that big deal :-).

> If I try again to
> download new messages, it gives the same error. The connection to port
> 995 seems stalled or, better yet, cannot complete succesfully. It seems
> to time out.
> 
> 3) the server will stay this way, until I do an "nmap" to the server.
> This way, everything goes back to normal.

Ok. Though this all opens more questions than answers... :-(, why isn't 
there any traffic in neither of the tcpdumps then (not in the client's
nor in the server's).

> 	So, the server at point 2 got stalled and just an nmap server
> can force the server to go back to normal behaviour (I discovered that
> nmap solved the issue by luck).

I guess it might have something to do with the additional 3-way 
handshake that gets attempted but who knows...

> > The server's log captured not only 995 traffic but everything else to the 
> > host with the given ip (including udp which should show the tunnelled 
> > traffic I guess). Unless there's some other route to that host with 
> 	
> 	Ok, that's because I forgot to restrict traffic to port 995 on
> the server. Sorry.

I don't think it was bad at all... :-) I just meant that there wasn't any 
other visible traffic, which is very very strange because nothing port 995 
related (or anything else) seems to happen during the nmap... Which 
network interfaces the server has? Could things get routed through some 
other iface during the time of trouble (and during the nmap solution), 
that would explain why it isn't visible in the tcpdump which is for the 
specific interface.

> > This makes me wander if the network behavior is at all related to 
> > resolving of the problem. Only thing I can think of is that for some 
> > reason the userspace gets notified much later than it should about
> > TCP reset and therefore is waiting until that happens and can only
> > then continue.
> 
> 	What I can assure you is that other users (which use Microsoft
> Outlook Express) had the same problem, so, in this case, we can be
> pretty sure it isn't related to user space client.

Ah, ok.



-- 
 i.
---696208474-498208092-1219869154=:4693--
