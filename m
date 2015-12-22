From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [REGRESSION] tcp/ipv4: kernel panic because of (possible)
 division by zero
Date: Mon, 21 Dec 2015 18:10:32 -0800
Message-ID: <CAK6E8=d1FquYTtMXi6v+koruRhA2MUe693-DX5jbU8urRatUoQ@mail.gmail.com>
References: <26396443.iDTTxgChSj@spock>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bf0d954aad8870527731e3e
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>
To: Oleksandr Natalenko <oleksandr@natalenko.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37410 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbLVCLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 21:11:14 -0500
Received: by mail-wm0-f43.google.com with SMTP id p187so92306312wmp.0
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 18:11:13 -0800 (PST)
In-Reply-To: <26396443.iDTTxgChSj@spock>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7bf0d954aad8870527731e3e
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 21, 2015 at 12:25 PM, Oleksandr Natalenko
<oleksandr@natalenko.name> wrote:
> Commit 3759824da87b30ce7a35b4873b62b0ba38905ef5 (tcp: PRR uses CRB mode b=
y
> default and SS mode conditionally) introduced changes to net/ipv4/tcp_inp=
ut.c
> tcp_cwnd_reduction() that, possibly, cause division by zero, and therefor=
e,
> kernel panic in interrupt handler [1].
>
> Reverting 3759824da87b30ce7a35b4873b62b0ba38905ef5 seems to fix the issue=
.
>
> I'm able to reproduce the issue on 4.3.0=E2=80=934.3.3 once per several d=
ay
> (occasionally).
>
> What could be done to help in debugging this issue?
Do you have ECN enabled (i.e. sysctl net.ipv4.tcp_ecn > 0)?

If so I suspect an ACK carrying ECE during CA_Loss causes entering CWR
state w/o calling tcp_init_cwnd_reduct() to set tp->prior_cwnd. Can
you try this debug / quick-fix patch and send me the error message if
any?


>
> Regards,
>   Oleksandr.
>
> [1] http://i.piccy.info/
> i9/6f5cb187c4ff282d189f78c63f95af43/1450729403/283985/951663/panic.jpg

--047d7bf0d954aad8870527731e3e
Content-Type: application/octet-stream;
	name="0001-tcp-debug-tcp_cwnd_reduction-div0.patch"
Content-Disposition: attachment;
	filename="0001-tcp-debug-tcp_cwnd_reduction-div0.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iigr7l1t0

RnJvbSAwMGM4MGJkZGFlOTNkNzEyZDFlNTFlMDIxMjY2YzAwNjdkMmUxMzBlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZdWNodW5nIENoZW5nIDx5Y2hlbmdAZ29vZ2xlLmNvbT4KRGF0
ZTogTW9uLCAyMSBEZWMgMjAxNSAxNzozNzo1MSAtMDgwMApTdWJqZWN0OiBbUEFUQ0hdIHRjcDog
ZGVidWcgdGNwX2N3bmRfcmVkdWN0aW9uIGRpdjAKCkl0J3MgYmVlbiByZXBvcnRlZCB0Y3BfY3du
ZF9yZWR1Y3Rpb24oKSBtYXkgaGF2ZSBkaXYwIGJ1ZyBiL2MKdHAtPnByaW9yX2N3bmQgPT0gMC4g
VG8gYXZvaWQgdGhpcywgdGhlIGJlc3Qgb3B0aW9uIGlzIHRvIHNpbXBseQp1c2UgcGFja2V0IGNv
bnNlcnZhdGlvbiB0byBzZW5kIHBhY2tldHMgaW4gY3duZCByZWR1Y3Rpb24gc3RhdGVzLgpBbHNv
IGFkZCBzb21lIHByX2VyciB0byBkZWJ1ZyB0aGlzLgoKU2lnbmVkLW9mZi1ieTogWXVjaHVuZyBD
aGVuZyA8eWNoZW5nQGdvb2dsZS5jb20+Ci0tLQogbmV0L2lwdjQvdGNwX2lucHV0LmMgfCA2ICsr
KysrLQogMSBmaWxlIGNoYW5nZWQsIDUgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlm
ZiAtLWdpdCBhL25ldC9pcHY0L3RjcF9pbnB1dC5jIGIvbmV0L2lwdjQvdGNwX2lucHV0LmMKaW5k
ZXggN2IxZmRkYy4uYzI3ZmE4NCAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdGNwX2lucHV0LmMKKysr
IGIvbmV0L2lwdjQvdGNwX2lucHV0LmMKQEAgLTI0NzgsOCArMjQ3OCwxMiBAQCBzdGF0aWMgdm9p
ZCB0Y3BfY3duZF9yZWR1Y3Rpb24oc3RydWN0IHNvY2sgKnNrLCBjb25zdCBpbnQgcHJpb3JfdW5z
YWNrZWQsCiAJaW50IG5ld2x5X2Fja2VkX3NhY2tlZCA9IHByaW9yX3Vuc2Fja2VkIC0KIAkJCQkg
KHRwLT5wYWNrZXRzX291dCAtIHRwLT5zYWNrZWRfb3V0KTsKIAorCWlmIChXQVJOX09OKCF0cC0+
cHJpb3JfY3duZCkpCisJCXByX2VycigiIGN3ciBwcmlvcl9jd25kMCAlZCBjd25kICV1ICVkICVk
IDB4JXhcbiIsCisJCQlpbmV0X2NzayhzayktPmljc2tfY2Ffc3RhdGUsIHRwLT5zbmRfY3duZCwK
KwkJCXRwLT5wcnJfb3V0LCB0cC0+cHJyX2RlbGl2ZXJlZCwgZmxhZyk7CiAJdHAtPnBycl9kZWxp
dmVyZWQgKz0gbmV3bHlfYWNrZWRfc2Fja2VkOwotCWlmIChkZWx0YSA8IDApIHsKKwlpZiAoZGVs
dGEgPCAwICYmIHRwLT5wcmlvcl9jd25kKSB7CiAJCXU2NCBkaXZpZGVuZCA9ICh1NjQpdHAtPnNu
ZF9zc3RocmVzaCAqIHRwLT5wcnJfZGVsaXZlcmVkICsKIAkJCSAgICAgICB0cC0+cHJpb3JfY3du
ZCAtIDE7CiAJCXNuZGNudCA9IGRpdl91NjQoZGl2aWRlbmQsIHRwLT5wcmlvcl9jd25kKSAtIHRw
LT5wcnJfb3V0OwotLSAKMi42LjAucmMyLjIzMC5nM2RkMTVjMAoK
--047d7bf0d954aad8870527731e3e--
