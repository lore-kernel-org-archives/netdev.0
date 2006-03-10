From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and IPoIB performance degradation
Date: Thu, 09 Mar 2006 23:23:01 -0800 (PST)
Message-ID: <20060309.232301.77550306.davem@davemloft.net>
References: <20060308125311.GE17618@mellanox.co.il>
	<20060309.154819.104282952.davem@davemloft.net>
	<4410C671.2050300@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rick.jones2@hp.com
In-Reply-To: <4410C671.2050300@hp.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 09 Mar 2006 16:21:05 -0800

> well, there are stacks which do "stretch acks" (after a fashion) that 
> make sure when they see packet loss to "do the right thing" wrt sending 
> enough acks to allow cwnds to open again in a timely fashion.

Once a loss happens, it's too late to stop doing the stretch ACKs, the
damage is done already.  It is going to take you at least one
extra RTT to recover from the loss compared to if you were not doing
stretch ACKs.

You have to keep giving consistent well spaced ACKs back to the
receiver in order to recover from loss optimally.

The ACK every 2 full sized frames behavior of TCP is absolutely
essential.
