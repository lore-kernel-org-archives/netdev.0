From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 05/10] sch_generic.c changes.
Date: Fri, 20 Jul 2007 13:24:01 +0200
Message-ID: <46A09B51.6030301@trash.net>
References: <OF9D893096.26B48226-ON6525731E.003999A1-6525731E.0039ED23@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <OF9D893096.26B48226-ON6525731E.003999A1-6525731E.0039ED23@in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Krishna Kumar2 wrote:
> Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 03:41:01 PM:
>   
>>> -static inline int qdisc_restart(struct net_device *dev)
>>> +static inline int qdisc_restart(struct net_device *dev,
>>> +            struct sk_buff_head *blist)
>>>  {
>>>     struct Qdisc *q = dev->qdisc;
>>>     struct sk_buff *skb;
>>> -   unsigned lockless;
>>> +   unsigned getlock;      /* whether we need to get lock or not */
>>>       
>> Unrelated rename, please get rid of this to reduce the noise.
>>     
>
> OK, I guess I should have sent that change earlier :) The reason to change
> the name is to avoid (double-negative) checks like :
>
>       if (!lockless)
> to
>       if (getlock).
>
> I will remove these changes.
>   

I guess you could put it in another patch. But frankly, I think
the biggest uglyness is the conditional locking, not naming or
double negation, so it won't really make the code any nicer :)
