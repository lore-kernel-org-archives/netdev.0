From: Yuchung Cheng <ycheng@google.com>
Subject: Re: 3.10.0 network trace
Date: Wed, 11 Sep 2013 09:32:04 -0700
Message-ID: <CAK6E8=eRZQnPeVPpzcdzUtLqr0n2kjUQ2_JRE8_WXn3sSV2y9A@mail.gmail.com>
References: <CA+rTEUPfP8ouJHbaFrO=-zktg2D06kYgXOq-LnmyKbbEzj-TmA@mail.gmail.com>
 <CA+rTEUMYihwm_5ado5q1ZrYovgM6=Yc99mSaO-dNUyj4XyTj_Q@mail.gmail.com>
 <CAK6E8=eNa72=LySKsgpnKd5A6CSkr0pbpet1X2g8em9Or=m7bg@mail.gmail.com>
 <CA+rTEUNfHvr-Zs1JWVQV+_7ygW5AP9UScePSBEM-dsi0h7nS=w@mail.gmail.com>
 <CAK6E8=eqFm5_nDMdzkt6WUJXmKVTOyGbt-WtVPHDWdrOdYK_Ow@mail.gmail.com>
 <CA+rTEUNkqngK5cTUPPKAYkNgF4P8JcHoRoaEgUzBUTvO+h5JXQ@mail.gmail.com>
 <CAK6E8=fefVLUorMKCqJGSnq6Sc9LOKp7eUyOnh6h8rcOcJtQNQ@mail.gmail.com>
 <CA+rTEUOXAH4TGMGvgBJ6FktA6E=hFhQmFHRf4Zaw5YJ6giOpOA@mail.gmail.com> <CA+5PVA5bDAz5a-TrM4ALA9vJz2JbE14VT7xM5=WqaRg=Ro0_xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0158b304a419fe04e61e2a55
Cc: Michael Sterrett <michael@sterretts.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:62421 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792Ab3IKQc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 12:32:26 -0400
Received: by mail-ie0-f180.google.com with SMTP id 10so15892694ied.25
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 09:32:25 -0700 (PDT)
In-Reply-To: <CA+5PVA5bDAz5a-TrM4ALA9vJz2JbE14VT7xM5=WqaRg=Ro0_xQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e0158b304a419fe04e61e2a55
Content-Type: text/plain; charset=ISO-8859-1

On Wed, Sep 11, 2013 at 5:49 AM, Josh Boyer <jwboyer@fedoraproject.org> wrote:
> On Sun, Jul 21, 2013 at 9:36 PM, Michael Sterrett <michael@sterretts.net> wrote:
>> Since upgraded to 3.10.1 which exhibits the same issue (probably not
>> surprising).
>>
>> sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=3 seems to take
>> care of it.
>
> We're still getting reports of this with 3.10.10 in Fedora [1].  At
> least one of the reporters has said those sysctl settings didn't help.
>
> Is there anything else that can be gathered to help track this down?
since frto=0 didn't help, I suspect it's either a bug introduced in
the tail loss probe patch 9b717a8d (tcp: TLP loss detection) or other
changes related loss recovery.

could you try disable TLP by
sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=1

if it still does not work. disable any form of early retransmit by
sysctl net.ipv4.tcp_frto=0 net.ipv4.tcp_early_retrans=0

if you can test a custom build kernel, please try this debugging patch.

>
> josh
>
> [1] https://bugzilla.redhat.com/show_bug.cgi?id=989251

--089e0158b304a419fe04e61e2a55
Content-Type: application/octet-stream;
	name="0001-tcp-debug-fastretrans-warning.patch"
Content-Disposition: attachment;
	filename="0001-tcp-debug-fastretrans-warning.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hlgrmai50

