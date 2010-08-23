From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Mon, 23 Aug 2010 16:34:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1008231628010.21000@obet.zrqbmnf.qr>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>  <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com> <1282570935.7198.5.camel@powerslave>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ext Changli Gao <xiaosuo@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1282570935.7198.5.camel@powerslave>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2010-08-23 15:42, Luciano Coelho wrote:
>> >  /* Defaults, these can be overridden on the module command-line. */
>> >  static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
>> >  static unsigned int condition_uid_perms = 0;
>> >  static unsigned int condition_gid_perms = 0;
>> > +static unsigned int condition_capabilities = CAP_NET_ADMIN;
>> >
>> It is strange that we set security policy in this way. Maybe the
>> permission of the proc file is enough in this case.
>
>Yes, that is another way to do it.  But in our device we use security
>capabilities more extensively than normal file permissions.  That's why
>we need this.
>
>If this is too restrictive (ie. having CAP_NET_ADMIN) for most users, we
>could change the default value to no capabilities needed.  Then we can
>set CAP_NET_ADMIN when loading the module.

But it looks as strange as the Yama code attempt. This is the one time 
where I would personally be looking into SELinux, or perhaps SMACK if 
the former is too complex, to whether _t'ing off procfs is possible.
