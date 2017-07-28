From: Mark Salyzyn <salyzyn@android.com>
Subject: refcount_t + (resend to wider audience)
Date: Fri, 28 Jul 2017 10:15:23 -0700
Message-ID: <adaee9d9-1d35-921c-36b3-e32e6c8ce9e3@android.com>
References: <cc109bec-d4bb-8965-3169-fe36d85e6e19@android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <cc109bec-d4bb-8965-3169-fe36d85e6e19@android.com>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Resend to wider audience to comply with 
Documentation/networking/netdev-FAQ.txt)

Please apply/backport the following upstream feature and followup
grouped fixes patches to the stable trees (expect included in at least
3.10.y, 3.18.y, 4.4.y and 4.9.y):


GROUP 1: refcount_t feature:

f405df5de3170c00e5c54f8b7cf4766044a032ba refcount_t: Introduce a special
purpose refcount type
29dee3c03abce04cd527878ef5f9e5f91b7b83f4 locking/refcounts: Out-of-line
everything
bd174169c7a12a37b3b4aa2221f084ade010b182 locking/refcount: Add
refcount_t API kernel-doc comments
fd25d19f6b8da315332bb75936605fb45d3ea981 locking/refcount: Create
unchecked atomic_t implementation

They should merge cleanly as they are orthogonal, except for the last
one which will have a trivial merge conflict to arch/Kconfig.

Following these that add the refcount_t upstream API, the following
groups of
upsteam patches are requested because we are experiencing KASAN errors:


GROUP 2: sk_buff.users:

3889a803e1da9bd7cd10d6504bf281ee7e55dfd6 net: factor out a helper to
decrement the skb refcount
7608894e43d071ef2322a01c79522954c070ac6c net: use skb_unref() in
napi_consume_skb()
9899886d5e8ec5b343b1efe44f185a0e68dc6454 net: core: Prevent from
dereferencing null pointer when releasing SKB
633547973ffc32fd2c815639d4675e1531f0896f net: convert sk_buff.users from
atomic_t to refcount_t

They appear to merge trivially (4.9), but the last one will likely need
#include
<linux/refcount.h> added after the #include <lunux/atomic.h> in
include/linux/skbuff.h to facilitate compilation.


GROUP 3: sec_path.refcnt:

b0fcee825c0ad05057a97d1f4685e1b9e9d00c53 xfrm: Add a secpath_set helper.
55eabed60a68e918abc44f6beb64f38cc008b29d net, xfrm: convert
sec_path.refcnt from atomic_t to refcount_t

They merged with zero conflict on 4.9.


GROUP 4: sock.sk_wmem_alloc

14afee4b6092fde451ee17604e5f5c89da33e71e net: convert sock.sk_wmem_alloc
from atomic_t to refcount_t

This did not merge entirely cleanly (4.9), appears fragments for
net/ipv4/esp4.c and net/ipv6/esp6.c need to be dropped as well as minor
conflicts in two other files.


There may be more related to follow as our investigations continue, but
this is already turning into a tall order so we stop here.


Sincerely -- Mark Salyzyn
