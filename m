From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] netfilter: potential NULL dereference in get_inner_hdr()
Date: Mon, 14 May 2012 11:39:12 +0300
Message-ID: <20120514083912.GB16999@mwanda>
References: <20120512110003.GB19472@elgon.mountain>
 <201205140936.56960.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201205140936.56960.hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 09:36:55AM +0200, Hans Schillstrom wrote:
> On Saturday 12 May 2012 13:00:03 Dan Carpenter wrote:
> > There is a typo in the error checking and "&&" was used instead of "||".
> > If skb_header_pointer() returns NULL then it leads to a NULL
> > dereference.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Ack-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
>  
> > ---
> > Btw, this is new code and Sparse complains about endian bugs.
> 
> Can you give me some hints here, arch , compiler version etc.
> I guess it was input to hmark_addr_mask() that complains ?
> 

Yes.  That was one of the warnings.

http://lwn.net/Articles/205624/

net/netfilter/xt_HMARK.c:87:35: warning: incorrect type in assignment (different base types)
net/netfilter/xt_HMARK.c:87:35:    expected unsigned short [unsigned] [usertype] src
net/netfilter/xt_HMARK.c:87:35:    got restricted __be16 [usertype] all
net/netfilter/xt_HMARK.c:88:35: warning: incorrect type in assignment (different base types)
net/netfilter/xt_HMARK.c:88:35:    expected unsigned short [unsigned] [usertype] dst
net/netfilter/xt_HMARK.c:88:35:    got restricted __be16 [usertype] all
net/netfilter/xt_HMARK.c:181:35: warning: incorrect type in argument 1 (different base types)
net/netfilter/xt_HMARK.c:181:35:    expected unsigned int const [usertype] *addr32
net/netfilter/xt_HMARK.c:181:35:    got restricted __be32 *<noident>
net/netfilter/xt_HMARK.c:182:35: warning: incorrect type in argument 1 (different base types)
net/netfilter/xt_HMARK.c:182:35:    expected unsigned int const [usertype] *addr32
net/netfilter/xt_HMARK.c:182:35:    got restricted __be32 *<noident>
net/netfilter/xt_HMARK.c:261:16: warning: invalid assignment: &=
net/netfilter/xt_HMARK.c:261:16:    left side has type unsigned int
net/netfilter/xt_HMARK.c:261:16:    right side has type restricted __be32
net/netfilter/xt_HMARK.c:262:16: warning: invalid assignment: &=
net/netfilter/xt_HMARK.c:262:16:    left side has type unsigned int
net/netfilter/xt_HMARK.c:262:16:    right side has type restricted __be32

regards,
dan carpenter

