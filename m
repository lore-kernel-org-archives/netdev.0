From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] veth: Configurable nterface MTU
Date: Fri, 27 Feb 2009 05:22:46 -0800 (PST)
Message-ID: <20090227.052246.177817156.davem@davemloft.net>
References: <m1fxi1kasv.fsf@fess.ebiederm.org>
	<20090227.024916.184944062.davem@davemloft.net>
	<m163iwf3w3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m163iwf3w3.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Fri, 27 Feb 2009 04:41:48 -0800

> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> 
> > From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
> > Date: Wed, 25 Feb 2009 21:49:04 -0800
> >
> >> @@ -249,6 +253,19 @@ static int veth_close(struct net_device *dev)
> >>  	return 0;
> >>  }
> >>  
> >> +static int is_valid_veth_mtu(int new_mtu)
> >> +{
> >> +	return (new_mtu >= MIN_MTU && new_mtu <= MAX_MTU);
> >> +}
> >> +
> >> +static int veth_change_mtu(struct net_device *dev, int new_mtu)
> >> +{
> >> +	if (is_valid_veth_mtu(new_mtu))
> >> +		return -EINVAL;
> >> +	dev->mtu = new_mtu;
> >> +	return 0;
> >> +}
> >> +
> >
> > This validity test seems to be reversed?
> 
> Crap.  You are correct. I will respin.

Please test your patches.

This one obviously didn't get even one single "ifconfig x mtu y" type
test.  It would have failed on any in-range value.
