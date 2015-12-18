From: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH 11/14] openvswitch: use list_for_each_entry
Date: Fri, 18 Dec 2015 23:33:35 +0800
Message-ID: <13c7141db917b9fb45dfec05da494318bd7d0ff9.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang-9Onoh4P/yGk@public.gmane.org>
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

VXNlIGxpc3RfZm9yX2VhY2hfZW50cnkoKSBpbnN0ZWFkIG9mIGxpc3RfZm9yX2VhY2goKSB0byBz
aW1wbGlmeQp0aGUgY29kZS4KClNpZ25lZC1vZmYtYnk6IEdlbGlhbmcgVGFuZyA8Z2VsaWFuZ3Rh
bmdAMTYzLmNvbT4KLS0tCiBuZXQvb3BlbnZzd2l0Y2gvZmxvd190YWJsZS5jIHwgNiArKy0tLS0K
IDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0pCgpkaWZmIC0t
Z2l0IGEvbmV0L29wZW52c3dpdGNoL2Zsb3dfdGFibGUuYyBiL25ldC9vcGVudnN3aXRjaC9mbG93
X3RhYmxlLmMKaW5kZXggZDA3M2ZmZi4uOWI1OTk5YmEgMTAwNjQ0Ci0tLSBhL25ldC9vcGVudnN3
aXRjaC9mbG93X3RhYmxlLmMKKysrIGIvbmV0L29wZW52c3dpdGNoL2Zsb3dfdGFibGUuYwpAQCAt
NjUxLDExICs2NTEsOSBAQCBzdGF0aWMgYm9vbCBtYXNrX2VxdWFsKGNvbnN0IHN0cnVjdCBzd19m
bG93X21hc2sgKmEsCiBzdGF0aWMgc3RydWN0IHN3X2Zsb3dfbWFzayAqZmxvd19tYXNrX2ZpbmQo
Y29uc3Qgc3RydWN0IGZsb3dfdGFibGUgKnRibCwKIAkJCQkJICAgY29uc3Qgc3RydWN0IHN3X2Zs
b3dfbWFzayAqbWFzaykKIHsKLQlzdHJ1Y3QgbGlzdF9oZWFkICptbDsKKwlzdHJ1Y3Qgc3dfZmxv
d19tYXNrICptOwogCi0JbGlzdF9mb3JfZWFjaChtbCwgJnRibC0+bWFza19saXN0KSB7Ci0JCXN0
cnVjdCBzd19mbG93X21hc2sgKm07Ci0JCW0gPSBjb250YWluZXJfb2YobWwsIHN0cnVjdCBzd19m
bG93X21hc2ssIGxpc3QpOworCWxpc3RfZm9yX2VhY2hfZW50cnkobSwgJnRibC0+bWFza19saXN0
LCBsaXN0KSB7CiAJCWlmIChtYXNrX2VxdWFsKG1hc2ssIG0pKQogCQkJcmV0dXJuIG07CiAJfQot
LSAKMi41LjAKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
XwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcKaHR0cDovL29wZW52c3dpdGNo
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
