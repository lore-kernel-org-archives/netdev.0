From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 17/17] net,act_police,rcu: remove rcu_barrier()
Date: Tue, 15 Mar 2011 12:04:12 +0100
Message-ID: <1300187052.10062.12.camel@edumazet-laptop>
References: <4D7F3610.6000809@cn.fujitsu.com> <4D7F3B62.6000005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        linux-decnet-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
        Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        "Pekka Savola \(ipv6\)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
        Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
        "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        Sridhar Samudrala <sri-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
        Vlad Yasevich <vladislav.yasevich-VXdhtT5mjnY@public.gmane.org>,
        Hagen Paul Pfeifer <hagen-GvnIQ6b/HdU@public.gmane.org>,
        "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Hideaki YOSHIFU
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D7F3B62.6000005-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

TGUgbWFyZGkgMTUgbWFycyAyMDExIMOgIDE4OjExICswODAwLCBMYWkgSmlhbmdzaGFuIGEgw6lj
cml0IDoKPiAKPiBUaGVyZSBpcyBubyBjYWxsYmFjayBvZiB0aGlzIG1vZHVsZSBtYXliZSBxdWV1
ZWQKPiBzaW5jZSB3ZSB1c2Uga2ZyZWVfcmN1KCksIHdlIGNhbiBzYWZlbHkgcmVtb3ZlIHRoZSBy
Y3VfYmFycmllcigpLgo+IAo+IFNpZ25lZC1vZmYtYnk6IExhaSBKaWFuZ3NoYW4gPGxhaWpzQGNu
LmZ1aml0c3UuY29tPgo+IC0tLQo+ICBuZXQvc2NoZWQvYWN0X3BvbGljZS5jIHwgICAgMSAtCj4g
IDEgZmlsZXMgY2hhbmdlZCwgMCBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQo+IAo+IGRp
ZmYgLS1naXQgYS9uZXQvc2NoZWQvYWN0X3BvbGljZS5jIGIvbmV0L3NjaGVkL2FjdF9wb2xpY2Uu
Ywo+IGluZGV4IDA4M2IwOTEuLjIyZTNmOWIgMTAwNjQ0Cj4gLS0tIGEvbmV0L3NjaGVkL2FjdF9w
b2xpY2UuYwo+ICsrKyBiL25ldC9zY2hlZC9hY3RfcG9saWNlLmMKPiBAQCAtMzk3LDcgKzM5Nyw2
IEBAIHN0YXRpYyB2b2lkIF9fZXhpdAo+ICBwb2xpY2VfY2xlYW51cF9tb2R1bGUodm9pZCkKPiAg
ewo+ICAJdGNmX3VucmVnaXN0ZXJfYWN0aW9uKCZhY3RfcG9saWNlX29wcyk7Cj4gLQlyY3VfYmFy
cmllcigpOyAvKiBXYWl0IGZvciBjb21wbGV0aW9uIG9mIGNhbGxfcmN1KCkncyAodGNmX3BvbGlj
ZV9mcmVlX3JjdSkgKi8KPiAgfQo+ICAKPiAgbW9kdWxlX2luaXQocG9saWNlX2luaXRfbW9kdWxl
KTsKCgpXaHkgaXMgaXQgYSBzZXBhcmF0ZSBwYXRjaCwgYW5kIG5vdCBpbmNsdWRlZCBpbiBwYXRj
aCA1LzE3ID8KCgoKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpDb250YWluZXJzIG1haWxpbmcgbGlzdApDb250YWluZXJzQGxpc3RzLmxpbnV4LWZvdW5k
YXRpb24ub3JnCmh0dHBzOi8vbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0
aW5mby9jb250YWluZXJz
