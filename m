From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] per-nic module parameters
Date: Fri, 24 Oct 2008 13:39:20 -0700
Message-ID: <20081024133920.6588026c@extreme>
References: <49022B7F.8080809@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33763 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753801AbYJXUj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 16:39:27 -0400
In-Reply-To: <49022B7F.8080809@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Oct 2008 22:09:35 +0200
Brice Goglin <brice@myri.com> wrote:

> Hello,
> 
> We're working on making myri10ge module parameters per-nic. It looks
> like ixgb already does so with the following macro in ixgb_param.c:
> 
> #define IXGB_PARAM_INIT { [0 ... IXGB_MAX_NIC] = OPTION_UNSET }
> #define IXGB_PARAM(X, desc)                                     \
>         static int __devinitdata X[IXGB_MAX_NIC+1]              \
>                 = IXGB_PARAM_INIT;                              \
>         static unsigned int num_##X = 0;                        \
>         module_param_array_named(X, X, int, &num_##X, 0);       \
>         MODULE_PARM_DESC(X, desc);
> 
> Is this the recommended way to implement per-nic module params? Or
> should we do something else?

Module parameters are bad. They are device specific and awkward for
any general configuration system to deal with. As much as possible,
please convert any module parameters to real interfaces like netlink,
ethtool, or sysfs.
