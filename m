From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix secure tcp sequence number generation
Date: Tue, 5 Oct 2004 13:27:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005132724.6a913c48.davem@davemloft.net>
References: <415EEF0E.3080808@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <415EEF0E.3080808@colorfullife.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 02 Oct 2004 20:10:22 +0200
Manfred Spraul <manfred@colorfullife.com> wrote:

> Description:
> The tcp sequence number generator needs a random seed that is reset every
> few minutes. Since the sequence numbers should be constantly increasing,
> for each rekey 2^24 is added to the sequence number.
> The actual use of the sequence number generator is lockless,
> synchronization is achieved by having two copies of the control structure.
> 
> The attached patch:
> - fixes a race in rekey_seq_generator(): schedule_work doesn't
>    provide synchronization.
> - Uses schedule_delayed_work() for the rekey: simplifies synchronization
>    and speeds up the hot path.
> - replaces do_gettimeofday with get_seconds(): get_seconds is faster and
>    usec resolution is not required.
> - removes tmpdata - not needed with new locking.
> - Adds a late_initcall for the first initialization after boot.
>    init_call would be too early, I've checked that the late_initcall runs
>    before net/ipv4/ipconfig.c, i.e. the BOOTP/DHCP autoconfiguration.
> 
> Signed-Off-By: Manfred Spraul <manfred@colorfullife.com>

I like this patch, but you may have sent the wrong copy.  You
mention in the description that you changed over to use
get_seconds(), yet the only reference to get_seconds() in the
patch is:

-	keyptr = check_and_rekey(get_seconds());
+	keyptr = get_keyptr();

Please clarify that this is just a brain fart in the description
and not the patch.
