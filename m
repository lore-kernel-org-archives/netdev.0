From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH] netfilter: xt_condition: add security capability
 support
Date: Mon, 23 Aug 2010 16:42:15 +0300
Message-ID: <1282570935.7198.5.camel@powerslave>
References: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
	 <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "kaber@trash.net" <kaber@trash.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>
To: ext Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=2H+ytOQU9nC_dRp_GB5Sy1831VY14oW=YSOrG@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-23 at 15:37 +0200, ext Changli Gao wrote:
> On Mon, Aug 23, 2010 at 8:50 PM,  <luciano.coelho@nokia.com> wrote:
> > From: Luciano Coelho <luciano.coelho@nokia.com>
> >
> > Add a module parameter that allows the required security capability to
> > change the conditions from userspace to be specified.  By default the
> > module will require the CAP_NET_ADMIN capability.
> >
> > Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
> > ---
> >  net/netfilter/xt_condition.c |   10 ++++++++++
> >  1 files changed, 10 insertions(+), 0 deletions(-)
> >
> > diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
> > index 06205aa..fd279e5 100644
> > --- a/net/netfilter/xt_condition.c
> > +++ b/net/netfilter/xt_condition.c
> > @@ -29,11 +29,13 @@
> >  #include <linux/netfilter/xt_condition.h>
> >  #include <net/netns/generic.h>
> >  #include <asm/uaccess.h>
> > +#include <linux/capability.h>
> >
> >  /* Defaults, these can be overridden on the module command-line. */
> >  static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
> >  static unsigned int condition_uid_perms = 0;
> >  static unsigned int condition_gid_perms = 0;
> > +static unsigned int condition_capabilities = CAP_NET_ADMIN;
> >
> >  MODULE_AUTHOR("Stephane Ouellette <ouellettes@videotron.ca>");
> >  MODULE_AUTHOR("Massimiliano Hofer <max@nucleus.it>");
> > @@ -47,6 +49,8 @@ module_param(condition_uid_perms, uint, S_IRUSR | S_IWUSR);
> >  MODULE_PARM_DESC(condition_uid_perms, "default user owner of /proc/net/nf_condition/* files");
> >  module_param(condition_gid_perms, uint, S_IRUSR | S_IWUSR);
> >  MODULE_PARM_DESC(condition_gid_perms, "default group owner of /proc/net/nf_condition/* files");
> > +module_param(condition_capabilities, uint, CAP_NET_ADMIN);
> > +MODULE_PARM_DESC(condition_capabilities, "default capabilities required to change /proc/net/nf_condition/* files");
> 
> It is strange that we set security policy in this way. Maybe the
> permission of the proc file is enough in this case.

Yes, that is another way to do it.  But in our device we use security
capabilities more extensively than normal file permissions.  That's why
we need this.

If this is too restrictive (ie. having CAP_NET_ADMIN) for most users, we
could change the default value to no capabilities needed.  Then we can
set CAP_NET_ADMIN when loading the module.


-- 
Cheers,
Luca.

