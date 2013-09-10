From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/26] bonding: use neighbours instead of own
 lists
Date: Tue, 10 Sep 2013 18:41:59 +0200
Message-ID: <20130910164159.GC8474@redhat.com>
References: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: jiri@resnulli.us, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Dimitris Michailidis <dm@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631Ab3IJQn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 12:43:57 -0400
Content-Disposition: inline
In-Reply-To: <1378757804-3159-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 09, 2013 at 10:16:18PM +0200, Veaceslav Falico wrote:
>(David, feel free to drop the whole patchset - I know that the window is
>closed and I'm quite sure that it's not the last version, and even if it is
>- I'll easily re-submit it. Sorry for the mess :-/)
>
>Hi,
>
>RFC -> v1:
>I've added proper, consistent naming for all variables/functions, uninlined
>some helpers to get better backtraces, just in case (overhead is minimal,
>no hot paths), rearranged patches for better review, dropped bondings
>->prev and bond_for_each_slave_continue() functionality - to be able to
>RCUify it easier, and renamed slave_* sysfs links to lower_* sysfs links to
>maintain upper/lower naming. I've also dropped, thanks to bonding cleanup,
>some heavy and ugly/intrusive patches.

Self-NAK on this version, there is a bug - desynchronization of
adj_list/all_adj_list lists in case we make a loop consecutively (otherwise
it won't trigger):

ifenslave bond0 eth0
vconfig add eth0 100
ifenslave bond0 eth0.100
ifesnlave -d bond0 eth0.100

It's, however, easily fixable (and quite a rare scenario) - so all reviews
are still welcome. I'll continue testing and waiting for any input.

Thanks all!
