From: Cong Wang <cwang@twopensource.com>
Subject: Re: Bug 75571
Date: Mon, 2 Jun 2014 14:19:52 -0700
Message-ID: <CAHA+R7Oog=fAGjcfVTus2HdCt_Vv-1XDFePR3mLb0FM1N3q0ow@mail.gmail.com>
References: <1401085231.1775.9.camel@anpws>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c29e0aba38b204fae0f478
Cc: netdev <netdev@vger.kernel.org>
To: Alex <d77190@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:41245 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbaFBVTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:19:53 -0400
Received: by mail-qa0-f52.google.com with SMTP id cm18so3565803qab.25
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 14:19:52 -0700 (PDT)
In-Reply-To: <1401085231.1775.9.camel@anpws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c29e0aba38b204fae0f478
Content-Type: text/plain; charset=UTF-8

On Sun, May 25, 2014 at 11:20 PM, Alex <d77190@mail.ru> wrote:
> Hello!
> I caught a bug and adviced to post it to this list from
> https://bugzilla.kernel.org/show_bug.cgi?id=75571
>
> I tried ifconfig interfaces down (both tun and ifb) before setting rules
> with no luck. This is new trace from kernel 3.2.59.
>
> [ 2945.851717] skb_under_panic: text:f9ca8566 len:209 put:148
> head:ece89000 data:ece88fce tail:0xece8909f end:0xece89140 dev:tun4177

Could you try the following patch? We need to call skb_cow_head() before
skb_push().

--001a11c29e0aba38b204fae0f478
Content-Type: text/plain; charset=US-ASCII; name="mirred.diff"
Content-Disposition: attachment; filename="mirred.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hvya5jbu0

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9hY3RfbWlycmVkLmMgYi9uZXQvc2NoZWQvYWN0X21pcnJl
ZC5jCmluZGV4IDRmOTEyYzAuLjM1YjhiOGUgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9hY3RfbWly
cmVkLmMKKysrIGIvbmV0L3NjaGVkL2FjdF9taXJyZWQuYwpAQCAtMTU2LDggKzE1NiwxNCBAQCBz
dGF0aWMgaW50IHRjZl9taXJyZWQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgY29uc3Qgc3RydWN0IHRj
X2FjdGlvbiAqYSwKIAkJZ290byBvdXQ7CiAKIAlpZiAoIShhdCAmIEFUX0VHUkVTUykpIHsKLQkJ
aWYgKG0tPnRjZm1fb2tfcHVzaCkKKwkJaWYgKG0tPnRjZm1fb2tfcHVzaCkgeworCQkJZXJyID0g
c2tiX2Nvd19oZWFkKHNrYjIsIHNrYjItPmRldi0+aGFyZF9oZWFkZXJfbGVuKTsKKwkJCWlmIChl
cnIpIHsKKwkJCQlrZnJlZV9za2Ioc2tiMik7CisJCQkJZ290byBvdXQ7CisJCQl9CiAJCQlza2Jf
cHVzaChza2IyLCBza2IyLT5kZXYtPmhhcmRfaGVhZGVyX2xlbik7CisJCX0KIAl9CiAKIAkvKiBt
aXJyb3IgaXMgYWx3YXlzIHN3YWxsb3dlZCAqLwo=
--001a11c29e0aba38b204fae0f478--
