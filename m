From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Fri, 28 Jan 2005 11:29:29 +1100
Message-ID: <1106872169.18360.6.camel@localhost.localdomain>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	 <p73zn0ccaee.fsf@verdi.suse.de>
	 <1105117559.11753.34.camel@baythorne.infradead.org>
	 <20050107100017.454ddadc@dxpl.pdx.osdl.net>
	 <1105133241.3375.16.camel@localhost.localdomain>
	 <20050118135735.4b77d38d.davem@davemloft.net>
	 <1106433059.4486.11.camel@localhost.localdomain>
	 <1106436153.20995.42.camel@tux.rsn.bth.se>
	 <1106484019.3376.5.camel@localhost.localdomain>
	 <1106496509.1085.1.camel@tux.rsn.bth.se>
	 <20050125220558.6e824f8a.davem@davemloft.net>
	 <1106730510.4041.4.camel@localhost.localdomain>
	 <41F82C6D.7020006@trash.net> <20050126231801.7bf90338.davem@davemloft.net>
	 <41F929FA.3050800@trash.net> <20050127114726.2205b4ed.davem@davemloft.net>
	 <41F96FA4.4000105@trash.net>  <20050127152450.6daba4fa.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, bdschuym@pandora.be, netdev@oss.sgi.com,
        Netfilter development mailing list <netfilter-devel@lists.netfilter.org>,
        snort2004@mail.ru, ak@suse.de, bridge@osdl.org, gandalf@wlug.westbo.se,
        dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050127152450.6daba4fa.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-27 at 15:24 -0800, David S. Miller wrote:
> It is never the case that both indev and outdev are both
> set, so we can use some nf_hook_desc piece of state to
> indicate which (in or out) the passed device pointer is.

NF_IP_FORWARD... it's really *really* useful for filtering forwarded
packets.  However, is it ever the case that indev != skb->dev?  If not,
we can simply drop that arg and use skb->dev.

> Now, back to the compatability issue.  We could create a
> new macro, NF_HOOK_DESC() and keep the existing ones around
> via some nf_hook_slow() that basically does:

No, let's just fix them all.  Also, gcc 3.4 will discard unused static
variables, so I prefer the kernel start just declaring structs as
normal, and have them "used" in the !CONFIG case by an inline function
which allows gcc to realize that it can be eliminated, but suppresses
unused warnings.  This also means you get type checking etc without the
config option.

BTW, someone should go through and start ripping out #ifdef
CONFIG_PROC_FS around those structs, too...

Cheers,
Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman
