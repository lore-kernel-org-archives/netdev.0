From: David Miller <davem@davemloft.net>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Tue, 09 Oct 2007 14:22:35 -0700 (PDT)
Message-ID: <20071009.142235.74385364.davem@davemloft.net>
References: <p73k5pw44ew.fsf@bingen.suse.de>
	<20071009.134331.35664207.davem@davemloft.net>
	<20071009135340.33e5922c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, jeff@garzik.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, andi@firstfloor.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, randy.dunlap@oracle.com, jagana@us.ibm.com,
	kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: shemminger@linux-foundation.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071009135340.33e5922c@freepuppy.rosehill>
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

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 9 Oct 2007 13:53:40 -0700

> I was thinking why not have a default transmit queue len of 0 like
> the virtual devices.

I'm not so sure.

Even if the device has "huge queues" I still think we need a software
queue for when the hardware one backs up.

It is even beneficial to stick with reasonably sized TX queues because
it keeps the total resident state accessed by the CPU within the
bounds of the L2 cache.  If you go past that it actually hurts to make
the TX queue larger instead of helps even if it means you never hit
back pressure.
