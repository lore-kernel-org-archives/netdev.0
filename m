From: Martin Josefsson <gandalf@mjufs.se>
Subject: Re: [Bugme-new] [Bug 12954] New: SAMEIP --nodst functionality gone
 missing
Date: Wed, 8 Apr 2009 10:03:38 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0904080941370.10428@wlug.westbo.se>
References: <bug-12954-10286@http.bugzilla.kernel.org/>
 <20090407143509.05ab3b28.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	berni@birkenwald.de, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090407143509.05ab3b28.akpm@linux-foundation.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Apr 2009, Andrew Morton wrote:

>> Back in the days of 2.6.18 there was the SAME target which allowed, with the
>> option '--nodst' to SNAT internal hosts to the same address of a whole SNAT
>> range regardless of the destination address.
>>
>> In cb76c6a597350534d211ba79d92da1f9771f8226 the SAME target was removed from
>> the kernel sources due to being obsolete, since the same functionality was now
>> in nf_nat. Shortly after that a discussion Patrick McHardy proposed a patch to
>> mimic the behaviour of SAME with --nodst in nf_nat by dropping the destination
>> IP from the jhash. The patch was dropped shortly after because it apparently
>> showed some uneven distribution.
>>
>> The whole thread can be read at
>> http://thread.gmane.org/gmane.comp.security.firewalls.netfilter.devel/23275/focus=27670
>> .
>>
>> This thread went dead, I tried to revive it but did not get an answer. We're
>> getting hit by this regression because we are currently NATing some thousand IP
>> addresses (student dorms) to an external /28. It works fine with our old
>> 2.6.18+SAME setup, but tests with 2.6.25+SNAT showed massive issues with
>> connections from the same internal address to different destinations getting
>> NATed to different addresses in the pool. Which breaks, for example, ICQ quite
>> badly.

Problems like these were the reason why I wrote the SAME target in the 
first place. I NAT'ed a few hundred students behind a small range of 
ipaddresses and with normal SNAT they had extreme problems with ICQ and 
online banking sites which require you to have the same source ip even if 
you move between servers (diffrent destinations) etc.

After I wrote SAME I didn't get a single complaint.

One bonus feature that many students really liked was that they always 
had the same external ipaddress as long as they had the same internal 
ipaddress and the external range of ipaddresses remained the same.

This feature isn't as important as having the same source ip for all 
current sessions when using online banking services etc.

I didn't think anyone was still using SAME... guess I was wrong.

The uneven distribution of the patch in question can't be worse than the 
SAME distributions which, iirc, just does something like:

first_ip_in_snat_range + (client_ip % num_ips_in_snat_range)

And given many clients behind the SNAT the distribution should be quite 
even.


Patrick, how about making the ipaddress selection based on only client 
ipaddress behaviour selectable with an SNAT parameter if the problem with 
the patch is that the distribution can be uneven for a small number of 
clients?

/Martin
