From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not
 equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Wed, 22 Sep 2010 02:02:12 -0700
Message-ID: <20100922020212.d2aaec57.akpm@linux-foundation.org>
References: <bug-18952-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, yuri@itinteg.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54092 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752272Ab0IVJDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 05:03:17 -0400
In-Reply-To: <bug-18952-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 22 Sep 2010 08:50:12 GMT bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=18952
> 
>            Summary: The mount of SYN retries is not equal to
>                     /proc/sys/net/ipv4/tcp_syn_retries
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32.12, 2.6.32.15, 2.6.35.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: yuri@itinteg.net
>         Regression: No
> 
> 
> When setting a value in  /proc/sys/net/ipv4/tcp_syn_retries, the actual number
> of syn retries is the number set in  /proc/sys/net/ipv4/tcp_syn_retries minus
> 2.
> 
> For example:
> When setting /proc/sys/net/ipv4/tcp_syn_retries to 5 the actual number of SYN
> retries is 3.
> When setting /proc/sys/net/ipv4/tcp_syn_retries to 7 the actual number of SYN
> retries is 5.
> However, when setting setting /proc/sys/net/ipv4/tcp_syn_retries to 2 the
> actual number of SYN retries is 2.
> 
> Note: In the kernel 2.6.31.9 actual number of SYN = tcp_syn_retries + 1
> 
> 
> Steps to reproduce:
> sudo iptables -I INPUT 1 -i lo -p tcp --dport 88 -j DROP
> sudo tcpdump -n -i lo -v tcp port 88
> 
> from another console run:
> time wget -t 1 -O - --connect-timeout=300 http://0:88
> 
> tcpdump output:
> sudo tcpdump -n -i lo -v tcp port 88
> 11:29:39.820058 IP (tos 0x0, ttl 64, id 14664, offset 0, flags [DF], proto TCP
> (6), length 60)
>     127.0.0.1.43730 > 127.0.0.1.kerberos: Flags [S], cksum 0xfe30 (incorrect ->
> 0xecf4), seq 1012617667, win 32792, options [mss 16396,sackOK,TS val 12871819
> ecr 0,nop,wscale 7], length 0
> 11:29:42.824091 IP (tos 0x0, ttl 64, id 14665, offset 0, flags [DF], proto TCP
> (6), length 60)
>     127.0.0.1.43730 > 127.0.0.1.kerberos: Flags [S], cksum 0xfe30 (incorrect ->
> 0xe137), seq 1012617667, win 32792, options [mss 16396,sackOK,TS val 12874824
> ecr 0,nop,wscale 7], length 0
> 11:29:48.832153 IP (tos 0x0, ttl 64, id 14666, offset 0, flags [DF], proto TCP
> (6), length 60)
>     127.0.0.1.43730 > 127.0.0.1.kerberos: Flags [S], cksum 0xfe30 (incorrect ->
> 0xc9bf), seq 1012617667, win 32792, options [mss 16396,sackOK,TS val 12880832
> ecr 0,nop,wscale 7], length 0
> 
> wget output:
> time wget -t 1 -O - --connect-timeout=300 http://0:88
> Resolving 0... 0.0.0.0
> Connecting to 0|0.0.0.0|:88... failed: Connection timed out.
> Giving up.
> 
> 
> real    0m21.050s
> user    0m0.003s
> sys     0m0.004s
> 
> It valid for remote host also.
> 

