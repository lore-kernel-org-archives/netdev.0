From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix skb binding time in some network drivers due to skb_padto
 conversion
Date: Sun, 31 Aug 2003 09:25:12 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F51F738.5040607@pobox.com>
References: <3F515DD0.9000409@jcom.home.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Yusuf Wilajati Purna <purna@jcom.home.ne.jp>
In-Reply-To: <3F515DD0.9000409@jcom.home.ne.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yusuf Wilajati Purna wrote:
> Hi Jeff,
> 
> It seems that skb_padto security fixes in 2.4 and 2.5 trying
> to fix "CAN-2003-0001:Multiple ethernet NID device drivers
> do not pad frames with null bytes", do not put the skb_padto
> blocks in proper places in the  3c527, eth16i, fmv18x, seeq8005,
> yellowfin device drivers.   
> 
> In case a driver calls skb_padto(), it is possible
> that the space available in the original skb buffer tailroom is less
> than the space to pad. In this case, in short, the skb_padto()
> will create a new skb buffer, copy data from the original
> skb buffer to a new skb buffer, free the original buffer,
> and finally return the new buffer.
> 
> If this happens to the aforementioned device drivers, they come to
> point to wrong data. And, for 3c527 and yellowfin, the drivers can
> unexpectedly double free the original skb buffers since they still
> point to the original skb buffers. The attached patch against
> 2.4.23pre1 fixes these issues.
> 
> If the patch looks okay, please consider including it in
> 2.4 and 2.5/6.


Yes, this looks needed.  Thanks!

	Jeff
