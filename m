From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 2/3] fs: poll/select/recvmmsg: use
 timespec64 for timeout events
Date: Fri, 06 May 2016 15:45:48 -0400 (EDT)
Message-ID: <20160506.154548.630368691269399992.davem@davemloft.net>
References: <4256673.7Gok2HNpOM@wuerfel>
 <20160504165115.e0247881921fdcd0af4a394c@linux-foundation.org>
 <CALAqxLVPGBfuSmN_b_obAL5-ChfqpyipZtE-20x9omk_QeTQMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: eliezer.tamir@linux.intel.com, arnd@arndb.de, y2038@lists.linaro.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, oleg@redhat.com,
 arjan@linux.intel.com, deepa.kernel@gmail.com, linux-fsdevel@vger.kernel.org,
 akpm@linux-foundation.org, torvalds@linux-foundation.org, tglx@linutronix.de,
 viro@zeniv.linux.org.uk
To: john.stultz@linaro.org
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <CALAqxLVPGBfuSmN_b_obAL5-ChfqpyipZtE-20x9omk_QeTQMw@mail.gmail.com>
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

RnJvbTogSm9obiBTdHVsdHogPGpvaG4uc3R1bHR6QGxpbmFyby5vcmc+CkRhdGU6IFdlZCwgNCBN
YXkgMjAxNiAxNzowMToyNCAtMDcwMAoKPiBPbiBXZWQsIE1heSA0LCAyMDE2IGF0IDQ6NTEgUE0s
IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+IHdyb3RlOgo+PiBPbiBX
ZWQsIDA0IE1heSAyMDE2IDIzOjA4OjExICswMjAwIEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIu
ZGU+IHdyb3RlOgo+Pgo+Pj4gPiBCdXQgSSdtIGxlc3MgY29tZm9ydGFibGUgbWFraW5nIHRoZSBj
YWxsIG9uIHRoaXMgb25lLiBJdCBsb29rcwo+Pj4gPiByZWxhdGl2ZWx5IHN0cmFpZ2h0IGZvcndh
cmQsIGJ1dCBpdCB3b3VsZCBiZSBnb29kIHRvIGhhdmUgbWFpbnRhaW5lcgo+Pj4gPiBhY2tzIGJl
Zm9yZSBJIGFkZCBpdCB0byBteSB0cmVlLgo+Pj4KPj4+IEFncmVlZC4gRmVlbCBmcmVlIHRvIGFk
ZCBteQo+Pj4KPj4+IFJldmlld2VkLWJ5OiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPgo+
Pj4KPj4+IGF0IGxlYXN0ICh3aG9ldmVyIHBpY2tzIGl0IHVwKS4KPj4KPj4gSW4gcmVwbHkgdG8g
WzEvM10gSm9obiBzYWlkCj4+Cj4+IDogTG9va3Mgb2sgYXQgdGhlIGZpcnN0IGdsYW5jZS4gSSd2
ZSBxdWV1ZWQgdGhlc2UgdXAgZm9yIHRlc3RpbmcsCj4+IDogaG93ZXZlciBJIG9ubHkgZ290ICMx
IGFuZCAjMyBvZiB0aGUgc2V0LiBBcmUgeW91IGhvcGluZyB0aGVzZSB0d28KPj4gOiBwYXRjaGVz
IHdpbGwgZ28gdGhyb3VnaCB0aXAvdGltZXJzL2NvcmUgb3IgYXJlIHlvdSBsb29raW5nIGZvciBh
Y2tzIHNvCj4+IDogdGhleSBjYW4gZ28gdmlhIGFub3RoZXIgdHJlZT8KPj4KPj4gSG93ZXZlciBu
b25lIG9mIHRoZSBwYXRjaGVzIGFyZSBpbiBsaW51eC1uZXh0Lgo+Pgo+PiBKb2huIGhhZCBxdWFs
bXMgYWJvdXQgWzIvM10sIGJ1dCBpdCBsb29rcyBsaWtlIGEgc3RyYWlnaHRmb3J3YXJkCj4+IHN1
YnN0aXR1dGlvbiBpbiBhcmVhcyB3aGljaCB3aWxsIGdldCBwbGVudHkgb2YgdGVzdGluZwo+IAo+
IFllYS4gTXkgbWFpbiBjb25jZXJuIGlzIGp1c3Qgbm90IHN0ZXBwaW5nIG9uIGFueSBvdGhlciBt
YWludGFpbmVycyB0b2VzLgoKVGhlIG5ldHdvcmtpbmcgY2hhbmdlcyBsb29rIGZpbmUgdG8gbWU6
CgpBY2tlZC1ieTogRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PgpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5nIGxp
c3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFpbG1h
bi9saXN0aW5mby95MjAzOAo=
