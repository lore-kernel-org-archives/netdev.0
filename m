From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 2/7] NetLabel: core network changes
Date: Mon, 31 Jul 2006 08:43:50 -0400
Message-ID: <36282A1733C57546BE392885C0618592013E80CA@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@epoch.ncsc.mil, jmorris@redhat.com,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:49735 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1030182AbWGaMqP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 08:46:15 -0400
To: Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The NetLabel patch allows administrators to assign specific a CIPSO 
> DOI/configuration to each LSM "domain".  Blindly using the 
> CIPSO tag that the 
> remote host sends could violate the administrator's NetLabel 
> configuration.  
> 
> The current patch reads the CIPSO tag off the child socket, 
> translating the 
> tag according to the CIPSO DOI configuration to arrive at the 
> correct/desired 
> LSM  security attributes.  These LSM security attributes and 
> the "domain" are 
> then used to set the NetLabel on the socket.  In the case 
> where everyone is 
> well behaved this should have no effect on the socket IP 
> options and the 
> packets sent across the wire.  However, in the case of a 
> not-nice remote host 
> the outgoing CIPSO tag may change to match the administrators desired 
> settings.

I wonder if waiting till accept isn't too late though. Perhaps this
should be done when the openreq is created so the syn-ack and such
will go out with the right tag?
