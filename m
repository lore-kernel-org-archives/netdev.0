From: Wensong Zhang <wensong@linux-vs.org>
Subject: Re: [PATCH] (4/6) ipvs -- use reader locks and refcounts correctly.
Date: Sat, 20 Sep 2003 23:39:10 +0800 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309202338250.2193-200000@penguin.linux-vs.org>
References: <20030920010010.7ed69543.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463755008-885633216-1064072350=:2193"
Cc: shemminger@osdl.org, <lvs-users@LinuxVirtualServer.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030920010010.7ed69543.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1463755008-885633216-1064072350=:2193
Content-Type: TEXT/PLAIN; charset=US-ASCII



On Sat, 20 Sep 2003, David S. Miller wrote:

> On Thu, 18 Sep 2003 00:44:16 +0800 (CST)
> Wensong Zhang <wensong@linux-vs.org> wrote:
> 
> > So, maybe we just apply the simple patch with making the lock local and 
> > tagging user pointers.
> 
> Can someone put such a patch together for me?
> 

Please see the attached patch.

Thanks,

Wensong

---1463755008-885633216-1064072350=:2193
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="typetidyup.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309202339100.2193@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="typetidyup.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTMxNSAgLT4gMS4xMzE2IA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX2N0bC5jCTEuNCAgICAgLT4gMS41ICAgIA0K
Iw0KIyBUaGUgZm9sbG93aW5nIGlzIHRoZSBCaXRLZWVwZXIgQ2hhbmdlU2V0
IExvZw0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIyAwMy8wOS8xOAlzaGVtbWluZ2VyQG9zZGwub3JnCTEuMTMx
Ng0KIyBbSVBWNF0gSVBWUzogc29tZSB0eXBlIGRlY2xhcmF0aW9uIHRpZHkg
dXANCiMgDQojIC0gbWFrZSB0aGUgX19pcF92c19zdmNfbG9jayBsb2NhbA0K
IyAtIHRhZyB1c2VyIHBvaW50ZXJzIF9fdXNlcg0KIyAtLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KIw0KZGlmZiAtTnJ1
IGEvbmV0L2lwdjQvaXB2cy9pcF92c19jdGwuYyBiL25ldC9pcHY0L2lwdnMv
aXBfdnNfY3RsLmMNCi0tLSBhL25ldC9pcHY0L2lwdnMvaXBfdnNfY3RsLmMJ
U2F0IFNlcCAyMCAyMjo1NTozOSAyMDAzDQorKysgYi9uZXQvaXB2NC9pcHZz
L2lwX3ZzX2N0bC5jCVNhdCBTZXAgMjAgMjI6NTU6MzkgMjAwMw0KQEAgLTQ2
LDcgKzQ2LDcgQEANCiBzdGF0aWMgREVDTEFSRV9NVVRFWChfX2lwX3ZzX211
dGV4KTsNCiANCiAvKiBsb2NrIGZvciBzZXJ2aWNlIHRhYmxlICovDQotcnds
b2NrX3QgX19pcF92c19zdmNfbG9jayA9IFJXX0xPQ0tfVU5MT0NLRUQ7DQor
c3RhdGljIHJ3bG9ja190IF9faXBfdnNfc3ZjX2xvY2sgPSBSV19MT0NLX1VO
TE9DS0VEOw0KIA0KIC8qIGxvY2sgZm9yIHRhYmxlIHdpdGggdGhlIHJlYWwg
c2VydmljZXMgKi8NCiBzdGF0aWMgcndsb2NrX3QgX19pcF92c19yc19sb2Nr
ID0gUldfTE9DS19VTkxPQ0tFRDsNCkBAIC0xOTEyLDcgKzE5MTIsNyBAQA0K
IA0KIHN0YXRpYyBpbmxpbmUgaW50DQogX19pcF92c19nZXRfc2VydmljZV9l
bnRyaWVzKGNvbnN0IHN0cnVjdCBpcF92c19nZXRfc2VydmljZXMgKmdldCwN
Ci0JCQkgICAgc3RydWN0IGlwX3ZzX2dldF9zZXJ2aWNlcyAqdXB0cikNCisJ
CQkgICAgc3RydWN0IGlwX3ZzX2dldF9zZXJ2aWNlcyBfX3VzZXIgKnVwdHIp
DQogew0KIAlpbnQgaWR4LCBjb3VudD0wOw0KIAlzdHJ1Y3QgaXBfdnNfc2Vy
dmljZSAqc3ZjOw0KQEAgLTE5NTUsNyArMTk1NSw3IEBADQogDQogc3RhdGlj
IGlubGluZSBpbnQNCiBfX2lwX3ZzX2dldF9kZXN0X2VudHJpZXMoY29uc3Qg
c3RydWN0IGlwX3ZzX2dldF9kZXN0cyAqZ2V0LA0KLQkJCSBzdHJ1Y3QgaXBf
dnNfZ2V0X2Rlc3RzICp1cHRyKQ0KKwkJCSBzdHJ1Y3QgaXBfdnNfZ2V0X2Rl
c3RzIF9fdXNlciAqdXB0cikNCiB7DQogCXN0cnVjdCBpcF92c19zZXJ2aWNl
ICpzdmM7DQogCWludCByZXQgPSAwOw0KQEAgLTIwMzQsNyArMjAzNCw3IEBA
DQogfTsNCiANCiBzdGF0aWMgaW50DQotZG9faXBfdnNfZ2V0X2N0bChzdHJ1
Y3Qgc29jayAqc2ssIGludCBjbWQsIHZvaWQgKnVzZXIsIGludCAqbGVuKQ0K
K2RvX2lwX3ZzX2dldF9jdGwoc3RydWN0IHNvY2sgKnNrLCBpbnQgY21kLCB2
b2lkIF9fdXNlciAqdXNlciwgaW50ICpsZW4pDQogew0KIAl1bnNpZ25lZCBj
aGFyIGFyZ1sxMjhdOw0KIAlpbnQgcmV0ID0gMDsNCg==
---1463755008-885633216-1064072350=:2193--
