From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Thu, 7 Jan 2010 09:55:23 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001070954240.3417@melkinpaasi.cs.helsinki.fi>
References: <20100106.002328.141253811.davem@davemloft.net> <20100106.150453.186399201.davem@davemloft.net> <alpine.DEB.2.00.1001070231540.26362@melkinpaasi.cs.helsinki.fi> <20100106.165933.226786062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-861915836-1262850924=:3417"
Cc: Netdev <netdev@vger.kernel.org>, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47833 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab0AGHzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 02:55:25 -0500
In-Reply-To: <20100106.165933.226786062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-861915836-1262850924=:3417
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 6 Jan 2010, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 7 Jan 2010 02:34:51 +0200 (EET)
> 
> > On Wed, 6 Jan 2010, David Miller wrote:
> > 
> >> 3) tcp_data_queue() should make it to, and hit, this conditional:
> >> 
> >> 	if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
> >> 
> >>    which will schedule an ACK the same exact way we would if
> >>    tcp_sequence() rejected the sequence range.
> >> 
> >> So it's a mystery why we aren't responding to Windows 2000's
> >> BSD 4.2 style zero window probes.
> >> 
> >> Can someone please validate my analysis?
> > 
> > In 3) I don't see why we'd hit that one as peer's snd_una+1 would be 
> > larger than rcv_nxt.
> 
> Peer constructs keepalive packet using sequence [snd.una-1,snd.una],
> both of which are <= rcv_nxt

Right, I later realized that there was this !urgent but was already too 
much heading to zzz to correct it.


-- 
 i.
---696230645-861915836-1262850924=:3417--
