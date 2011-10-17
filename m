From: Bin Li <libin.charles@gmail.com>
Subject: [PATCH] iproute2: Conforming to -D_FORTIFY_SOURCE=2 restrictions
Date: Mon, 17 Oct 2011 15:35:35 +0800
Message-ID: <CAGBH1r6P_nmVhSQ7d9sj1qU_1VY7QssWm3ftS4mNcQjyAuCcqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=90e6ba2121b9153c6804af79a706
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47503 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab1JQHfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 03:35:36 -0400
Received: by iaek3 with SMTP id k3so5802432iae.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 00:35:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--90e6ba2121b9153c6804af79a706
Content-Type: text/plain; charset=ISO-8859-1

Hi,

The issue is from below link.

https://bugzilla.novell.com/show_bug.cgi?id=719537

The issue is debug at below.

(gdb) bt
#0  0x00007ffff7697945 in raise (sig=<optimized out>)
    at ../nptl/sysdeps/unix/sysv/linux/raise.c:64
#1  0x00007ffff7698f21 in abort () at abort.c:92
#2  0x00007ffff76d48ef in __libc_message (do_abort=2,
    fmt=0x7ffff7789541 "*** %s ***: %s terminated\n")
    at ../sysdeps/unix/sysv/linux/libc_fatal.c:186
#3  0x00007ffff7750177 in __fortify_fail (
    msg=0x7ffff77894d8 "buffer overflow detected") at fortify_fail.c:32
#4  0x00007ffff774de10 in __chk_fail () at chk_fail.c:29
#5  0x00007ffff774cf8d in __strncpy_chk (
    s1=0x640c <Address 0x640c out of bounds>,
    s2=0x640c <Address 0x640c out of bounds>, n=6, s1len=18446744073709551615)
    at strncpy_chk.c:34
#6  0x000000000041e9c8 in strncpy (__len=<optimized out>,
    __src=<optimized out>, __dest=<optimized out>)
    at /usr/include/bits/string3.h:123
#7  xfrm_algo_parse (max=<optimized out>, buf=<optimized out>,
    key=<optimized out>, name=<optimized out>, type=<optimized out>,
    alg=<optimized out>) at xfrm_state.c:166

(gdb) l
161                     len = slen;
162                     if (len > 0) {
163                             if (len > max)
164                                     invarg("\"ALGOKEY\" makes buffer
overflow\n", key);
165
166                             strncpy(buf, key, len);
167                     }
168             }
169
170             alg->alg_key_len = len * 8;
(gdb) up
#8  xfrm_state_modify (cmd=<optimized out>, flags=<optimized out>, argc=1,
    argv=0x7fffffffe370) at xfrm_state.c:406
