From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Network namespace and bonding WARNING at fs/proc/generic.c
	remove_proc_entry
Date: Fri, 6 Jul 2012 19:47:41 +0000
Message-ID: <20120706194741.GA22113@mail.hallyn.com>
References: <1340900320.3441.88.camel@pro6455b.example.com>
	<20120705220749.GA11255@mail.hallyn.com>
	<87ehopu3e5.fsf@xmission.com>
	<20120706170538.GA31679@mail.hallyn.com>
	<87fw94g1kq.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Dilip Daya <dilip.daya-VXdhtT5mjnY@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87fw94g1kq.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> >> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >> index 2ee8cf9..818ed64 100644
> >> --- a/drivers/net/bonding/bond_main.c
> >> +++ b/drivers/net/bonding/bond_main.c
> >> @@ -4345,6 +4345,9 @@ static void bond_setup(struct net_device *bond_dev)
> >>         bond_dev->priv_flags |= IFF_BONDING;
> >>         bond_dev->priv_flags &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
> >>  
> >> +       /* Don't allow bond devices to change network namespaces. */
> >> +       bond_dev->features |= NETIF_F_LOCAL;
> >
> > I believe this needs to be NETIF_F_NETNS_LOCAL.  Test build still going with
> > that change.
> 
> Yes that is what I mean.

With that change, build is fine, boots fine, I can't pass a bond to another
netns (preventing the problem), and I can create a bond in a child netns
just fine.

Thanks!

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

-serge
