From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Thu, 17 Dec 2015 16:48:09 +0800
Message-ID: <20151217084809.GC9239@gondor.apana.org.au>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <20151130093755.GA8159@gondor.apana.org.au>
 <20151130101401.GA17712@orbit.nwl.cc>
 <20151130101859.GA8378@gondor.apana.org.au>
 <20151203124129.GA5505@gondor.apana.org.au>
 <CADvbK_cA5qaooTOE4Z2bGYs+ys17ZajSMgKDVWgctSZWJ0vjpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil@nwl.cc>, davem <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADvbK_cA5qaooTOE4Z2bGYs+ys17ZajSMgKDVWgctSZWJ0vjpw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 17, 2015 at 04:46:00PM +0800, Xin Long wrote:
>
> sorry for late test, but unfortunately, my case with rhashtalbe still
> return EBUSY.
> I added some debug code in rhashtable_insert_rehash(), and found:
> *future_tbl is null*
> 
> fail:
>         /* Do not fail the insert if someone else did a rehash. */
>         if (likely(rcu_dereference_raw(tbl->future_tbl))) {
>                 printk("future_tbl is there\n");
>                 return 0;
>         } else {
>                 printk("future_tbl is null\n");
>         }
> 
> any idea why ?

That's presumably because you got a genuine double rehash.

Until you post your code we can't really help you.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
