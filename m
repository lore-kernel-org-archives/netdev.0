From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
 support in IPoIB
Date: Fri, 24 Aug 2007 14:25:03 -0700 (PDT)
Message-ID: <20070824.142503.30177455.davem@davemloft.net>
References: <46CE0BA1.60206@hp.com>
	<20070823231820.2ae52cc0.billfink@mindspring.com>
	<1187957657.4255.35.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, billfink@mindspring.com, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	johnpol@2ka.mipt.ru, shemminger@linux-foundation.org,
	kaber@trash.net, sri@us.ibm.com
To: hadi@cyberus.ca
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <1187957657.4255.35.camel@localhost>
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

From: jamal <hadi@cyberus.ca>
Date: Fri, 24 Aug 2007 08:14:16 -0400

> Seems the receive side of the sender is also consuming a lot more cpu
> i suspect because receiver is generating a lot more ACKs with TSO.

I've seen this behavior before on a low cpu powered receiver and the
issue is that batching too much actually hurts a receiver.

If the data packets were better spaced out, the receive would handle
the load better.

This is the thing the TOE guys keep talking about overcoming with
their packet pacing algorithms in their on-card TOE stack.

My hunch is that even if in the non-TSO case the TX packets were all
back to back in the cards TX ring, TSO still spits them out faster on
the wire.
