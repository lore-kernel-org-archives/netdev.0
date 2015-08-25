From: Cong Wang <cwang@twopensource.com>
Subject: Re: iproute2: Behavioural Bug?
Date: Tue, 25 Aug 2015 14:00:27 -0700
Message-ID: <CAHA+R7NNF2O3e==g_-MoFtaHg_G37jHBNPrui+RA5uJR8kjkjg@mail.gmail.com>
References: <CAA5aLPjmomaEv28==0wxtwNeRUguXimJqyWCEFNt0jrOkZ9O7g@mail.gmail.com>
	<20150824232229.GC5905@breakpoint.cc>
	<CAA5aLPj6Whq_U3VXx60J+b0rZFj9kucXy8H9NM9rYCTc9OPMoQ@mail.gmail.com>
	<CAHA+R7OWyfupqmCk69ykN7TP+sMwUyVtFNX=Mr_Q9DCXRSx6fw@mail.gmail.com>
	<CAA5aLPjLhLdp2QPMw-ZvNOVjsewnM3TqV4zHFfY2_HX0UOqoFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=089e0112d15e108a1c051e29064c
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34067 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbbHYVA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 17:00:29 -0400
Received: by lbbtg9 with SMTP id tg9so108453305lbb.1
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 14:00:28 -0700 (PDT)
In-Reply-To: <CAA5aLPjLhLdp2QPMw-ZvNOVjsewnM3TqV4zHFfY2_HX0UOqoFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--089e0112d15e108a1c051e29064c
Content-Type: text/plain; charset=UTF-8

(Cc'ing Jamal)

On Tue, Aug 25, 2015 at 12:18 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> Well if that is the case, then just an additional information (which I
> have initially mentioned though), if hashtable is 800, then behaviour
> is correct i.e. deleting only a single filter but for hash tables
> other than 800, the bug (if any) gets triggered.
>

Hmm, I didn't read your initial email before my previous reply.

But I bet you deleted the 800: filter _after_ deleting the 15: one?
u32 hashtables are stateful, try the reverse order, I don't see
any reason why 800: could be any special here, expect it is the
default handle picked by kernel.

The attached patch works for me, let me know if it works for you..

--089e0112d15e108a1c051e29064c
Content-Type: text/plain; charset=US-ASCII; name="u32.diff"
Content-Disposition: attachment; filename="u32.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_idru41rb0

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9jbHNfdTMyLmMgYi9uZXQvc2NoZWQvY2xzX3UzMi5jCmlu
ZGV4IGNhYjllOWIuLmFjNWUwYWQgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9jbHNfdTMyLmMKKysr
IGIvbmV0L3NjaGVkL2Nsc191MzIuYwpAQCAtNDk1LDYgKzQ5NSwyMCBAQCBzdGF0aWMgYm9vbCB1
MzJfZGVzdHJveShzdHJ1Y3QgdGNmX3Byb3RvICp0cCwgYm9vbCBmb3JjZSkKIAlpZiAocm9vdF9o
dCAmJiAtLXJvb3RfaHQtPnJlZmNudCA9PSAwKQogCQl1MzJfZGVzdHJveV9obm9kZSh0cCwgcm9v
dF9odCk7CiAKKwlpZiAoIWZvcmNlKSB7CisJCXN0cnVjdCB0Y191X2hub2RlICpodDsKKworCQlp
ZiAodHBfYy0+cmVmY250ID4gMSkKKwkJCXJldHVybiBmYWxzZTsKKwkJaWYgKHRwX2MtPnJlZmNu
dCA9PSAxKSB7CisJCQlmb3IgKGh0ID0gcnRubF9kZXJlZmVyZW5jZSh0cF9jLT5obGlzdCk7CisJ
CQkgICAgIGh0OworCQkJICAgICBodCA9IHJ0bmxfZGVyZWZlcmVuY2UoaHQtPm5leHQpKQorCQkJ
CWlmICghaHRfZW1wdHkoaHQpKQorCQkJCQlyZXR1cm4gZmFsc2U7CisJCX0KKwl9CisKIAlpZiAo
LS10cF9jLT5yZWZjbnQgPT0gMCkgewogCQlzdHJ1Y3QgdGNfdV9obm9kZSAqaHQ7CiAK
--089e0112d15e108a1c051e29064c--