RnJvbSA2MjU2MWM5MWQ0NjU1NTM5NzgxMTEzZTBmYTA0ZWU2ODFiMjJhMmE0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZdWNodW5nIENoZW5nIDx5Y2hlbmdAZ29vZ2xlLmNvbT4KRGF0
ZTogV2VkLCAzMSBKdWwgMjAxMyAwOToyMjozNSAtMDcwMApTdWJqZWN0OiBbUEFUQ0hdIHRjcDog
ZGVidWcgZmFzdHJldHJhbnMgd2FybmluZwoKcHJpbnRrIGEgdG9uIG9mIHN0YXRlcyB0byBkZWJ1
ZyBmYXN0cmV0cmFucyB3YXJuaW5nCgpTaWduZWQtb2ZmLWJ5OiBZdWNodW5nIENoZW5nIDx5Y2hl
bmdAZ29vZ2xlLmNvbT4KLS0tCiBuZXQvaXB2NC90Y3BfaW5wdXQuYyB8IDE1ICsrKysrKysrKysr
KysrLQogMSBmaWxlIGNoYW5nZWQsIDE0IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRp
ZmYgLS1naXQgYS9uZXQvaXB2NC90Y3BfaW5wdXQuYyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jCmlu
ZGV4IDljNjIyNTcuLmMxOGRhYjEgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L3RjcF9pbnB1dC5jCisr
KyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jCkBAIC0yNzczLDcgKzI3NzMsMjAgQEAgc3RhdGljIHZv
aWQgdGNwX2Zhc3RyZXRyYW5zX2FsZXJ0KHN0cnVjdCBzb2NrICpzaywgaW50IHBrdHNfYWNrZWQs
CiAJLyogRC4gQ2hlY2sgc3RhdGUgZXhpdCBjb25kaXRpb25zLiBTdGF0ZSBjYW4gYmUgdGVybWlu
YXRlZAogCSAqICAgIHdoZW4gaGlnaF9zZXEgaXMgQUNLZWQuICovCiAJaWYgKGljc2stPmljc2tf
Y2Ffc3RhdGUgPT0gVENQX0NBX09wZW4pIHsKLQkJV0FSTl9PTih0cC0+cmV0cmFuc19vdXQgIT0g
MCk7CisJCWlmIChXQVJOX09OKHRwLT5yZXRyYW5zX291dCAhPSAwKSkgeworCQkJcHJpbnRrKEtF
Uk5fREVCVUcgIiVwSTQ6JXUgRjB4JXggUyV1IHMlZCBJRiV1KyV1LSV1LSV1IgorCQkJICAgICAg
ICJmJXUgdXIldSByciV1IHJ0JXUgdW0ldSBocyV1IG54dCV1XG4iLAorCQkJICAgICAgICZpbmV0
X3NrKHNrKS0+aW5ldF9kYWRkciwKKwkJCSAgICAgICBudG9ocyhpbmV0X3NrKHNrKS0+aW5ldF9k
cG9ydCksCisJCQkgICAgICAgZmxhZywgc2stPnNrX3N0YXRlLCB0cC0+cnhfb3B0LnNhY2tfb2ss
CisJCQkgICAgICAgdHAtPnBhY2tldHNfb3V0LCB0cC0+cmV0cmFuc19vdXQsCisJCQkgICAgICAg
dHAtPnNhY2tlZF9vdXQsIHRwLT5sb3N0X291dCwKKwkJCSAgICAgICB0cC0+ZnJ0bywgdHAtPnVu
ZG9fcmV0cmFucywKKwkJCSAgICAgICB0cC0+cmVvcmRlcmluZywgaWNzay0+aWNza19yZXRyYW5z
bWl0cywKKwkJCSAgICAgICB0cC0+dW5kb19tYXJrZXIgPyB0cC0+dW5kb19tYXJrZXItdHAtPnNu
ZF91bmE6MCwKKwkJCSAgICAgICB0cC0+aGlnaF9zZXEgLSB0cC0+c25kX3VuYSwKKwkJCSAgICAg
ICB0cC0+c25kX254dCAtIHRwLT5zbmRfdW5hKTsKKwkJfQogCQl0cC0+cmV0cmFuc19zdGFtcCA9
IDA7CiAJfSBlbHNlIGlmICghYmVmb3JlKHRwLT5zbmRfdW5hLCB0cC0+aGlnaF9zZXEpKSB7CiAJ
CXN3aXRjaCAoaWNzay0+aWNza19jYV9zdGF0ZSkgewotLSAKMS44LjMKCg==
--089e0158b304a419fe04e61e2a55--
