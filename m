From: Rick Jones <rick.jones2-VXdhtT5mjnY@public.gmane.org>
Subject: Re: Ideas on why using WPA2 encryption speeds up many TCP connections?
Date: Thu, 03 Oct 2013 11:50:59 -0700
Message-ID: <524DBC93.1070400@hp.com>
References: <524DB6F6.6020405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <524DB6F6.6020405-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/03/2013 11:27 AM, Ben Greear wrote:
> I'm seeing something a bit strange and wondering if anyone had an
> opinion on why...
>
> I am testing up to 200 wifi station systems, each with a TCP connection
> running on them (download only, from VAP to stations).
>
> Without encryption (ie, open network), I see total throughput go from
> about 108Mbps down to 69Mbps as I add more stations (I add 25 at a time,
> so the 108Mbps is with 25 active, and 69Mbps is with 200 active).
>
> However, if I enable encryption, the throughput is actually higher
> (111Mbps to 71Mbps).  I'm doing encryption in software, so it adds a fair
> bit of CPU load in this test.  The numbers bounce around since this is
> wifi after all, but in general encryption tends to win reliably in this
> test.
>
> When testing with a single station (and 5 tcp streams with jacked up
> snd/rcv buffers) the open networks perform significantly better at total throughput:
> 263Mbps vs 246Mbps.
>
> Maybe the extra delay for decryption increases odds that GRO will take
> affect for the many, slower streams (and maybe that will decrease ACK
> traffic?)
>
> Any other ideas?

Fewer times two or more stations step on one another?  The recievers 
will only try to transmit when they receive data.  Modulo timing, if the 
individual downloads are a bit slower, less chance of the receivers 
looking to send ACKs back through at the same time?  Got any low-level 
stats for the health and well being of the wireless network?

rick jones

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
