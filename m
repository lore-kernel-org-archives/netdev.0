From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [Bugme-new] [Bug 14839] New: Trying to use a TUN device fir IPv6
 traffic, cannot set destination address.
Date: Mon, 28 Dec 2009 11:00:06 -0800
Message-ID: <4B390036.90300@qualcomm.com>
References: <bug-14839-10286@http.bugzilla.kernel.org/> <20091222151238.e7e44e36.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"mcisho@yahoo.com" <mcisho@yahoo.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:36715 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074AbZL1TAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 14:00:07 -0500
Received: from ironrogue.qualcomm.com (ironrogue.qualcomm.com [129.46.61.164])
	by numenor.qualcomm.com (8.14.2/8.14.2/1.0) with ESMTP id nBSJ06GN001593
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 11:00:07 -0800
In-Reply-To: <20091222151238.e7e44e36.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Sat, 19 Dec 2009 10:35:18 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=14839
>>
>>            Summary: Trying to use a TUN device fir IPv6 traffic, cannot
>>                     set destination address.
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.31.6
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: IPV6
>>         AssignedTo: yoshfuji@linux-ipv6.org
>>         ReportedBy: mcisho@yahoo.com
>>         Regression: No
>>
>>
>> I am modifying a program that uses a TUN device for IPv4 traffic so that the
>> same TUN device can also be used for IPv6 traffic. Using ioctl SIOCSIFADDR will
>> add an IPv6 address but ioctl SIOCSDSTADDR to add an IPv6 destination address
>> always results in error ENODEV (19 No such device).
>>
>> I searched around the source and found addrconf_set_dstaddr in addrconf.c which
>> seems to be the routine called to set the destination address. However, the
>> routine only sets a destination address for a SIT device, otherwise if returns
>> ENODEV.
>>
>> Below is the ifconfig output for the TUN device:-
>> $ ifconfig tun3
>> tun3      Link encap:UNSPEC  HWaddr
>> 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  
>>           inet addr:192.168.3.235  P-t-P:192.168.250.235  Mask:255.255.255.255
>>           inet6 addr: fd00::3:235/128 Scope:Global
>>           UP POINTOPOINT RUNNING  MTU:1344  Metric:1
>>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>>           collisions:0 txqueuelen:500 
>>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>>
>> BTW, ifconfig cannot add an IPv6 destination address either, the code has a
>> comment saying that the support needs to be written.
>>
>> Can a TUN device be used for IPv6 traffic? I cannot find a definitive answer,
>> only 'should'. Or is that nobody has ever wanted to use a TUN device for IPv6
>> traffic, and so the kernel support has not been written? Or am I doing
>> something wrong?

Sorry for the delay guys. I was under the impression that things like OpenVPN
work just fine with IPv6 (OpenVPN uses TUN device).

Here is a quote from OpenVPN FAQ
--
Point-to-point IPv6 tunnels are supported on OSes which have IPv6 TUN driver
support (this includes Linux and the BSDs). IPv6 over TAP is always supported
as is any other protocol which can run over Ethernet.
--

So. I'd suggest looking at the OpenVPN code. AFAIK all the kernel plumbing is
fine.

Max



