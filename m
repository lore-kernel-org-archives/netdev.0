From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/3] netfilter: Fix copy_to_user too small size
 parametre.
Date: Thu, 1 Mar 2012 14:06:37 +0100
Message-ID: <20120301130637.GB7429@1984>
References: <1330593390-19233-1-git-send-email-santoshprasadnayak@gmail.com>
 <20120301101809.GA6488@1984>
 <20120301113736.GE22598@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh nayak <santoshprasadnayak@gmail.com>,
	bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120301113736.GE22598@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2012 at 02:37:36PM +0300, Dan Carpenter wrote:
> On Thu, Mar 01, 2012 at 11:18:09AM +0100, Pablo Neira Ayuso wrote:
> > On Thu, Mar 01, 2012 at 02:46:30PM +0530, santosh nayak wrote:
> > > From: Santosh Nayak <santoshprasadnayak@gmail.com>
> > > 
> > > While copying to userspace, the size of source is 29byte where as
> > > size parametre is 32 byte.  Its leaking extra-information from
> > > kernel space to user space.
> > > Replace EBT_FUNCTION_MAXNAMELEN by XT_EXTENSION_MAXNAMELEN.
> > 
> > There's no information leak.
> > 
> 
> Where do we clear "m"? 
> 
> include/linux/netfilter/x_tables.h
>    287  struct xt_match {
>    288          struct list_head list;
>    289  
>    290          const char name[XT_EXTENSION_MAXNAMELEN];
>    291          u_int8_t revision;
>    292  
> 
> There is a 2 byte holes here between "revision" and "match()".  We
> copy three bytes past the end of name, so we include revision and
> the hole.
> 
> But maybe we memset it somewhere?  I'm not sure.

xt_match instances are declared as static for each module so it's
allocated in the BSS (already zeroed), is that what you mean?

>    293          /* Return true or false: return FALSE and set *hotdrop = 1 to
>    294             force immediate packet drop. */
>    295          /* Arguments changed since 2.6.9, as this must now handle
>    296             non-linear skb, using skb_header_pointer and
>    297             skb_ip_make_writable. */
>    298          bool (*match)(const struct sk_buff *skb,
>    299                        struct xt_action_param *);
> 
> regards,
> dan carpenter
> 
