From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Fri, 22 Sep 2006 14:13:22 +0200
Message-ID: <20060922141322.24f2e5c4@logostar.upir.cz>
References: <20060822173241.313859000@devicescape.com>
	<20060822173419.GF12500@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Simon Barber" <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:29575 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932354AbWIVMNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 08:13:25 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060822173419.GF12500@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 10:34:19 -0700, David Kimdon wrote:
> This ioctl is used when radar is delected on a channel.  Data frames must stop
> but management frames must be allowed to continue for some time to communicate
> the channel switch to stations.

Any progress here? Is what Simon wrote (quoted below) reasonable? (It seems
so to me.)

Anybody volunteers to implement this? ;-)

On Wed, 23 Aug 2006 12:20:16 -0700, Simon Barber wrote:
> There is one other application where data frames should be buffered - in
> a client while roaming between 2 APs. The best way to implement this
> will be to extend the 802.11 qdisc. Currently there are 4 queues,
> representing the 4 EDCA access categories. Only the top AC (AC_VO) is
> used for sending management frames. I would recommend we split the
> qdisc, so that there are 2 software queues attached to this AC - one for
> management frames and 802.1x, and another for data frames. This way if
> we want to stop data (either for radar, or because we are mid BSS
> transition) we can simply stop all the queues except the AC_VO
> management queue.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
