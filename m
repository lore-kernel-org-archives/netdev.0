From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [RFC PATCH 6/6] ppp: add rtnetlink device creation support
Date: Wed, 6 Apr 2016 10:21:07 +0200
Message-ID: <20160406082107.GA1620@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
 <dc5fd88775581dba073d0051bbfb4c2c9c5c2d23.1459807527.git.g.nault@alphalink.fr>
 <5703F356.6050107@bfs.de>
 <20160405212222.GD1305@alphalink.fr>
 <5704C2B0.6020504@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: walter harms <wharms@bfs.de>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5704C2B0.6020504@bfs.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2016 at 10:02:56AM +0200, walter harms wrote:
> 
> 
> Am 05.04.2016 23:22, schrieb Guillaume Nault:
> > On Tue, Apr 05, 2016 at 07:18:14PM +0200, walter harms wrote:
> >>
> >>
> >> Am 05.04.2016 02:56, schrieb Guillaume Nault:
> >>> @@ -1043,12 +1048,39 @@ static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
> >>>  			     const struct ppp_config *conf)
> >>>  {
> >>>  	struct ppp *ppp = netdev_priv(dev);
> >>> +	struct file *file;
> >>>  	int indx;
> >>> +	int err;
> >>> +
> >>> +	if (conf->fd < 0) {
> >>> +		file = conf->file;
> >>> +		if (!file) {
> >>> +			err = -EBADF;
> >>> +			goto out;
> >>
> >> why not just return -EBADF;
> >>
> >>> +		}
> >>> +	} else {
> >>> +		file = fget(conf->fd);
> >>> +		if (!file) {
> >>> +			err = -EBADF;
> >>> +			goto out;
> >> 	
> >> why not just return -EBADF;
> >>
> > Just because the 'out' label is declared anyway and because this
> > centralises the return point. But I agree returning -EBADF directly
> > could be more readable. I don't have strong opinion.
> 
> in this special case i would go for readable. People tend to miss these
> if
>  if
>   if
> constructs.
> 
Ok, I'll do that in v3.
