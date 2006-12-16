From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: [patch] scrub non-__GLIBC__ checks in linux/socket.h and linux/stat.h
Date: Sat, 16 Dec 2006 13:42:11 -0500
Message-ID: <8bd0f97a0612161042g3b61d42csd54cae46e4864f30@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_157207_25499960.1166294531766"
Cc: "Alexey Dobriyan" <adobriyan@gmail.com>,
	"Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:18525 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965487AbWLPSmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Dec 2006 13:42:14 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1137872uga
        for <netdev@vger.kernel.org>; Sat, 16 Dec 2006 10:42:12 -0800 (PST)
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_157207_25499960.1166294531766
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 11/30/06, Robert P. J. Day <rpjday@mindspring.com> wrote:
> but there are a few other
> cases which still contain compound preprocessor directives such as:
>
>   #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
>
> having never worked with unifdef before, i guess i was being overly
> optimistic in thinking that it, if i "unifdef"ed __KERNEL__, it might
> at least simplify the expression.  oh, well ... live and learn.

userspace should be worrying about userspace, so having the socket.h
and stat.h pollute the namespace in the non-glibc case is wrong and
pretty much prevents any other libc from utilizing these headers
sanely unless they set up the __GLIBC__ define themselves (which
sucks)
-mike

------=_Part_157207_25499960.1166294531766
Content-Type: application/octet-stream; name="linux-scrub-GLIBC-ifdefs.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="linux-scrub-GLIBC-ifdefs.patch"
X-Attachment-Id: f_evsdoreu

aW5kZXggOTJjZDM4ZS4uNTQ1YzA0MSAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9zb2NrZXQu
aAorKysgYi9pbmNsdWRlL2xpbnV4L3NvY2tldC5oCkBAIC0xNiw3ICsxNiw3IEBAIHN0cnVjdCBf
X2tlcm5lbF9zb2NrYWRkcl9zdG9yYWdlIHsKIAkJCQkvKiBfU1NfTUFYU0laRSB2YWx1ZSBtaW51
cyBzaXplIG9mIHNzX2ZhbWlseSAqLwogfSBfX2F0dHJpYnV0ZV9fICgoYWxpZ25lZChfS19TU19B
TElHTlNJWkUpKSk7CS8qIGZvcmNlIGRlc2lyZWQgYWxpZ25tZW50ICovCiAKLSNpZiBkZWZpbmVk
KF9fS0VSTkVMX18pIHx8ICFkZWZpbmVkKF9fR0xJQkNfXykgfHwgKF9fR0xJQkNfXyA8IDIpCisj
aWZkZWYgX19LRVJORUxfXwogCiAjaW5jbHVkZSA8YXNtL3NvY2tldC5oPgkJCS8qIGFyY2gtZGVw
ZW5kZW50IGRlZmluZXMJKi8KICNpbmNsdWRlIDxsaW51eC9zb2NraW9zLmg+CQkvKiB0aGUgU0lP
Q3h4eCBJL08gY29udHJvbHMJKi8KaW5kZXggNjc5ZWYwZC4uNTllNmJhMyAxMDA2NDQKLS0tIGEv
aW5jbHVkZS9saW51eC9zdGF0LmgKKysrIGIvaW5jbHVkZS9saW51eC9zdGF0LmgKQEAgLTcsNyAr
Nyw3IEBACiAKICNlbmRpZgogCi0jaWYgZGVmaW5lZChfX0tFUk5FTF9fKSB8fCAhZGVmaW5lZChf
X0dMSUJDX18pIHx8IChfX0dMSUJDX18gPCAyKQorI2lmZGVmIF9fS0VSTkVMX18KIAogI2RlZmlu
ZSBTX0lGTVQgIDAwMTcwMDAwCiAjZGVmaW5lIFNfSUZTT0NLIDAxNDAwMDAK
------=_Part_157207_25499960.1166294531766--
