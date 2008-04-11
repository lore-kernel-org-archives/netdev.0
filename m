From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: [PATCH] [mcast-tools] Changing the type of pim_cksum.
Date: Fri, 11 Apr 2008 12:14:37 +0300
Message-ID: <147a89290804110214nb1cc55fp4645ce1f913d74d6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_6285_31861950.1207905277589"
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:50224 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758545AbYDKJOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 05:14:47 -0400
Received: by fg-out-1718.google.com with SMTP id l27so334437fgb.17
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 02:14:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_6285_31861950.1207905277589
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

>In glibc-2.3.x both defines were provided, but after that the old
>ICMP6_* defines were completely removed.

>Probably Yoshifuji-san tests the user tool builds on a glibc-2.3.x or
>earlier system, which has the old deprecated defines.


I could get access today (at last...) to a machine running glibc-2.3.4-2.13.
I had done the following:
git-clone git://git.linux-ipv6.org/gitroot/yoshfuji/mcast-tools.git

cd mcast-tools

aclocal; automake; autoconf
./configure
cd pim6sd
make


I got the following error:

In file included from debug.c:71:
../include/linux/pim.h:17: error: syntax error before "__be16"
../include/linux/pim.h:17: warning: no semicolon at end of struct or union
make[1]: *** [debug.o] Error 1
make[1]: Leaving directory ...
make: *** [all-recursive] Error 1

As far as I understand, the __be16 is good for kernel headers, but not
for user space headers. I am not sure about it. However, in case I am
right, I changed it to  "uint16_t pim_cksum" instead of  "__be16  pim_cksum"
in /include/linux/pim.h;
and then "make" finsihed ok.
And attached here is the patch. What do you think ?


Regards,
AJ



Signed-off-by: Andy Johnson <johnsonzjo@gmail.com>



On Tue, Apr 8, 2008 at 12:14 PM, David Miller <davem@davemloft.net> wrote:
> From: "Andy Johnson" <johnsonzjo@gmail.com>
>  Date: Tue, 8 Apr 2008 09:57:39 +0300
>
>
>  > mld6.c: In function 'init_mld6':
>  > mld6.c:210: error: 'ICMP6_MEMBERSHIP_QUERY' undeclared (first use in
>  > this function)
>  > mld6.c:210: error: (Each undeclared identifier is reported only once
>  > mld6.c:210: error: for each function it appears in.)
>  > mld6.c:211: error: 'ICMP6_MEMBERSHIP_REPORT' undeclared (first use in
>  > this function)
>  > mld6.c:212: error: 'ICMP6_MEMBERSHIP_REDUCTION' undeclared (first use
>  > in this function)
>  > mld6.c: In function 'accept_mld6':
>  > mld6.c:451: error: 'MLD_LISTENER_DONE' undeclared (first use in this function)
>
>  Somewhere along the line ICMP6_MEMBERSHIP_* got changed
>  into MLD_LISTENER_* in the glibc headers.
>
>  Similarly MLD_LISTENER_DONE should be MLD_LISTENER_REDUCTION.
>
>  In glibc-2.3.x both defines were provided, but after that the old
>  ICMP6_* defines were completely removed.
>
>  Probably Yoshifuji-san tests the user tool builds on a glibc-2.3.x or
>  earlier system, which has the old deprecated defines.
>
>  So if you simply change:
>
>         ICMP6_MEMBERSHIP_* --> MLD_LISTENER_*
>
>  and also:
>
>         MLD_LISTENER_DONE --> MLD_LISTENER_REDUCTION
>
>  the build will complete successfully.
>

------=_Part_6285_31861950.1207905277589
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fewjl6gx0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvcGltLmggYi9pbmNsdWRlL2xpbnV4L3BpbS5oCmlu
ZGV4IGY5ZDNmYTAuLjQxM2IyZGEgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvcGltLmgKKysr
IGIvaW5jbHVkZS9saW51eC9waW0uaApAQCAtMTQsNyArMTQsNyBAQCBzdHJ1Y3QgcGltIHsKIAkJ
cGltX3R5cGU6NDsJCS8qIFBJTSBtZXNzYWdlIHR5cGUgKi8KICNlbmRpZgogCV9fdTgJcGltX3Jz
djsJCS8qIFJlc2VydmVkICovCi0JX19iZTE2CXBpbV9ja3N1bTsJCS8qIENoZWNrc3VtICovCisJ
dWludDE2X3QgcGltX2Nrc3VtOwkJLyogQ2hlY2tzdW0gKi8KIH07CiAKICNkZWZpbmUgUElNX01J
TkxFTgkJOAo=
------=_Part_6285_31861950.1207905277589--
