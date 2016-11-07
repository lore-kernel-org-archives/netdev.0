From: =?iso-8859-1?q?Asbj=F8rn_Sloth_T=F8nnesen?= <asbjorn@asbjorn.st>
Subject: Re: [PATCH net-next 1/5] net: l2tp: fix L2TP_ATTR_UDP_CSUM
 attribute type
Date: Mon, 07 Nov 2016 21:00:29 +0000
Message-ID: <1478545589.6033.5@x201s.roaming.asbjorn.biz>
References: <20161107.130845.286540537414841421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-IQytyiA9D4pZ7q9KUF8N"
Cc: jchapman@katalix.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, shankerwangmiao@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107.130845.286540537414841421.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-IQytyiA9D4pZ7q9KUF8N
Content-Type: text/plain; charset=UTF-8

Hi David,

Thanks for the review.

On Mon, 07 Nov 2016 13:08:45 -0500 (EST), David Miller <davem@davemloft.net> wrote:
> From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
> Date: Fri,  4 Nov 2016 22:48:34 +0000
> 
> > L2TP_ATTR_UDP_CSUM is a flag, and gets read with
> > nla_get_flag, but it is defined as NLA_U8 in
> > the nla_policy.
> > 
> > It appears that this is only publicly used in
> > iproute2, where it's broken, because it's used as
> > a NLA_FLAG, and fails validation as a NLA_U8.
> > 
> > The only place it's used as a NLA_U8 is in
> > l2tp_nl_tunnel_send(), but iproute2 again reads that
> > as a flag, it's therefore always set. Fortunately
> > it is never used for anything, just read.
> > 
> > CC: Miao Wang <shankerwangmiao@gmail.com>
> > Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>
> 
> This is definitely the wrong way to go about this.
> 
> The kernel is everywhere and updating iproute2 is infinitely
> easier for users to do than updating the kernel.
> 
> And in any event, once exported we really should never change
> the API of anything shown to userspace like this.  Just because
> you can't find a user out there doesn't mean it doesn't exist.

Sure, I have submitted a v2 of the patchset, that keeps the
current netlink API intact.

Was unsure how frozen the API was in these outlying corners,
also only tried changing the cases where the kernel side is inconsistently
implemented, ie. kept L2TP_ATTR_{SEND,RECV}_SEQ as u8-flags since it was
used consitently.


> Please instead fix iproute2 to use u8 attributes for this.

Will do (set with u8-flag, read as u8).

-- 
Best regards
Asbjørn Sloth Tønnesen

--=-IQytyiA9D4pZ7q9KUF8N--
