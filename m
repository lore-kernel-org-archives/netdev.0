From: Baruch Even <baruch@ev-en.org>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 13:59:19 +0000
Message-ID: <4219E937.6030108@ev-en.org>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl> <4219B99E.1000603@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bert hubert <ahu@ds9a.nl>, Nivedita Singhvi <niv@us.ibm.com>,
        netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
In-Reply-To: <4219B99E.1000603@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid wrote:
> bert hubert wrote:
> 
>> On Mon, Feb 21, 2005 at 01:35:33AM +0100, Christian Schmid wrote:
> Outgoing data. I am using sendfile() to send the file on a non-blocking 
> socket but the call blocks for 100 ms per socket if I get over 3000 
> sockets. Thats causing the massive slowdown in sum. I first thought its 
> a disk-issue but I tried with pure-cache data as well and it still blocks.
> 
>>> 3000 sockets = no slowdown at all (500 MBit in use)
>>> 3300 sockets = 10% slowdown
>>> 3600 sockets = 30% slowdown
>>> 4000 sockets = 60% slowdown (i aborted here, as it only uses 200 MBit 
>>> for sending... catastrophy!)
>>>
[snip]
>> I'm a bit confused, it is a download service so you are probably 
>> *sending*
>> data? 
> 
> Only sending. Receiving ACKs of course.

I've been doing some work to improve ACK performance, you can find some 
patches for Linux 2.6.6 at http://hamilton.ie/net/

I've only tested these patches for a single (or few) very fast 
connections, but I'd expect the problem might manifest itself for a very 
large number of connections as well. Though then you might hit other 
bottlenecks (memory access for different structures).

Baruch
