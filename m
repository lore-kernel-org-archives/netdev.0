From: Patrick McHardy <kaber@trash.net>
Subject: Re: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 18:46:48 +0100
Message-ID: <4B140508.1090802@trash.net>
References: <alpine.DEB.2.00.0911301104520.16713@router.home> <4B13FF05.5060005@trash.net> <alpine.DEB.2.00.0911301123110.17037@router.home> <4B140129.2050907@trash.net> <alpine.DEB.2.00.0911301133280.17037@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56303 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbZK3Rqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:46:43 -0500
In-Reply-To: <alpine.DEB.2.00.0911301133280.17037@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> On Mon, 30 Nov 2009, Patrick McHardy wrote:
> 
>>> Where do I find more recent documentation?
>> Below :)
> 
> I found http://lwn.net/Articles/271597/ which mentions that those two
> values may be set too strictly. Can they default to zero?

No, this is deliberate since it diverges from the behaviour of other
helpers. Usually they only allow to create RELATED connections between
the two hosts communicating. If you set either of these module options
to zero, they will allow completely foreign addresses to establish
connections when those addresses appear in the SDP payload. You should
usually use additional filters to f.i. only allow source addresses of
your registrar:

iptables -A FORWARD -m state --state RELATED \
		    -m helper --helper "sip" \
		    -s registrar-network/X -j ACCEPT

>> You of course also need to accept the packets marked RELATED by
>> the helper. If this is missing it might result in one-way audio.
> 
> Firewall is configured to accept all udp traffic. Will that do it?

That should be fine, but you can restrict it to just accept
-m state --state RELATED packets.

> The "helper" is the conntrack module?

Yes.

