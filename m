From: jamal <hadi@cyberus.ca>
Subject: Re: sch_dsmark bug
Date: 11 Apr 2004 15:43:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1081712583.1044.375.camel@jzny.localdomain>
References: <40793D5A.9060706@innerghost.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-W0I2djxKtMlUoVZlYoDp"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hugo Santos <hugo@innerghost.net>
In-Reply-To: <40793D5A.9060706@innerghost.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-W0I2djxKtMlUoVZlYoDp
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Looks legit nit. Why are you sending empty opts anyways? ;->
patchlet attached - you should have sent one ;->
Maybe you can inspect other qdiscs.

cheers,
jamal

On Sun, 2004-04-11 at 08:43, Hugo Santos wrote:
> Hi there,
> 
> I tried to contact the person whose name is in the source file but with
> no success. While developing some code that handles with kernel's TC
> objects direcly (by netlink) i found a small problem with dsmark (maybe
> other scheds have it too, but i haven't checked). This is in linux 2.6.4
> (there is no change in this context in 2.6.5); in dsmark_init, if opt is
> NULL, the module will crash and TC will get stuck. the module will have a
> ref count of 1 so i can't unload it, and i can't change any other TC
> stuff since the netlink socket gets stuck when dsmark crashes. So, a simple
> 
> if (!opt) return -EINVAL;
> 
> would prevent such problems.
> 
> If you prefer i may send a patch, but since it's only a one line patch i didn't
> send one.
> 
> Best regards,
> Hugo Santos
> 
> 
> 
> 
> 

--=-W0I2djxKtMlUoVZlYoDp
Content-Disposition: attachment; filename=p1
Content-Type: text/plain; name=p1; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- sch_dsmark.c	2004/04/11 19:39:16	1.1
+++ sch_dsmark.c	2004/04/11 19:39:41
@@ -321,6 +321,7 @@
 	struct rtattr *tb[TCA_DSMARK_MAX];
 	__u16 tmp;
 
+	if (!opt) return -EINVAL;
 	DPRINTK("dsmark_init(sch %p,[qdisc %p],opt %p)\n",sch,p,opt);
 	if (rtattr_parse(tb,TCA_DSMARK_MAX,RTA_DATA(opt),RTA_PAYLOAD(opt)) < 0 ||
 	    !tb[TCA_DSMARK_INDICES-1] ||

--=-W0I2djxKtMlUoVZlYoDp--
