From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 07 Mar 2006 16:18:08 -0800 (PST)
Message-ID: <20060307.161808.60227862.davem@davemloft.net>
References: <1141767891.6119.903.camel@localhost>
	<20060307134907.733d3d27@localhost.localdomain>
	<1141776697.6119.938.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org, shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: mlleinin@hpcn.ca.sandia.gov
In-Reply-To: <1141776697.6119.938.camel@localhost>
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

From: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Date: Tue, 07 Mar 2006 16:11:37 -0800

>   I used the standard setting for tcp_rmem and tcp_wmem.   Here are a
> few other runs that change those variables.  I was able to improve
> performance by ~30MB/s to 403 MB/s, but this is still a ways from the
> 474 MB/s before the TSO patches.

How limited are the IPoIB devices, TX descriptor wise?

One side effect of the TSO changes is that one extra descriptor
will be used for outgoing packets.  This is because we have to
put the headers as well as the user data, into page based
buffers now.

Perhaps you can experiment with increasing the transmit descriptor
table size, if that's possible.
