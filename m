From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 05/11] time/posix-timers:Convert to the 64bit
 methods for k_clock callback functions
Date: Tue, 21 Apr 2015 10:45:48 +0200
Message-ID: <8072977.i0FsrGW3CD@wuerfel>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <alpine.DEB.2.11.1504202243070.13914@nanos>
 <CAMz4kuKF2sU4tMD7UtDobu2kVDMp7cfHNERSPQ9Yyzs80tOzYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Xunlei Pang <pang.xunlei@linaro.org>, peterz@infradead.org,
 heiko.carstens@de.ibm.com, paulus@samba.org, cl@linux.com,
 Heena Sirwani <heenasirwani@gmail.com>, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, rafael.j.wysocki@intel.com,
 Andrew Hunter <ahh@google.com>,
 =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>,
 Paul Turner <pjt@google.com>, riel@redhat.com,
 Richard Cochran <richardcochran@gmail.com>, tj@kernel.org,
 John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>,
 rth@twiddle.net, Baolin Wang <baolin.wang@linaro.org>,
 gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, schwidefsky@de.ibm.com, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: y2038@lists.linaro.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <CAMz4kuKF2sU4tMD7UtDobu2kVDMp7cfHNERSPQ9Yyzs80tOzYg@mail.gmail.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

T24gVHVlc2RheSAyMSBBcHJpbCAyMDE1IDE2OjM2OjEzIEJhb2xpbiBXYW5nIHdyb3RlOgo+IE9u
IDIxIEFwcmlsIDIwMTUgYXQgMDQ6NDgsIFRob21hcyBHbGVpeG5lciA8dGdseEBsaW51dHJvbml4
LmRlPiB3cm90ZToKPiAKPiA+IE9uIE1vbiwgMjAgQXByIDIwMTUsIEJhb2xpbiBXYW5nIHdyb3Rl
Ogo+ID4gPiAgLyogU2V0IGNsb2NrX3JlYWx0aW1lICovCj4gPiA+ICBzdGF0aWMgaW50IHBvc2l4
X2Nsb2NrX3JlYWx0aW1lX3NldChjb25zdCBjbG9ja2lkX3Qgd2hpY2hfY2xvY2ssCj4gPiA+IC0g
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBjb25zdCBzdHJ1Y3QgdGltZXNwZWMgKnRw
KQo+ID4gPiArICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgY29uc3Qgc3RydWN0IHRp
bWVzcGVjNjQgKnRwKQo+ID4gPiAgewo+ID4gPiAtICAgICByZXR1cm4gZG9fc3lzX3NldHRpbWVv
ZmRheSh0cCwgTlVMTCk7Cj4gPiA+ICsgICAgIHN0cnVjdCB0aW1lc3BlYyB0cyA9IHRpbWVzcGVj
NjRfdG9fdGltZXNwZWMoKnRwKTsKPiA+ID4gKwo+ID4gPiArICAgICByZXR1cm4gZG9fc3lzX3Nl
dHRpbWVvZmRheSgmdHMsIE5VTEwpOwo+ID4KPiA+IFNpZ2guIE5vLiBXZSBmaXJzdCBwcm92aWRl
IGEgcHJvcGVyIGZ1bmN0aW9uIGZvciB0aGlzLCB3aGljaCB0YWtlcyBhCj4gPiB0aW1lc3BlYzY0
LCBpLmUuIGRvX3N5c19zZXR0aW1lb2ZkYXk2NCgpIGluc3RlYWQgb2YgaGF2aW5nIHRoaXMKPiA+
IHdyYXBwZXIgbWVzcyBhbGwgb3ZlciB0aGUgcGxhY2UuCj4gPgo+IAo+IFRoYW5rcyBmb3IgeW91
ciBjb21tZW50cyxidXQgaWYgdXNlIGRvX3N5c19zZXR0aW1lb2ZkYXk2NCgpIGhlcmUgdGhhdAo+
IHdpbGwgIGludHJvZHVjZQo+IGEgc2VjdXJpdHkgYnVnOiBkb19zeXNfc2V0dGltZW9mZGF5IGNv
bnRhaW5zIGEgY2FwYWJpbGl0eQo+IGNoZWNrIHRoYXQgbm9ybWFsbHkgcHJldmVudHMgbm9uLXJv
b3QgdXNlcnMgZnJvbSBzZXR0aW5nIHRoZSB0aW1lLgo+IAo+IFdpdGggeW91ciBjaGFuZ2UsIGFu
eSB1c2VyIGNhbiBzZXQgdGhlIHN5c3RlbSB0aW1lLgoKSGUgd2FzIGFza2luZyBmb3IgYSBuZXcg
ZG9fc3lzX3NldHRpbWVvZmRheTY0IGZ1bmN0aW9uIHRvIGJlIGFkZGVkLApub3QgdXNpbmcgdGhl
IGxvdy1sZXZlbCBkb19zZXR0aW1lb2ZkYXk2NC4KCglBcm5kCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGlu
dXhwcGMtZGV2QGxpc3RzLm96bGFicy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3Rp
bmZvL2xpbnV4cHBjLWRldg==
