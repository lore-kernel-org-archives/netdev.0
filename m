From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Devel] Re: Network virtualization/isolation
Date: Thu, 30 Nov 2006 11:15:11 -0500
Message-ID: <456F038F.8090509@hp.com>
References: <453F8800.9070603@fr.ibm.com>	<45408397.8070404@fr.ibm.com>	<20061026085659.33b4c6dd@freekitty>	<200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com>	<1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>	<456C447E.5090703@fr.ibm.com>	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>	<456C9B8C.1010701@fr.ibm.com> <m14psji6lw.fsf@ebiederm.dsl.xmission.com> <456DEBAC.4060106@hp.com> <456E055F.8020100@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>, hadi@cyberus.ca,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:25506 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S1759257AbWK3Q0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 11:26:21 -0500
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <456E055F.8020100@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano wrote:
> Brian Haley wrote:
>> Eric W. Biederman wrote:
>>> I think for cases across network socket namespaces it should
>>> be a matter for the rules, to decide if the connection should
>>> happen and what error code to return if the connection does not
>>> happen.
>>>
>>> There is a potential in this to have an ambiguous case where two
>>> applications can be listening for connections on the same socket
>>> on the same port and both will allow the connection.  If that
>>> is the case I believe the proper definition is the first socket
>>> that we find that will accept the connection gets the connection.
> No. If you try to connect, the destination IP address is assigned to a
> network namespace. This network namespace is used to leave the listening
> socket ambiguity.
>>
>> Wouldn't you want to catch this at bind() and/or configuration time and
>> fail?  Having overlapping namespaces/rules seems undesirable, since as
>> Herbert said, can get you "unexpected behaviour".
> 
> Overlapping is not a problem, you can have several sockets binded on the
> same INADDR_ANY/port without ambiguity because the network namespace
> pointer is added as a new key for sockets lookup, (src addr, src port,
> dst addr, dst port, net ns pointer). The bind should not be forced to a
> specific address because you will not be able to connect via 127.0.0.1.

So, all this leads to me ask, how to handle 127.0.0.1?

For L2 it seems easy.  Each namespace gets a tagged lo device.
How do you propose to do it for L3, because disabling access to loopback is
not a valid option, IMO.

I agree that adding a namespace to the (using generic terms) TCB lookup 
solves the conflict issue.

-vlad
