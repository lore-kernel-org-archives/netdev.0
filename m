From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [Bugme-new] [Bug 15571] New: TCP madness - some packets are
 shunned.
Date: Thu, 25 Mar 2010 16:34:25 +0100
Message-ID: <4BAB8281.8000905@nets.rwth-aachen.de>
References: <bug-15571-10286@http.bugzilla.kernel.org/>
 <20100322143711.b78c7a93.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, jasen@treshna.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:38752 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754032Ab0CYPel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 11:34:41 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KZU001GLGLRTTF0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 25 Mar 2010 16:34:39 +0100 (CET)
In-reply-to: <20100322143711.b78c7a93.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.03.2010 22:37, schrieb Andrew Morton:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 18 Mar 2010 02:46:29 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=15571
>>
>>                URL: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=53646
>>                     2
>>            Summary: TCP madness - some packets are shunned.
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 2.6.30
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>         AssignedTo: acme@ghostprotocols.net
>>         ReportedBy: jasen@treshna.com
>>         Regression: No
>>
>>
>> The host http://www.cv-it.com is virtually unreachable with kernel 2.6.26 
>> (and later) slow with kernel 2.6.18 and just fine with windows XP.
>>
>> I used telnet to port 80 for testing.
>>
>> it seems to be a TCP issue, as the having the XP machine behind a linux based
>> iptables firewall pc causes no problems, but telnet from the firewall pc itself
>> to port 80 on www.cv-it.com does not work

For me it seems to be the host is messing up with the window scale option.
Although it claims to support window scaling:
16:23:17.466592 IP x.x.x.x.51151 > 121.199.32.220.80: Flags [S], seq 2159265664, win 5840, options [mss 1460,sackOK,TS val 8382141 ecr 0,nop,wscale 7], length 0
16:23:17.761697 IP 121.199.32.220.80 > x.x.x.x.51151: Flags [S.], seq 3910885479, ack 2159265665, win 65535, options [mss 1448,sackOK,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,nop,wscale 8], length 0

My host (linux 2.6.32) is offering a window of 5888 (46<<7):
16:23:17.761740 IP x.x.x.x.51151 > 121.199.32.220.80: Flags [.], ack 1, win 46, length 0

And cv-it.com seems to think there is only a window of 46 ignoring the previously negotiated window scaling:
16:23:23.066318 IP 121.199.32.220.80 > x.x.x.x.51151: Flags [.], seq 1:47, ack 112, win 65160, length 46

You can disable window scaling with:
sysctl -w "net.ipv4.tcp_window_scaling=0"


Best regards,
Arnd
