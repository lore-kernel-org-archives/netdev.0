From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: strict isolation of net interfaces
Date: Fri, 30 Jun 2006 10:56:13 +0200
Message-ID: <44A4E72D.2060105@fr.ibm.com>
References: <m1psgulf4u.fsf@ebiederm.dsl.xmission.com> <44A1689B.7060809@candelatech.com> <20060627225213.GB2612@MAIL.13thfloor.at> <1151449973.24103.51.camel@localhost.localdomain> <20060627234210.GA1598@ms2.inr.ac.ru> <m1mzbyj6ft.fsf@ebiederm.dsl.xmission.com> <20060628133640.GB5088@MAIL.13thfloor.at> <1151502803.5203.101.camel@jzny2> <44A44124.5010602@vilain.net> <44A450D1.2030405@fr.ibm.com> <20060630023947.GA24726@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sam Vilain <sam@vilain.net>, hadi@cyberus.ca,
	Herbert Poetzl <herbert@13thfloor.at>,
	Alexey Kuznetsov <alexey@sw.ru>, viro@ftp.linux.org.uk,
	devel@openvz.org, dev@sw.ru, Andrew Morton <akpm@osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrey Savochkin <saw@swsoft.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>,
	Dave Hansen <haveblue@us.ibm.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:13489 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932141AbWF3I4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 04:56:31 -0400
To: "Serge E. Hallyn" <serue@us.ibm.com>
In-Reply-To: <20060630023947.GA24726@sergelap.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Serge E. Hallyn wrote:
> 
> The last one in your diagram confuses me - why foo0:1?  I would
> have thought it'd be

just thinking aloud. I thought that any kind/type of interface could be
mapped from host to guest.

> host                  |  guest 0  |  guest 1  |  guest2
> ----------------------+-----------+-----------+--------------
>   |                   |           |           |
>   |-> l0      <-------+-> lo0 ... | lo0       | lo0
>   |                   |           |           |
>   |-> eth0            |           |           |
>   |                   |           |           |
>   |-> veth0  <--------+-> eth0    |           |
>   |                   |           |           |
>   |-> veth1  <--------+-----------+-----------+-> eth0
>   |                   |           |           |
>   |-> veth2   <-------+-----------+-> eth0    |
> 
> I think we should avoid using device aliases, as trying to do
> something like giving eth0:1 to guest1 and eth0:2 to guest2
> while hiding eth0:1 from guest2 requires some uglier code (as
> I recall) than working with full devices.  In other words,
> if a namespace can see eth0, and eth0:2 exists, it should always
> see eth0:2.
> 
> So conceptually using a full virtual net device per container
> certainly seems cleaner to me, and it seems like it should be
> simpler by way of statistics gathering etc, but are there actually
> any real gains?  Or is the support for multiple IPs per device
> actually enough?
> 
> Herbert, is this basically how ngnet is supposed to work?
