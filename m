From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Thu, 9 Aug 2007 09:49:57 +0530
Message-ID: <OF000FAFC5.C9245715-ON65257332.0016D216-65257332.0017CCB2@in.ibm.com>
References: <20070808.150137.50597736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, netdev@vger.kernel.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808.150137.50597736.davem@davemloft.net>
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

Hi Dave,

David Miller <davem@davemloft.net> wrote on 08/09/2007 03:31:37 AM:

> > What do you generally think of the patch/implementation ? :)
>
> We have two driver implementation paths on recieve and now
> we'll have two on send, and that's not a good trend.

Correct.

> In an ideal world all the drivers would be NAPI and netif_rx()
> would only be used by tunneling drivers and similar in the
> protocol layers.  And likewise all sends would go through
> ->hard_start_xmit().
>
> If you can come up with a long term strategy that gets rid of
> the special transmit method, that'd be great.
>
> We should make Linux network drivers easy to write, not more difficult
> by constantly adding most interfaces than we consolidate.

I think that is a good top level view, and I agree with that.

Patrick had suggested calling dev_hard_start_xmit() instead of
conditionally calling the new API and to remove the new API
entirely. The driver determines whether batching is required or
not depending on (skb==NULL) or not. Would that approach be fine
with this "single interface" goal ?

Thanks,

- KK
