From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 15720] New: IPv6's ipv4-compatibility addresses
 don't bind
Date: Tue, 13 Apr 2010 11:06:38 -0400
Message-ID: <4BC4887E.1050801@hp.com>
References: <bug-15720-10286@https.bugzilla.kernel.org/> <20100412212241.d8bf4185.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: charles@kde.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:12038 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab0DMPGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:06:43 -0400
In-Reply-To: <20100412212241.d8bf4185.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
>> When attempting to bind to an address using ipv4-compatibility, for example,
>> "::ffff:127.0.0.1", Linux refuses to bind to that address when
>> /proc/sys/net/ipv6/bindv6only is set.

This is actually not a (deprecated) IPv4-compatible IPv6 address (::127.0.0.1),
but an IPv4-mapped IPv6 address.

>> It seems to me that the intent of "bindv6only" was to not bind to the ipv4
>> address when you bind to all addresses (specifically ipv6 address "::"). So
>> when you bind to ::, an ipv4 client connects to you, and it appears to be
>> connecting from ::ffff:192.168.5.5. I don't think its intent was to effectively
>> disable binding to ::ffff:x.x.x.x addresses - just breaking that feature makes
>> no sense.

It is documented in ip-sysctl.txt:

bindv6only - BOOLEAN
        Default value for IPV6_V6ONLY socket option,
        which restricts use of the IPv6 socket to IPv6 communication
        only.
                TRUE: disable IPv4-mapped address feature
                FALSE: enable IPv4-mapped address feature

        Default: FALSE (as specified in RFC2553bis)

-Brian
