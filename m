From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12753] New: /proc/net/xt_recent/: +IP / -IP
 commands broken for IPv4
Date: Wed, 25 Feb 2009 06:04:09 +0100
Message-ID: <49A4D149.7070101@trash.net>
References: <bug-12753-10286@http.bugzilla.kernel.org/> <20090224125830.e89f28c5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, joe-lk@ttdpatch.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51149 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbZBYFEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 00:04:13 -0500
In-Reply-To: <20090224125830.e89f28c5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>>
>> Latest working kernel version: up to at least 2.6.24
>> Earliest failing kernel version: first noticed with upgrade to 2.6.28
> 
> So it's a regression?

Yes. The fix is on its way upstream.

>> Possible solutions:
>> - initialize the addr variable in recent_mt_proc_write
>> - compare only 4 bytes for IPv4 addresses in recent_entry_lookup
>>
>> Simplest fix:
>> --- linux-2.6.28.7/net/netfilter/xt_recent.c.org        2009-02-22
>> 17:34:19.000000000 +0100
>> +++ linux-2.6.28.7/net/netfilter/xt_recent.c    2009-02-22 17:34:21.000000000
>> +0100
>> @@ -544,7 +544,7 @@
>>         struct recent_entry *e;
>>         char buf[sizeof("+b335:1d35:1e55:dead:c0de:1715:5afe:c0de")];
>>         const char *c = buf;
>> -       union nf_inet_addr addr;
>> +       union nf_inet_addr addr = {};
>>         u_int16_t family;
>>         bool add, succ;
>>
> 
> hm, that function does some pretty ugly things.
> 
> I wonder if the same bug exists elsewhere (or might do so in the
> future).  A more general fix would be to write a new
> in6_to_nf_inet_addr() and in4_to_nf_inet_addr() which correctly
> initialise the whole union.

I don't think thats necessary, there are no intentions of adding
more text-based interfaces.
