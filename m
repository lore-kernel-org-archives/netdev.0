From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Mon, 31 Dec 2012 10:55:42 +0100
Message-ID: <20121231095542.GA1594@minipsycho.orion>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
 <1356868702-8144-2-git-send-email-jiri@resnulli.us>
 <20121230205633.5e5614ac@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63657 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842Ab2LaJzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 04:55:48 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so5997073eek.5
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2012 01:55:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121230205633.5e5614ac@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 31, 2012 at 05:56:33AM CET, shemminger@vyatta.com wrote:
>On Sun, 30 Dec 2012 12:58:08 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> This lists are supposed to serve for storing pointers to all upper devices.
>> Eventually it will replace dev->master pointer which is used for
>> bonding, bridge, team but it cannot be used for vlan, macvlan where
>> there might be multiple upper present. In case the upper link is
>> replacement for dev->master, it is marked with "master" flag.
>> 
>> New upper device list resolves this limitation. Also, the information
>> stored in lists is used for preventing looping setups like
>> "bond->somethingelse->samebond"
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>What is the use case for this?
>Could you describe a topology that the new upper device list supports,
>that the old scheme does not?


The old scheme is not possible to track the upper-lower dependencies for
all types of devices. (dev->master is used by bonding,bridge,team only).
My new scheme using upper lists allows to track all dependencies. That
provides ability to prevent loops in the dependency trees.


>
>I am concerned that it may open up many new possibilities for user
>error that were not possible before. For example how does it prevent
>an ethernet from being assigned to both a bonding and bridge at the
>same time?

No. netdev_master_upper_dev_link() is used in bond,bridge,team etc.
This function ensures that only one upper device marked as "master" is
present at a time.

This patchset does not introduce any possibility for user error. Only
prevents one group of them - loops.
