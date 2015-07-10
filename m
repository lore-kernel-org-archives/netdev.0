From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [RFC net-next 06/22] ipv4: redirect dst output to
	lwtunnel output
Date: Fri, 10 Jul 2015 16:19:08 +0200
Message-ID: <ec85c9cef76c5106822f3647eacca7b31e71abab.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org, rshearma-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
 hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org, pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org,
 edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org, marcelo.leitner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <cover.1436537414.git.tgraf-G/eBtMaohhA@public.gmane.org>
In-Reply-To: <cover.1436537414.git.tgraf-G/eBtMaohhA@public.gmane.org>
References: <cover.1436537414.git.tgraf-G/eBtMaohhA@public.gmane.org>
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
YmVlbiB0ZXN0ZWQgdG8gd29yayB3aXRoIG1wbHMgaXAgdHVubmVscy4KCk9wZW4gaXRlbXM6IFN1
cHBvcnQgZm9yIHR1bm5lbCBtdHUsIHBtdHUsIGZyYWdtZW50YXRpb24gY2FuIGJlCmFkZGVkIGJ5
IGhvb2tpbmcgaW50byB0aGUgY29ycmVzcG9uZGluZyAoaXB2NCwgaXB2NikgZHN0IG9wcy4KV2Ug
bWF5IGRvIHRoaXMgZGlmZmVyZW50bHkgd2hlbiBsd3RzdGF0ZSBtb3ZlcyB0byBkc3Qgb3IgZHN0
X21ldGFkYXRhCmFzIHBlciB1cHN0cmVhbSBkaXNjdXNzaW9ucy4KClNpZ25lZC1vZmYtYnk6IFJv
b3BhIFByYWJodSA8cm9vcGFAY3VtdWx1c25ldHdvcmtzLmNvbT4KLS0tCiBuZXQvaXB2NC9yb3V0
ZS5jIHwgMiArKwogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBh
L25ldC9pcHY0L3JvdXRlLmMgYi9uZXQvaXB2NC9yb3V0ZS5jCmluZGV4IGJmYzBhMTguLmQzOTY0
ZmEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L3JvdXRlLmMKKysrIGIvbmV0L2lwdjQvcm91dGUuYwpA
QCAtMTYzNCw2ICsxNjM0LDggQEAgc3RhdGljIGludCBfX21rcm91dGVfaW5wdXQoc3RydWN0IHNr
X2J1ZmYgKnNrYiwKIAlydGgtPmRzdC5vdXRwdXQgPSBpcF9vdXRwdXQ7CiAKIAlydF9zZXRfbmV4
dGhvcChydGgsIGRhZGRyLCByZXMsIGZuaGUsIHJlcy0+ZmksIHJlcy0+dHlwZSwgaXRhZyk7CisJ
aWYgKGx3dHVubmVsX291dHB1dF9yZWRpcmVjdChydGgtPnJ0X2x3dHN0YXRlKSkKKwkJcnRoLT5k
c3Qub3V0cHV0ID0gbHd0dW5uZWxfb3V0cHV0OwogCXNrYl9kc3Rfc2V0KHNrYiwgJnJ0aC0+ZHN0
KTsKIG91dDoKIAllcnIgPSAwOwotLSAKMi40LjMKCl9fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fCmRldiBtYWlsaW5nIGxpc3QKZGV2QG9wZW52c3dpdGNoLm9y
ZwpodHRwOi8vb3BlbnZzd2l0Y2gub3JnL21haWxtYW4vbGlzdGluZm8vZGV2Cg==
