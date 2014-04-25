From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net] bridge: Handle IFLA_ADDRESS correctly when
 creating bridge device
Date: Fri, 25 Apr 2014 16:54:11 +0900
Message-ID: <1398412451.3920.3.camel@ubuntu-vm-makita>
References: <CAG-2HqVnWXu2dW=Su6DDxDzgg3cLSvTMu5Sf=Eq+YUv4P1d4NQ@mail.gmail.com>
	<CAG-2HqU2f+4i3ttLSeitwr15=cVyin9VT+UrQvKC9pMV04fW7Q@mail.gmail.com>
	<1398341177.4171.11.camel@ubuntu-vm-makita>
	<1398341787.4171.16.camel@ubuntu-vm-makita>
	<20140424113827.6d27ec5b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Gundersen <teg@jklm.no>, netdev <netdev@vger.kernel.org>,
	bridge <bridge@lists.linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, "C. R. Oldham" <cr@saltstack.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140424113827.6d27ec5b@nehalam.linuxnetplumber.net>
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

On Thu, 2014-04-24 at 11:38 -0700, Stephen Hemminger wrote:
> On Thu, 24 Apr 2014 21:16:27 +0900
> Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp> wrote:
> 
> > +static int br_dev_newlink(struct net *src_net, struct net_device *dev,
> > +			  struct nlattr *tb[], struct nlattr *data[])
> > +{
> > +	int err;
> > +	struct net_bridge *br = netdev_priv(dev);
> > +
> > +	if (tb[IFLA_ADDRESS]) {
> > +		spin_lock_bh(&br->lock);
> > +		br_stp_change_bridge_id(br, nla_data(tb[IFLA_ADDRESS]));
> > +		spin_unlock_bh(&br->lock);
> > +	}
> > +
> > +	err = register_netdevice(dev);
> > +	if (err)
> > +		return err;
> > +
> > +	return 0;
> > +}
> 
> Looks good.
> 
> Why not just do simpler tail call??
>     return register_netdevice(dev);

Yes, It's simpler.
I mimicked team_newlink()'s style, so we can also make it simpler
later :)

I'll send v2.

Thanks,
Toshiaki Makita
