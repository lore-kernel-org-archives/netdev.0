From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: Bug-hunting
Date: Thu, 24 Feb 2005 13:29:53 +0100
Message-ID: <421DC8C1.60704@rapidforum.com>
References: <421B4AB7.9030003@rapidforum.com> <20050222104448.31373a99.davem@davemloft.net> <421B8563.9030608@rapidforum.com> <20050222115114.0d0e568e.davem@davemloft.net> <421BBE7B.1050009@rapidforum.com> <20050222193000.404ae6d2.davem@davemloft.net> <421C5AC8.70601@rapidforum.com> <20050223112927.349550d0.davem@davemloft.net> <421CDD95.2020108@rapidforum.com> <Pine.LNX.4.58.0502231453260.28189@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0502231453260.28189@dexter.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More track-downs:

I have watched /proc/net/netstat and it didnt change. I experimented more with vm-parameters as I 
have understood that Linux is complex enough that bugs aren't obvious enough to simply say its the 
net-code just because a non-blocking socket suddenly blocks.

I found out that changing /proc/sys/vm/min_free_kbytes gives the most drastic differences. I changed 
it to 1024000 and it suddenly speeded up drastically. I changed back to around 16000 and it suddenly 
slowed down immediately. Changed back to 1024000 and it speeded up immediately. Does someone know 
more about this? What does this parameter do? I watched /proc/meminfo but it didnt change anything 
really.MemFree is always around 10 MB:

MemTotal:      8314392 kB
MemFree:         10284 kB
Buffers:         25644 kB
Cached:        7724180 kB
SwapCached:          0 kB
Active:         991312 kB
Inactive:      6977476 kB
HighTotal:     6421952 kB
HighFree:          640 kB
LowTotal:      1892440 kB
LowFree:          9644 kB
SwapTotal:           0 kB
SwapFree:            0 kB
Dirty:          116272 kB
Writeback:           0 kB
Mapped:         223940 kB
Slab:           322652 kB
CommitLimit:   4157196 kB
Committed_AS:   794200 kB
PageTables:       1788 kB
VmallocTotal:   114680 kB
VmallocUsed:      1200 kB
VmallocChunk:   113392 kB


John Heffner wrote:
> Christian,
> 
> Try looking at /proc/net/netstat while running.  If TCPMemoryPressures is
> increasing, you are running out of TCP memory, and you would expect to see
> your socket buffers shrinking.
> 
>   -John
> 
> 
