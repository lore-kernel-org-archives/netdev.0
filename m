From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 3 Feb 2005 11:33:35 -0800
Message-ID: <20050203113335.46396c11@dxpl.pdx.osdl.net>
References: <4201A382.1020208@rapidforum.com>
	<20050202205437.571a702b@localhost.localdomain>
	<4201B4EA.2030101@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <4201B4EA.2030101@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Feb 2005 06:21:46 +0100
Christian Schmid <webmaster@rapidforum.com> wrote:

> Actually, thats my problem. Single streams are too slow! Before I had buffers up to 500 KB. This was 
> very nice to CPU because I only needed to "push" more data once in 5 seconds. I am doing this every 
> second now... *sigh* well maybe you might just want to add a /proc file in order to configure this 
> behaviour.
> 
> btw: Another problem I am experiencing is that downloads suddenly break in speed from 360 kb/sec to 
> 8-12 kb/sec. 5 seconds later they stall completely. But the interesting part is, that the send-queue 
> is completely full (checked with a grep in netstat). This looks like as if the receiver is just too 
> slow. But this is not the case. That makes it rather funny. The receiver is waiting with an empty 
> pipe but linux doesn't send. What could this be?
>

Are you using a board that support TCP Segmentation Offload.  The problem may well be that
before we were not doing congestion control properly with TSO.  A pre-2.6.8 host with TSO was violating
all sorts of RFC's and unfairly monopolizing bandwidth.

-- 
Stephen Hemminger	<shemminger@osdl.org>
