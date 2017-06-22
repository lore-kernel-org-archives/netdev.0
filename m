From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [RFC PATCH net-next 0/3] ethtool: Add link down reason
 reporting
Date: Thu, 22 Jun 2017 14:53:47 -0700
Message-ID: <20170622145347.4b5d7295@cakuba.netronome.com>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
        <20170621211443.674e18a6@cakuba.netronome.com>
        <daf82b38-3642-6f4a-d9c0-c4cf806d6b7f@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:49188 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752714AbdFVVx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 17:53:57 -0400
In-Reply-To: <daf82b38-3642-6f4a-d9c0-c4cf806d6b7f@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jun 2017 14:37:26 +0300, Gal Pressman wrote:
> > Any particular reason for implementing this ABI in ethtool rather than
> > via some netlink-based interface?  Devlink naturally comes to mind,
> > given that cabling problems are not really related to the L2 and netdev
> > shouldn't be required for diagnostics..  
> 
> ethtool is already used for reporting and handling of link related stuff through get/set_link_ksettings.
> How is reporting the link modes/port type/speed/etc different from this?
> This feature is only an extension of the already existent "link detected" field.
> 
> Implementing this ABI in devlink is a good idea, but it shouldn't be instead of ethtool but in addition to ethtool.
> Many users already use ethtool for this kind of info, we can tell them to use devlink to check why their link is down,
> but I think it's nicer to have it all in one place.

I understand where you're coming from, but it's a matter of user space
tooling.  If ethtool has to invoke devlink or know a little of netlink
to get this info, so be it.  Ethtool implements a lot of features, I'm
worried that if we select where things are added based on where the
similar features already live, we will be stuck adding ioctls for
ever :(

But I'm happy to let this go if others don't feel the same way ;)  

In general thanks for working on this feature, it's very useful!
