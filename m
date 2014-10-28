From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv2 5/6] net: fec: simplify loop counter handling in
 swap_buffer()
Date: Tue, 28 Oct 2014 12:01:43 +0100
Message-ID: <1414494104-27943-6-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Fabio Estevam <fabio.estevam@freescale.com>,
 Frank Li <Frank.Li@freescale.com>, linux-kernel@vger.kernel.org,
 Russell King <rmk+kernel@arm.linux.org.uk>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

RWxpbWluYXRlIHRoZSBESVZfUk9VTkRfVVAoKSBhbmQgY2hhbmdlIHRoZSBsb29wIGNvdW50ZXIg
aW5jcmVtZW50IHRvCjQgaW5zdGVhZC4gVGhpcyByZXN1bHRzIGluIHNhdmluZyA2IGluc3RydWN0
aW9ucyBpbiB0aGUgZnVuY3Rpb25zCmFzc2VtYmx5IGNvZGUuCgpTaWduZWQtb2ZmLWJ5OiBMb3Ro
YXIgV2HDn21hbm4gPExXQEtBUk8tZWxlY3Ryb25pY3MuZGU+Ci0tLQogZHJpdmVycy9uZXQvZXRo
ZXJuZXQvZnJlZXNjYWxlL2ZlY19tYWluLmMgfCAgICAyICstCiAxIGZpbGUgY2hhbmdlZCwgMSBp
bnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhl
cm5ldC9mcmVlc2NhbGUvZmVjX21haW4uYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2Fs
ZS9mZWNfbWFpbi5jCmluZGV4IDNhMTAzZTkuLjQwNGZiOWQgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMv
bmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mZWNfbWFpbi5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVy
bmV0L2ZyZWVzY2FsZS9mZWNfbWFpbi5jCkBAIC0zMzMsNyArMzMzLDcgQEAgc3RhdGljIHZvaWQg
KnN3YXBfYnVmZmVyKHZvaWQgKmJ1ZmFkZHIsIGludCBsZW4pCiAJaW50IGk7CiAJdW5zaWduZWQg
aW50ICpidWYgPSBidWZhZGRyOwogCi0JZm9yIChpID0gMDsgaSA8IERJVl9ST1VORF9VUChsZW4s
IDQpOyBpKyssIGJ1ZisrKQorCWZvciAoaSA9IDA7IGkgPCBsZW47IGkgKz0gNCwgYnVmKyspCiAJ
CXN3YWIzMnMoYnVmKTsKIAogCXJldHVybiBidWZhZGRyOwotLSAKMS43LjEwLjQKCgpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVs
IG1haWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDov
L2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==
