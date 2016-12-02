From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH main-v4.9-rc7] net/ipv6: allow sysctl to change link-local
 address generation mode
Date: Thu, 1 Dec 2016 20:36:08 -0800
Message-ID: <CAM_iQpV_7X_ON0XLkd+b3cMRDpg0kN8opPWzx=CfxGGCcNqQQA@mail.gmail.com>
References: <20161202021457.13163-1-felix.jia@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Carl Smith <carl.smith@alliedtelesis.co.nz>
To: Felix Jia <felix.jia@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35270 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753128AbcLBEga (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 23:36:30 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so6209717ioe.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 20:36:29 -0800 (PST)
In-Reply-To: <20161202021457.13163-1-felix.jia@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 6:14 PM, Felix Jia <felix.jia@alliedtelesis.co.nz> wrote:
> +static void addrconf_addrgenmode_change(struct net *net)
> +{
> +       struct net_device *dev;
> +       struct inet6_dev *idev;
> +
> +       read_lock(&dev_base_lock);
> +       for_each_netdev(net, dev) {
> +               rcu_read_lock();
> +               idev = __in6_dev_get(dev);
> +               if (idev) {
> +                       idev->cnf.addrgenmode = ipv6_devconf_dflt.addrgenmode;
> +                       idev->addr_gen_mode = ipv6_devconf_dflt.addrgenmode;
> +                       rtnl_lock();
> +                       addrconf_dev_config(idev->dev);
> +                       rtnl_unlock();

You can't call rtnl lock in atomic context.

> +               }
> +               rcu_read_unlock();
> +       }
> +       read_unlock(&dev_base_lock);

Did you test your patch seriously?
