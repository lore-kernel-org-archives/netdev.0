From: Xin Long <lucien.xin@gmail.com>
Subject: Re: rhashtable: Prevent spurious EBUSY errors on insertion
Date: Fri, 18 Dec 2015 00:07:08 +0800
Message-ID: <CADvbK_e_H91UAatLSOEAvPFxZZTNNs5ZFR5TieXBdWt65z4Qzg@mail.gmail.com>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
	<20151130093755.GA8159@gondor.apana.org.au>
	<20151130101401.GA17712@orbit.nwl.cc>
	<20151130101859.GA8378@gondor.apana.org.au>
	<20151203124129.GA5505@gondor.apana.org.au>
	<CADvbK_cA5qaooTOE4Z2bGYs+ys17ZajSMgKDVWgctSZWJ0vjpw@mail.gmail.com>
	<20151217084809.GC9239@gondor.apana.org.au>
	<CADvbK_df=Z1re2wPUF9JCXggBzRqF=Tgt86PXV0KqBcx3VeVNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Phil Sutter <phil@nwl.cc>, davem <davem@davemloft.net>,
	network dev <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CADvbK_df=Z1re2wPUF9JCXggBzRqF=Tgt86PXV0KqBcx3VeVNA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 17, 2015 at 5:00 PM, Xin Long <lucien.xin@gmail.com> wrote:
> On Thu, Dec 17, 2015 at 4:48 PM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> On Thu, Dec 17, 2015 at 04:46:00PM +0800, Xin Long wrote:
>>>
>>> sorry for late test, but unfortunately, my case with rhashtalbe still
>>> return EBUSY.
>>> I added some debug code in rhashtable_insert_rehash(), and found:
>>> *future_tbl is null*
>>>
>>> fail:
>>>         /* Do not fail the insert if someone else did a rehash. */
>>>         if (likely(rcu_dereference_raw(tbl->future_tbl))) {
>>>                 printk("future_tbl is there\n");
>>>                 return 0;
>>>         } else {
>>>                 printk("future_tbl is null\n");
>>>         }
>>>
>>> any idea why ?
>>
>> That's presumably because you got a genuine double rehash.
>>
>> Until you post your code we can't really help you.
>>
> i wish i could , but my codes is a big patch for sctp, and this issue
> happens in a special stress test based on this patch.
> im trying to think how i can show you. :)

I'm just wondering, why do not we handle the genuine double rehash
issue inside rhashtable? i mean it's just a temporary error that a
simple retry may fix it.
