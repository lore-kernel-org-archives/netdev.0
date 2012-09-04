From: Jonathan Morton <chromatix99@gmail.com>
Subject: Re: [RFC v2] fq_codel : interval servo on hosts
Date: Tue, 4 Sep 2012 18:25:18 +0300
Message-ID: <1C18E243-42BC-46F0-A336-EAD9BC881C45@gmail.com>
References: <1346396137.2586.301.camel@edumazet-glaptop>
	<1346421031.2591.34.camel@edumazet-glaptop>
	<1346421466.2591.38.camel@edumazet-glaptop>
	<CAK6E8=cwpq0MVK6fcrOa=wTX237xQiVP2xzh0aX-AtuSmzt-sw@mail.gmail.com>
	<1346503884.7996.65.camel@edumazet-glaptop>
	<CAB_+Fg5xPRqEZNdH0mYogmm4LitMvycSLB-X1_7ryn4RY9FvSA@mail.gmail.com>
Mime-Version: 1.0 (iPhone Mail 8C148)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
	Tomas Hruby <thruby@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <CAB_+Fg5xPRqEZNdH0mYogmm4LitMvycSLB-X1_7ryn4RY9FvSA@mail.gmail.com>
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

I think that in most cases, a long RTT flow and a short RTT flow on the same interface means that the long RTT flow isn't bottlenecked here, and therefore won't ever build up a significant queue - and that means you would want to track over the shorter interval. Is that a reasonable assumption?

The key to knowledge is not to rely on others to teach you it. 

On 4 Sep 2012, at 18:10, Nandita Dukkipati <nanditad@google.com> wrote:

> The idea of using srtt as interval makes sense to me if alongside we
> also hash flows with similar RTTs into same bucket. But with just the
> change in interval, I am not sure how codel is expected to behave.
> 
> My understanding is: the interval (usually set to worst case expected
> RTT) is used to measure the standing queue or the "bad" queue. Suppose
> 1ms and 100ms RTT flows get hashed to same bucket, then the interval
> with this patch will flip flop between 1ms and 100ms. How is this
> expected to measure a standing queue? In fact I think the 1ms flow may
> land up measuring the burstiness or the "good" queue created by the
> long RTT flows, and this isn't desirable.
> 
> 
> On Sat, Sep 1, 2012 at 5:51 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2012-08-31 at 18:37 -0700, Yuchung Cheng wrote:
>> 
>>> Just curious: tp->srtt is a very rough estimator, e.g., Delayed-ACks
>>> can easily add 40 - 200ms fuzziness. Will this affect short flows?
>> 
>> Good point
>> 
>> Delayed acks shouldnt matter, because they happen when flow had been
>> idle for a while.
>> 
>> I guess we should clamp the srtt to the default interval
>> 
>> if (srtt)
>>        q->cparams.interval = min(tcp_srtt_to_codel(srtt),
>>                                  q->default_interval);
>> 
>> 
>> 
> _______________________________________________
> Codel mailing list
> Codel@lists.bufferbloat.net
> https://lists.bufferbloat.net/listinfo/codel
