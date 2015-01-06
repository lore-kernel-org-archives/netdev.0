From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 3/5] rhashtable: use future
 table size to make expansion decision
Date: Tue, 6 Jan 2015 17:56:23 +0800
Message-ID: <54ABB147.6020904@windriver.com>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
	<1420529003-22244-4-git-send-email-ying.xue@windriver.com>
	<20150106093557.GC12468@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20150106093557.GC12468@casper.infradead.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01/06/2015 05:35 PM, Thomas Graf wrote:
> On 01/06/15 at 03:23pm, Ying Xue wrote:
>> Should use future table size instead of old table size to decide
>> whether hash table is worth being expanded.
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Cc: Thomas Graf <tgraf@suug.ch>
>> ---
>>  lib/rhashtable.c |    5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Apologies as you were probably mislead by the bug as commented
> on in the previous patch.
> 
> I don't think we need this. future_tbl only points to a different
> table until the old table entries are linked from the new table.
> The condition in the resize check where meant to exclude this
> phase so we would newer get to the deferred worker while relinking
> is happening.
> 
> 

Thank you for above nice explanation. Regarding my understanding, as
rhashtable_expand() and rhashtable_shrink() are always under the
protection of "ht->mutex", the "future_tbl" and "tbl" absolutely point
to the same bucket array once rhashtable_expand() or rhashtable_shrink()
returns. Therefore, if rht_deferred_worker() takes the "ht->mutex" lock,
the both "future_tbl" and "tbl" should point to the same bucket array.
So the change made in the patch is useless for us, right?

But as you pointed in above patch, there is a bug in
rhashtable_wakeup_worker(). As long as ht->tbl == ht->future_tbl, we
should wake up the work. OK, I will drop the patch and fix the error in
patch #2.

In all, thank you for quickly reviewing the series, and I would deliver
the next version soon in which your all comments would be resolved.

Please wait a moment.

Regards,
Ying



------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
