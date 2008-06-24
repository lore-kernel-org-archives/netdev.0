From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies available to userspace
Date: Tue, 24 Jun 2008 10:02:42 +0200
Message-ID: <200806241002.42482.tomasz@grobelny.oswiecenia.net>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806202303.37924.tomasz@grobelny.oswiecenia.net> <20080623165826.GB8692@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from oswiecenia.net ([83.13.108.58]:2111 "EHLO poczta.oswiecenia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbYFXIDC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 04:03:02 -0400
In-Reply-To: <20080623165826.GB8692@gerrit.erg.abdn.ac.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia Monday 23 of June 2008, Gerrit Renker napisa=B3:
> | > We could still encode the parameters in the policy ID, by splitti=
ng the
> | > bitmask, e.g. the low 24 bits to encode parameters, and the high =
8 bits
> | > to encode the policies using the same combination of parameters.
> |
> | Yes, technically we could do it this way. Encoding accepted paramet=
ers in
> | policy ID would provide applications with means to check whether ce=
rtain
> | parameters are supported. But should we mix two IMO distinct concep=
ts
> | (policy behaviour and accepted parameters) in one bitfield? I'd rat=
her
> | have them separated.
>
> Yes having them separate gives a clearer semantics. But it comes at a=
 price
> - to retrieve the parameters, we need an extra function or lookup tab=
le.
>
An additional bitfield in dccp_qpolicy_operations should do it when it =
comes=20
to storing that information. When it comes to retrieving see next point=
=2E..

> Maybe there is an elegant solution which allows to encode the require=
d
> parameters while keeping the semantics clear?
>
What about something like:
	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_ID, DCCPQ_POLICY_PRIO);
to choose policy (exactly as it is now) and a new function to ensure th=
at the=20
kernel understands parameters:
	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_PARAMS, DCCP_SCM_PRIORITY |=20
DCCP_SCM_TIMEOUT);

The second call would return an error if the kernel does not know anyth=
ing=20
about DCCP_SCM_TIMEOUT (or a choosen policy does not support it). This =
would=20
have the additional benefit (over similar getsockopt) that the kernel w=
ill be=20
able to optimize its behaviour knowning the set of parameters that will=
 be=20
used.

What do you think about such an interface?
--=20
Regards,
Tomasz Grobelny
