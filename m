From: emann@mrv.com (Eran Mann)
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Mon, 07 Mar 2005 10:05:36 +0200
Message-ID: <422C0B50.20500@mrv.com>
References: <m1y8d0mss2.fsf@muc.de>	<E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>	<E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>	<E1D7lQN-0002gz-00@smtp06.mrf.mail.rcn.net>	<E1D7zBN-0004hX-00@smtp02.mrf.mail.rcn.net>	<20050306173145.GQ31837@postel.suug.ch>	<E1D81mg-0002rz-00@smtp01.mrf.mail.rcn.net> <m1y8d0mss2.fsf@muc.de> <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040802000603020000010405"
Cc: Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        Martin Mares <mj@ucw.cz>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <3sp35g$7hpm0@smtp04.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040802000603020000010405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Zdenek Radouch wrote:
...
> 
> 2) If it does require kernel hacking, would you like to do it for me?
>     (as I had said, as a contract)
I think what Andi Kleen was talking about below is something like the 
attached 5 minutes patch (applies cleanly to 2.4.2x kernels I have at 
hand, and to 2.6.11 with minor offset). Please donate the 5 minute wages 
to the OSDL or the FSF at your choice ;-)
...
> 
> Not accepting packets with with a loopback address is one
> thing, not accepting any 127.0.0.0/8 packets is entirely something else.

Yes, however it seems to be required by the RFC (quoting RFC 3330 
"special use IPv4 addresses") :

"  127.0.0.0/8 - This block is assigned for use as the Internet host
    loopback address.  A datagram sent by a higher level protocol to an
    address anywhere within this block should loop back inside the host.
    This is ordinarily implemented using only 127.0.0.1/32 for loopback,
    but no addresses within this block should ever appear on any network
    anywhere [RFC1700, page 5]. "

>>* Andi Kleen <m1y8d0mss2.fsf@muc.de> 2005-03-06 21:19
>>
...
>>>
>>>It is. 127.* is hardcoded in the routing engine and e.g.
>>>it won't accept outside packets with a loopback address.
>>>
>>>Most likely it's enough to change the "LOOPBACK" macro to allow
>>>parts of the Class A to be used for other purposes.
...
-- 
Eran Mann
MRV International

--------------040802000603020000010405
Content-Type: text/x-patch;
 name="lo_hack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lo_hack.patch"

--- 2.4.27/include/linux/in.h	2004-05-28 17:15:37.000000000 +0300
+++ 2.4.27.hacked/include/linux/in.h	2005-03-07 09:53:02.000000000 +0200
@@ -226,7 +226,7 @@
 
 /* Address to loopback in software to local host.  */
 #define	INADDR_LOOPBACK		0x7f000001	/* 127.0.0.1   */
-#define	IN_LOOPBACK(a)		((((long int) (a)) & 0xff000000) == 0x7f000000)
+#define	IN_LOOPBACK(a)		((((long int) (a)) & 0xffff0000) == 0x7f000000)
 
 /* Defines for Multicast INADDR */
 #define INADDR_UNSPEC_GROUP   	0xe0000000U	/* 224.0.0.0   */
@@ -240,7 +240,7 @@
 
 #ifdef __KERNEL__
 /* Some random defines to make it easier in the kernel.. */
-#define LOOPBACK(x)	(((x) & htonl(0xff000000)) == htonl(0x7f000000))
+#define LOOPBACK(x)	(((x) & htonl(0xffff0000)) == htonl(0x7f000000))
 #define MULTICAST(x)	(((x) & htonl(0xf0000000)) == htonl(0xe0000000))
 #define BADCLASS(x)	(((x) & htonl(0xf0000000)) == htonl(0xf0000000))
 #define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))

--------------040802000603020000010405--
