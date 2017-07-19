From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 01/17] net: core: Make the FIB notification
 chain generic
Date: Wed, 19 Jul 2017 17:35:27 +0300
Message-ID: <20170719143527.GA11503@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-2-jiri@resnulli.us>
 <50e59e23-cc6e-2e75-ddb8-9b8b5afc847d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0061.outbound.protection.outlook.com ([104.47.0.61]:63552
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932707AbdGSOfi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 10:35:38 -0400
Content-Disposition: inline
In-Reply-To: <50e59e23-cc6e-2e75-ddb8-9b8b5afc847d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 08:11:56AM -0600, David Ahern wrote:
> On 7/19/17 1:02 AM, Jiri Pirko wrote:
> > +struct fib_notifier_ops *
> > +fib_notifier_ops_register(const struct fib_notifier_ops *tmpl, struct net *net)
> > +{
> > +	struct fib_notifier_ops *ops;
> > +	int err;
> > +
> > +	ops = kmemdup(tmpl, sizeof(*ops), GFP_KERNEL);
> 
> why allocate memory to copy the ops?

It contains a list pointer that I use to list all the registered
families in each net namespace. Same pattern used in FIB rules.
