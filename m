From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Cannot communicate with brX when its
 MAC address is changed
Date: Thu, 01 Dec 2011 13:02:50 -0500 (EST)
Message-ID: <20111201.130250.796100558647164266.davem@davemloft.net>
References: <4ED5E9D6.3070404@jp.fujitsu.com>
	<20111201092106.00473fed@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sanagi.koki@jp.fujitsu.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, shemminger@linux-foundation.org
To: shemminger@vyatta.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20111201092106.00473fed@nehalam.linuxnetplumber.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 1 Dec 2011 09:21:06 -0800

> Looked into using fdb to handle this, but then there would be fdb entries
> where the destination port entry was either NULL (or a dummy), and that
> would require a bunch of auditing of all usages and could introduce new
> bugs.
> 
> I am testing a patch that does same thing by moving compare_ether up
> to where broadcast is tested.

Stephen please fix this bug correctly.

The bug is that the FDB gets updated with the initial MAC address, but
doesn't get updated when the MAC address changes.

There is no other valid fix than to update the FDB when the MAC changes,
and making whatever is necessary for that to work.

I'm not applying a patch that adds a MAC address comparison here, because
you might was well not add the FDB entry in the first place if you're
going to add a hack like that.
