From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: ip route del bug?
Date: Thu, 05 May 2005 15:15:24 -0400
Message-ID: <1115320524.8006.50.camel@localhost.localdomain>
References: <427A3370.3090001@skywaywest.com>
	 <20050505113557.7d21baf2@dxpl.pdx.osdl.net>  <427A6B77.1030200@trash.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-wgwMQDo2D6A5JlW9zFg0"
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427A6B77.1030200@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-wgwMQDo2D6A5JlW9zFg0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain

On Thu, 2005-05-05 at 20:52 +0200, Patrick McHardy wrote:
> Stephen Hemminger wrote:
> > It looks like an accidental behaviour (of the kernel) in response to
> > an ip route delete netlink message with no additional data.
> 
> I don't believe it is accidental, it seems correct to me to delete
> the default route when no more specific selector is given. To avoid
> this, iproute could print an error when dst.bytelen == 0.

Agreed - basically the kernel does what its told.  
I think the check should be on missing dst (default will always give you
bytelen of 0 for example and is legit).
Patchlet attached.

cheers,
jamal

--=-wgwMQDo2D6A5JlW9zFg0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=iprdl_p
Content-Type: text/plain; name=iprdl_p; charset=utf-8

--- a/ip/iproute.c	2005/05/05 18:56:30	1.1
+++ b/ip/iproute.c	2005/05/05 19:10:49
@@ -857,6 +857,11 @@
 		argc--; argv++;
 	}
 
+	if (!dst_ok) {
+		fprintf(stderr,"route must specify destination address \n");
+		return -1;
+	}
+
 	if (rtnl_open(&rth, 0) < 0)
 		exit(1);
 

--=-wgwMQDo2D6A5JlW9zFg0--
