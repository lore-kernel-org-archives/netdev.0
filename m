From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: bluetooth-2.6 2010-09-27
Date: Thu, 30 Sep 2010 17:26:57 -0700 (PDT)
Message-ID: <20100930.172657.123994559.davem@davemloft.net>
References: <20100928023035.GA3033@vigoh>
	<20100927.200016.226762808.davem@davemloft.net>
	<20100928224941.GA19409@vigoh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100928224941.GA19409@vigoh>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Date: Tue, 28 Sep 2010 19:49:41 -0300

> Actually sk_stream_wait_memory is another point why it's safe to release
> the lock and block waiting for memory. We've been doing that safely in
> protocols like TCP, SCTP and DCCP for a long time.

Do you notice what TCP does when sk_stream_wait_memory() returns?

It reloads all volatile state that might have changed in the socket
while the lock was dropped.

For example, TCP will reload the current MSS that can change
asynchronously while we don't have the socket lock.
