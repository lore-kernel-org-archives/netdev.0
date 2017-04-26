From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: blocking ops when !TASK_RUNNING in vsock_stream_sendmsg() (again)
Date: Wed, 26 Apr 2017 10:18:57 -0700
Message-ID: <CAM_iQpXg-L2XOQfb_+Nngw7Qt0nh6Gy9nqBir0B3Ht3PjMKKmg@mail.gmail.com>
References: <20170421081458.GI13789@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c0e3f304f4d18054e150a7b
Cc: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andy King <acking@vmware.com>,
        George Zhang <georgezhang@vmware.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36880 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752766AbdDZRTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 13:19:19 -0400
Received: by mail-wm0-f52.google.com with SMTP id m123so11235028wma.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 10:19:18 -0700 (PDT)
In-Reply-To: <20170421081458.GI13789@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0e3f304f4d18054e150a7b
Content-Type: text/plain; charset=UTF-8

Hi,

On Fri, Apr 21, 2017 at 1:14 AM, Michal Kubecek <mkubecek@suse.cz> wrote:
> I tried to think about a solution but there doesn't seem to be an easy
> way to fix this in vmw_stream_sendmsg() as moving prepare_to_wait()
> inside the loop would result in missed wake-ups (that was the problem
> with the original fix); IMHO the right way to resolve the issue would be
> rewriting the vmci queue pair code to allow performing the has_space()
> check without taking a mutex.


Can you try the attached patch (compile only)?

Thanks.

--94eb2c0e3f304f4d18054e150a7b
Content-Type: text/plain; charset=US-ASCII; name="vsock-wait.diff"
Content-Disposition: attachment; filename="vsock-wait.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j1z8vo5g0

