From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is dropped
 after ~40 seconds
Date: Thu, 17 Dec 2009 21:53:20 +0100
Message-ID: <4B2A9A40.90203@freemail.hu>
References: <bug-14794-10286@http.bugzilla.kernel.org/> <20091216154713.f082e7cf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02d.mail.t-online.hu ([84.2.42.7]:53837 "EHLO
	mail02d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759982AbZLQVDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 16:03:51 -0500
In-Reply-To: <20091216154713.f082e7cf.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I bisected the problem, see http://bugzilla.kernel.org/show_bug.cgi?id=3D=
14794
for details. Any idea what is the relation between this problem and the=
 found
patch?

Regards,

	M=E1rton N=E9meth

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> A 2.6.31 -> 2.6.32 regression.
>=20
> On Sun, 13 Dec 2009 08:59:48 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
>> http://bugzilla.kernel.org/show_bug.cgi?id=3D14794
>>
>>            Summary: IP address assigned by DHCP is dropped after ~40
>>                     seconds
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.32
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV4
>>         AssignedTo: shemminger@linux-foundation.org
>>         ReportedBy: nm127@freemail.hu
>>         Regression: Yes
>>
>>
>> Created an attachment (id=3D24165)
>>  --> (http://bugzilla.kernel.org/attachment.cgi?id=3D24165)
>> Wireshark log while acquiring IP address
>>
>> The IP address which was assigned by DHCP is dropped and the address
>> 169.254.123.251 is set. This happens on Clevo D4J model D410J with 2=
=2E6.32, but
>> works correctly with 2.6.31.
>>
>> Steps to reproduce:
>> 1. Boot the system
>> 2. In an xterm window execute the following command to see the actua=
l IP
>> address settings:
>>    while true; do clear; date; /sbin/ifconfig; sleep 1; done
>> 3. Unplug the network cable for some seconds: the IP address should =
be gone
>> 4. Plug the network cable.
>> 5. After about 10 seconds the IP address 192.168.1.64 assigned by DH=
CP is
>> visible
>> 6. After about 50 seconds (counting from the plug of the network cab=
le) no IP
>> address is assigned
>> 7. After about 65 seconds (counting from the plug of the network cab=
le) the IP
>> address 169.254.123.251 is assigned. This IP address will not work o=
n this
>> network.
>>
>> I run Wireshark during the whole process, see the attached log file.
>> Packet 25..28: DHCP address is fetched.
>> Packet 63: DHCP release: this should not happen
