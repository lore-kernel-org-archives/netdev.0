From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [patch net-next v5 06/21] net: introduce generic switch devices
 support
Date: Sat, 29 Nov 2014 10:31:39 +0100
Message-ID: <5479927B.4020807@gmx.de>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us> <1417181672-11531-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:52895 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751385AbaK2Jdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Nov 2014 04:33:46 -0500
In-Reply-To: <1417181672-11531-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

On 28.11.2014 14:34, Jiri Pirko wrote:
> +
> +  ndo_switch_parent_id_get - This returns the same ID for two port netdevices
> +			     of the same physical switch chip. This is
> +			     mandatory to be implemented by all switch drivers
> +			     and serves the caller for recognition of a port
> +			     netdevice.
> +  ndo_switch_parent_* - Functions that serve for a manipulation of the switch
> +			chip itself (it can be though of as a "parent" of the
> +			port, therefore the name). They are not port-specific.
> +			Caller might use arbitrary port netdevice of the same
> +			switch and it will make no difference.

I doubt that this is a good solution. If you want to access some kind of
parent device why dont you provide a device structure for it along with
register and unregister functions? Also each device should IMHO show up
in sysfs somehow, which should also be part of a register function.
There is already an existing driver (see net/dsa) that addresses the
representation of switch devices. What is wrong with that?

Regards,
Lino
