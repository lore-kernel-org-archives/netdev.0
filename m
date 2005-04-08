From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Fri, 08 Apr 2005 22:33:58 +0100
Message-ID: <4256F8C6.40704@ev-en.org>
References: <20050407164146.GA6479@ev-en.org> <20050407101653.2cc68db1@dxpl.pdx.osdl.net> <42557895.8040004@ev-en.org> <20050407113121.31b71a94.davem@davemloft.net> <Pine.LNX.4.58.0504071435450.17545@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
        netdev@oss.sgi.com, werner@almesberger.net
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0504071435450.17545@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> This test looks correct to me.  (We never touched it.)  It is the bounding
> parameter specified in rate halving.  If you actually get down that far,
> then rate halving is getting confused, though.

In my tests with either NewReno at high-BDP network settings
(300Kbit/s, 120ms delay, BDP = 3200 packets), we always go into this
confused mode.

It will always upon a drop go to a point between the one-half and 
one-quarter of the original cwnd, but then, due to performance problems 
at that point the queue is filled and lots of packets are getting lost 
in bursts after I disabled throttling, with throttling it goes even 
below one quarter.

If I understand you correctly this check (that I changed) is correct and 
should not be changed but rather that the bug is elsewhere. I'll give it 
another look when I have some more time.

Baruch
