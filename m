From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net-next] net/core: ensure features get disabled on new
 lower devs
Date: Tue, 3 Nov 2015 22:53:10 +0100
Message-ID: <20151103215310.GA7839@unicorn.suse.cz>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
 <1446583017-19021-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46339 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932285AbbKCVxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 16:53:13 -0500
Content-Disposition: inline
In-Reply-To: <1446583017-19021-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 03, 2015 at 03:36:57PM -0500, Jarod Wilson wrote:
> With moving netdev_sync_lower_features() after the .ndo_set_features
> calls, I neglected to verify that devices added *after* a flag had been
> disabled on an upper device were properly added with that flag disabled as
> well. This currently happens, because we exit __netdev_update_features()
> when we see dev->features == features for the upper dev. We can retain the
> optimization of leaving without calling .ndo_set_features with a bit of
> tweaking and a goto here.

I haven't reviewed the patch yet (I'm going to take a look with fresher
mind in the morning) but if you are going to handle this in a generic
way, you may want to remove the LRO specific hacks added to
bond_enslave() and team_port_add() by commit fbe168ba91f7 ("net: generic
dev_disable_lro() stacked device handling").

                                                          Michal Kubecek
