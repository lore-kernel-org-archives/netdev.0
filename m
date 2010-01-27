From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Wed, 27 Jan 2010 14:36:18 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1001261016320.17103@melkinpaasi.cs.helsinki.fi>
References: <200912261703.49067.denys@visp.net.lb> <201001191309.03927.denys@visp.net.lb> <alpine.DEB.2.00.1001191308490.14108@wel-95.cs.helsinki.fi> <201001232337.19122.denys@visp.net.lb> <alpine.DEB.2.00.1001240007530.16552@melkinpaasi.cs.helsinki.fi>
 <4B5D8ABB.8030906@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48946 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753397Ab0A0MgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 07:36:20 -0500
In-Reply-To: <4B5D8ABB.8030906@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010, Damian Lukowski wrote:

> considering Denys' latest tests, I think we should bound
> at TCP_RTO_MIN inside __tcp_set_rto().
> Look at the following piece:
> > [  604.193389] rto: 200 (0 >> 3 + 0, 32) time: 304193 sent: 304091 pen: 1 307291 rem: 98                                                                                         
> > [  604.193518] lower bound violation: 0 code 1 sk_state 1                                                                                                                        
> > [  604.193589] rto: 200 (0 >> 3 + 0, 31) time: 304193 sent: 304091 pen: 1 304291 rem: 98                                                                                         
> > [  604.193706] lower bound violation: 0 code 1 sk_state 1                                                                                                                        
> > [  604.193776] rto: 200 (0 >> 3 + 0, 30) time: 304193 sent: 304091 pen: 1 304291 rem: 98                                                                                         
> > [  607.341327] lower bound violation: 0 code 1 sk_state 1                                                                                                                        
> > [  607.341412] rto: 200 (0 >> 3 + 0, 33) time: 307341 sent: 307091 pen: 1 310291 rem: 0  
> 
> We have a burst of three incoming ICMPs, not triggering retransmissions because
> of rem > 0. Nevertheless, there is an increase of icsk_backoff by four
> within 3100ms, with no ICMPs in between.
> For me, this is explainable by the broken mdev/rtt issue together with
> bursty ICMP replies.

Unless they are for a different connection? We might have to print sk (%p) 
in all those printouts to be sure which maps to which. If a peer becomes 
unreachable, it may well have multiple connections open (this was a 
proxy, iirc?).

-- 
 i.
