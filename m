From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: tg3 pxe weirdness
Date: Mon, 25 Sep 2017 15:11:04 +0530
Message-ID: <CAMet4B6mZ8SyCT7W2j4OBEUDiy3ZupYKWXBFti0nXoxm51_6kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a114749a87e0e44055a005b0e"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Berend De Schouwer <berend.de.schouwer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:45471 "EHLO
        mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934236AbdIYJlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 05:41:05 -0400
Received: by mail-qk0-f169.google.com with SMTP id r141so6052964qke.2
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 02:41:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114749a87e0e44055a005b0e
Content-Type: text/plain; charset="UTF-8"

On Fri, Sep 22, 2017 at 9:04 PM, Berend De Schouwer
<berend.de.schouwer@gmail.com> wrote:
> On Fri, 2017-09-22 at 11:51 +0530, Siva Reddy Kallam wrote:
>>
>>
>> Can you please share below details?
>> 1) Model and Manufacturer of the system
>> 2) Linux distro/kernel used?
>
> 4.13.3 gets a little further, but after some more data is transferred
> the tg3 driver still crashes.  This is unfortunately before I've got a
> writeable filesystem.
>
> The last line is:
> tg3 0000:01:00.0: tg3_stop_block timed out, ofs=4c00 enable_bit=2
>
> I've got some ideas to get the full dmesg.
>
> As with the other kernels it works OK on 1Gbps, but not slower
> switches.
I am suspecting with link aware mode, the clock speed could be slow
and boot code does not
complete within the expected time with lower link speeds. So,
Providing a patch to override clock.
Can you please try with attached debug patch and provide us the
feedback with 100M link?
If it solves this issue, we will work on proper changes.

--001a114749a87e0e44055a005b0e
Content-Type: application/octet-stream;
	name="0001-tg3-Add-clock-override-support-for-5762.patch"
Content-Disposition: attachment;
	filename="0001-tg3-Add-clock-override-support-for-5762.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j7zzbidk0

