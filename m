From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: truesize for pages shared between SKBs
Date: Tue, 02 Sep 2014 14:20:40 +0200
Message-ID: <1409660440.1808.17.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ido Yariv <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>, Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

In our driver, we have 4k receive buffers, but usually ~1500 byte
packets.

How do other drivers handle this? We currently set up the truesize of
each SKB to be its size plus the 4k page size, but we see performance
improvements when we lie and pretend the truesize is just 4k/(# of
packets in the page), which is correct as long as the packets are all
pending in the stack since they share the page.

How do other drivers handle this? Should the truesize maybe be aware of
this kind of sharing? Should we just lie about it and risk that the
truesize is accounted erroneously if some but not all of the packets are
freed?

Thanks,
johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
