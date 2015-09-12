From: Cong Wang <cwang@twopensource.com>
Subject: Re: [fw filter]: Broken! fw mark based tc class selection not working
Date: Fri, 11 Sep 2015 17:00:49 -0700
Message-ID: <CAHA+R7N6rTS5rmALk_2FxUXc0s9Ni4snJQ52tS3imaA6hotdHw@mail.gmail.com>
References: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
	<CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
	<CAA5aLPgCqOXU3vw6moSvADuOc4Q_TM2iJLHjSH0O8NwYJJ1t7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114820c469114f051f818611
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:35652 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbbILAAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 20:00:50 -0400
Received: by ykdu9 with SMTP id u9so107902634ykd.2
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 17:00:49 -0700 (PDT)
In-Reply-To: <CAA5aLPgCqOXU3vw6moSvADuOc4Q_TM2iJLHjSH0O8NwYJJ1t7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114820c469114f051f818611
Content-Type: text/plain; charset=UTF-8

On Fri, Sep 11, 2015 at 3:24 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> There is no handle with fw filter. That's the whole point is. If
> handle and class (flow id) is not specified, then whatever be the mark
> on the packet, its automatically set as flowid. So if mark is 0x10003,
> then this fw filter
>
> tc filter add dev eth0 parent 1:0 protocol ip fw
>
> will cause 0x10003 being set as classid I.e. 1:3.
>
>
> tc qdisc add dev eth0 root handle 1: htb
> tc class add dev eth0 parent 1: classid 1:a htb rate 1mbit
> tc class add dev eth0 parent 1: classid 1:b htb rate 1mbit
> tc class add dev eth0 parent 1: classid 1:c htb rate 1mbit
> tc filter add dev eth0 parent 1:0 protocol ip fw
>
> iptables -t mangle -I OUTPUT -o eth0 -p tcp -j MARK --set-mark 0x1000a
> iptables -t mangle -I OUTPUT -o eth0 -p icmp -j MARK --set-mark 0x1000b
> iptables -t mangle -I OUTPUT -o eth0 -p udp -j MARK --set-mark 0x1000c


Hmm, I didn't know that before either. Looks like my tp->init change
breaks it.

Could you try the following patch?

Thanks!

--001a114820c469114f051f818611
Content-Type: text/plain; charset=US-ASCII; name="cls_fw.diff"
Content-Disposition: attachment; filename="cls_fw.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iegb3wp00

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9jbHNfZncuYyBiL25ldC9zY2hlZC9jbHNfZncuYwppbmRl
eCA3MTVlMDFlLi5iNjM5NGFiIDEwMDY0NAotLS0gYS9uZXQvc2NoZWQvY2xzX2Z3LmMKKysrIGIv
bmV0L3NjaGVkL2Nsc19mdy5jCkBAIC0zNCw2ICszNCw3IEBACiBzdHJ1Y3QgZndfaGVhZCB7CiAJ
dTMyCQkJbWFzazsKIAlib29sCQkJbWFza19zZXQ7CisJYm9vbAkJCW9sZF9tZXRob2Q7CiAJc3Ry
dWN0IGZ3X2ZpbHRlciBfX3JjdQkqaHRbSFRTSVpFXTsKIAlzdHJ1Y3QgcmN1X2hlYWQJCXJjdTsK
IH07CkBAIC02NSw3ICs2Niw3IEBAIHN0YXRpYyBpbnQgZndfY2xhc3NpZnkoc3RydWN0IHNrX2J1
ZmYgKnNrYiwgY29uc3Qgc3RydWN0IHRjZl9wcm90byAqdHAsCiAJaW50IHI7CiAJdTMyIGlkID0g
c2tiLT5tYXJrOwogCi0JaWYgKGhlYWQgIT0gTlVMTCkgeworCWlmICghaGVhZC0+b2xkX21ldGhv
ZCkgewogCQlpZCAmPSBoZWFkLT5tYXNrOwogCiAJCWZvciAoZiA9IHJjdV9kZXJlZmVyZW5jZV9i
aChoZWFkLT5odFtmd19oYXNoKGlkKV0pOyBmOwpAQCAtMTIwLDYgKzEyMSw3IEBAIHN0YXRpYyBp
bnQgZndfaW5pdChzdHJ1Y3QgdGNmX3Byb3RvICp0cCkKIAlpZiAoaGVhZCA9PSBOVUxMKQogCQly
ZXR1cm4gLUVOT0JVRlM7CiAKKwloZWFkLT5vbGRfbWV0aG9kID0gdHJ1ZTsKIAloZWFkLT5tYXNr
X3NldCA9IGZhbHNlOwogCXJjdV9hc3NpZ25fcG9pbnRlcih0cC0+cm9vdCwgaGVhZCk7CiAJcmV0
dXJuIDA7CkBAIC0zMDIsNiArMzA0LDcgQEAgc3RhdGljIGludCBmd19jaGFuZ2Uoc3RydWN0IG5l
dCAqbmV0LCBzdHJ1Y3Qgc2tfYnVmZiAqaW5fc2tiLAogCWlmICghaGFuZGxlKQogCQlyZXR1cm4g
LUVJTlZBTDsKIAorCWhlYWQtPm9sZF9tZXRob2QgPSBmYWxzZTsKIAlpZiAoIWhlYWQtPm1hc2tf
c2V0KSB7CiAJCWhlYWQtPm1hc2sgPSAweEZGRkZGRkZGOwogCQlpZiAodGJbVENBX0ZXX01BU0td
KQo=
--001a114820c469114f051f818611--
