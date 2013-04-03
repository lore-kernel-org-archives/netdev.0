From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [Suggestion] ISDN: isdnloop:  C grammar issue,  '}' miss match
 'if' and 'switch' statement.
Date: Wed, 3 Apr 2013 16:08:24 +0200
Message-ID: <20130403140823.GB3401@unicorn.suse.cz>
References: <515C303B.1040304@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fengguang.wu@intel.com, isdn@linux-pingi.de,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44474 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850Ab3DCOI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 10:08:26 -0400
Content-Disposition: inline
In-Reply-To: <515C303B.1040304@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 09:35:55PM +0800, Chen Gang wrote:
> 
> in drivers/isdn/isdnloop/isdnloop.c
> 
>   issue description:
>     it is in function 'isdnloop_command'.
>     it seems a C grammar issue for '}' miss match 'if' and 'switch' statement
>     please check the line 1243, 1265, 1341.
> 
>   building:
>     make allyesconfig, can not let it built.
>     in menuconfig, we (at least for me) can not let ISDN_DRV_LOOP = 'y' or 'm'.
>     is this module a waste module which should be deleted ?
> 
>   the related commit:
>     commit 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2
>     Author: Linus Torvalds <torvalds@ppc970.osdl.org>
>     Date:   Sat Apr 16 15:20:36 2005 -0700

As far as I can see, this rather comes from

commit 475be4d85a274d0961593db41cf85689db1d583c
Author: Joe Perches <joe@perches.com>
Date:   Sun Feb 19 19:52:38 2012 -0800

    isdn: whitespace coding style cleanup

> 1240         case ISDN_CMD_ACCEPTB:
> 1241                 if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
> 1242                         return -ENODEV;
> 1243                 if (c->arg < ISDNLOOP_BCH) {
> 1244                         a = c->arg + 1;
> 1245                         switch (card->l2_proto[a - 1]) {
> 1246                         case ISDN_PROTO_L2_X75I:
> 1247                                 sprintf(cbuf, "%02d;BCON_R,BX75\n", (int) a);
> 1248                                 break;
> 1249 #ifdef CONFIG_ISDN_X25
> 1250                         case ISDN_PROTO_L2_X25DTE:
> 1251                                 sprintf(cbuf, "%02d;BCON_R,BX2T\n", (int) a);
> 1252                                 break;
> 1253                         case ISDN_PROTO_L2_X25DCE:
> 1254                                 sprintf(cbuf, "%02d;BCON_R,BX2C\n", (int) a);
> 1255                                 break;
> 1256 #endif
> 1257                         case ISDN_PROTO_L2_HDLC:
> 1258                                 sprintf(cbuf, "%02d;BCON_R,BTRA\n", (int) a);
> 1259                                 break;
> 1260                         default:
> 1261                                 sprintf(cbuf, "%02d;BCON_R\n", (int) a);
> 1262                         }
> 1263                         printk(KERN_DEBUG "isdnloop writecmd '%s'\n", cbuf);
> 1264                         i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
> 1265                         break;
> 1266                 case ISDN_CMD_HANGUP:

Michal Kubecek
