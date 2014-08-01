From: Nikolay Aleksandrov <nikolay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] netlink: Convert
 netlink_lookup() to use RCU protected hash table
Date: Fri, 01 Aug 2014 17:20:41 +0200
Message-ID: <53DBB049.30902@redhat.com>
References: <cover.1406891028.git.tgraf@suug.ch>
 <72a64dfee4f20f2ca596df26f3e4ae543cf4c068.1406891028.git.tgraf@suug.ch>
 <53DBA976.8030103@redhat.com> <20140801151527.GF7331@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org,
 tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140801151527.GF7331-FZi0V3Vbi30CUdFEqe4BF2D2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/01/2014 05:15 PM, Thomas Graf wrote:
> On 08/01/14 at 04:51pm, Nikolay Aleksandrov wrote:
>> Hmm, in both the rhashtable_insert() and rhashtable_remove() calls in the
>> netlink code you're using GFP_ATOMIC flags but if rhashtable_expand/shring gets
>> called even though the allocation will be with GFP_ATOMIC, they still call
>> synchronize_rcu() which may block. Now I'm not familiar with the netlink code,
>> but I think that in general the flags are useless for GFP_ATOMIC because of the
>> calls to synchronize_rcu() in expand/shrink which can block anyway.
>> Just a thought, I may be missing something of course.
> 
> I don't think you are missing anything. The GFP_ATOMIC flag was
> inherited from how the bucket table was allocated prior to the
> convertion to the new hash table but you are right, it can't be
> needed since the table protection was converted to a mutex.
> Using GFP_KERNEL will have a better chance of succeeding.
> 
Right, I was wondering why it was atomic in the first place and couldn't find a
good reason from the code :-)
But that explains it.

Cheers,
 Nik
