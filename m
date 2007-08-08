From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 2/9 Rev3] [core] Add skb_blist &
	hard_start_xmit_batch
Date: Wed, 8 Aug 2007 16:54:34 +0530
Message-ID: <OF7D1FEAF4.C4EEC93F-ON65257331.003D1B34-65257331.003EACA3@in.ibm.com>
References: <20070808065946.6c80c470@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	sri@us.ibm.com, davem@davemloft.net, rdreier@cisco.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808065946.6c80c470@oldman>
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

Stephen Hemminger <shemminger@linux-foundation.org> wrote on 08/08/2007
04:29:46 PM:

> How do qdisc's that do rate control work now? Did you add logic to
> breakup batches for token bucket, etc.

My thought was that the code works identically to the current code except
in requeue cases. For requeue the existing code sched decides which skb
to pass next (first) to device; while in batching case it is assumed that
skbs already in batch list are part of the hardware queue and sent first.

If that is a problem - at the time of enabling batching it is possible
to check what qdisc_ops is being used (or whenever the qdisc's change),
or maybe add a flag to each qdisc_ops to indicate whether qdisc supports
batching, etc ? Like definitely enable batching if using pfifo_fast_ops..

What is your suggestion ?

thanks,

- KK
