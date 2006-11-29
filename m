From: Brian Haley <brian.haley@hp.com>
Subject: Re: Network virtualization/isolation
Date: Wed, 29 Nov 2006 15:21:00 -0500
Message-ID: <456DEBAC.4060106@hp.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>	<20061026085659.33b4c6dd@freekitty>	<200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com>	<1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>	<456C447E.5090703@fr.ibm.com>	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>	<456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, hadi@cyberus.ca,
	Dmitry Mishin <dim@openvz.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:6606 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S967623AbWK2UVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 15:21:14 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m14psji6lw.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> I think for cases across network socket namespaces it should
> be a matter for the rules, to decide if the connection should
> happen and what error code to return if the connection does not
> happen.
> 
> There is a potential in this to have an ambiguous case where two
> applications can be listening for connections on the same socket
> on the same port and both will allow the connection.  If that
> is the case I believe the proper definition is the first socket
> that we find that will accept the connection gets the connection.

Wouldn't you want to catch this at bind() and/or configuration time and 
fail?  Having overlapping namespaces/rules seems undesirable, since as 
Herbert said, can get you "unexpected behaviour".

> I think with the appropriate set of rules it provides what is needed
> for application migration.  I.e. 127.0.0.1 can be filtered so that
> you can only connect to sockets in your current container.
> 
> It does get a little odd because it does allow for the possibility
> that you can have multiple connected sockets with same source ip,
> source port, destination ip, destination port.  If the rules are
> setup appropriately.  I don't see that peculiarity being visible on
> the outside network so it shouldn't be a problem.

So if they're using the same protocol (eg TCP), how is it decided which 
one gets an incoming packet?  Maybe I'm missing something as I don't 
understand your inside/outside network reference - is that to the 
loopback address comment in the previous paragraph?

Thanks,

-Brian
