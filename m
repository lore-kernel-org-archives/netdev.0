From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Sun, 29 Jul 2007 19:28:09 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707291922370.11113@kivilampi-30.cs.helsinki.fi>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu>
 <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
 <20070729085427.GA22784@1wt.eu> <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi>
 <20070729160721.GA31276@1wt.eu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-2123637381-1185726287=:11113"
Cc: "Ilpo =?iso-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	"Darryl L. Miles" <darryl-mailinglists@netbauds.net>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53124 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763549AbXG2Q2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 12:28:11 -0400
In-Reply-To: <20070729160721.GA31276@1wt.eu>
Content-ID: <Pine.LNX.4.64.0707291926380.11113@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2123637381-1185726287=:11113
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707291925011.11113@kivilampi-30.cs.helsinki.fi>

On Sun, 29 Jul 2007, Willy Tarreau wrote:

> On Sun, Jul 29, 2007 at 12:28:04PM +0300, Ilpo Järvinen wrote:
> 
> > [...snip...]
> > 
> > > BTW, some information are missing. It would have been better if the trace
> > > had been read with tcpdump -Svv. We would have got seq numbers and ttl.
> > > Also, we do not know if there's a firewall between both sides. Sometimes,
> > > some IDS identify attacks in crypted traffic and kill connections. It
> > > might have been the case here, with the connection closed one way on an
> > > intermediate firewall.
> > 
> > Yeah, firewall or some other issue, I'd say it's quite unlikely a bug in 
> > TCP because behavior to both directions indicate client -> sender 
> > blackhole independently of each other...
> 
> It would also be possible that something stupid between both ends simply
> drops packets with the SACK option set. Also something which sometimes
> happen is that some firewalls automatically translate sequence numbers
> but not necessarily SACK values, which could pretty well lead to this
> packet being received but ignored on the server side.

...One can toggle those off with /proc/sys/net/ipv4/tcp_dsack but I 
suspect DSACKs are not the cause because these retransmissions neither
are making it through (there are many of them also earlier in the log, 
just quoted the easiest ones :-) ):

> > > > 09:36:44.335591 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > > > 378 <nop,nop,timestamp 800227942 7692910>
> > > > 09:38:44.351950 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > > > 378 <nop,nop,timestamp 800257942 7692910>
> > > > 09:40:44.368172 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > > > 378 <nop,nop,timestamp 800287943 7692910>

...there are no SACKs involved in them, yet no cumulative ACK ever 
arrives from SERVER...


-- 
 i.
---696243703-2123637381-1185726287=:11113--
