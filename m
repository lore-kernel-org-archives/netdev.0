From: Peter Bieringer <pb@bieringer.de>
Subject: ip6t_LOG.c: patch killing spaces on ouput of IPv4 address on
 TUNNEL=
Date: Sat, 05 Mar 2005 17:01:53 +0100
Message-ID: <DB755B5F6CF46771B8607810@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="==========FB26CE9DD55CAE312C21=========="
To: Maillist netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==========FB26CE9DD55CAE312C21==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

I'm still wondering that this was never fixed since 3 years:

--- linux-2.6.11/net/ipv6/netfilter/ip6t_LOG.c.orig     2005-03-05
16:39:41.390675372 +0100
+++ linux-2.6.11/net/ipv6/netfilter/ip6t_LOG.c  2005-03-05
16:56:53.975208199 +0100
@@ -404,10 +404,10 @@
                            printk("TUNNEL=");
                            p = skb->mac.raw + 12;
                            for (i = 0; i < 4; i++,p++)
-                               printk("%3d%s", *p,
+                               printk("%d%s", *p,
                                        i == 3 ? "->" : ".");
                            for (i = 0; i < 4; i++,p++)
-                               printk("%3d%c", *p,
+                               printk("%d%c", *p,
                                        i == 3 ? ' ' : '.');
                          }
                        }

This will fix the really not nice output like shown below and avoid simple
parsers for becoming in trouble:

Mar  5 16:47:31 host kernel: FW6-default-DROP-extIN:
IN=sit1
OUT= 
MAC=01:23:45:67:89:ab->01:23:45:47:89:ac
TUNNEL=123.123.  0.123-> 12.123.  6.123
       ^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^
SRC=fe80:0000:0000:0000:0000:0000:0123:4567
DST=ff3e:0012:3456:789a:0000:0000:0000:1234
LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=131 CODE=0


I've nowhere else in netfilter log lines such empty space in IPv4 addresses

See also:
<https://lists.netfilter.org/pipermail/netfilter-devel/2002-April/007366.html>
Here, at least trailing "0" were printed.

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
--==========FB26CE9DD55CAE312C21==========
Content-Type: application/octet-stream; name="ip6t_LOG.c.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="ip6t_LOG.c.diff"; size=490

LS0tIGxpbnV4LTIuNi4xMS9uZXQvaXB2Ni9uZXRmaWx0ZXIvaXA2dF9MT0cuYy5vcmlnCTIwMDUt
MDMtMDUgMTY6Mzk6NDEuMzkwNjc1MzcyICswMTAwCisrKyBsaW51eC0yLjYuMTEvbmV0L2lwdjYv
bmV0ZmlsdGVyL2lwNnRfTE9HLmMJMjAwNS0wMy0wNSAxNjo1Njo1My45NzUyMDgxOTkgKzAxMDAK
QEAgLTQwNCwxMCArNDA0LDEwIEBACiAJCQkgICAgcHJpbnRrKCJUVU5ORUw9Iik7CiAJCQkgICAg
cCA9IHNrYi0+bWFjLnJhdyArIDEyOwogCQkJICAgIGZvciAoaSA9IDA7IGkgPCA0OyBpKysscCsr
KQotCQkJCXByaW50aygiJTNkJXMiLCAqcCwKKwkJCQlwcmludGsoIiVkJXMiLCAqcCwKIAkJCQkJ
aSA9PSAzID8gIi0+IiA6ICIuIik7CiAJCQkgICAgZm9yIChpID0gMDsgaSA8IDQ7IGkrKyxwKysp
Ci0JCQkJcHJpbnRrKCIlM2QlYyIsICpwLAorCQkJCXByaW50aygiJWQlYyIsICpwLAogCQkJCQlp
ID09IDMgPyAnICcgOiAnLicpOwogCQkJICB9CiAJCQl9Cg==

--==========FB26CE9DD55CAE312C21==========--
