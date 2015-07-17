From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 11/22] icmp: Don't leak original dst into
	ip_route_input()
Date: Fri, 17 Jul 2015 14:55:30 +0200
Message-ID: <d00f216c959631aa50f472e0ec1135272001a7fe.1437137396.git.tgraf@suug.ch>
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

aXBfcm91dGVfaW5wdXQoKSB1bmNvbmRpdGlvbmFsbHkgb3ZlcndyaXRlcyB0aGUgZHN0LiBIaWRl
IHRoZSBvcmlnaW5hbApkc3QgYXR0YWNoZWQgdG8gdGhlIHNrYiBieSBjYWxsaW5nIHNrYl9kc3Rf
c2V0KHNrYiwgTlVMTCkgcHJpb3IgdG8KaXBfcm91dGVfaW5wdXQoKS4KClJlcG9ydGVkLWJ5OiBK
dWxpYW4gQW5hc3Rhc292IDxqYUBzc2kuYmc+ClNpZ25lZC1vZmYtYnk6IFRob21hcyBHcmFmIDx0
Z3JhZkBzdXVnLmNoPgotLS0KIG5ldC9pcHY0L2ljbXAuYyB8IDEgKwogMSBmaWxlIGNoYW5nZWQs
IDEgaW5zZXJ0aW9uKCspCgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvaWNtcC5jIGIvbmV0L2lwdjQv
aWNtcC5jCmluZGV4IGY1MjAzZmIuLmMwNTU2ZjEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2ljbXAu
YworKysgYi9uZXQvaXB2NC9pY21wLmMKQEAgLTQ5Niw2ICs0OTYsNyBAQCBzdGF0aWMgc3RydWN0
IHJ0YWJsZSAqaWNtcF9yb3V0ZV9sb29rdXAoc3RydWN0IG5ldCAqbmV0LAogCQl9CiAJCS8qIFVn
aCEgKi8KIAkJb3JlZmRzdCA9IHNrYl9pbi0+X3NrYl9yZWZkc3Q7IC8qIHNhdmUgb2xkIHJlZmRz
dCAqLworCQlza2JfZHN0X3NldChza2JfaW4sIE5VTEwpOwogCQllcnIgPSBpcF9yb3V0ZV9pbnB1
dChza2JfaW4sIGZsNF9kZWMuZGFkZHIsIGZsNF9kZWMuc2FkZHIsCiAJCQkJICAgICBSVF9UT1Mo
dG9zKSwgcnQyLT5kc3QuZGV2KTsKIAotLSAKMi40LjMKCl9fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNo
Lm9yZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
