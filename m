From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Sun, 30 Dec 2012 20:56:33 -0800
Message-ID: <20121230205633.5e5614ac@nehalam.linuxnetplumber.net>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
	<1356868702-8144-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com, fbl@redhat.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ebiederm@xmission.com, joe@perches.com,
	amwang@redhat.com, nhorman@tuxdriver.com,
	john.r.fastabend@intel.com, pablo@netfilter.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40400 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790Ab2LaE55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2012 23:57:57 -0500
In-Reply-To: <1356868702-8144-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Dec 2012 12:58:08 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> This lists are supposed to serve for storing pointers to all upper devices.
> Eventually it will replace dev->master pointer which is used for
> bonding, bridge, team but it cannot be used for vlan, macvlan where
> there might be multiple upper present. In case the upper link is
> replacement for dev->master, it is marked with "master" flag.
> 
> New upper device list resolves this limitation. Also, the information
> stored in lists is used for preventing looping setups like
> "bond->somethingelse->samebond"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

What is the use case for this?
Could you describe a topology that the new upper device list supports,
that the old scheme does not?

I am concerned that it may open up many new possibilities for user
error that were not possible before. For example how does it prevent
an ethernet from being assigned to both a bonding and bridge at the
same time?
