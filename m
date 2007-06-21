From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 21 Jun 2007 11:23:22 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903146CC1@orsmsx414.amr.corp.intel.com>
References: <467AC0AA.5000603@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C7B431.409EB5BA"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45220 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723AbXFUSXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2007 14:23:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467AC0AA.5000603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C7B431.409EB5BA
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

> Waskiewicz Jr, Peter P wrote:
> >> Please post the code.
> >>
> >>    =20
> >
> > Code is attached.  Please forgive the attachment and any whitespace=20
> > damage...currently using Doubtlook to send this (cringe).
> >  =20
>=20
> The code looks correct. Are you sure you had the config=20
> option enabled during your test?
>

Yes.  This is the tc command I used to configure the qdisc (with q_rr.c
attached from my patches iproute2 package):

# tc qdisc add dev eth2 root handle 1: rr bands 8
RTNETLINK answers: No such file or directory

At this point, sch_prio gets loaded correctly, but it obviously fails to
finish loading the qdisc.  Using prio works though:

# tc qdisc add dev eth2 root handle 1: prio bands 8

And yes, the NIC I'm working with has 8 queues, just to be clear.  Any
help is definitely appreciated; I'm going to keep this copy of the code
for now, but am going to get the separate module written back up just in
case this can't be solved in the short-term.  This is the only piece
keeping me from sending these patches back for consideration, so I'll
keep the parallel effort going.

Thanks Patrick,

-PJ Waskiewicz

------_=_NextPart_001_01C7B431.409EB5BA
Content-Type: application/octet-stream;
	name="q_rr.c"
Content-Transfer-Encoding: base64
Content-Description: q_rr.c
Content-Disposition: attachment;
	filename="q_rr.c"

