From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v4] Fix to avoid IS_ERR_VALUE and IS_ERR abuses on 64bit systems.
Date: Tue, 02 Aug 2016 09:45:18 +0200
Message-ID: <2484583.95xFmO7xir@wuerfel>
References: <1469963924-8800-1-git-send-email-arvind.yadav.cs@gmail.com>
 <1956647.cOmaJREgOE@wuerfel>
 <DB5PR0401MB19280ACA87C7F5EE2822D5FB91040@DB5PR0401MB1928.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
 "viresh.kumar@linaro.org" <viresh.kumar@linaro.org>,
 "zajec5@gmail.com" <zajec5@gmail.com>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 Scott Wood <scott.wood@nxp.com>,
 "David.Laight@aculab.com" <David.Laight@aculab.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "scottwood@freescale.com" <scottwood@freescale.com>,
 Arvind Yadav <arvind.yadav.cs@gmail.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux@roeck-us.net" <linux@roeck-us.net>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <DB5PR0401MB19280ACA87C7F5EE2822D5FB91040@DB5PR0401MB1928.eurprd04.prod.outlook.com>
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

T24gTW9uZGF5LCBBdWd1c3QgMSwgMjAxNiA0OjU1OjQzIFBNIENFU1QgU2NvdHQgV29vZCB3cm90
ZToKPiBPbiAwOC8wMS8yMDE2IDAyOjAyIEFNLCBBcm5kIEJlcmdtYW5uIHdyb3RlOgoKPiA+PiBk
aWZmIC0tZ2l0IGEvaW5jbHVkZS9saW51eC9lcnIuaCBiL2luY2x1ZGUvbGludXgvZXJyLmgKPiA+
PiBpbmRleCAxZTM1NTg4Li5jMmEyNzg5IDEwMDY0NAo+ID4+IC0tLSBhL2luY2x1ZGUvbGludXgv
ZXJyLmgKPiA+PiArKysgYi9pbmNsdWRlL2xpbnV4L2Vyci5oCj4gPj4gQEAgLTE4LDcgKzE4LDE3
IEBACj4gPj4gIAo+ID4+ICAjaWZuZGVmIF9fQVNTRU1CTFlfXwo+ID4+ICAKPiA+PiAtI2RlZmlu
ZSBJU19FUlJfVkFMVUUoeCkgdW5saWtlbHkoKHVuc2lnbmVkIGxvbmcpKHZvaWQgKikoeCkgPj0g
KHVuc2lnbmVkIGxvbmcpLU1BWF9FUlJOTykKPiA+PiArI2RlZmluZSBJU19FUlJfVkFMVUUoeCkg
dW5saWtlbHkoaXNfZXJyb3JfY2hlY2soeCkpCj4gPj4gKwo+ID4+ICtzdGF0aWMgaW5saW5lIGlu
dCBpc19lcnJvcl9jaGVjayh1bnNpZ25lZCBsb25nIGVycm9yKQo+ID4gCj4gPiBQbGVhc2UgbGVh
dmUgdGhlIGV4aXN0aW5nIG1hY3JvIGFsb25lLiBJIHRoaW5rIHlvdSB3ZXJlIGxvb2tpbmcgZm9y
Cj4gPiBzb21ldGhpbmcgc3BlY2lmaWMgdG8gdGhlIHJldHVybiBjb2RlIG9mIHFlX211cmFtX2Fs
bG9jKCkgZnVuY3Rpb24sCj4gPiBzbyBwbGVhc2UgYWRkIGEgaGVscGVyIGluIHRoYXQgc3Vic3lz
dGVtIGlmIHlvdSBuZWVkIGl0LCBub3QgaW4KPiA+IHRoZSBnZW5lcmljIGhlYWRlciBmaWxlcy4K
PiAKPiBxZV9tdXJhbV9hbGxvYyAoYS5rLmEuIGNwbV9tdXJhbV9hbGxvYykgcmV0dXJucyB1bnNp
Z25lZCBsb25nLiAgVGhlCj4gcHJvYmxlbSBpcyBjZXJ0YWluIGNhbGxlcnMgdGhhdCBzdG9yZSB0
aGUgcmV0dXJuIHZhbHVlIGluIGEgdTMyLiAgV2h5Cj4gbm90IGp1c3QgZml4IHRob3NlIGNhbGxl
cnMgdG8gc3RvcmUgaXQgaW4gdW5zaWduZWQgbG9uZyAoYXQgbGVhc3QgdW50aWwKPiBlcnJvciBj
aGVja2luZyBpcyBkb25lKT8KPiAKClllcywgdGhhdCB3b3VsZCBhbHNvIGFkZHJlc3MgYW5vdGhl
ciBwcm9ibGVtIHdpdGggY29kZSBsaWtlCgogICAgICAgICBrZnJlZSgodm9pZCAqKXVnZXRoLT50
eF9iZF9yaW5nX29mZnNldFtpXSk7Cgp3aGljaCBpcyBub3QgNjQtYml0IHNhZmUgd2hlbiB0eF9i
ZF9yaW5nX29mZnNldCBpcyBhIDMyLWJpdCB2YWx1ZQp0aGF0IGFsc28gaG9sZHMgdGhlIHJldHVy
biB2YWx1ZSBvZiBxZV9tdXJhbV9hbGxvYy4KCglBcm5kCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhw
cGMtZGV2QGxpc3RzLm96bGFicy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZv
L2xpbnV4cHBjLWRldg==
