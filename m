From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Mon, 31 Dec 2012 11:22:12 -0800
Message-ID: <20121231112212.03319226@nehalam.linuxnetplumber.net>
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
Received: from mail.vyatta.com ([76.74.103.46]:39185 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751662Ab2LaTXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 14:23:40 -0500
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

I like the concept of knowing the topology of layered network devices.
The name "upper device lists" is a little confusing to me.
Also, the amount of additional data structures and book keeping
seems more than needed; but not sure how to reduce it down to the
least code.

For simple case of detecting loops, just using existing master
pointer is sufficient.
       ethernet --> bonding --> bridge --+
                       ^                 |
                       |                 |
                       +-----------------+
This is the simple case of detecting if singularly linked list
is a loop.

The only device where multiple upper devices is possible seems
to be macvlan. Could the special case code be limited to there?
