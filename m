From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2] fq_codel : interval servo on hosts
Date: Sat, 01 Sep 2012 05:51:24 -0700
Message-ID: <1346503884.7996.65.camel@edumazet-glaptop>
References: <1346396137.2586.301.camel@edumazet-glaptop>
	<1346421031.2591.34.camel@edumazet-glaptop>
	<1346421466.2591.38.camel@edumazet-glaptop>
	<CAK6E8=cwpq0MVK6fcrOa=wTX237xQiVP2xzh0aX-AtuSmzt-sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tomas Hruby <thruby@google.com>, Nandita Dukkipati <nanditad@google.com>,
	netdev <netdev@vger.kernel.org>, codel@lists.bufferbloat.net
To: Yuchung Cheng <ycheng@google.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAK6E8=cwpq0MVK6fcrOa=wTX237xQiVP2xzh0aX-AtuSmzt-sw@mail.gmail.com>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

On Fri, 2012-08-31 at 18:37 -0700, Yuchung Cheng wrote:

> Just curious: tp->srtt is a very rough estimator, e.g., Delayed-ACks
> can easily add 40 - 200ms fuzziness. Will this affect short flows?

Good point

Delayed acks shouldnt matter, because they happen when flow had been
idle for a while.

I guess we should clamp the srtt to the default interval

if (srtt)
	q->cparams.interval = min(tcp_srtt_to_codel(srtt),
				  q->default_interval);
