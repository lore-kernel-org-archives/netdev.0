From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/11]  use ether_addr_equal_64bits
Date: Fri, 17 Jan 2014 13:18:35 +0300
Message-ID: <20140117101835.GQ7444@mwanda>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
 <1388427307-8691-5-git-send-email-Julia.Lawall@lip6.fr>
 <1388429761.4410.1.camel@jlt4.sipsolutions.net>
 <alpine.DEB.2.02.1312302057420.2209@localhost6.localdomain6>
 <1388438724.4573.2.camel@jlt4.sipsolutions.net>
 <20131230215701.GA4938@khazad-dum.debian.net>
 <1388445188.18164.0.camel@jlt4.sipsolutions.net>
 <20140106104802.GN30234@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Henrique de Moraes Holschuh <hmh-N3TV7GIv+o9fyO9Q7EP/yw@public.gmane.org>,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140106104802.GN30234@mwanda>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We're worried about reading beyond the end of the array and it's a heap
allocation and the last char of the eth addr is the last byte of the
page.  This causes an oops.

It's almost impossible to hit that bug.

1) You would have to have the eth addr at the end of the array.
2) It would have to be a packed struct.
3) The struct size would have to be a multiple of 4 because otherwise we
   can't put it at the end of the page.
4) It would need to be allocated on the heap.

You add all those up which is pretty rare so I wasn't able to find
anything like that.  Then you have to get extremely unlucky.

The closest thing I could find were a couple places like like:

static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };

It meets criteria 1 and 2 but not 3 and 4.

regards,
dan carpenter

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
