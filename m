From: Matt Mathis <mattmathis@google.com>
Subject: Re: DSCP values in TCP handshake
Date: Tue, 19 Apr 2011 11:09:41 -0400
Message-ID: <BANLkTi=fDdoF=kSfY=9ER4iR3M27L=CLXw@mail.gmail.com>
References: <loom.20110418T154445-102@post.gmane.org>
	<1303135512.3137.335.camel@edumazet-laptop>
	<20110418083827.05dd2d43@nehalam>
	<alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se>
	<4DAC8A8A.1010401@cox.net>
	<alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
	<20110418144908.55967b06@nehalam>
	<alpine.DEB.2.00.1104190547300.14027@uplift.swm.pp.se>
	<20110418211637.57f1cfb8@nehalam>
	<alpine.DEB.2.00.1104190620070.14027@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Joe Buehler <aspam@cox.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:31782 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab1DSPJq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 11:09:46 -0400
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p3JF9iuv027402
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 08:09:44 -0700
Received: from ewy6 (ewy6.prod.google.com [10.241.103.6])
	by kpbe19.cbf.corp.google.com with ESMTP id p3JF9gN8024309
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 08:09:43 -0700
Received: by ewy6 with SMTP id 6so1845033ewy.10
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 08:09:41 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1104190620070.14027@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't know why this didn't make it into RFC, I can inquiry if there=
 is
> interest.

Please do.    This missing spec is one of the things that makes Less
than Best Effort (aka scavenger service) unusable.   Only the client
knows if they are fetching data in the background.   The server
doesn't care.

The other botch it is the spec that DSCP can be cleared under certain
conditions, which has the effect of promoting LBE to BE.   I have lost
track of the details.

Making LBE work would go a long way to solving the buffer bloat
problem and more....

Thanks,
--MM--
The best way to predict the future is to create it. =A0- Alan Kay




On Tue, Apr 19, 2011 at 12:28 AM, Mikael Abrahamsson <swmike@swm.pp.se>=
 wrote:
> On Mon, 18 Apr 2011, Stephen Hemminger wrote:
>
>> Linux does not look at DSCP of incoming packets (there is no queue).
>
> Then I see no reason for the policy of not reflecting DSCP.
>
> If we receive the DSCP marked packet then it means the network is eit=
her not
> QoS enabled (it doesn't care) or it's actually allowed through the bo=
rder
> router with DSCP unchanged. Either means it's safe to reflect the DSC=
P
> value, either it will have no effect or it's actually meant to be
> prioritized.
>
> With precedence, it originally was mandated that if the precedence va=
lue
> changed, the TCP session should be reset. Fortunately, this was chang=
ed but
> I would still say that it's thought that DSCP values should be reflec=
ted by
> the server.
>
> For instance:
>
> <http://tools.ietf.org/html/draft-ietf-ieprep-reflexive-dscp-02>
>
> "The requester could initiate this. Thus, if the DSCP
> =A0 received on one TCP segment differs from the TCP used on a prior =
TCP
> =A0 segment in a session, the new DSCP SHOULD be reflected unless loc=
al
> =A0 policy prevents this."
>
> I don't know why this didn't make it into RFC, I can inquiry if there=
 is
> interest.
>
> --
> Mikael Abrahamsson =A0 =A0email: swmike@swm.pp.se
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
