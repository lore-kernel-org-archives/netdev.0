From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 17622] New: snmp trap ALG issue
Date: Tue, 14 Sep 2010 16:32:08 -0700
Message-ID: <20100914163208.2ba165ca.akpm@linux-foundation.org>
References: <bug-17622-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: wtweeker@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33503 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755396Ab0INXcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 19:32:41 -0400
In-Reply-To: <bug-17622-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 2 Sep 2010 09:25:12 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=17622
> 
>            Summary: snmp trap ALG issue
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.35.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: wtweeker@163.com
>         Regression: No
> 
> 
> Symptom:
> SNMP manager can't show trap when SNMP agent set trap message to  version1.
> 
> steps to reproduce:
> (1)SNMP agent-----linux device(NAT)-----SNMP manager.
> (2)Set SNMP agent trap message to version 1, destination IP as SNMP   manger's
> IP.
> (3)Do some operation to generate trap message, such as make one port of SNMP
> agent up and down. But SNMP manger can't accept trap message.
> 
> I have capured the packet by Ethereal software, and check the SNMP trap packet,
> found that the UDP checksum is incorrect. 
> I think that the function fast_csum()(nf_nat_snmp_basic.c) have some problem.
> 

and


> I have changed this function by refering to other checksum algorithm.
> And tested it, it can work. the checksum is correct. 
> 
> static void fast_csum(__sum16 *csum,
>               const unsigned char *optr,
>               const unsigned char *nptr,
>               int offset)
> {
>     unsigned char s[4];
> 
>     if (offset & 1) {
>         s[0] = s[2] = 0;
>         s[0] = ~s[0]; //this line is add by me
>         s[1] = ~*optr;
>         s[3] = *nptr;
>     } else {
>         s[1] = s[3] = 0;
>         s[1] = ~s[1];//this line is add by me
>         s[0] = ~*optr;
>         s[2] = *nptr;
>     }
> 
>     *csum = csum_fold(csum_partial(s, 4, ~csum_unfold(*csum)));
> }

Great.  Please prepare a kernel patch as per
Documentation/SubmittingPatches and send it via a reply-to-all to this
email?

Thanks.
