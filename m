From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] audit: Simplify by assuming the callers socket
	buffer is large enough
Date: Sat, 08 Mar 2014 01:34:51 -0500 (EST)
Message-ID: <20140308.013451.1713896236113364692.davem@davemloft.net>
References: <1394232722.17779.57.camel@flatline.rdu.redhat.com>
	<20140307.194801.1893514114998807038.davem@davemloft.net>
	<5147229.ivUnbSCGlH@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rgb@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, ebiederm@xmission.com,
        akpm@linux-foundation.org
To: sgrubb@redhat.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <5147229.ivUnbSCGlH@x2>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Steve Grubb <sgrubb@redhat.com>
Date: Fri, 07 Mar 2014 22:27:28 -0500

> On Friday, March 07, 2014 07:48:01 PM David Miller wrote:
>> From: Eric Paris <eparis@redhat.com>
>> Date: Fri, 07 Mar 2014 17:52:02 -0500
>> 
>> > Audit is non-tolerant to failure and loss.
>> 
>> Netlink is not a loss-less transport.
> 
> Perhaps. But in all our testing over the years its been very good.

What I really meant by that was that there is flow control.

You can push as much data reliably over it as you want, but you have
to block when the socket limits are hit.

And I'd say you might as well make the creator of the event do the
blocking rather than making other threads do this.
