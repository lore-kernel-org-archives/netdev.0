From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 06/22] ipv4: redirect dst output to
	lwtunnel output
Date: Tue, 21 Jul 2015 10:43:50 +0200
Message-ID: <94de0c414dbab2f36b7e67f5c9011c9e1ed6f7d0.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
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
In-Reply-To: <cover.1437468140.git.tgraf-G/eBtMaohhA@public.gmane.org>
In-Reply-To: <cover.1437468140.git.tgraf-G/eBtMaohhA@public.gmane.org>
References: <cover.1437468140.git.tgraf-G/eBtMaohhA@public.gmane.org>
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

RnJvbTogUm9vcGEgUHJhYmh1IDxyb29wYUBjdW11bHVzbmV0d29ya3MuY29tPgoKRm9yIGlucHV0
IHJvdXRlcyB3aXRoIHR1bm5lbCBlbmNhcCBzdGF0ZSB0aGlzIHBhdGNoIHJlZGlyZWN0cwpkc3Qg
b3V0cHV0IGZ1bmN0aW9ucyB0byBsd3R1bm5lbF9vdXRwdXQgd2hpY2ggbGF0ZXIgcmVzb2x2ZXMg
dG8KdGhlIGNvcnJlc3BvbmRpbmcgbHd0dW5uZWwgb3V0cHV0IGZ1bmN0aW9uLgoKVGhpcyBoYXMg
YmVlbiB0ZXN0ZWQgdG8gd29yayB3aXRoIG1wbHMgaXAgdHVubmVscy4KClNpZ25lZC1vZmYtYnk6
IFJvb3BhIFByYWJodSA8cm9vcGFAY3VtdWx1c25ldHdvcmtzLmNvbT4KLS0tCiBuZXQvaXB2NC9y
b3V0ZS5jIHwgMiArKwogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdp
dCBhL25ldC9pcHY0L3JvdXRlLmMgYi9uZXQvaXB2NC9yb3V0ZS5jCmluZGV4IDIyNjU3MGIuLmNk
MzE1N2MgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L3JvdXRlLmMKKysrIGIvbmV0L2lwdjQvcm91dGUu
YwpAQCAtMTYzMyw2ICsxNjMzLDggQEAgc3RhdGljIGludCBfX21rcm91dGVfaW5wdXQoc3RydWN0
IHNrX2J1ZmYgKnNrYiwKIAlydGgtPmRzdC5vdXRwdXQgPSBpcF9vdXRwdXQ7CiAKIAlydF9zZXRf
bmV4dGhvcChydGgsIGRhZGRyLCByZXMsIGZuaGUsIHJlcy0+ZmksIHJlcy0+dHlwZSwgaXRhZyk7
CisJaWYgKGx3dHVubmVsX291dHB1dF9yZWRpcmVjdChydGgtPnJ0X2x3dHN0YXRlKSkKKwkJcnRo
LT5kc3Qub3V0cHV0ID0gbHd0dW5uZWxfb3V0cHV0OwogCXNrYl9kc3Rfc2V0KHNrYiwgJnJ0aC0+
ZHN0KTsKIG91dDoKIAllcnIgPSAwOwotLSAKMi40LjMKCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNo
Lm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
