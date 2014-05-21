From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next] net: ipv6: trigger action when setting conf.all sysctls
Date: Wed, 21 May 2014 10:35:17 -0700
Message-ID: <CAHA+R7PaM4c6TmUtTLDAGnBUmRKE7=vnsjm67i=rmNebZvacVw@mail.gmail.com>
References: <1400519372-5703-1-git-send-email-milos.vyletel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"open list:NETWORKING [IPv4/..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Milos Vyletel <milos.vyletel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:46683 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbaEURfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 13:35:18 -0400
Received: by mail-qg0-f47.google.com with SMTP id j107so3746980qga.20
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 10:35:17 -0700 (PDT)
In-Reply-To: <1400519372-5703-1-git-send-email-milos.vyletel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 10:09 AM, Milos Vyletel <milos.vyletel@gmail.com> wrote:
> As it is right now most of these tunables don't do anything - they don't
> set any interface specific settings to the desired value and they don't
> take precedence before device specific settings in most cases.
>
> Documentation/networking/ip-sysctl.txt defines them to be:
> conf/all/*:
>         Change all the interface-specific settings.
>
> but that is not really the case.
>

I don't think it's a good idea, it enforces interface specific changes.

You need to mimic what IPv4 conf does (if it hasn't done yet), something
like below:

#define IN_DEV_MAXCONF(in_dev, attr) \
        (max(IPV4_DEVCONF_ALL(dev_net(in_dev->dev), attr), \
             IN_DEV_CONF_GET((in_dev), attr)))
