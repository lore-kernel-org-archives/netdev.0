From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v4 2/2] vxlan: allow specifying multiple
 default destinations
Date: Mon, 24 Jun 2013 08:18:18 -0700
Message-ID: <20130624081818.2693ef68@nehalam.linuxnetplumber.net>
References: <1372004543-24675-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004543-24675-3-git-send-email-mike.rapoport@ravellosystems.com>
	<kq8q3h$9lu$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f194.google.com ([209.85.192.194]:54038 "EHLO
	mail-pd0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab3FXPSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 11:18:23 -0400
Received: by mail-pd0-f194.google.com with SMTP id 10so130988pdi.1
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 08:18:22 -0700 (PDT)
In-Reply-To: <kq8q3h$9lu$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Jun 2013 06:48:17 +0000 (UTC)
Cong Wang <xiyou.wangcong@gmail.com> wrote:

> > +static int vxlan_fill_remotes_info(struct sk_buff *skb,
> > +				   const struct vxlan_dev *vxlan)
> > +{
> > +	struct vxlan_rdst *rd;
> > +	struct nlattr *nest, *rdst_nest;
> > +	__be32 ip;
> > +	int i = 1;
> > +
> > +	if (!vxlan->remotes_cnt)
> > +		return 0;
> > +
> > +	nest = nla_nest_start(skb, IFLA_VXLAN_REMOTES);
> > +	if (nest == NULL)
> > +		goto nla_put_failure;
> > +
> > +	list_for_each_entry_rcu(rd, &vxlan->remotes, list) {  
> 
> 
> Need RCU read lock here?

RCU is unnecessary here since already protected by RTNL.
 
rtnl_fill_ifinfo
   ASSERT_RTNL()
   rtnl_link_fill
      vxlan_fill_info
         vxlan_fill_remotes_info

Better just to remove the for_each_entry_rcu and use for_each_entry
