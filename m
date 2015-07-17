From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 07/22] ipv6: rt6_info output redirect to
	tunnel output
Date: Fri, 17 Jul 2015 14:55:26 +0200
Message-ID: <602e7e389279a446937d3708b20a686d4ac29c21.1437137396.git.tgraf@suug.ch>
References: <cover.1437137396.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org,
 edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
 simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, joestringer-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, ja-FgGsKACvmQM@public.gmane.org,
 ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org, weichunc-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1437137396.git.tgraf-G/eBtMaohhA@public.gmane.org>
In-Reply-To: <cover.1437137396.git.tgraf-G/eBtMaohhA@public.gmane.org>
References: <cover.1437137396.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

RnJvbTogUm9vcGEgUHJhYmh1IDxyb29wYUBjdW11bHVzbmV0d29ya3MuY29tPgoKVGhpcyBpcyBz
aW1pbGFyIHRvIGlwdjQgcmVkaXJlY3Qgb2YgZHN0IG91dHB1dCB0byBsd3R1bm5lbApvdXRwdXQg
ZnVuY3Rpb24gZm9yIGVuY2Fwc3VsYXRpb24gYW5kIHhtaXQuCgpTaWduZWQtb2ZmLWJ5OiBSb29w
YSBQcmFiaHUgPHJvb3BhQGN1bXVsdXNuZXR3b3Jrcy5jb20+Ci0tLQogbmV0L2lwdjYvcm91dGUu
YyB8IDEgKwogMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspCgpkaWZmIC0tZ2l0IGEvbmV0
L2lwdjYvcm91dGUuYyBiL25ldC9pcHY2L3JvdXRlLmMKaW5kZXggYjM0MzFiNy4uN2YyMjE0ZiAx
MDA2NDQKLS0tIGEvbmV0L2lwdjYvcm91dGUuYworKysgYi9uZXQvaXB2Ni9yb3V0ZS5jCkBAIC0x
NzgwLDYgKzE3ODAsNyBAQCBpbnQgaXA2X3JvdXRlX2FkZChzdHJ1Y3QgZmliNl9jb25maWcgKmNm
ZykKIAkJCWdvdG8gb3V0OwogCQlsd3R1bm5lbF9zdGF0ZV9nZXQobHd0c3RhdGUpOwogCQlydC0+
cnQ2aV9sd3RzdGF0ZSA9IGx3dHN0YXRlOworCQlydC0+ZHN0Lm91dHB1dCA9IGx3dHVubmVsX291
dHB1dDY7CiAJfQogCiAJaXB2Nl9hZGRyX3ByZWZpeCgmcnQtPnJ0NmlfZHN0LmFkZHIsICZjZmct
PmZjX2RzdCwgY2ZnLT5mY19kc3RfbGVuKTsKLS0gCjIuNC4zCgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3
aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
