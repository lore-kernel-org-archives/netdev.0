From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 06/10] bridge: introduce fdb offloading via
 switchdev
Date: Sun, 09 Nov 2014 22:47:48 -0500
Message-ID: <54603564.3070606@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:51076 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbaKJDry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:47:54 -0500
Received: by mail-ie0-f170.google.com with SMTP id tp5so8574869ieb.15
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:47:53 -0800 (PST)
In-Reply-To: <1415530280-9190-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/14 05:51, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add two new ndos: ndo_sw_port_fdb_add/del to offload static bridge
> fdb entries.  Static bridge FDB entries are installed, for example,
> using iproute2 bridge cmd:
>
>         bridge fdb add ADDR dev DEV master vlan VID
>
> This would install ADDR into the bridge's FDB for port DEV on vlan VID.  The
> switch driver implements two ndo_swdev ops to add/delete FDB entries in the
> switch device:
>
>         int ndo_sw_port_fdb_add(struct net_device *dev,
>                                 const unsigned char *addr,
>                                 u16 vid);
>
>         int ndo_sw_port_fdb_del(struct net_device *dev,
>                                 const unsigned char *addr,
>                                 u16 vid);
>
> The driver returns 0 on success, negative error code on failure.
>
> Note: the switch driver would not implement ndo_fdb_add/del/dump on a port
> netdev as these are intended for devices maintaining their own FDB.  In our
> case, we want the Linux bridge to own the FBD.
>
> Note: by default, the bridge does not filter on VLAN and only bridges untagged
> traffic.  To enable VLAN support, turn on VLAN filtering:
>
>        echo 1 >/sys/class/net/<bridge>/bridge/vlan_filtering
>

Sorry - why is the current fdb_add/del insufficient? It needs a vlanid
and the master/self flags should indicate intent to add to h/w vs s/w.

cheers,
jamal
