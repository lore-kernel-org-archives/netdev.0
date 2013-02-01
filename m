From: Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] netns: bridge: allow unprivileged users
	add/delete mdb entry
Date: Thu, 31 Jan 2013 20:11:10 -0800
Message-ID: <20130201041110.GA5829@us.ibm.com>
References: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1359685860-29636-3-git-send-email-gaofeng@cn.fujitsu.com>
	<20130201034629.GE8400@us.ibm.com>
	<510B3D87.6050908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amwang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <510B3D87.6050908-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 01, 2013 at 11:59:03AM +0800, Gao feng wrote:
> On 2013/02/01 11:46, Matt Helsley wrote:
> > On Fri, Feb 01, 2013 at 10:30:59AM +0800, Gao feng wrote:
> >> since the mdb table is belong to bridge device,and the
> >> bridge device can only be seen in one netns.
> >> So it's safe to allow unprivileged user which is the
> >> creator of userns and netns to modify the mdb table.
> >>
> >> Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> >> ---
> >>  net/bridge/br_mdb.c | 3 ---
> >>  1 file changed, 3 deletions(-)
> >>
> >> diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
> >> index acc9f4c..38991e0 100644
> >> --- a/net/bridge/br_mdb.c
> >> +++ b/net/bridge/br_mdb.c
> >> @@ -272,9 +272,6 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
> >>  	struct net_device *dev;
> >>  	int err;
> >>
> >> -	if (!capable(CAP_NET_ADMIN))
> >> -		return -EPERM;
> >> -
> > 
> > I'm wondering why this doesn't follow the:
> > 
> > ...
> > - if (!capable(CAP_NET_ADMIN))
> > + if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> > 
> > pattern like the rest of the changes you provided. Perhaps I'm
> > neglecting something but it looks wrong to remove the CAP_NET_ADMIN
> > check entirely.
> > 
> 
> rtnetlink_rcv_msg has done this job,in commit dfc47ef8639facd77210e74be831943c2fdd9c74
> Eric change capable to ns_capable in rtnetlink_rcv_msg and Push capable(CAP_NET_ADMIN)
> into the rtnl methods.So we only need to do is remove this capable in br_mdb_parse.
> 
> Thanks!

OK, thanks!

Cheers,
	-Matt