RnJvbSA3NzBiYzM0NmZkNWQ0MzgwYzM1NzJiOGUzMTNjM2QyNzE0MjI3MDY5IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTaXZhIFJlZGR5IEthbGxhbSA8c2l2YS5rYWxsYW1AYnJvYWRj
b20uY29tPgpEYXRlOiBNb24sIDI1IFNlcCAyMDE3IDEyOjM3OjA1ICswNTMwClN1YmplY3Q6IFtQ
QVRDSF0gdGczOiBBZGQgY2xvY2sgb3ZlcnJpZGUgc3VwcG9ydCBmb3IgNTc2MgoKVGhpcyBwYXRj
aCBhZGQgdGhlIG92ZXJyaWRlIHN1cHBvcnQgZm9yIDU3NjIKClNpZ25lZC1vZmYtYnk6IFNpdmEg
UmVkZHkgS2FsbGFtIDxzaXZhLmthbGxhbUBicm9hZGNvbS5jb20+Ci0tLQogZHJpdmVycy9uZXQv
ZXRoZXJuZXQvYnJvYWRjb20vdGczLmMgfCAxOSArKysrKysrKysrKystLS0tLS0tCiAxIGZpbGUg
Y2hhbmdlZCwgMTIgaW5zZXJ0aW9ucygrKSwgNyBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS90ZzMuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0
L2Jyb2FkY29tL3RnMy5jCmluZGV4IGQ4ZDVmMjAuLmNkZTYyNDQgMTAwNjQ0Ci0tLSBhL2RyaXZl
cnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL3RnMy5jCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0
L2Jyb2FkY29tL3RnMy5jCkBAIC05MDA5LDYgKzkwMDksMTEgQEAgc3RhdGljIHZvaWQgdGczX292
ZXJyaWRlX2NsayhzdHJ1Y3QgdGczICp0cCkKIAljYXNlIEFTSUNfUkVWXzU3MjA6CiAJCXR3MzIo
VEczX0NQTVVfQ0xDS19PUklERSwgQ1BNVV9DTENLX09SSURFX01BQ19PUklERV9FTik7CiAJCWJy
ZWFrOworCWNhc2UgQVNJQ19SRVZfNTc2MjoKKwkJdmFsID0gdHIzMihURzNfQ1BNVV9DTENLX09S
SURFX0VOQUJMRSk7CisJCXR3MzIoVEczX0NQTVVfQ0xDS19PUklERV9FTkFCTEUsIHZhbCB8CisJ
CSAgICAgVEczX0NQTVVfTUFDX09SSURFX0VOQUJMRSk7CisJCWJyZWFrOwogCiAJZGVmYXVsdDoK
IAkJcmV0dXJuOwpAQCAtOTEzMSwxMyArOTEzNiw2IEBAIHN0YXRpYyBpbnQgdGczX2NoaXBfcmVz
ZXQoc3RydWN0IHRnMyAqdHApCiAJCSAgICAgdHIzMihHUkNfVkNQVV9FWFRfQ1RSTCkgJiB+R1JD
X1ZDUFVfRVhUX0NUUkxfSEFMVF9DUFUpOwogCX0KIAotCS8qIFNldCB0aGUgY2xvY2sgdG8gdGhl
IGhpZ2hlc3QgZnJlcXVlbmN5IHRvIGF2b2lkIHRpbWVvdXRzLiBXaXRoIGxpbmsKLQkgKiBhd2Fy
ZSBtb2RlLCB0aGUgY2xvY2sgc3BlZWQgY291bGQgYmUgc2xvdyBhbmQgYm9vdGNvZGUgZG9lcyBu
b3QKLQkgKiBjb21wbGV0ZSB3aXRoaW4gdGhlIGV4cGVjdGVkIHRpbWUuIE92ZXJyaWRlIHRoZSBj
bG9jayB0byBhbGxvdyB0aGUKLQkgKiBib290Y29kZSB0byBmaW5pc2ggc29vbmVyIGFuZCB0aGVu
IHJlc3RvcmUgaXQuCi0JICovCi0JdGczX292ZXJyaWRlX2Nsayh0cCk7Ci0KIAkvKiBNYW5hZ2Ug
Z3BoeSBwb3dlciBmb3IgYWxsIENQTVUgYWJzZW50IFBDSWUgZGV2aWNlcy4gKi8KIAlpZiAodGcz
X2ZsYWcodHAsIDU3MDVfUExVUykgJiYgIXRnM19mbGFnKHRwLCBDUE1VX1BSRVNFTlQpKQogCQl2
YWwgfD0gR1JDX01JU0NfQ0ZHX0tFRVBfR1BIWV9QT1dFUjsKQEAgLTkyMzUsNiArOTIzMywxMyBA
QCBzdGF0aWMgaW50IHRnM19jaGlwX3Jlc2V0KHN0cnVjdCB0ZzMgKnRwKQogCWlmIChlcnIpCiAJ
CXJldHVybiBlcnI7CiAKKwkvKiBTZXQgdGhlIGNsb2NrIHRvIHRoZSBoaWdoZXN0IGZyZXF1ZW5j
eSB0byBhdm9pZCB0aW1lb3V0cy4gV2l0aCBsaW5rCisJICogYXdhcmUgbW9kZSwgdGhlIGNsb2Nr
IHNwZWVkIGNvdWxkIGJlIHNsb3cgYW5kIGJvb3Rjb2RlIGRvZXMgbm90CisJICogY29tcGxldGUg
d2l0aGluIHRoZSBleHBlY3RlZCB0aW1lLiBPdmVycmlkZSB0aGUgY2xvY2sgdG8gYWxsb3cgdGhl
CisJICogYm9vdGNvZGUgdG8gZmluaXNoIHNvb25lciBhbmQgdGhlbiByZXN0b3JlIGl0LgorCSAq
LworCXRnM19vdmVycmlkZV9jbGsodHApOworCiAJdHczMihHUkNfTU9ERSwgdHAtPmdyY19tb2Rl
KTsKIAogCWlmICh0ZzNfY2hpcF9yZXZfaWQodHApID09IENISVBSRVZfSURfNTcwNV9BMCkgewot
LSAKMS44LjMuMQoK
--001a114749a87e0e44055a005b0e--
