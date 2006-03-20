From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 10:58:25 -0800
Message-ID: <441EFB51.70102@hp.com>
References: <20060320090629.GA11352@mellanox.co.il>	<20060320.015500.72136710.davem@davemloft.net>	<20060320102234.GV29929@mellanox.co.il>	<20060320.023704.70907203.davem@davemloft.net>	<20060320112753.GX29929@mellanox.co.il>	<1142855223.3114.30.camel@laptopd505.fenrus.org>	<20060320114933.GA3058@xi.wantstofly.org>	<20060320120407.GY29929@mellanox.co.il>
	<20060320150941.GD16108@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Arjan van de Ven <arjan@infradead.org>
Return-path: <openib-general-bounces@openib.org>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060320150941.GD16108@kvack.org>
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

> Wouldn't it make sense to strech the ACK when the previous ACK is still in 
> the TX queue of the device?  I know that sort of behaviour was always an 
> issue on modem links where you don't want to send out redundant ACKs.

Perhaps, but it isn't clear that it would be worth the cycles to check. 
    I doubt that a simple reference count on the ACK skb would do it 
since if it were a bare ACK I doubt that TCP keeps a reference to the 
skb in the first place?

Also, what would be the "trigger" to send the next ACK after the 
previous one had left the building (Elvis-like)?  Receipt of N in-order 
segments?  A timeout?

If you are going to go ahead and try to do stretch-ACKs, then I suspect 
the way to go about doing it is to have it behave very much like HP-UX 
or Solaris, both of which have arguably reasonable ACK-avoidance 
heuristics in them.

But don't try to do it quick and dirty.

rick "likes ACK avoidance, just check the archives" jones
on netdev, no need to cc me directly
