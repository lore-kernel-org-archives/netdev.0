From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: memory leak in udp_table_init
Date: Wed, 29 Feb 2012 10:28:13 -0800
Message-ID: <877gz5ze82.fsf@xmission.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	<paul.gortmaker@windriver.com>, <tim.bird@am.sony.com>,
	<kuznet@ms2.inr.ac.ru>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E7D@saturn3.aculab.com>
	(David Laight's message of "Mon, 27 Feb 2012 11:33:07 -0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"David Laight" <David.Laight@ACULAB.COM> writes:

>> It was to match the comment we have few lines above :
>> 
>> /*
>>  * The pid hash table is scaled according to the amount of memory in
> the
>>  * machine.  From a minimum of 16 slots up to 4096 slots at one
> gigabyte or
>>  * more.
>>  */

The comment was actually correct until someone converted the code to use
alloc_large_system_hash.

> These large hash tables are, IMHO, an indication that the
> algorithm used is, perhaps, suboptimal.
>
> Not least of the problems is actually finding a suitable
> (and fast) hash function that will work with the actual
> real-life data.
>
> The pid table is a good example of something where a hash
> table is unnecessary.
> Linux should steal the code I put into NetBSD :-)

On this unrelated topic.  What algorithm did you use on NetBSD for
dealing with pids?

A hash chain length of 1 for common sizes is a pretty attractive
algorithm, as it minimizes the number of cache line misses.  Ages ago
when I modeled the linux situation that is what I was seeing.

The normal case for the linux pid hash table is that it has 4096
entries taking 16k or 32k of memory and the typical process load
has about 200 or so processes.    Making it very easy in the common
case to have a single entry hash chain.

All of the other algorithms I know have a tree structure and thus
more cache misses (as you traverse the tree) and ultimately worse
real world performance.

Eric
