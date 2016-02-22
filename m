From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH 8/8] net: sunrpc: Replace CURRENT_TIME by
	current_fs_time()
Date: Mon, 22 Feb 2016 07:17:54 -0800
Message-ID: <1456154274-30487-9-git-send-email-deepa.kernel@gmail.com>
References: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-nfs@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@primarydata.com>,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 "J. Bruce Fields" <bfields@fieldses.org>,
 Jeff Layton <jlayton@poochiereds.net>,
 Anna Schumaker <anna.schumaker@netapp.com>
To: linux-fsdevel@vger.kernel.org,
	y2038@lists.linaro.org
Return-path: <y2038-bounces@lists.linaro.org>
In-Reply-To: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com>
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

Q1VSUkVOVF9USU1FIG1hY3JvIGlzIG5vdCBhcHByb3ByaWF0ZSBmb3IgZmlsZXN5c3RlbXMgYXMg
aXQKZG9lc24ndCB1c2UgdGhlIHJpZ2h0IGdyYW51bGFyaXR5IGZvciBmaWxlc3lzdGVtIHRpbWVz
dGFtcHMuClVzZSBjdXJyZW50X2ZzX3RpbWUoKSBpbnN0ZWFkLgoKU2lnbmVkLW9mZi1ieTogRGVl
cGEgRGluYW1hbmkgPGRlZXBhLmtlcm5lbEBnbWFpbC5jb20+CkNjOiAiSi4gQnJ1Y2UgRmllbGRz
IiA8YmZpZWxkc0BmaWVsZHNlcy5vcmc+CkNjOiBKZWZmIExheXRvbiA8amxheXRvbkBwb29jaGll
cmVkcy5uZXQ+CkNjOiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0
YS5jb20+CkNjOiBBbm5hIFNjaHVtYWtlciA8YW5uYS5zY2h1bWFrZXJAbmV0YXBwLmNvbT4KQ2M6
ICJEYXZpZCBTLiBNaWxsZXIiIDxkYXZlbUBkYXZlbWxvZnQubmV0PgpDYzogbGludXgtbmZzQHZn
ZXIua2VybmVsLm9yZwpDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZwotLS0KIG5ldC9zdW5ycGMv
cnBjX3BpcGUuYyB8IDQgKysrLQogMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMSBk
ZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvcnBjX3BpcGUuYyBiL25ldC9zdW5y
cGMvcnBjX3BpcGUuYwppbmRleCAzMTc4OWVmLi5iYWIzMTg3IDEwMDY0NAotLS0gYS9uZXQvc3Vu
cnBjL3JwY19waXBlLmMKKysrIGIvbmV0L3N1bnJwYy9ycGNfcGlwZS5jCkBAIC00NzcsNyArNDc3
LDkgQEAgcnBjX2dldF9pbm9kZShzdHJ1Y3Qgc3VwZXJfYmxvY2sgKnNiLCB1bW9kZV90IG1vZGUp
CiAJCXJldHVybiBOVUxMOwogCWlub2RlLT5pX2lubyA9IGdldF9uZXh0X2lubygpOwogCWlub2Rl
LT5pX21vZGUgPSBtb2RlOwotCWlub2RlLT5pX2F0aW1lID0gaW5vZGUtPmlfbXRpbWUgPSBpbm9k
ZS0+aV9jdGltZSA9IENVUlJFTlRfVElNRTsKKwlpbm9kZS0+aV9hdGltZSA9IGN1cnJlbnRfZnNf
dGltZShzYik7CisJaW5vZGUtPmlfbXRpbWUgPSBpbm9kZS0+aV9hdGltZTsKKwlpbm9kZS0+aV9j
dGltZSA9IGlub2RlLT5pX2F0aW1lOwogCXN3aXRjaCAobW9kZSAmIFNfSUZNVCkgewogCWNhc2Ug
U19JRkRJUjoKIAkJaW5vZGUtPmlfZm9wID0gJnNpbXBsZV9kaXJfb3BlcmF0aW9uczsKLS0gCjEu
OS4xCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpZMjAz
OCBtYWlsaW5nIGxpc3QKWTIwMzhAbGlzdHMubGluYXJvLm9yZwpodHRwczovL2xpc3RzLmxpbmFy
by5vcmcvbWFpbG1hbi9saXN0aW5mby95MjAzOAo=
