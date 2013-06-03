From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Sun, 02 Jun 2013 20:49:15 -0700 (PDT)
Message-ID: <20130602.204915.334823676645400072.davem@davemloft.net>
References: <1370229169.24311.119.camel@edumazet-glaptop>
	<20130602.202703.1059637861388689182.davem@davemloft.net>
	<20130603034254.GC29614@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, klamm@yandex-team.ru, brouer@redhat.com,
	dipankar@in.ibm.com, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, David.Laight@ACULAB.COM
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab3FCDtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 23:49:16 -0400
In-Reply-To: <20130603034254.GC29614@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Sun, 2 Jun 2013 20:42:54 -0700

> On Sun, Jun 02, 2013 at 08:27:03PM -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Sun, 02 Jun 2013 20:12:49 -0700
>> 
>> > On Sun, 2013-06-02 at 19:58 -0700, David Miller wrote:
>> >> From: Eric Dumazet <eric.dumazet@gmail.com>
>> >> Date: Sun, 02 Jun 2013 16:31:35 -0700
>> >> 
>> >> > On Thu, 2013-05-30 at 12:25 +0400, Roman Gushchin wrote:
>> >> >> On 29.05.2013 23:06, Eric Dumazet wrote:
>> >> >> > On Wed, 2013-05-29 at 14:09 +0400, Roman Gushchin wrote:
>> >> >> >
>> >> >> > True, these lookup functions are usually structured the same around the
>> >> >> > hlist_nulls_for_each_entry_rcu() loop.
>> >> >> >
>> >> >> > A barrier() right before the loop seems to be a benefit, the size of
>> >> >> > assembly code is reduced by 48 bytes.
>> >> >> >
>> >> >> > And its one of the documented way to handle this kind of problems
>> >> >> > (Documentation/atomic_ops.txt line 114)
>> >> >> >
>> >> >> > I guess we should amend this documentation, eventually.
>> >> >> >
>> >> >> > Thanks, please add you "Signed-off-by" if you agree with the patch.
>> >> >> >
>> >> >> 
>> >> >> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
>> >> >> 
>> >> >> Many thanks to you, Paul E. McKenney and David Laight for your
>> >> >> patches, help and participation in this discussion.
>> >> > 
>> >> > Thanks to you !
>> >> > 
>> >> > David, is there any problem with the patch ?
>> >> > 
>> >> > http://patchwork.ozlabs.org/patch/247360/ says "Not applicable", please
>> >> > tell me what is needed to get it merged.
>> >> 
>> >> It's not a networking patch, it's a patch for generic RCU upstream.
>> >> So it either goes through Paul McKenney, or directly via Linus on
>> >> linux-kernel.
>> > 
>> > Well, whole discussion went on linux kernel, and you were the original
>> > committer of this patch five years ago.
>> > 
>> > http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=bbaffaca4810de1a25e32ecaf836eeaacc7a3d11
>> > 
>> > So please Paul or David make sure the patch goes in.
>> > 
>> > My only concern is that Paul seems quite busy these days.
>> 
>> Ok I can take it then, no problem.
> 
> Or if you would like to take it:
> 
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Let's end this deadlock by me taking it :-)
