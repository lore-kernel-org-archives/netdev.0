From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] netconsole: enable netconsole can make net_device
 refcnt
Date: Tue, 11 Oct 2011 22:11:48 -0300
Message-ID: <20111011221148.2ef4487d@asterix.rh>
References: <4E93E238.7000105@cn.fujitsu.com>
	<1318319438-7159-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<4E93F8DC.5080909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab1JLBL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 21:11:58 -0400
In-Reply-To: <4E93F8DC.5080909@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Oct 2011 16:05:48 +0800
Gao feng <gaofeng@cn.fujitsu.com> wrote:

> Im so sorry.
> the first patch has some format err.
> Please use this one.
> thanks wanlong! ^V^
> 
> 11.10.2011 15:50, Wanlong Gao wrote:
> > There is no check if netconsole is enabled current.
> > so when exec echo 1 > enabled;
> > the reference of net_device will increment always.
> > 
> > Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> > ---
> >  drivers/net/netconsole.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
> > index ed2a397..4e6323df 100644
> > --- a/drivers/net/netconsole.c
> > +++ b/drivers/net/netconsole.c
> > @@ -307,6 +307,8 @@ static ssize_t store_enabled(struct
> > netconsole_target *nt, return err;
> >  	if (enabled < 0 || enabled > 1)
> >  		return -EINVAL;
> > +	if (enabled == nt->enabled)
> > +		return err;

It looks like 'err' will be 0.  Maybe it is better to
return -EINVAL?

fbl
