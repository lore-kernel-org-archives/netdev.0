From: Thomas Graf <tgraf@suug.ch>
Subject: Re: af_packet.c bug?
Date: Mon, 28 Mar 2005 21:55:57 +0200
Message-ID: <20050328195557.GF3086@postel.suug.ch>
References: <424858D4.8060604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <424858D4.8060604@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ben Greear <424858D4.8060604@candelatech.com> 2005-03-28 11:19
> 
> What is the '13' doing here?  Maybe it should be IFNAMSIZ?
> 
> 	/*
> 	 *	Find the device first to size check it
> 	 */
> 
> 	saddr->spkt_device[13] = 0;
> 	dev = dev_get_by_name(saddr->spkt_device);
> 	err = -ENODEV;
> 	if (dev == NULL)
> 		goto out_unlock;

Seems so, please adopt the size of spkt_device in struct sockaddr_pkt
as well if you change it, it's currently hardcoded as 14.
