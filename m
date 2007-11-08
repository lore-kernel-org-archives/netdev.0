From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Why does a connect to IPv6 LLA address fail ?
Date: Thu, 08 Nov 2007 15:50:52 -0500
Message-ID: <473376AC.7010808@hp.com>
References: <20071107094007.GA15575@pingi.kke.suse.de> <20071107112838.GA22180@dhcp79.suse.cz> <4732151B.70309@hp.com> <200711081901.59334.agruen@suse.de> <47335258.4000806@hp.com> <20071108183221.GA17878@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Andreas Gruenbacher <agruen@suse.de>,
	Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:43062 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759541AbXKHUuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 15:50:55 -0500
In-Reply-To: <20071108183221.GA17878@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Karsten Keil wrote:
> 
> OK I run into this issue while running the TAHI testsuite. The test is as
> follows:
> 
>   Check 03:
>     DNS Address: fec0::9
>     Candidate Source Addresses: fec0::1(SS) or LLA(LS)
>     Destination Address List: 3fff::2(GS) or fe80::2(LS)
>     Result: fe80::2 (src LLA) then 3fff::2 (src fec0::1)
> 
>     Scope(fe80::2) = Scope(LLA) and Scope(3fff::2) <> Scope(fec0::1), then prefer fe80::2
> 
> the nameserver send following answer for the query:
> 
> | | | | DNS_Question                    (length:21)
> | | | | | DNS_QuestionEntry               (length:21)
> | | | | | | Name                             = server.tahi.org.
> | | | | | | Type                             = 28 (AAAA)
> | | | | | | Class                            = 1
> | | | | DNS_Answer                      (length:86)
> | | | | | DNS_RR_AAAA                     (length:43)
> | | | | | | Name                             = server.tahi.org.
> | | | | | | Type                             = 28
> | | | | | | Class                            = 1
> | | | | | | TTL                              = 0
> | | | | | | Length                           = 16
> | | | | | | Address                          = 3fff::2
> | | | | | DNS_RR_AAAA                     (length:43)
> | | | | | | Name                             = server.tahi.org.
> | | | | | | Type                             = 28
> | | | | | | Class                            = 1
> | | | | | | TTL                              = 0
> | | | | | | Length                           = 16
> | | | | | | Address                          = fe80::2
> 
> 
> 
> So how we should handle this issue, claim that the test is wrong, the test
> should not use LLA for this ?
> 

You could argue that a DNS server should not return link-local addresses because there
is no way for the DNS server to specify a correct zone.

I believe this is actually documented somewhere...

-vlad

