From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [RFC 1/2] netfilter: xt_condition: export list management code
Date: Mon, 19 Jul 2010 22:14:36 +0300
Message-ID: <1279566876.11662.102.camel@powerslave>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
	 <1279548947-10470-2-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1007191807020.19191@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007191807020.19191@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-07-19 at 18:13 +0200, ext Jan Engelhardt wrote:
> On Monday 2010-07-19 16:15, Luciano Coelho wrote:
> 
> >From: Luciano Coelho <coelho@testbed>
> >
> >This patch isolates and exports the condition list management code, in
> >preparation for the CONDITION target to use it.  No functional change,
> >just reorganization of the code.
> 
> Well, I guess it would make more sense if the two extensions be in a 
> single file. That would alleviate the need for export reorganizations, 
> and also works because the module metadata overhead is large already.

Right.  I'll change the code so that the two extensions are in the same
file/module.  You're the second person to mention this already. ;)


> >@@ -3,12 +3,27 @@
> > 
> > #include <linux/types.h>
> > 
> >+#define XT_CONDITION_MAX_NAME_SIZE 30
> >+
> > struct xt_condition_mtinfo {
> >-	char name[31];
> >+	char name[XT_CONDITION_MAX_NAME_SIZE + 1];
> > 	__u8 invert;
> 
> Oh noes. Please please avoid any math operations inside []. It has 
> already driven XT_FUNCTION_MAXNAMELEN into nuts ("was it now +1 or -1, 
> or even -2 that we needed to pass for various functions?"). Just let MAX 
> be 31 and have name[MAX].

Yeah, I had already done as you suggested in my previous module
(IDLETIMER), I don't know what I had in my head today when I did it
differently.  Even the name of the macro is totally wrong (_SIZE), it
would make a tiny little bit more sense if it was _LEN.  I'll change it.


> > MODULE_ALIAS("ip6t_condition");
> > 
> >-struct condition_variable {
> >-	struct list_head list;
> >-	struct proc_dir_entry *status_proc;
> >-	unsigned int refcount;
> >-	bool enabled;
> >-};
> 
> Given your excellent usage example of a CONDITION target, I think it 
> even makes sense to enlarge the "enabled" variable to a full-fledged 
> 32-bit value that can be &, | and ^'d, similar to nfmark.

Ok, that's a good idea, I'll do that.

Thanks for your comments!


-- 
Cheers,
Luca.

