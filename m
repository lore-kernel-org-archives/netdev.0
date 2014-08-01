From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] nftables: Convert nft_hash to
 use generic rhashtable
Date: Fri, 1 Aug 2014 11:39:01 +0100
Message-ID: <20140801103901.GC7331@casper.infradead.org>
References: <cover.1406882738.git.tgraf@suug.ch>
 <cover.1406882738.git.tgraf@suug.ch>
 <ea51f2fdfb1ce84ff109d03bf37811e4b24135c5.1406882738.git.tgraf@suug.ch>
 <970429e5-2465-40f2-998b-b82dab3debe8@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <970429e5-2465-40f2-998b-b82dab3debe8-2ueSQiBKiTY7tOexoI0I+QC/G2K4zDHf@public.gmane.org>
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

On 08/01/14 at 11:17am, Patrick McHardy wrote:
> On 1. August 2014 09:52:00 GMT+01:00, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
> >If the set size is known in advance, the table is sized accordingly,
> >otherwise the table size will default to 64. This is a slight change
> >in behaviour as previously the default was 4 which eventually required
> >many expansion iterations.
> 
> That's assuming a sufficient number of entries will be added. I think there
> will be many cases in nftables where the number will be lower. Since
> expansion is not very expansive this number was chosen very deliberately
> and I'd prefer to keep it.
> 
> Other than that:
> 
> Acked-by: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>

OK, I will change the nft_hash default size back to 4.

I think the expansion is more expensive than it looks though as we
are potentially calling synchronize_rcu() multiple times while
holding a mutex to protect from concurrent mutations.
