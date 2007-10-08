From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCHES] TX batching
Date: Mon, 8 Oct 2007 16:51:25 +0400
Message-ID: <20071008125125.GA31456@2ka.mipt.ru>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070916.161748.48388692.davem@davemloft.net>
	<1189988958.4230.55.camel@localhost>
	<1190569987.4256.52.camel@localhost>
	<1191782093.4394.60.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, peter.p.waskiewicz.jr@intel.com, kumarkr@linux.ibm.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, mcarlson@broadcom.com,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <1191782093.4394.60.camel@localhost>
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

Hi Jamal.

On Sun, Oct 07, 2007 at 02:34:53PM -0400, jamal (hadi@cyberus.ca) wrote:
> 
> Please provide feedback on the code and/or architecture.
> Last time i posted them i received little. They are now updated to 
> work with the latest net-2.6.24 from a few hours ago.
> 
> Patch 1: Introduces batching interface
> Patch 2: Core uses batching interface
> Patch 3: get rid of dev->gso_skb

it looks like you and Krishna use the same requeueing methods - get one
from qdisk, queue it into blist, get next from qdisk, queue it,
eventually start transmit, where you dequeue it one-by-one and send (or
prepare and commit). This is not the 100% optimal approach, but if you
proved it does not hurt usual network processing, it is ok.
Number of comments dusted to very small - that's a sign, but I'm a bit
lost - did you and Krishna create the competing approaches, or they can
co-exist together, in the former case I doubt you can push, until all
problematic places are resolved, in the latter case, this is probably
ready.

-- 
	Evgeniy Polyakov
