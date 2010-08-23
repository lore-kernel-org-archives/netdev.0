From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Mon, 23 Aug 2010 21:45:01 +0300
Message-ID: <1282589101.7198.28.camel@powerslave>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
	 <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
	 <1282570935.7198.5.camel@powerslave>
	 <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:57549 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753591Ab0HWSpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 14:45:17 -0400
In-Reply-To: <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 16:34 +0200, ext Jan Engelhardt wrote:
> On Monday 2010-08-23 15:42, Luciano Coelho wrote:
> >> >  /* Defaults, these can be overridden on the module command-line. */
> >> >  static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
> >> >  static unsigned int condition_uid_perms = 0;
> >> >  static unsigned int condition_gid_perms = 0;
> >> > +static unsigned int condition_capabilities = CAP_NET_ADMIN;
> >> >
> >> It is strange that we set security policy in this way. Maybe the
> >> permission of the proc file is enough in this case.
> >
> >Yes, that is another way to do it.  But in our device we use security
> >capabilities more extensively than normal file permissions.  That's why
> >we need this.
> >
> >If this is too restrictive (ie. having CAP_NET_ADMIN) for most users, we
> >could change the default value to no capabilities needed.  Then we can
> >set CAP_NET_ADMIN when loading the module.
> 
> But it looks as strange as the Yama code attempt.

What is so strange about it? Is it because it's possible to set the
capability requirement from modprobe arguments? The capability check
already exists in at least in nfnetlink, where it checks for received
messages for the CAP_NET_ADMIN capability.  Is it strange because we're
checking for the capability when someone tries to write to a file?


>  This is the one time 
> where I would personally be looking into SELinux, or perhaps SMACK if 
> the former is too complex, to whether _t'ing off procfs is possible.

Yeah, but it's not up to me to decide this.  We have one entire team
dedicated to figuring out how to ensure "security" in our device.  It
was that team who advised us to protect this file by checking for
CAP_NET_ADMIN.


-- 
Cheers,
Luca.

