From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: fix TCP roundtrip time update code
Date: Tue, 03 Jun 2003 23:04:02 -0700
Sender: linux-ia64-admin@linuxia64.org
Message-ID: <3EDD8BD2.9040008@us.ibm.com>
References: <200306040043.EAA24505@dub.inr.ac.ru>	<3EDD52F5.8090706@us.ibm.com>	<20030603.202320.59680883.davem@redhat.com>	<16093.30507.661714.676184@napali.hpl.hp.com>	<3EDD7832.7010804@us.ibm.com> <16093.34022.445246.52398@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   jmorris@intercode.com.au, gandalf@wlug.westbo.se,
   linux-kernel@vger.kernel.org, linux-ia64@linuxia64.org, netdev@oss.sgi.com,
   akpm@digeo.com
Return-path: <linux-ia64-admin@linuxia64.org>
To: davidm@hpl.hp.com
In-Reply-To: <16093.34022.445246.52398@napali.hpl.hp.com>
Errors-To: linux-ia64-admin@linuxia64.org
List-Help: <mailto:linux-ia64-request@linuxia64.org?subject=help>
List-Post: <mailto:linux-ia64@linuxia64.org>
List-Subscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=subscribe>
List-Unsubscribe: <http://lists.linuxia64.org/lists/listinfo/linux-ia64>,
	<mailto:linux-ia64-request@linuxia64.org?subject=unsubscribe>
List-Archive: <http://lists.linuxia64.org/archives//linux-ia64/>
List-Id: netdev.vger.kernel.org

David Mosberger wrote:

>  $ httperf --rate 1000 --num-conns 1000000 --verbose --hog --server HOST \
> 	--uri pathto30KBfile

Hmm, ditto, except I was way down at --rate 300 (was seeing client
errors of fd-unavail). Have ulimited upwards but am still seeing
them..

> on 3 clients (for a total of 3000 conns/sec).  You can't go higher
> than 1000 conn/sec per client (IP address) because otherwise you run
> out of port space (due to TIME_WAIT).

You can hike /proc/sys/net/ipv4/tcp_tw_recycle for that.

> This load worked well for a machine with a single GigE card.  All
> network tunables were on the default setting (in particular, the tx
> queue len was 300, which is were the losses came from).
> 
> With this load, I saw bad RTT values in the route cache within a
> couple of seconds after starting the third httperf generator.  It then
> took a bit longer (on the order of 1-2 minutes) until the first
> TCPAbortFailed errors started to pop up

I saw a few AbortOnTimeouts, but no AbortFailed counts.

Those should be TCPAbortOnTimeout counts, rather than TCPAbortFailed
errors, I would expect? Why AbortFailed?  Coming from IP via
tcp_transmit_skb()?

thanks,
Nivedita
