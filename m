From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Implementation worries about default address selection (fwd)
Date: Wed, 16 Oct 2002 08:51:23 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210160849300.9623-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There were some worries about default address selection performance.

This is one person's (BSD implementer) has noticed, and it doesn't look 
*too* bad for now.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords

---------- Forwarded message ----------
Date: Wed, 16 Oct 2002 14:27:03 +0900
From: "JINMEI Tatuya / [ISO-2022-JP] 神明達哉"
    <jinmei@isl.rdc.toshiba.co.jp>
To: Pekka Savola <pekkas@netcore.fi>
Cc: Erik Nordmark <Erik.Nordmark@Sun.COM>, ipng@sunroof.eng.sun.com
Subject: Re: Implementation worries about default address selection

>>>>> On Fri, 11 Oct 2002 09:54:55 +0300 (EEST), 
>>>>> Pekka Savola <pekkas@netcore.fi> said:

> Perhaps we should have been more careful when discussing "how/when" to use 
> caching.

> But well, 'htsearch' on RFC's for "cache" at http://rfc.eunet.fi (for
> example) returns 520 RFC's.

> I think there are examples of some caching specification, as well (e.g.  
> neighbor discovery, multicast, ...).  The level of detail is of course
> imporant.  At least, very many specifications say, like "this and this
> part is critical and should [or SHOULD] be cached".

> One of my main worries was that it seemed that nobody even bothered to 
> mention that the steps could be complex and some caching mechanism 
> (possibly with some examples) should be implemented.

IMO, it is not necessarily a problem that nobody bothered.  I've not
bothered (though I've made some comments on the draft) about the
complexity because I didn't think it was a problem of the document
based on my experiences on implementing and operating with the
specification.

In general, whether or not we need a cache depends on how severe the
related performance issue is.  And the performance in this case
depends on several parameters such as the number of addresses and how
many times each selection rule applies.

Please let me explain my own environments.  My laptop usually has
quite a large number of addresses, and the property of the addresses
varies much; it has 12 (unicast) addresses as of writing this,
including the loopback, link-local, site-local, and global ones.  It
also has temporary addresses for privacy extension, and some of the
temporary addresses are often deprecated due to the short lifetimes.
(note: the number "12" will be much increased in a few days.  I
rebooted my laptop last night, so it has only one temporary address
for each autoconfigured prefix.  More and more new temporary addresses
will come.)

A few days ago, I checked statistics on the source address selection
on the laptop.  By then it had been running for 6.5 days.  According
to the statistics, about 76.8% of the pair-wise address comparisons
had been broken by the rule 2 (Prefer appropriate scope) and the rule
3 (Avoid deprecated addresses).  IMO, the rules 1-3 are quite simple
and light, and do not affect the performance much.

I don't have a quantitative result on the performance, but at least
I've never felt untolerable performance degradation that can be
considered due to the complexity of the source address selection.  I
can expect counterarguments against the analysis above; "it is just a
single, personal, and limited environment." "perhaps your laptop has a
fast CPU.  Think about poor devices." "just because you don't feel
degradation does not mean the performance issue is not a problem",
etc...  I understand all of them.  But I'd say this comes from a
*real* experiences on implementation and operation, not just from
reading the specification.  If you want to make the document include
caching, please show us how the selection rules badly affect the
performance and how the caching improves the performance degradation
*with a working implementation*.  (However, I must also say that it is
not always the case that the requirement to implement caching comes
from actual experiences with working implementations.  So I may be a
bit unfair here.)

As a result, I don't think it is necessary to require (either SHOULD
or MUST) caching in the address selection draft.  I don't oppose to
mentioning the fact that caching may improve the performance, though.

					JINMEI, Tatuya
					Communication Platform Lab.
					Corporate R&D Center, Toshiba Corp.
					jinmei@isl.rdc.toshiba.co.jp