LyoKICogcV9yci5jCQlSUi4KICoKICoJCVRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlOyB5
b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IKICoJCW1vZGlmeSBpdCB1bmRlciB0aGUgdGVy
bXMgb2YgdGhlIEdOVSBHZW5lcmFsIFB1YmxpYyBMaWNlbnNlCiAqCQlhcyBwdWJsaXNoZWQgYnkg
dGhlIEZyZWUgU29mdHdhcmUgRm91bmRhdGlvbjsgZWl0aGVyIHZlcnNpb24KICoJCTIgb2YgdGhl
IExpY2Vuc2UsIG9yIChhdCB5b3VyIG9wdGlvbikgYW55IGxhdGVyIHZlcnNpb24uCiAqCiAqIEF1
dGhvcnM6CVBKIFdhc2tpZXdpY3osIDxwZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tPgog
KiBPcmlnaW5hbCBBdXRob3JzOglBbGV4ZXkgS3V6bmV0c292LCA8a3V6bmV0QG1zMi5pbnIuYWMu
cnU+IChmcm9tIFBSSU8pCiAqCiAqIENoYW5nZXM6CiAqCiAqIE9sZSBIdXNnYWFyZCA8c3BhcnJl
QGxvZ2luLmRrbmV0LmRrPjogOTkwNTEzOiBwcmlvMmJhbmQgbWFwIHdhcyBhbHdheXMgcmVzZXQu
CiAqIEogSGFkaSBTYWxpbSA8aGFkaUBjeWJlcnVzLmNhPjogOTkwNjA5OiBwcmlvbWFwIGZpeC4K
ICovCgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5oPgojaW5jbHVkZSA8dW5p
c3RkLmg+CiNpbmNsdWRlIDxzeXNsb2cuaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxz
eXMvc29ja2V0Lmg+CiNpbmNsdWRlIDxuZXRpbmV0L2luLmg+CiNpbmNsdWRlIDxhcnBhL2luZXQu
aD4KI2luY2x1ZGUgPHN0cmluZy5oPgoKI2luY2x1ZGUgInV0aWxzLmgiCiNpbmNsdWRlICJ0Y191
dGlsLmgiCgpzdGF0aWMgdm9pZCBleHBsYWluKHZvaWQpCnsKCWZwcmludGYoc3RkZXJyLCAiVXNh
Z2U6IC4uLiByciBiYW5kcyBOVU1CRVIgcHJpb21hcCBQMSBQMi4uLlxuIik7Cn0KCiNkZWZpbmUg
dXNhZ2UoKSByZXR1cm4oLTEpCgpzdGF0aWMgaW50IHJyX3BhcnNlX29wdChzdHJ1Y3QgcWRpc2Nf
dXRpbCAqcXUsIGludCBhcmdjLCBjaGFyICoqYXJndiwgc3RydWN0IG5sbXNnaGRyICpuKQp7Cglp
bnQgb2sgPSAwOwoJaW50IHBtYXBfbW9kZSA9IDA7CglpbnQgaWR4ID0gMDsKCXN0cnVjdCB0Y19w
cmlvX3FvcHQgb3B0PXszLHsgMSwgMiwgMiwgMiwgMSwgMiwgMCwgMCwgMSwgMSwgMSwgMSwgMSwg
MSwgMSwgMSB9fTsKCgl3aGlsZSAoYXJnYyA+IDApIHsKCQlpZiAoc3RyY21wKCphcmd2LCAiYmFu
ZHMiKSA9PSAwKSB7CgkJCWlmIChwbWFwX21vZGUpCgkJCQlleHBsYWluKCk7CgkJCU5FWFRfQVJH
KCk7CgkJCWlmIChnZXRfaW50ZWdlcigmb3B0LmJhbmRzLCAqYXJndiwgMTApKSB7CgkJCQlmcHJp
bnRmKHN0ZGVyciwgIklsbGVnYWwgXCJiYW5kc1wiXG4iKTsKCQkJCXJldHVybiAtMTsKCQkJfQoJ
CQlvaysrOwoJCX0gZWxzZSBpZiAoc3RyY21wKCphcmd2LCAicHJpb21hcCIpID09IDApIHsKCQkJ
aWYgKHBtYXBfbW9kZSkgewoJCQkJZnByaW50ZihzdGRlcnIsICJFcnJvcjogZHVwbGljYXRlIHBy
aW9tYXBcbiIpOwoJCQkJcmV0dXJuIC0xOwoJCQl9CgkJCXBtYXBfbW9kZSA9IDE7CgkJfSBlbHNl
IGlmIChzdHJjbXAoKmFyZ3YsICJoZWxwIikgPT0gMCkgewoJCQlleHBsYWluKCk7CgkJCXJldHVy
biAtMTsKCQl9IGVsc2UgewoJCQl1bnNpZ25lZCBiYW5kOwoJCQlpZiAoIXBtYXBfbW9kZSkgewoJ
CQkJZnByaW50ZihzdGRlcnIsICJXaGF0IGlzIFwiJXNcIj9cbiIsICphcmd2KTsKCQkJCWV4cGxh
aW4oKTsKCQkJCXJldHVybiAtMTsKCQkJfQoJCQlpZiAoZ2V0X3Vuc2lnbmVkKCZiYW5kLCAqYXJn
diwgMTApKSB7CgkJCQlmcHJpbnRmKHN0ZGVyciwgIklsbGVnYWwgXCJwcmlvbWFwXCIgZWxlbWVu
dFxuIik7CgkJCQlyZXR1cm4gLTE7CgkJCX0KCQkJaWYgKGJhbmQgPiBvcHQuYmFuZHMpIHsKCQkJ
CWZwcmludGYoc3RkZXJyLCAiXCJwcmlvbWFwXCIgZWxlbWVudCBpcyBvdXQgb2YgYmFuZHNcbiIp
OwoJCQkJcmV0dXJuIC0xOwoJCQl9CgkJCWlmIChpZHggPiBUQ19QUklPX01BWCkgewoJCQkJZnBy
aW50ZihzdGRlcnIsICJcInByaW9tYXBcIiBpbmRleCA+IFRDX1JSX01BWD0ldVxuIiwgVENfUFJJ
T19NQVgpOwoJCQkJcmV0dXJuIC0xOwoJCQl9CgkJCW9wdC5wcmlvbWFwW2lkeCsrXSA9IGJhbmQ7
CgkJfQoJCWFyZ2MtLTsgYXJndisrOwoJfQoKCWFkZGF0dHJfbChuLCAxMDI0LCBUQ0FfT1BUSU9O
UywgJm9wdCwgc2l6ZW9mKG9wdCkpOwoJcmV0dXJuIDA7Cn0KCmludCBycl9wcmludF9vcHQoc3Ry
dWN0IHFkaXNjX3V0aWwgKnF1LCBGSUxFICpmLCBzdHJ1Y3QgcnRhdHRyICpvcHQpCnsKCWludCBp
OwoJc3RydWN0IHRjX3ByaW9fcW9wdCAqcW9wdDsKCglpZiAob3B0ID09IE5VTEwpCgkJcmV0dXJu
IDA7CgoJaWYgKFJUQV9QQVlMT0FEKG9wdCkgIDwgc2l6ZW9mKCpxb3B0KSkKCQlyZXR1cm4gLTE7
Cglxb3B0ID0gUlRBX0RBVEEob3B0KTsKCWZwcmludGYoZiwgImJhbmRzICV1IHByaW9tYXAgIiwg
cW9wdC0+YmFuZHMpOwoJZm9yIChpPTA7IGkgPD0gVENfUFJJT19NQVg7IGkrKykKCQlmcHJpbnRm
KGYsICIgJWQiLCBxb3B0LT5wcmlvbWFwW2ldKTsKCXJldHVybiAwOwp9CgpzdHJ1Y3QgcWRpc2Nf
dXRpbCBycl9xZGlzY191dGlsID0gewoJLmlkCSAJPSAicnIiLAoJLnBhcnNlX3FvcHQJPSBycl9w
YXJzZV9vcHQsCgkucHJpbnRfcW9wdAk9IHJyX3ByaW50X29wdCwKfTsK

------_=_NextPart_001_01C7B431.409EB5BA--
