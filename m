From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: TCP-Protection is really a pain...
Date: Thu, 03 Feb 2005 06:21:46 +0100
Message-ID: <4201B4EA.2030101@rapidforum.com>
References: <4201A382.1020208@rapidforum.com> <20050202205437.571a702b@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050202205437.571a702b@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Actually, thats my problem. Single streams are too slow! Before I had buffers up to 500 KB. This was 
very nice to CPU because I only needed to "push" more data once in 5 seconds. I am doing this every 
second now... *sigh* well maybe you might just want to add a /proc file in order to configure this 
behaviour.

btw: Another problem I am experiencing is that downloads suddenly break in speed from 360 kb/sec to 
8-12 kb/sec. 5 seconds later they stall completely. But the interesting part is, that the send-queue 
is completely full (checked with a grep in netstat). This looks like as if the receiver is just too 
slow. But this is not the case. That makes it rather funny. The receiver is waiting with an empty 
pipe but linux doesn't send. What could this be?


Stephen Hemminger wrote:
> On Thu, 03 Feb 2005 05:07:30 +0100
> Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> 
>>Hi.
>>
>>Your new dynamically adjusted socket-buffer in 2.6.10 is really a pain for big servers. PLEASE tell 
>>me a way how to disable it.
> 
> 
> sysctl -w net.ipv4.tcp_wmem="4096 8192 16384"
> 
> Your single stream will be slower, but the memory footprint will be smaller.
> 
> 
