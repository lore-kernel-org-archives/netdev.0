From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Fri, 04 Dec 2015 14:38:44 -0500 (EST)
Message-ID: <20151204.143844.1840501199234860407.davem@davemloft.net>
References: <20151130101401.GA17712@orbit.nwl.cc>
	<20151130101859.GA8378@gondor.apana.org.au>
	<20151203124129.GA5505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151203124129.GA5505@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 3 Dec 2015 20:41:29 +0800

> Thomas and Phil observed that under stress rhashtable insertion
> sometimes failed with EBUSY, even though this error should only
> ever been seen when we're under attack and our hash chain length
> has grown to an unacceptable level, even after a rehash.
> 
> It turns out that the logic for detecting whether there is an
> existing rehash is faulty.  In particular, when two threads both
> try to grow the same table at the same time, one of them may see
> the newly grown table and thus erroneously conclude that it had
> been rehashed.  This is what leads to the EBUSY error.
> 
> This patch fixes this by remembering the current last table we
> used during insertion so that rhashtable_insert_rehash can detect
> when another thread has also done a resize/rehash.  When this is
> detected we will give up our resize/rehash and simply retry the
> insertion with the new table.
> 
> Reported-by: Thomas Graf <tgraf@suug.ch>
> Reported-by: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied, thanks Herbert.
