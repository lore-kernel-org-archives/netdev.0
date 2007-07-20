From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 17:55:18 +0530
Message-ID: <OF5FB5DB1E.711307CE-ON6525731E.0043AC4C-6525731E.00443C1B@in.ibm.com>
References: <46A09A85.7020500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A09A85.7020500@trash.net>
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

Patrick McHardy <kaber@trash.net> wrote on 07/20/2007 04:50:37 PM:

> 32 bytes? I count 16, - 4 for the pointer, so its 12 bytes of waste.
> If you'd use it for gso_skb it would come down to 8 bytes. struct
> net_device is a pig already, and there are better ways to reduce this
> than starting to allocating single members with a few bytes IMO.

Currently, this allocated pointer is an indication to let kernel users
(qdisc_restart, setting/resetting tx_batch_skbs) know whether batching
is enabled or disabled. Removing the pointer and making it static means
those users cannot figure out this information . Adding another field to
netdev may be a bad idea, so I am thinking of overloading dev->features
to add a new flag (other than NETIF_F_BATCH_SKBS, since that is a driver
capabilities flag) which can be set/cleared based on NETIF_F_BATCH_SKBS
bit. Does this approach sound OK ?

Thanks,

- KK
