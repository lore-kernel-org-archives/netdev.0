From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bugme-new] [Bug 4381] New: When i try to start a pppoe conn.,
 crash at net/core/skbuff.c:91
Date: Wed, 23 Mar 2005 03:20:22 +0100
Message-ID: <4240D266.4080403@trash.net>
References: <20050321201150.39ba3467.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070500070604000205000301"
Cc: netdev@oss.sgi.com, o.cornu@gmail.com, paulus@samba.org
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050321201150.39ba3467.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070500070604000205000301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andrew Morton wrote:
> Repeatable pppoe crash :(
> 
> 
> Begin forwarded message:
> 
> http://bugme.osdl.org/show_bug.cgi?id=4381
> 
>            Summary: When i try to start a pppoe conn., crash at
>                     net/core/skbuff.c:91
>     Kernel Version: 2.6.11 (gentoo-dev-sources)
>             Status: NEW
>           Severity: blocking
>              Owner: shemminger@osdl.org
>          Submitter: o.cornu@gmail.com
> 
> Mar 21 21:28:05 Pai-mei <6>skput:over: f89b2335:16 put:16
> dev:<NULL>

Looks like hdrlen is uninitialized in ppp_async. This patch
initializes it to 2 like in ppp_synctty, but I'm not sure
whether this value is correct here. Paul?

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------070500070604000205000301
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== drivers/net/ppp_async.c 1.26 vs edited =====
--- 1.26/drivers/net/ppp_async.c	2005-01-21 06:02:12 +01:00
+++ edited/drivers/net/ppp_async.c	2005-03-23 03:15:31 +01:00
@@ -183,6 +183,7 @@
 	ap->chan.private = ap;
 	ap->chan.ops = &async_ops;
 	ap->chan.mtu = PPP_MRU;
+	ap->chan.hdrlen = 2;
 	err = ppp_register_channel(&ap->chan);
 	if (err)
 		goto out_free;

--------------070500070604000205000301--
