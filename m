From: "David S. Miller" <davem@davemloft.net>
Subject: Re: af_packet.c bug?
Date: Thu, 31 Mar 2005 20:59:48 -0800
Message-ID: <20050331205948.0a7477af.davem@davemloft.net>
References: <424858D4.8060604@candelatech.com>
	<20050328195557.GF3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050328195557.GF3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005 21:55:57 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> * Ben Greear <424858D4.8060604@candelatech.com> 2005-03-28 11:19
> > 
> > What is the '13' doing here?  Maybe it should be IFNAMSIZ?
> > 
> > 	/*
> > 	 *	Find the device first to size check it
> > 	 */
> > 
> > 	saddr->spkt_device[13] = 0;
> > 	dev = dev_get_by_name(saddr->spkt_device);
> > 	err = -ENODEV;
> > 	if (dev == NULL)
> > 		goto out_unlock;
> 
> Seems so, please adopt the size of spkt_device in struct sockaddr_pkt
> as well if you change it, it's currently hardcoded as 14.

No can do, that structure is exported to userspace.
Thus, changing it from 14 to IFNAMESZ (which is 16) will
break stuff.
