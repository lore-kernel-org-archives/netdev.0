From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 1/4] net: add name_assign_type netdev attribute
Date: Mon, 17 Mar 2014 17:12:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DF74F@AcuExch.aculab.com>
References: <1394990490-1076-2-git-send-email-dh.herrmann@gmail.com>
 <1395075825-5824-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: 'David Herrmann' <dh.herrmann@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395075825-5824-1-git-send-email-dh.herrmann@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Herrmann
> The name_assign_type attribute gives hints where the interface name of a
> given net-device comes from. Three different values are currently defined:
>   NET_NAME_ENUM:
>     This is the default. The ifname is provided by the kernel with an
>     enumerated suffix. Names may be reused and unstable.
>   NET_NAME_USER:
>     The ifname was provided by user-space during net-device setup.
>   NET_NAME_RENAMED:
>     The net-device has been renamed via RTNL. Once this type is set, it
>     cannot change again.
...
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index b8d8c80..6698e87 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1248,6 +1248,7 @@ struct net_device {
>  	 * of the interface.
>  	 */
>  	char			name[IFNAMSIZ];
> +	unsigned char		name_assign_type; /* name assignment type */
> 
>  	/* device name hash chain, please keep it close to name[] */
>  	struct hlist_node	name_hlist;

Do you really need to add 7 byte of padding here?
There seems to be some padding lurking elsewhere that really ought
to be mergable.

	David
