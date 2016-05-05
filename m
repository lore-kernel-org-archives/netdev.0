From: John Stultz <john.stultz@linaro.org>
Subject: Re: [RESEND PATCH 2/3] fs: poll/select/recvmmsg: use
 timespec64 for timeout events
Date: Wed, 4 May 2016 17:01:24 -0700
Message-ID: <CALAqxLVPGBfuSmN_b_obAL5-ChfqpyipZtE-20x9omk_QeTQMw@mail.gmail.com>
References: <1461947989-21926-3-git-send-email-deepa.kernel@gmail.com>
 <1462389899-2480-1-git-send-email-deepa.kernel@gmail.com>
 <CALAqxLVB8XiRrFKxK3GzBxw-CfEmC=Dh-CrTOEqT144ngZg-Dw@mail.gmail.com>
 <4256673.7Gok2HNpOM@wuerfel>
 <20160504165115.e0247881921fdcd0af4a394c@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
 Arnd Bergmann <arnd@arndb.de>, y2038 Mailman List <y2038@lists.linaro.org>,
 netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
 Oleg Nesterov <oleg@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 "David S. Miller" <davem@davemloft.net>,
 Deepa Dinamani <deepa.kernel@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <20160504165115.e0247881921fdcd0af4a394c@linux-foundation.org>
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

T24gV2VkLCBNYXkgNCwgMjAxNiBhdCA0OjUxIFBNLCBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4
LWZvdW5kYXRpb24ub3JnPiB3cm90ZToKPiBPbiBXZWQsIDA0IE1heSAyMDE2IDIzOjA4OjExICsw
MjAwIEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+IHdyb3RlOgo+Cj4+ID4gQnV0IEknbSBs
ZXNzIGNvbWZvcnRhYmxlIG1ha2luZyB0aGUgY2FsbCBvbiB0aGlzIG9uZS4gSXQgbG9va3MKPj4g
PiByZWxhdGl2ZWx5IHN0cmFpZ2h0IGZvcndhcmQsIGJ1dCBpdCB3b3VsZCBiZSBnb29kIHRvIGhh
dmUgbWFpbnRhaW5lcgo+PiA+IGFja3MgYmVmb3JlIEkgYWRkIGl0IHRvIG15IHRyZWUuCj4+Cj4+
IEFncmVlZC4gRmVlbCBmcmVlIHRvIGFkZCBteQo+Pgo+PiBSZXZpZXdlZC1ieTogQXJuZCBCZXJn
bWFubiA8YXJuZEBhcm5kYi5kZT4KPj4KPj4gYXQgbGVhc3QgKHdob2V2ZXIgcGlja3MgaXQgdXAp
Lgo+Cj4gSW4gcmVwbHkgdG8gWzEvM10gSm9obiBzYWlkCj4KPiA6IExvb2tzIG9rIGF0IHRoZSBm
aXJzdCBnbGFuY2UuIEkndmUgcXVldWVkIHRoZXNlIHVwIGZvciB0ZXN0aW5nLAo+IDogaG93ZXZl
ciBJIG9ubHkgZ290ICMxIGFuZCAjMyBvZiB0aGUgc2V0LiBBcmUgeW91IGhvcGluZyB0aGVzZSB0
d28KPiA6IHBhdGNoZXMgd2lsbCBnbyB0aHJvdWdoIHRpcC90aW1lcnMvY29yZSBvciBhcmUgeW91
IGxvb2tpbmcgZm9yIGFja3Mgc28KPiA6IHRoZXkgY2FuIGdvIHZpYSBhbm90aGVyIHRyZWU/Cj4K
PiBIb3dldmVyIG5vbmUgb2YgdGhlIHBhdGNoZXMgYXJlIGluIGxpbnV4LW5leHQuCj4KPiBKb2hu
IGhhZCBxdWFsbXMgYWJvdXQgWzIvM10sIGJ1dCBpdCBsb29rcyBsaWtlIGEgc3RyYWlnaHRmb3J3
YXJkCj4gc3Vic3RpdHV0aW9uIGluIGFyZWFzIHdoaWNoIHdpbGwgZ2V0IHBsZW50eSBvZiB0ZXN0
aW5nCgpZZWEuIE15IG1haW4gY29uY2VybiBpcyBqdXN0IG5vdCBzdGVwcGluZyBvbiBhbnkgb3Ro
ZXIgbWFpbnRhaW5lcnMgdG9lcy4KCj4gSSdsbCBncmFiIHRoZSBwYXRjaGVzIGZvciBub3cgdG8g
Z2V0IHRoZW0gc29tZSBleHRlcm5hbCB0ZXN0aW5nLgoKSSdkIGJlIGp1c3QgYXMgaGFwcHkgaWYg
dGhlIHNldCB3ZW50IHRocm91Z2ggeW91IEFuZHJldy4KCkZvciB0aGUgc2V0OiBBY2tlZC1ieTog
Sm9obiBTdHVsdHogPGpvaG4uc3R1bHR6QGxpbmFyby5vcmc+Cgp0aGFua3MKLWpvaG4KX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWTIwMzggbWFpbGluZyBs
aXN0ClkyMDM4QGxpc3RzLmxpbmFyby5vcmcKaHR0cHM6Ly9saXN0cy5saW5hcm8ub3JnL21haWxt
YW4vbGlzdGluZm8veTIwMzgK
