From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: many outgoing tcp sockets are slower than a few
Date: Mon, 21 Feb 2005 20:10:36 +0100
Message-ID: <421A322C.6020302@rapidforum.com>
References: <421925DB.2060602@rapidforum.com> <42192AAF.8020609@us.ibm.com> <42192CD5.5090401@rapidforum.com> <20050221090121.GA7478@outpost.ds9a.nl> <4219B99E.1000603@rapidforum.com> <20050221120223.GA30348@xi.wantstofly.org> <421A179C.1030505@rapidforum.com> <20050221172458.GA21715@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
        Nivedita Singhvi <niv@us.ibm.com>, netdev@oss.sgi.com
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20050221172458.GA21715@outpost.ds9a.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> On Mon, Feb 21, 2005 at 06:17:16PM +0100, Christian Schmid wrote:
> 
> 
>>Because thats the first I excluded. I changed the program by replacing 
>>sendfile with a caching-routine plus syswrite. And it was really 
>>interesting that the syswrite was the one which needs most of the 
>>real-time, not the caching-routine. syswrite blocked 100 ms per socket.
> 
> 
> Do you poll/select for socket readiness before doing write() with EAGAIN?
> (shouldn't matter all that much, but could narrow down debugging)

Yes. Using the IO::Poll in Perl.

> 100ms is a bit of an odd number - how big is your write (in bytes)?

Its an estimation. Its a non-blocking write with sendfile() so it writes around 90 KB if the buffer 
is set to 128 KB. It writes not the full because POLLOUT comes active before all is empty on the queue.

> Do you have 3500 threads or processes, or one big one?

Tried several types. 2 processes with 2000 connections each and 6 processes with 500 connections 
each. Both versions slow down if the system-wide socket-count goes over 3500.

> What does 'id' say in vmstat 1 typically, both below and above 3500 sockets?

(s02) [19:51:33] root:~# vmstat 1
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
  2  2      0   8196  27192 7994020    0    0  2383   275 1540   650 16 19 41 24
  0  3      0  12888  27172 7989144    0    0 36872     0 6542  2501 14 20 37 28
  1  2      0   8004  27248 7993828    0    0 34988   448 6876  2270 13 19 38 31
  0  2      0  17928  27280 7984208    0    0 30660     0 6571  2999 15 20 36 30
  3  2      0   9480  27316 7991108    0    0 37168     0 6349  2476 16 22 33 29
  2  1      0   9244  27360 7992492    0    0 37616     0 6397  2934 16 23 33 28
  0  2      0   8988  27332 7991840    0    0 36628     0 6187  3010 17 21 34 28
  3  1      0   9400  27484 7989648    0    0 35556  5708 6072  2696 18 28 27 27
