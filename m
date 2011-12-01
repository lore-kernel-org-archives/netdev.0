From: Jeroen van Ingen <jeroen@zijndomein.nl>
Subject: Re: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Thu, 01 Dec 2011 17:25:28 +0100
Message-ID: <1322756728.12482.52.camel@icts-sp-039>
References: <1322585087.25018.115.camel@icts-sp-039>
	 <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>
	 <20111129.182333.365445684859306013.davem@davemloft.net>
	 <alpine.LFD.2.00.1111300148400.2328@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.utsp.utwente.nl ([130.89.2.8]:33263 "EHLO smtp.utwente.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882Ab1LAQZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Dec 2011 11:25:49 -0500
In-Reply-To: <alpine.LFD.2.00.1111300148400.2328@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian, David,

> > > 	May be the solution is to convert inet_addr_lst
> > > from hlist to normal list, so that we can append new
> > > addresses at tail and __ip_dev_find to find the first
> > > device where IP was added.
> > 
> > Sure, but do we really want to guarentee this behavior forever?
> 
> 	I remember for such issue with ipsec%d interfaces
> years ago. May be the PPP servers should be configured
> to use another local IP for PPP devices because broadcasts
> and multicasts may need their own local address - they can use
> addresses to refer to output devices.
> 
> 	Not sure what else we can do, now we have to waste
> 1-2KB for this to work before someone recreates the eth
> addresses and changes the ordering.

FYI: we successfully tested two scenarios that provide a workaround with
the current kernel versions:

1) Explicitly configuring Radius to use one of the secondary IPs as
source for the DHCP broadcast. Since the IP we chose is only bound to
eth0, this broadcast goes out the correct interface. Other
system-generated broadcast would probably still go out the wrong
interface, but at least it allows us to accept more than one PPTP
client.

2) Adding an option to the "pppd" config, so the ppp-devices it creates
do not use the primary IP from eth0 but rather one of the secondary
addresses. This way we don't have to modify any other software that
might generate a broadcast.


While the second option provides a workable solution for us, we're still
under the impression that this change in behavior might cause a problem
for other users and/or configurations as well. We'll leave the rest of
the considerations to the real experts, while remaining curious about
the outcome :)

Thanks again for your assistance.


Regards,

Jeroen van Ingen
ICT Service Centre
University of Twente, P.O.Box 217, 7500 AE Enschede, The Netherlands
