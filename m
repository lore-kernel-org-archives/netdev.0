From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 4/7] bridge: call NETDEV_RELEASE notifier in
	br_del_if()
Date: Mon, 30 Jul 2012 09:59:38 +0800
Message-ID: <1343613578.1642.6.camel@cr0>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
	<1343403484-29347-5-git-send-email-amwang@redhat.com>
	<20120727085021.1d4ef810@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120727085021.1d4ef810@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-27 at 08:50 -0700, Stephen Hemminger wrote:
> On Fri, 27 Jul 2012 23:38:01 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > When a bridge interface deletes its underlying ports, it should
> > notify netconsole too, like what bonding interface does.
> > 
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> >  net/bridge/br_if.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> > index e1144e1..d243914 100644
> > --- a/net/bridge/br_if.c
> > +++ b/net/bridge/br_if.c
> > @@ -427,6 +427,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
> >  	if (!p || p->br != br)
> >  		return -EINVAL;
> >  
> > +	call_netdevice_notifiers(NETDEV_RELEASE, br->dev);
> >  	del_nbp(p);
> >  
> >  	spin_lock_bh(&br->lock);
> 
> Since you can have multiple ports attached to the bridge, this
> doesn't seem correct. Don't you want the netconsole to keep going
> on the other ports of the bridge?
> 
> What exactly is the problem with having netconsole persist?

Hmm, I saw an incorrect log message when deleting the last port from the
bridge when netconsole is setup on it. After rethinking it today, you
are right we should not simply disable netconsole when one port is
detached, as we have no way to know if that port is used to reach the
netconsole server.

So, please ignore this patch.

Thanks.