ZGlmZiAtLWdpdCBhL25ldC92bXdfdnNvY2svYWZfdnNvY2suYyBiL25ldC92bXdfdnNvY2svYWZf
dnNvY2suYwppbmRleCA2ZjdmNjc1Li5kZmM4YzUxZSAxMDA2NDQKLS0tIGEvbmV0L3Ztd192c29j
ay9hZl92c29jay5jCisrKyBiL25ldC92bXdfdnNvY2svYWZfdnNvY2suYwpAQCAtMTU0MCw4ICsx
NTQwLDcgQEAgc3RhdGljIGludCB2c29ja19zdHJlYW1fc2VuZG1zZyhzdHJ1Y3Qgc29ja2V0ICpz
b2NrLCBzdHJ1Y3QgbXNnaGRyICptc2csCiAJbG9uZyB0aW1lb3V0OwogCWludCBlcnI7CiAJc3Ry
dWN0IHZzb2NrX3RyYW5zcG9ydF9zZW5kX25vdGlmeV9kYXRhIHNlbmRfZGF0YTsKLQotCURFRklO
RV9XQUlUKHdhaXQpOworCURFRklORV9XQUlUX0ZVTkMod2FpdCwgd29rZW5fd2FrZV9mdW5jdGlv
bik7CiAKIAlzayA9IHNvY2stPnNrOwogCXZzayA9IHZzb2NrX3NrKHNrKTsKQEAgLTE1ODQsMTEg
KzE1ODMsMTAgQEAgc3RhdGljIGludCB2c29ja19zdHJlYW1fc2VuZG1zZyhzdHJ1Y3Qgc29ja2V0
ICpzb2NrLCBzdHJ1Y3QgbXNnaGRyICptc2csCiAJaWYgKGVyciA8IDApCiAJCWdvdG8gb3V0Owog
Ci0KIAl3aGlsZSAodG90YWxfd3JpdHRlbiA8IGxlbikgewogCQlzc2l6ZV90IHdyaXR0ZW47CiAK
LQkJcHJlcGFyZV90b193YWl0KHNrX3NsZWVwKHNrKSwgJndhaXQsIFRBU0tfSU5URVJSVVBUSUJM
RSk7CisJCWFkZF93YWl0X3F1ZXVlKHNrX3NsZWVwKHNrKSwgJndhaXQpOwogCQl3aGlsZSAodnNv
Y2tfc3RyZWFtX2hhc19zcGFjZSh2c2spID09IDAgJiYKIAkJICAgICAgIHNrLT5za19lcnIgPT0g
MCAmJgogCQkgICAgICAgIShzay0+c2tfc2h1dGRvd24gJiBTRU5EX1NIVVRET1dOKSAmJgpAQCAt
MTU5NywzMyArMTU5NSwzMCBAQCBzdGF0aWMgaW50IHZzb2NrX3N0cmVhbV9zZW5kbXNnKHN0cnVj
dCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBtc2doZHIgKm1zZywKIAkJCS8qIERvbid0IHdhaXQgZm9y
IG5vbi1ibG9ja2luZyBzb2NrZXRzLiAqLwogCQkJaWYgKHRpbWVvdXQgPT0gMCkgewogCQkJCWVy
ciA9IC1FQUdBSU47Ci0JCQkJZmluaXNoX3dhaXQoc2tfc2xlZXAoc2spLCAmd2FpdCk7CisJCQkJ
cmVtb3ZlX3dhaXRfcXVldWUoc2tfc2xlZXAoc2spLCAmd2FpdCk7CiAJCQkJZ290byBvdXRfZXJy
OwogCQkJfQogCiAJCQllcnIgPSB0cmFuc3BvcnQtPm5vdGlmeV9zZW5kX3ByZV9ibG9jayh2c2ss
ICZzZW5kX2RhdGEpOwogCQkJaWYgKGVyciA8IDApIHsKLQkJCQlmaW5pc2hfd2FpdChza19zbGVl
cChzayksICZ3YWl0KTsKKwkJCQlyZW1vdmVfd2FpdF9xdWV1ZShza19zbGVlcChzayksICZ3YWl0
KTsKIAkJCQlnb3RvIG91dF9lcnI7CiAJCQl9CiAKIAkJCXJlbGVhc2Vfc29jayhzayk7Ci0JCQl0
aW1lb3V0ID0gc2NoZWR1bGVfdGltZW91dCh0aW1lb3V0KTsKKwkJCXRpbWVvdXQgPSB3YWl0X3dv
a2VuKCZ3YWl0LCBUQVNLX0lOVEVSUlVQVElCTEUsIHRpbWVvdXQpOwogCQkJbG9ja19zb2NrKHNr
KTsKIAkJCWlmIChzaWduYWxfcGVuZGluZyhjdXJyZW50KSkgewogCQkJCWVyciA9IHNvY2tfaW50
cl9lcnJubyh0aW1lb3V0KTsKLQkJCQlmaW5pc2hfd2FpdChza19zbGVlcChzayksICZ3YWl0KTsK
KwkJCQlyZW1vdmVfd2FpdF9xdWV1ZShza19zbGVlcChzayksICZ3YWl0KTsKIAkJCQlnb3RvIG91
dF9lcnI7CiAJCQl9IGVsc2UgaWYgKHRpbWVvdXQgPT0gMCkgewogCQkJCWVyciA9IC1FQUdBSU47
Ci0JCQkJZmluaXNoX3dhaXQoc2tfc2xlZXAoc2spLCAmd2FpdCk7CisJCQkJcmVtb3ZlX3dhaXRf
cXVldWUoc2tfc2xlZXAoc2spLCAmd2FpdCk7CiAJCQkJZ290byBvdXRfZXJyOwogCQkJfQotCi0J
CQlwcmVwYXJlX3RvX3dhaXQoc2tfc2xlZXAoc2spLCAmd2FpdCwKLQkJCQkJVEFTS19JTlRFUlJV
UFRJQkxFKTsKIAkJfQotCQlmaW5pc2hfd2FpdChza19zbGVlcChzayksICZ3YWl0KTsKKwkJcmVt
b3ZlX3dhaXRfcXVldWUoc2tfc2xlZXAoc2spLCAmd2FpdCk7CiAKIAkJLyogVGhlc2UgY2hlY2tz
IG9jY3VyIGJvdGggYXMgcGFydCBvZiBhbmQgYWZ0ZXIgdGhlIGxvb3AKIAkJICogY29uZGl0aW9u
YWwgc2luY2Ugd2UgbmVlZCB0byBjaGVjayBiZWZvcmUgYW5kIGFmdGVyCg==
--94eb2c0e3f304f4d18054e150a7b--
