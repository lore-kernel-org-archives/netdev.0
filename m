From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [v11 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH based fwmark
Date: Mon, 23 Apr 2012 14:33:16 +0200
Message-ID: <201204231433.17751.hans.schillstrom@ericsson.com>
References: <1332417593-26232-1-git-send-email-hans.schillstrom@ericsson.com> <1332417593-26232-3-git-send-email-hans.schillstrom@ericsson.com> <20120412155442.GA10767@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120412155442.GA10767@1984>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 April 2012 17:54:42 Pablo Neira Ayuso wrote:
> Hi Hans,
> 
> On Thu, Mar 22, 2012 at 12:59:52PM +0100, Hans Schillstrom wrote:
[snip]

> >
> > +config NETFILTER_XT_TARGET_HMARK
> > +     tristate '"HMARK" target support'
> > +     depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
> 
> do we really need this dependency above?

Nope, I'll removed it.

[snip] 
> 
> There's an inconsistency here. No conntrack support for IPv6.

That's true, since it was intended for nat from the very begining..
I'll added.

> 
> I'd suggest to split hmark_v4 into two functions by checking:
> 
or make a common  hmark_ct for ipv6 and ipv4

> ... hmark_v4(...)
> {
>         if (info->flags & XT_F_HMARK_CT)
>                 ret = hmark_tg_ct_v4(...)
>         else
>                 ret = hmark_tg_v4(...)
> 
>         return ret;
> }
> 
> Same thing for IPv6. Those function will look smaller, and that's good
> to make the code more maintainable.
> 
> You can define some hmark_hash_v4 and hmark_hash_v6 function that you
> may want to inline.
> 
> Another suggestion in case you may need to extend HMARK in
> the future. I think some info->type field to specify the
> 
> info->type can be HMARK_T_PKT or HMARK_T_CT.
> 
> Thus, the code above would look like:
> 
> ... hmark_v4(...)
> {
>         switch(info->type) {
>         case HMARK_T_PKT:
>                 ret = hmark_tg_ct_v4(...)
>                 break;
>         case HMARK_T_CT:
>                 ret = hmark_tg_v4(...)
>                 break;
>         }
> }
> 
> But *this is only a suggestion*, of course.
> 
Thanks Pablo for your review , I will send a new patch today

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
