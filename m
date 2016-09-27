From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: linux-next: Tree for Sep 27
Date: Tue, 27 Sep 2016 19:03:24 +0900
Message-ID: <20160927100324.GA466@swordfish>
References: <20160927164026.741b290b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160927164026.741b290b@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On (09/27/16 16:40), Stephen Rothwell wrote:
> 
> Changes since 20160923:
> 

seems that commit e3b37f11e6e4e6b6 ("netfilter: replace list_head with
single linked list") breaks the build on !CONFIG_NETFILTER_INGRESS systems
accessing ->nf_hooks_ingress

static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
                             struct nf_hook_entry *entry)
{
       switch (reg->pf) {
       case NFPROTO_NETDEV:
               /* We already checked in nf_register_net_hook() that this is
                * used from ingress.
                */
               rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
					^^^^^^^^^^^^^^^^^^^^


log:


In file included from ./include/linux/linkage.h:4:0,
                 from ./include/linux/kernel.h:6,
                 from net/netfilter/core.c:10:
net/netfilter/core.c: In function ‘nf_set_hooks_head’:
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:322:17: note: in definition of macro ‘WRITE_ONCE’
  union { typeof(x) __val; char __c[1]; } __u = \
                 ^
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:323:30: note: in definition of macro ‘WRITE_ONCE’
   { .__val = (__force typeof(x)) (val) }; \
                              ^
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:323:35: note: in definition of macro ‘WRITE_ONCE’
   { .__val = (__force typeof(x)) (val) }; \
                                   ^~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:324:22: note: in definition of macro ‘WRITE_ONCE’
  __write_once_size(&(x), __u.__c, sizeof(x)); \
                      ^
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:324:42: note: in definition of macro ‘WRITE_ONCE’
  __write_once_size(&(x), __u.__c, sizeof(x)); \
                                          ^
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
In file included from ./include/linux/linkage.h:4:0,
                 from ./include/linux/kernel.h:6,
                 from net/netfilter/core.c:10:
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:498:19: note: in definition of macro ‘__compiletime_assert’
   bool __cond = !(condition);    \
                   ^~~~~~~~~
./include/linux/compiler.h:518:2: note: in expansion of macro ‘_compiletime_assert’
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^~~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:2: note: in expansion of macro ‘compiletime_assert’
  compiletime_assert(__native_word(t),    \
  ^~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:21: note: in expansion of macro ‘__native_word’
  compiletime_assert(__native_word(t),    \
                     ^~~~~~~~~~~~~
./arch/x86/include/asm/barrier.h:64:2: note: in expansion of macro ‘compiletime_assert_atomic_type’
  compiletime_assert_atomic_type(*p);    \
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:498:19: note: in definition of macro ‘__compiletime_assert’
   bool __cond = !(condition);    \
                   ^~~~~~~~~
./include/linux/compiler.h:518:2: note: in expansion of macro ‘_compiletime_assert’
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^~~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:2: note: in expansion of macro ‘compiletime_assert’
  compiletime_assert(__native_word(t),    \
  ^~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:21: note: in expansion of macro ‘__native_word’
  compiletime_assert(__native_word(t),    \
                     ^~~~~~~~~~~~~
./arch/x86/include/asm/barrier.h:64:2: note: in expansion of macro ‘compiletime_assert_atomic_type’
  compiletime_assert_atomic_type(*p);    \
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:498:19: note: in definition of macro ‘__compiletime_assert’
   bool __cond = !(condition);    \
                   ^~~~~~~~~
./include/linux/compiler.h:518:2: note: in expansion of macro ‘_compiletime_assert’
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^~~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:2: note: in expansion of macro ‘compiletime_assert’
  compiletime_assert(__native_word(t),    \
  ^~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:21: note: in expansion of macro ‘__native_word’
  compiletime_assert(__native_word(t),    \
                     ^~~~~~~~~~~~~
./arch/x86/include/asm/barrier.h:64:2: note: in expansion of macro ‘compiletime_assert_atomic_type’
  compiletime_assert_atomic_type(*p);    \
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:498:19: note: in definition of macro ‘__compiletime_assert’
   bool __cond = !(condition);    \
                   ^~~~~~~~~
./include/linux/compiler.h:518:2: note: in expansion of macro ‘_compiletime_assert’
  _compiletime_assert(condition, msg, __compiletime_assert_, __LINE__)
  ^~~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:2: note: in expansion of macro ‘compiletime_assert’
  compiletime_assert(__native_word(t),    \
  ^~~~~~~~~~~~~~~~~~
./include/linux/compiler.h:521:21: note: in expansion of macro ‘__native_word’
  compiletime_assert(__native_word(t),    \
                     ^~~~~~~~~~~~~
./arch/x86/include/asm/barrier.h:64:2: note: in expansion of macro ‘compiletime_assert_atomic_type’
  compiletime_assert_atomic_type(*p);    \
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
In file included from ./include/linux/linkage.h:4:0,
                 from ./include/linux/kernel.h:6,
                 from net/netfilter/core.c:10:
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:322:17: note: in definition of macro ‘WRITE_ONCE’
  union { typeof(x) __val; char __c[1]; } __u = \
                 ^
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:323:30: note: in definition of macro ‘WRITE_ONCE’
   { .__val = (__force typeof(x)) (val) }; \
                              ^
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:323:35: note: in definition of macro ‘WRITE_ONCE’
   { .__val = (__force typeof(x)) (val) }; \
                                   ^~~
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:25: note: in expansion of macro ‘RCU_INITIALIZER’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
                         ^~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:323:35: note: in definition of macro ‘WRITE_ONCE’
   { .__val = (__force typeof(x)) (val) }; \
                                   ^~~
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:25: note: in expansion of macro ‘RCU_INITIALIZER’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
                         ^~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:324:22: note: in definition of macro ‘WRITE_ONCE’
  __write_once_size(&(x), __u.__c, sizeof(x)); \
                      ^
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:324:42: note: in definition of macro ‘WRITE_ONCE’
  __write_once_size(&(x), __u.__c, sizeof(x)); \
                                          ^
./include/asm-generic/barrier.h:157:33: note: in expansion of macro ‘__smp_store_release’
 #define smp_store_release(p, v) __smp_store_release(p, v)
                                 ^~~~~~~~~~~~~~~~~~~
./include/linux/rcupdate.h:668:3: note: in expansion of macro ‘smp_store_release’
   smp_store_release(&p, RCU_INITIALIZER((typeof(p))_r_a_p__v)); \
   ^~~~~~~~~~~~~~~~~
net/netfilter/core.c:96:3: note: in expansion of macro ‘rcu_assign_pointer’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
   ^~~~~~~~~~~~~~~~~~
  CC      net/ipv4/ip_fragment.o
make[2]: *** [scripts/Makefile.build:290: net/netfilter/core.o] Error 1
make[1]: *** [scripts/Makefile.build:475: net/netfilter] Error 2
make[1]: *** Waiting for unfinished jobs....

	-ss
