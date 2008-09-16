From: "Andrew Victor" <avictor.za@gmail.com>
Subject: [PATCH] at91_ether: late collistions are counted twice (resubmit)
Date: Tue, 16 Sep 2008 22:48:07 +0200
Message-ID: <cd73a99e0809161348p42f702ck678dbf7aa7093eeb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_10572_18166146.1221598087524"
Cc: marc.pignat@hevs.ch
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:43035 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbYIPUsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 16:48:12 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1495253wri.5
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 13:48:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_10572_18166146.1221598087524
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

According to the at91rm9200 datasheet, table 36-6, late collisions
(AT91_EMAC_LCOL) are already counted in the collision register (in scol, mcol or
ecol , depending on the type of error).

So don't count them twice in stats.collisions.

Signed-off-by: Marc Pignat <marc.pignat@hevs.ch>
Signed-off-by: Andrew Victor <linux@maxim.org.za>

------=_Part_10572_18166146.1221598087524
Content-Type: text/x-patch; name=7-ethernet_lcol.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fl6zqn040
Content-Disposition: attachment; filename=7-ethernet_lcol.patch

ZGlmZiAtdXJOIGxpbnV4LTIuNi4yNy1yYzYub3JpZy9kcml2ZXJzL25ldC9hcm0vYXQ5MV9ldGhl
ci5jIGxpbnV4LTIuNi4yNy1yYzYvZHJpdmVycy9uZXQvYXJtL2F0OTFfZXRoZXIuYwotLS0gbGlu
dXgtMi42LjI3LXJjNi5vcmlnL2RyaXZlcnMvbmV0L2FybS9hdDkxX2V0aGVyLmMJMjAwOC0wOS0x
NiAyMToxMTozOS4wMDAwMDAwMDAgKzAyMDAKKysrIGxpbnV4LTIuNi4yNy1yYzYvZHJpdmVycy9u
ZXQvYXJtL2F0OTFfZXRoZXIuYwkyMDA4LTA5LTE2IDIxOjEzOjQ4LjAwMDAwMDAwMCArMDIwMApA
QCAtODQzLDcgKzg0Myw3IEBACiAgKi8KIHN0YXRpYyBzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyAq
YXQ5MWV0aGVyX3N0YXRzKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiB7Ci0JaW50IGFsZSwgbGVu
ZXJyLCBzZXFlLCBsY29sLCBlY29sOworCWludCBhbGUsIGxlbmVyciwgc2VxZSwgZWNvbDsKIAog
CWlmIChuZXRpZl9ydW5uaW5nKGRldikpIHsKIAkJZGV2LT5zdGF0cy5yeF9wYWNrZXRzICs9IGF0
OTFfZW1hY19yZWFkKEFUOTFfRU1BQ19PSyk7CQkvKiBHb29kIGZyYW1lcyByZWNlaXZlZCAqLwpA
QCAtODYyLDEyICs4NjIsMTEgQEAKIAkJZGV2LT5zdGF0cy50eF9jYXJyaWVyX2Vycm9ycyArPSBh
dDkxX2VtYWNfcmVhZChBVDkxX0VNQUNfQ1NFKTsJLyogQ2FycmllciBTZW5zZSBlcnJvcnMgKi8K
IAkJZGV2LT5zdGF0cy50eF9oZWFydGJlYXRfZXJyb3JzICs9IGF0OTFfZW1hY19yZWFkKEFUOTFf
RU1BQ19TUUVFKTsvKiBIZWFydGJlYXQgZXJyb3IgKi8KIAotCQlsY29sID0gYXQ5MV9lbWFjX3Jl
YWQoQVQ5MV9FTUFDX0xDT0wpOworCQlkZXYtPnN0YXRzLnR4X3dpbmRvd19lcnJvcnMgKz0gYXQ5
MV9lbWFjX3JlYWQoQVQ5MV9FTUFDX0xDT0wpOwkvKiBMYXRlIGNvbGxpc2lvbnMgKi8KIAkJZWNv
bCA9IGF0OTFfZW1hY19yZWFkKEFUOTFfRU1BQ19FQ09MKTsKLQkJZGV2LT5zdGF0cy50eF93aW5k
b3dfZXJyb3JzICs9IGxjb2w7CQkJLyogTGF0ZSBjb2xsaXNpb25zICovCi0JCWRldi0+c3RhdHMu
dHhfYWJvcnRlZF9lcnJvcnMgKz0gZWNvbDsJCQkvKiAxNiBjb2xsaXNpb25zICovCisJCWRldi0+
c3RhdHMudHhfYWJvcnRlZF9lcnJvcnMgKz0gZWNvbDsJCQkJLyogMTYgY29sbGlzaW9ucyAqLwog
Ci0JCWRldi0+c3RhdHMuY29sbGlzaW9ucyArPSAoYXQ5MV9lbWFjX3JlYWQoQVQ5MV9FTUFDX1ND
T0wpICsgYXQ5MV9lbWFjX3JlYWQoQVQ5MV9FTUFDX01DT0wpICsgbGNvbCArIGVjb2wpOworCQlk
ZXYtPnN0YXRzLmNvbGxpc2lvbnMgKz0gKGF0OTFfZW1hY19yZWFkKEFUOTFfRU1BQ19TQ09MKSAr
IGF0OTFfZW1hY19yZWFkKEFUOTFfRU1BQ19NQ09MKSArIGVjb2wpOwogCX0KIAlyZXR1cm4gJmRl
di0+c3RhdHM7CiB9Cg==
------=_Part_10572_18166146.1221598087524--
