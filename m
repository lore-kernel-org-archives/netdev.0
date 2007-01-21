From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Sun, 21 Jan 2007 14:02:15 +0100
Message-ID: <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
	 <20070109092602.GC1703@ff.dom.local>
	 <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <20070109130220.GA4060@ff.dom.local>
	 <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
	 <20070109200541.GA27089@xyzzy.farnsworth.org>
	 <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
	 <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
	 <20070111104220.GA3171@ff.dom.local>
	 <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_170201_27777079.1169384535439"
Cc: "Dale Farnsworth" <dale@farnsworth.org>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:31030 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbXAUNCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 08:02:17 -0500
Received: by ug-out-1314.google.com with SMTP id 44so800539uga
        for <netdev@vger.kernel.org>; Sun, 21 Jan 2007 05:02:16 -0800 (PST)
To: "Jarek Poplawski" <jarkao2@o2.pl>
In-Reply-To: <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_170201_27777079.1169384535439
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 1/21/07, Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
> On 1/11/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> >
> > PS: alas I didn't even check compiling - I had no time to
> > find all compile dependencies of this driver
> > ---
> Hmm, I think this is guaranteed not to work. In between those lines
> the lock is released, while data in the mp structure is still being
> accessed. It seems that this bit of code is indeed not race-safe
> though, I'm gonna try to figure something.

This was indeed the right spot. The attached raw hack seems to fix the
bug (I couldn't crash the box so far).  I haven't checked that the
same "situation" happens elsewhere in the code, I leave that as an
exercise for the maintainers (or until I experience another kind of
crash :)

The patch is a bit ugly (printk with irq disabled will not show, etc)
but at least it does work. I'm sure somebody will figure something

HTH

T-Bone

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/

------=_Part_170201_27777079.1169384535439
Content-Type: text/x-patch; name="fix_mv643xx_race.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="fix_mv643xx_race.patch"
X-Attachment-Id: f_ex7hciz1

LS0tIGxpbnV4LTIuNi4xOS5vcmlnL2RyaXZlcnMvbmV0L212NjQzeHhfZXRoLmMJMjAwNy0wMS0y
MSAxMzo1NjowNC40NTA2ODkxMjMgKzAxMDAKKysrIGxpbnV4LTIuNi4xOS9kcml2ZXJzL25ldC9t
djY0M3h4X2V0aC5jCTIwMDctMDEtMjEgMTM6Mzk6NTguMjI4NDA0NzYzICswMTAwCkBAIC0zMTIs
OCArMzEyLDggQEAKIAlpbnQgY291bnQ7CiAJaW50IHJlbGVhc2VkID0gMDsKIAorCXNwaW5fbG9j
a19pcnFzYXZlKCZtcC0+bG9jaywgZmxhZ3MpOwogCXdoaWxlIChtcC0+dHhfZGVzY19jb3VudCA+
IDApIHsKLQkJc3Bpbl9sb2NrX2lycXNhdmUoJm1wLT5sb2NrLCBmbGFncyk7CiAJCXR4X2luZGV4
ID0gbXAtPnR4X3VzZWRfZGVzY19xOwogCQlkZXNjID0gJm1wLT5wX3R4X2Rlc2NfYXJlYVt0eF9p
bmRleF07CiAJCWNtZF9zdHMgPSBkZXNjLT5jbWRfc3RzOwpAQCAtMzMyLDggKzMzMiw2IEBACiAJ
CWlmIChza2IpCiAJCQltcC0+dHhfc2tiW3R4X2luZGV4XSA9IE5VTEw7CiAKLQkJc3Bpbl91bmxv
Y2tfaXJxcmVzdG9yZSgmbXAtPmxvY2ssIGZsYWdzKTsKLQogCQlpZiAoY21kX3N0cyAmIEVUSF9F
UlJPUl9TVU1NQVJZKSB7CiAJCQlwcmludGsoIiVzOiBFcnJvciBpbiBUWFxuIiwgZGV2LT5uYW1l
KTsKIAkJCW1wLT5zdGF0cy50eF9lcnJvcnMrKzsKQEAgLTM0OSw2ICszNDcsNyBAQAogCiAJCXJl
bGVhc2VkID0gMTsKIAl9CisJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmbXAtPmxvY2ssIGZsYWdz
KTsKIAogCXJldHVybiByZWxlYXNlZDsKIH0K
------=_Part_170201_27777079.1169384535439--
