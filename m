From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next ] net: Allow userns root to control tun and
	tap devices
Date: Mon, 19 Nov 2012 14:23:31 +0000
Message-ID: <20121119142331.GA4453@mail.hallyn.com>
References: <87a9uekpvw.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87a9uekpvw.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
> 
> Allow an unpriviled user who has created a user namespace, and then
> created a network namespace to effectively use the new network
> namespace, by reducing capable(CAP_NET_ADMIN) calls to
> ns_capable(net->user_ns,CAP_NET_ADMIN) calls.
> 
> Allow setting of the tun iff flags.
> Allow creating of tun devices.
> Allow adding a new queue to a tun device.
> 

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/net/tun.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index b44d7b7..b01e8c0 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -373,10 +373,11 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
>  static inline bool tun_not_capable(struct tun_struct *tun)
>  {
>  	const struct cred *cred = current_cred();
> +	struct net *net = dev_net(tun->dev);
>  
>  	return ((uid_valid(tun->owner) && !uid_eq(cred->euid, tun->owner)) ||
>  		  (gid_valid(tun->group) && !in_egroup_p(tun->group))) &&
> -		!capable(CAP_NET_ADMIN);
> +		!ns_capable(net->user_ns, CAP_NET_ADMIN);
>  }
>  
>  static void tun_set_real_num_queues(struct tun_struct *tun)
> @@ -1559,7 +1560,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		char *name;
>  		unsigned long flags = 0;
>  
> -		if (!capable(CAP_NET_ADMIN))
> +		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
>  			return -EPERM;
>  		err = security_tun_dev_create();
>  		if (err < 0)
> -- 
> 1.7.5.4
