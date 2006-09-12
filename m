From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.18] WE-21 for ipw2200
Date: Tue, 12 Sep 2006 11:17:03 -0700
Message-ID: <20060912181703.GA3818@bougret.hpl.hp.com>
References: <20060830010140.GF8405@bougret.hpl.hp.com> <20060912180253.GC7703@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:47087 "EHLO madara.hpl.hp.com")
	by vger.kernel.org with ESMTP id S1030330AbWILSRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 14:17:45 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060912180253.GC7703@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2006 at 02:02:59PM -0400, John W. Linville wrote:
> On Tue, Aug 29, 2006 at 06:01:40PM -0700, Jean Tourrilhes wrote:
> > @@ -8861,7 +8861,7 @@ static int ipw_wx_set_essid(struct net_d
> >  	int length = 0;
> >  	mutex_lock(&priv->mutex);
> >  	if (wrqu->essid.flags && wrqu->essid.length) {
> > -		length = wrqu->essid.length - 1;
> > +		length = wrqu->essid.length;
> >  		essid = extra;
> >  	}
> >  	if (length == 0) {
> 
> This hunk doesn't apply to the upstream branch of wireless-2.6.

	It did apply to your branch the day I sent the patches. Sorry
about that.

> I propose this one instead:
> 
> @@ -8875,8 +8875,6 @@ static int ipw_wx_set_essid(struct net_d
>          }
>  
>  	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
> -	if (!extra[length - 1])
> -		length--;
>  
>  	priv->config |= CFG_STATIC_ESSID;
>  
> Everything else stays the same...OK?

	It looks good. I will double check the code, and redo the
out-of-tree patch for the IPW people. GIT through our HTTP proxy is
quite slow, so bear with me :-(

> John

	Jean
