From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Mon, 24 Aug 2015 13:21:11 +1000
Message-ID: <20150824132111.534ddea7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Benc <jbenc@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

In function 'dst_hold',
    inlined from '__ipv6_dev_ac_dec' at /home/sfr/next/next/net/ipv6/anycast.c:328:2:
/home/sfr/next/next/include/linux/compiler.h:447:38: error: call to '__compiletime_assert_243' declared with attribute error: BUILD_BUG_ON failed: offsetof(struct dst_entry, __refcnt) & 63
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
                                      ^
/home/sfr/next/next/include/linux/compiler.h:430:4: note: in definition of macro '__compiletime_assert'
    prefix ## suffix();    \
    ^
/home/sfr/next/next/include/linux/compiler.h:447:2: note: in expansion of macro '_compiletime_assert'
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^
/home/sfr/next/next/include/linux/bug.h:50:37: note: in expansion of macro 'compiletime_assert'
 #define BUILD_BUG_ON_MSG(cond, msg) compiletime_assert(!(cond), msg)
                                     ^
/home/sfr/next/next/include/linux/bug.h:74:2: note: in expansion of macro 'BUILD_BUG_ON_MSG'
  BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON failed: " #condition)
  ^
/home/sfr/next/next/include/net/dst.h:243:2: note: in expansion of macro 'BUILD_BUG_ON'
  BUILD_BUG_ON(offsetof(struct dst_entry, __refcnt) & 63);
  ^

And many more :-(

Caused by commit

  61adedf3e3f1 ("route: move lwtunnel state to dst_entry")

I have used the net-next tree from next-20150821 for today.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
