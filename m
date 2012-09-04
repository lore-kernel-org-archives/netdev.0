From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC v2] fq_codel : interval servo on hosts
Date: Tue, 04 Sep 2012 17:39:09 +0200
Message-ID: <1346773149.13121.44.camel@edumazet-glaptop>
References: <1346396137.2586.301.camel@edumazet-glaptop>
	<1346421031.2591.34.camel@edumazet-glaptop>
	<1346421466.2591.38.camel@edumazet-glaptop>
	<CAK6E8=cwpq0MVK6fcrOa=wTX237xQiVP2xzh0aX-AtuSmzt-sw@mail.gmail.com>
	<1346503884.7996.65.camel@edumazet-glaptop>
	<CAB_+Fg5xPRqEZNdH0mYogmm4LitMvycSLB-X1_7ryn4RY9FvSA@mail.gmail.com>
	<1C18E243-42BC-46F0-A336-EAD9BC881C45@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>, netdev <netdev@vger.kernel.org>,
	"codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
	Tomas Hruby <thruby@google.com>
To: Jonathan Morton <chromatix99@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1C18E243-42BC-46F0-A336-EAD9BC881C45@gmail.com>
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

On Tue, 2012-09-04 at 18:25 +0300, Jonathan Morton wrote:
> I think that in most cases, a long RTT flow and a short RTT flow on
> the same interface means that the long RTT flow isn't bottlenecked
> here, and therefore won't ever build up a significant queue - and that
> means you would want to track over the shorter interval. Is that a
> reasonable assumption?
> 

This would be reasonable, but if we have a shorter interval, this means
we could drop packets of the long RTT flow sooner than expected.

Thats because the drop_next value is setup on the previous packet, and
not based on the 'next packet'

Re-evaluating drop_next at the right time would need more cpu cycles.
