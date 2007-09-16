From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 0/10 REV5] Implement skb batching and
 support in IPoIB/E1000
Date: Sun, 16 Sep 2007 16:17:48 -0700 (PDT)
Message-ID: <20070916.161748.48388692.davem@davemloft.net>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	kumarkr@linux.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	netdev@vger.kernel.org, rdreier@cisco.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: krkumar2@in.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
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

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Fri, 14 Sep 2007 14:30:58 +0530

> This set of patches implements the batching xmit capability, and
> adds support for batching in IPoIB and E1000 (E1000 driver changes
> is ported, thanks to changes taken from Jamal's code from an old
> kernel).

The only major complaint I have about this patch series is that
the IPoIB part should just be one big changeset.  Otherwise the
tree is not bisectable, for example the initial ipoib header file
change breaks the build.

The tree must compile and work properly after every single patch.

On a lower priority, I question the indirection of skb_blist by making
it a pointer.  For what?  Saving 12 bytes on 64-bit?  That kmalloc()'d
thing is a nearly guarenteed cache and/or TLB miss.  Just inline the
thing, we generally don't do crap like this anywhere else.
