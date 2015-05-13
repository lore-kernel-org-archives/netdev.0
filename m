From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: netns: use a spin_lock to protect nsid management
Date: Wed, 13 May 2015 13:37:21 +0200
Message-ID: <55533771.6080406@6wind.com>
References: <20150512175227.GA19020@mwanda>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernel-janitors@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35811 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbbEMLhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:37:24 -0400
Received: by widdi4 with SMTP id di4so194396437wid.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 04:37:23 -0700 (PDT)
In-Reply-To: <20150512175227.GA19020@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/05/2015 19:52, Dan Carpenter a =E9crit :
> Hello Nicolas Dichtel,
>
> The patch 95f38411df05: "netns: use a spin_lock to protect nsid
> management" from May 7, 2015, leads to the following static checker
> warning:
>
> 	net/core/net_namespace.c:580 rtnl_net_newid()
> 	warn: inconsistent returns 'spin_lock:&nsid_lock'.
>
> net/core/net_namespace.c
>     565
>     566          spin_lock_irqsave(&nsid_lock, flags);
>     567          if (__peernet2id(net, peer) >=3D 0) {
>     568                  err =3D -EEXIST;
>     569                  goto out;
>
> I don't know if __peernet2id() unlocks on error but it can't possibly
> restore flags so this isn't right.
It's a bug. I will send a patch.

Thank you for the report.

Nicolas
