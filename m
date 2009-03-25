From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Wed, 25 Mar 2009 17:25:40 +0300
Message-ID: <20090325142540.GA20944@oksana.dev.rtsoft.ru>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, leoli@freescale.com,
	'linuxppc-dev Development' <linuxppc-dev@ozlabs.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 25, 2009 at 02:30:49PM +0100, Joakim Tjernlund wrote:
> >>From 1c2f23b1f37f4818c0fd0217b93eb38ab6564840 Mon Sep 17 00:00:00 2001
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Tue, 24 Mar 2009 10:19:27 +0100
> Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
>  Also increase NAPI weight somewhat.
>  This will make the system alot more responsive while
>  ping flooding the ucc_geth ethernet interaface.

Some time ago I've tried a similar thing for this driver, but during
tcp (or udp I don't quite remember) netperf tests I was getting tx
watchdog timeouts after ~2-5 minutes of work. I was testing with a
gigabit and 100 Mbit link, with 100 Mbit link the issue was not
reproducible.

Though, I recalling I was doing a bit more than your patch: I was
also clearing the TX events in the ucce register before calling
ucc_geth_tx, that way I was trying to avoid stale interrupts. That
helped to increase an overall performance (not only responsiveness),
but as I said my approach didn't pass the tests.

I don't really think that your patch may cause this, but can you
try netperf w/ this patch applied anyway? And see if it really
doesn't cause any issues under stress?

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