406                                     xfrm_algo_parse((void *)&alg, type,
name, key,

the compiler passes zero to __builtin___strncpy_chk as the buffer size.
xfrm_algo_parse is inlined into xfrm_state_modify.


Thanks!

Sincerely Yours,

Bin Li

http://zh.opensuse.org

--90e6ba2121b9153c6804af79a706
Content-Type: text/x-patch; charset=US-ASCII; name="iproute2-FORTIFY_SOURCE.patch"
Content-Disposition: attachment; filename="iproute2-FORTIFY_SOURCE.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gtv5c5e90

ZGlmZiAtLWdpdCBhL2lwL3hmcm1fc3RhdGUuYyBiL2lwL3hmcm1fc3RhdGUuYwppbmRleCBhNzZi
ZTQ3Li4zMGE5YWEzIDEwMDY0NAotLS0gYS9pcC94ZnJtX3N0YXRlLmMKKysrIGIvaXAveGZybV9z
dGF0ZS5jCkBAIC0zNjgsMTMgKzM2OCwxNiBAQCBzdGF0aWMgaW50IHhmcm1fc3RhdGVfbW9kaWZ5
KGludCBjbWQsIHVuc2lnbmVkIGZsYWdzLCBpbnQgYXJnYywgY2hhciAqKmFyZ3YpCiAJCQkJCQlz
dHJ1Y3QgeGZybV9hbGdvX2F1dGggYXV0aDsKIAkJCQkJfSB1OwogCQkJCQljaGFyIGJ1ZltYRlJN
X0FMR09fS0VZX0JVRl9TSVpFXTsKLQkJCQl9IGFsZyA9IHt9OworCQkJCX0gKmFsZzsKIAkJCQlp
bnQgbGVuOwogCQkJCV9fdTMyIGljdmxlbiwgdHJ1bmNsZW47CiAJCQkJY2hhciAqbmFtZTsKIAkJ
CQljaGFyICprZXk7CiAJCQkJY2hhciAqYnVmOwogCisJCQkJYWxnID0gYWxsb2NhIChzaXplb2Yg
KCphbGcpICsgWEZSTV9BTEdPX0tFWV9CVUZfU0laRSk7CisJCQkJbWVtc2V0IChhbGcsIDAsIHNp
emVvZiAoKmFsZykgKyBYRlJNX0FMR09fS0VZX0JVRl9TSVpFKTsKKwogCQkJCXN3aXRjaCAodHlw
ZSkgewogCQkJCWNhc2UgWEZSTUFfQUxHX0FFQUQ6CiAJCQkJCWlmIChhZWFkb3ApCkBAIC00MTIs
OCArNDE1LDggQEAgc3RhdGljIGludCB4ZnJtX3N0YXRlX21vZGlmeShpbnQgY21kLCB1bnNpZ25l
ZCBmbGFncywgaW50IGFyZ2MsIGNoYXIgKiphcmd2KQogCQkJCU5FWFRfQVJHKCk7CiAJCQkJa2V5
ID0gKmFyZ3Y7CiAKLQkJCQlidWYgPSBhbGcudS5hbGcuYWxnX2tleTsKLQkJCQlsZW4gPSBzaXpl
b2YoYWxnLnUuYWxnKTsKKwkJCQlidWYgPSBhbGctPnUuYWxnLmFsZ19rZXk7CisJCQkJbGVuID0g
c2l6ZW9mKGFsZy0+dS5hbGcpOwogCiAJCQkJc3dpdGNoICh0eXBlKSB7CiAJCQkJY2FzZSBYRlJN
QV9BTEdfQUVBRDoKQEAgLTQyMywxMCArNDI2LDEwIEBAIHN0YXRpYyBpbnQgeGZybV9zdGF0ZV9t
b2RpZnkoaW50IGNtZCwgdW5zaWduZWQgZmxhZ3MsIGludCBhcmdjLCBjaGFyICoqYXJndikKIAkJ
CQkJaWYgKGdldF91MzIoJmljdmxlbiwgKmFyZ3YsIDApKQogCQkJCQkJaW52YXJnKCJcImFlYWRc
IiBJQ1YgbGVuZ3RoIGlzIGludmFsaWQiLAogCQkJCQkJICAgICAgICphcmd2KTsKLQkJCQkJYWxn
LnUuYWVhZC5hbGdfaWN2X2xlbiA9IGljdmxlbjsKKwkJCQkJYWxnLT51LmFlYWQuYWxnX2ljdl9s
ZW4gPSBpY3ZsZW47CiAKLQkJCQkJYnVmID0gYWxnLnUuYWVhZC5hbGdfa2V5OwotCQkJCQlsZW4g
PSBzaXplb2YoYWxnLnUuYWVhZCk7CisJCQkJCWJ1ZiA9IGFsZy0+dS5hZWFkLmFsZ19rZXk7CisJ
CQkJCWxlbiA9IHNpemVvZihhbGctPnUuYWVhZCk7CiAJCQkJCWJyZWFrOwogCQkJCWNhc2UgWEZS
TUFfQUxHX0FVVEhfVFJVTkM6CiAJCQkJCWlmICghTkVYVF9BUkdfT0soKSkKQEAgLTQzNSwxOSAr
NDM4LDE5IEBAIHN0YXRpYyBpbnQgeGZybV9zdGF0ZV9tb2RpZnkoaW50IGNtZCwgdW5zaWduZWQg
ZmxhZ3MsIGludCBhcmdjLCBjaGFyICoqYXJndikKIAkJCQkJaWYgKGdldF91MzIoJnRydW5jbGVu
LCAqYXJndiwgMCkpCiAJCQkJCQlpbnZhcmcoIlwiYXV0aFwiIHRydW5jIGxlbmd0aCBpcyBpbnZh
bGlkIiwKIAkJCQkJCSAgICAgICAqYXJndik7Ci0JCQkJCWFsZy51LmF1dGguYWxnX3RydW5jX2xl
biA9IHRydW5jbGVuOworCQkJCQlhbGctPnUuYXV0aC5hbGdfdHJ1bmNfbGVuID0gdHJ1bmNsZW47
CiAKLQkJCQkJYnVmID0gYWxnLnUuYXV0aC5hbGdfa2V5OwotCQkJCQlsZW4gPSBzaXplb2YoYWxn
LnUuYXV0aCk7CisJCQkJCWJ1ZiA9IGFsZy0+dS5hdXRoLmFsZ19rZXk7CisJCQkJCWxlbiA9IHNp
emVvZihhbGctPnUuYXV0aCk7CiAJCQkJCWJyZWFrOwogCQkJCX0KIAotCQkJCXhmcm1fYWxnb19w
YXJzZSgodm9pZCAqKSZhbGcsIHR5cGUsIG5hbWUsIGtleSwKLQkJCQkJCWJ1Ziwgc2l6ZW9mKGFs
Zy5idWYpKTsKLQkJCQlsZW4gKz0gYWxnLnUuYWxnLmFsZ19rZXlfbGVuOworCQkJCXhmcm1fYWxn
b19wYXJzZSgodm9pZCAqKWFsZywgdHlwZSwgbmFtZSwga2V5LAorCQkJCQkJYnVmLCBzaXplb2Yo
YWxnLT5idWYpKTsKKwkJCQlsZW4gKz0gYWxnLT51LmFsZy5hbGdfa2V5X2xlbjsKIAogCQkJCWFk
ZGF0dHJfbCgmcmVxLm4sIHNpemVvZihyZXEuYnVmKSwgdHlwZSwKLQkJCQkJICAodm9pZCAqKSZh
bGcsIGxlbik7CisJCQkJCSAgKHZvaWQgKilhbGcsIGxlbik7CiAJCQkJYnJlYWs7CiAJCQl9CiAJ
CQlkZWZhdWx0Ogo=
--90e6ba2121b9153c6804af79a706--
