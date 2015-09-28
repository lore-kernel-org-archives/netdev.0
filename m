From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/5] ntp: use timespec64 in sync_cmos_clock
Date: Mon, 28 Sep 2015 22:21:30 +0200
Message-ID: <1443471692-2946597-4-git-send-email-arnd@arndb.de>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Rodolfo Giometti <giometti@enneenne.com>, Arnd Bergmann <arnd@arndb.de>,
 netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
 linux-kernel@vger.kernel.org, linux-net-drivers@solarflare.com,
 John Stultz <john.stultz@linaro.org>, Shradha Shah <sshah@solarflare.com>,
 Thomas Gleixner <tglx@linutronix.de>
To: y2038@lists.linaro.org
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1443471692-2946597-1-git-send-email-arnd@arndb.de>
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

VGhlIHN5bmNfY21vc19jbG9jayBoYXMgb25lIHVzZSBvZiBzdHJ1Y3QgdGltZXNwZWMsIHdoaWNo
IHdlIHdhbnQgdG8KZXZlbnR1YWxseSByZXBsYWNlIHdpdGggdGltZXNwZWM2NCBvciBzaW1pbGFy
IGluIHRoZSBrZXJuZWwuIFRoZXJlCmlzIG5vIHdheSB0aGlzIG9uZSBjYW4gb3ZlcmZsb3csIGJ1
dCB0aGUgY29udmVyc2lvbiB0byB0aW1lc3BlYzY0CmlzIHRyaXZpYWwgYW5kIGhhcyBubyBvdGhl
ciBkZXBlbmRlbmNpZXMuCgpTaWduZWQtb2ZmLWJ5OiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRi
LmRlPgotLS0KIGtlcm5lbC90aW1lL250cC5jIHwgNCArKy0tCiAxIGZpbGUgY2hhbmdlZCwgMiBp
bnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2tlcm5lbC90aW1lL250
cC5jIGIva2VybmVsL3RpbWUvbnRwLmMKaW5kZXggYmQ0ZmE2MjcxMjYyLi4xNDljYzgwODZhZWEg
MTAwNjQ0Ci0tLSBhL2tlcm5lbC90aW1lL250cC5jCisrKyBiL2tlcm5lbC90aW1lL250cC5jCkBA
IC01MDksNyArNTA5LDcgQEAgc3RhdGljIERFQ0xBUkVfREVMQVlFRF9XT1JLKHN5bmNfY21vc193
b3JrLCBzeW5jX2Ntb3NfY2xvY2spOwogc3RhdGljIHZvaWQgc3luY19jbW9zX2Nsb2NrKHN0cnVj
dCB3b3JrX3N0cnVjdCAqd29yaykKIHsKIAlzdHJ1Y3QgdGltZXNwZWM2NCBub3c7Ci0Jc3RydWN0
IHRpbWVzcGVjIG5leHQ7CisJc3RydWN0IHRpbWVzcGVjNjQgbmV4dDsKIAlpbnQgZmFpbCA9IDE7
CiAKIAkvKgpAQCAtNTU5LDcgKzU1OSw3IEBAIHN0YXRpYyB2b2lkIHN5bmNfY21vc19jbG9jayhz
dHJ1Y3Qgd29ya19zdHJ1Y3QgKndvcmspCiAJCW5leHQudHZfbnNlYyAtPSBOU0VDX1BFUl9TRUM7
CiAJfQogCXF1ZXVlX2RlbGF5ZWRfd29yayhzeXN0ZW1fcG93ZXJfZWZmaWNpZW50X3dxLAotCQkJ
ICAgJnN5bmNfY21vc193b3JrLCB0aW1lc3BlY190b19qaWZmaWVzKCZuZXh0KSk7CisJCQkgICAm
c3luY19jbW9zX3dvcmssIHRpbWVzcGVjNjRfdG9famlmZmllcygmbmV4dCkpOwogfQogCiB2b2lk
IG50cF9ub3RpZnlfY21vc190aW1lcih2b2lkKQotLSAKMi4xLjAucmMyCgpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAzOCBtYWlsaW5nIGxpc3QKWTIw
MzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFyby5vcmcvbWFpbG1hbi9saXN0
aW5mby95MjAzOAo=
