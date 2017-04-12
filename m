From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 07/12] fs: btrfs: Use ktime_get_real_ts for root
	ctime
Date: Wed, 12 Apr 2017 15:42:45 +0200
Message-ID: <20170412134245.GK4781@twin.jikos.cz>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
 <1491613030-11599-8-git-send-email-deepa.kernel@gmail.com>
Reply-To: dsterba@suse.cz
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: yuchao0@huawei.com, bfields@fieldses.org, clm@fb.com,
 linux-mtd@lists.infradead.org, dushistov@mail.ru, jlayton@poochiereds.net,
 ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
 linux-cifs@vger.kernel.org, paul@paul-moore.com, y2038@lists.linaro.org,
 mingo@redhat.com, jsimmons@infradead.org, arnd@arndb.de, rostedt@goodmis.org,
 oleg.drokin@intel.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk,
 dsterba@suse.com, jaegeuk@kernel.org, tglx@linutronix.de,
 andreas.dilger@intel.com, jbacik@fb.com, gregkh@linuxfoundation.org,
 samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
 eparis@redhat.com, linux-f2fs-devel@lists.sourceforge.net,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 akpm@linux-foundation.org, davem@davemloft.net, linux-btrfs@vger.kernel.org,
 lustre-devel@lists.lustre.org
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <y2038-bounces@lists.linaro.org>
Content-Disposition: inline
In-Reply-To: <1491613030-11599-8-git-send-email-deepa.kernel@gmail.com>
List-Unsubscribe: <https://lists.linaro.org/mailman/options/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=unsubscribe>
List-Archive: <http://lists.linaro.org/pipermail/y2038/>
List-Post: <mailto:y2038@lists.linaro.org>
List-Help: <mailto:y2038-request@lists.linaro.org?subject=help>
List-Subscribe: <https://lists.linaro.org/mailman/listinfo/y2038>,
 <mailto:y2038-request@lists.linaro.org?subject=subscribe>
Errors-To: y2038-bounces@lists.linaro.org
Sender: "Y2038" <y2038-bounces@lists.linaro.org>
List-Id: netdev.vger.kernel.org

T24gRnJpLCBBcHIgMDcsIDIwMTcgYXQgMDU6NTc6MDVQTSAtMDcwMCwgRGVlcGEgRGluYW1hbmkg
d3JvdGU6Cj4gYnRyZnNfcm9vdF9pdGVtIG1haW50YWlucyB0aGUgY3RpbWUgZm9yIHJvb3QgdXBk
YXRlcy4KPiBUaGlzIGlzIG5vdCBwYXJ0IG9mIHZmc19pbm9kZS4KPiAKPiBTaW5jZSBjdXJyZW50
X3RpbWUoKSB1c2VzIHN0cnVjdCBpbm9kZSogYXMgYW4gYXJndW1lbnQKPiBhcyBMaW51cyBzdWdn
ZXN0ZWQsIHRoaXMgY2Fubm90IGJlIHVzZWQgdG8gdXBkYXRlIHJvb3QKPiB0aW1lcyB1bmxlc3Ms
IHdlIG1vZGlmeSB0aGUgc2lnbmF0dXJlIHRvIHVzZSBpbm9kZS4KPiAKPiBTaW5jZSBidHJmcyB1
c2VzIG5hbm9zZWNvbmQgdGltZSBncmFudWxhcml0eSwgaXQgY2FuIGFsc28KPiB1c2Uga3RpbWVf
Z2V0X3JlYWxfdHMgZGlyZWN0bHkgdG8gb2J0YWluIHRpbWVzdGFtcCBmb3IKPiB0aGUgcm9vdC4g
SXQgaXMgbmVjZXNzYXJ5IHRvIHVzZSB0aGUgdGltZXNwZWMgdGltZSBhcGkKPiBoZXJlIGJlY2F1
c2UgdGhlIHNhbWUgYnRyZnNfc2V0X3N0YWNrX3RpbWVzcGVjXyooKSBhcGlzCj4gYXJlIHVzZWQg
Zm9yIHZmcyBpbm9kZSB0aW1lcyBhcyB3ZWxsLiBUaGVzZSBjYW4gYmUKPiB0cmFuc2l0aW9uZWQg
dG8gdXNpbmcgdGltZXNwZWM2NCB3aGVuIGJ0cmZzIGludGVybmFsbHkKPiBjaGFuZ2VzIHRvIHVz
ZSB0aW1lc3BlYzY0IGFzIHdlbGwuCj4gCj4gU2lnbmVkLW9mZi1ieTogRGVlcGEgRGluYW1hbmkg
PGRlZXBhLmtlcm5lbEBnbWFpbC5jb20+Cj4gQWNrZWQtYnk6IERhdmlkIFN0ZXJiYSA8ZHN0ZXJi
YUBzdXNlLmNvbT4KPiBSZXZpZXdlZC1ieTogQXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4K
CkknbSBnb2luZyB0byBhZGQgdGhlIHBhdGNoIHRvIG15IDQuMTIgcXVldWUgYW5kIHdpbGwgbGV0
IEFuZHJldyBrbm93LgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fXwpZMjAzOCBtYWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xp
c3RzLmxpbmFyby5vcmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
