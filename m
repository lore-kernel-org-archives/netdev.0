From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] trivial patch for if_indextoname()
Date: Wed, 26 May 2004 16:15:07 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFD3BD5C6F.D104319A-ON88256EA0.00798187-88256EA0.007A2D7C@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 007A2D6F88256EA0_="
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_mixed 007A2D6F88256EA0_=
Content-Type: text/plain; charset="US-ASCII"

RFC3493 (section 4.2) specifies that an invalid interface name
passed to if_indextoname() should return NULL with errno of ENXIO.
The current code sets errno to ENODEV for this case.

This could be remapped in glibc, but since the comment for
kernel function dev_ifname() says it's specifically for
if_indextoname(), maybe it should be fixed here.

                                        +-DLS

--- net/core/dev.c.orig 2004-05-09 19:32:37.000000000 -0700
+++ net/core/dev.c      2004-05-26 14:54:37.378210416 -0700
@@ -1927,7 +1927,7 @@
        dev = __dev_get_by_index(ifr.ifr_ifindex);
        if (!dev) {
                read_unlock(&dev_base_lock);
-               return -ENODEV;
+               return -ENXIO;
        }
 
        strcpy(ifr.ifr_name, dev->name);


--=_mixed 007A2D6F88256EA0_=
Content-Type: application/octet-stream; name="if_indextoname.patch"
Content-Disposition: attachment; filename="if_indextoname.patch"
Content-Transfer-Encoding: base64

LS0tIG5ldC9jb3JlL2Rldi5jLm9yaWcJMjAwNC0wNS0wOSAxOTozMjozNy4wMDAwMDAwMDAgLTA3
MDAKKysrIG5ldC9jb3JlL2Rldi5jCTIwMDQtMDUtMjYgMTQ6NTQ6MzcuMzc4MjEwNDE2IC0wNzAw
CkBAIC0xOTI3LDcgKzE5MjcsNyBAQAogCWRldiA9IF9fZGV2X2dldF9ieV9pbmRleChpZnIuaWZy
X2lmaW5kZXgpOwogCWlmICghZGV2KSB7CiAJCXJlYWRfdW5sb2NrKCZkZXZfYmFzZV9sb2NrKTsK
LQkJcmV0dXJuIC1FTk9ERVY7CisJCXJldHVybiAtRU5YSU87CiAJfQogCiAJc3RyY3B5KGlmci5p
ZnJfbmFtZSwgZGV2LT5uYW1lKTsK
--=_mixed 007A2D6F88256EA0_=--
