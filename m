From: "Dr. Peter Bieringer" <pb@bieringer.de>
Subject: (usagi-users 02409) 2.5.70-bk9: no IPsec modules are autoloaded
Date: Thu, 05 Jun 2003 13:21:40 +0200
Message-ID: <29980000.1054812100@klopffest.muc.aerasec.de>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: usagi-users@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: Maillist netdev <netdev@oss.sgi.com>
Content-Disposition: inline
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi again,

now playing around with 2.5.70-bk9...which still not solves the 
interoperability problem with FreeS/WAN. Are they talking different ESP?



Sure known that autoloading of IPsec modules is broken...is this a bug or 
by design?

The error messages of racoon are not very useful:


2003-06-05 11:34:34: INFO: main.c:174:main(): @(#)racoon 20001216 20001216 
sakane@kame.net
2003-06-05 11:34:34: INFO: main.c:175:main(): @(#)This product linked 
OpenSSL 0.9.6b [engine] 9 Jul 2001 (http://www.openssl.org/)
racoon: something error happened while pfkey initializing.
2003-06-05 11:34:34: ERROR: pfkey.c:364:pfkey_init(): libipsec failed pfkey 
open (Address family not supported by protocol)

-> missing module "af_key"


2003-06-05 11:42:07: INFO: isakmp.c:1048:isakmp_ph2begin_r(): respond new 
phase 2 negotiation: 10.3.62.31[0]<=>10.3.62.35[0]
2003-06-05 11:42:08: ERROR: pfkey.c:209:pfkey_handler(): pfkey UPDATE 
failed: No buffer space available
2003-06-05 11:42:08: ERROR: pfkey.c:209:pfkey_handler(): pfkey ADD failed: 
No buffer space available
2003-06-05 11:42:22: ERROR: pfkey.c:740:pfkey_timeover(): *remote* give up 
to get IPsec-SA due to time up to wait.
2003-06-05 11:42:37: INFO: pfkey.c:1367:pk_recvexpire(): IPsec-SA expired: 
ESP/Transport *remote*->*local* spi=256398122(0xf48532a)
2003-06-05 11:43:07: INFO: isakmp.c:1520:isakmp_ph1expire(): ISAKMP-SA 
expired *local*[500]-*remote*[500] spi:3087159632fe32b6:88a45a3eabd327fd
2003-06-05 11:43:08: INFO: isakmp.c:1568:isakmp_ph1delete(): ISAKMP-SA 
deleted *remote*[500]-*local*[500] spi:3087159632fe32b6:88a45a3eabd327fd

-> missing module "ah" and "esp"

(not so funny, cost me about 15 min to find the solution for "No buffer 
space available" - "why it worked yesterday and not today")


None of the above ones are automagically loaded, while others (e.g. the 
encrytion ones) are.



BTW: is this normal? (host is IPv4 only at the moment):


2003-06-05 13:17:03: INFO: isakmp.c:1362:isakmp_open(): 127.0.0.1[500] used 
as isakmp port (fd=7)
2003-06-05 13:17:03: INFO: isakmp.c:1362:isakmp_open(): *ip1*[500] used as 
isakmp port (fd=8)
2003-06-05 13:17:03: INFO: isakmp.c:1362:isakmp_open(): *ip2*[500] used as 
isakmp port (fd=9)
2003-06-05 13:17:03: INFO: isakmp.c:1362:isakmp_open(): *ip3*[500] used as 
isakmp port (fd=10)
2003-06-05 13:17:03: ERROR: isakmp.c:1354:isakmp_open(): failed to bind 
(Address already in use).
2003-06-05 13:17:03: ERROR: isakmp.c:1354:isakmp_open(): failed to bind 
(Address already in use).
2003-06-05 13:17:03: ERROR: isakmp.c:1354:isakmp_open(): failed to bind 
(Address already in use).
2003-06-05 13:17:03: ERROR: isakmp.c:1354:isakmp_open(): failed to bind 
(Address already in use).


	Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
