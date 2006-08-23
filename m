From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 5/5] d80211: add ioctl to stop data frame tx
Date: Wed, 23 Aug 2006 09:25:06 +0200
Message-ID: <1156317906.3629.18.camel@ux156>
References: <20060822173241.313859000@devicescape.com>
	 <20060822173419.GF12500@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51411 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751448AbWHWHYn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:24:43 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20060822173419.GF12500@devicescape.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 10:34 -0700, David Kimdon wrote:

> This ioctl is used when radar is delected on a channel.  Data frames must stop
> but management frames must be allowed to continue for some time to communicate
> the channel switch to stations.

Which does lead to the question: How are you detecting radar in
userspace in the first place??

> +       if (unlikely(local->stop_data_frame_tx)) {
> +               struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
> +               u16 fc = le16_to_cpu(hdr->frame_control);
> +               if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA) {
> +                       dev_kfree_skb(skb);
> +                       return 0;
> +               }
> +       }

Should that really drop dataframes dead on the floor? And wouldn't it
make sense stop the networking layer from injecting more data into the
stack when stop_data_frame_tx is enabled?

> +static int ieee80211_ioctl_set_stop_data_frame_tx(struct net_device *dev,
> +                                                 int val)
> +{
> +	struct ieee80211_local *local = dev->ieee80211_ptr;
> +        local->stop_data_frame_tx = val;
> +        return 0;
> +}

Again, whitespace damaged. Yes, I know it's hard to code in there with
any smart editor that thinks it knows what to do based on the
surroundings because those may also contain whitespace...


> +                ret = ieee80211_ioctl_set_stop_data_frame_tx(dev, value);

Ditto.

johannes
