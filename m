From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH repost] net,wireless: check against default_ethtool_ops
Date: Mon, 7 Jan 2013 12:57:18 +0100
Message-ID: <20130107115718.GC1587@minipsycho.orion>
References: <20130107095548.GA6931@redhat.com>
 <20130107102307.GA1587@minipsycho.orion>
 <20130107104413.GB6931@redhat.com>
 <20130107111108.GB1587@minipsycho.orion>
 <20130107112012.GE6931@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130107112012.GE6931-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mon, Jan 07, 2013 at 12:20:12PM CET, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
>On Mon, Jan 07, 2013 at 12:11:08PM +0100, Jiri Pirko wrote:
>> Mon, Jan 07, 2013 at 11:44:14AM CET, sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org wrote:
>> >On Mon, Jan 07, 2013 at 11:23:07AM +0100, Jiri Pirko wrote:
>> >> >-static const struct ethtool_ops default_ethtool_ops;
>> >> >+const struct ethtool_ops default_ethtool_ops;
>> >> >+EXPORT_SYMBOL_GPL(default_ethtool_ops);
>> >> 
>> >> I think that default_ethtool_ops should stay static. Wouldn't it be
>> >> nicer to introduce a helper like:
>> >> 
>> >> bool dev_has_default_ethtool_ops(struct net_device *dev)
>> >> {
>> >> 	return dev->ethtool_ops == &default_ethtool_ops;
>> >> }
>> >
>> >Then I still have to export this function. So with your approch, number
>> >of exported symbols will be the same, but there will be few more lines
>> >of code.
>> 
>> I think it's always better to add few more lines in order to prevent possible
>> confusion which exporting default_ethtool_ops might introduce...
>
>What possible confusion it might cause?

Someone would possibly like to do:

dev->netdev_ops = &default_ethtool_ops

in drivers for example...

+ I just do not think that exporting structs is the correct way in order
to do anything.

>
>Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
