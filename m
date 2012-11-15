From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix retransmission in repair mode
Date: Thu, 15 Nov 2012 17:45:46 -0500 (EST)
Message-ID: <20121115.174546.336072708541078221.davem@davemloft.net>
References: <1352988197-14414-1-git-send-email-avagin@openvz.org>
	<50A4F7F3.5080500@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@openvz.org, netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: xemul@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A4F7F3.5080500@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>
Date: Thu, 15 Nov 2012 18:10:59 +0400

> On 11/15/2012 06:03 PM, Andrey Vagin wrote:
>> From: Andrew Vagin <avagin@openvz.org>
>> 
>> Currently if a socket was repaired with a few packet in a write queue,
>> a kernel bug may be triggered:
>> 
>> kernel BUG at net/ipv4/tcp_output.c:2330!
>> RIP: 0010:[<ffffffff8155784f>] tcp_retransmit_skb+0x5ff/0x610
>> 
>> According to the initial realization v3.4-rc2-963-gc0e88ff,
>> all skb-s should look like already posted. This patch fixes code
>> according with this sentence.
>> 
>> Here are three points, which were not done in the initial patch:
>> 1. A tcp send head should not be changed
>> 2. Initialize TSO state of a skb
>> 3. Reset the retransmission time
>> 
>> This patch moves logic from tcp_sendmsg to tcp_write_xmit. A packet
>> passes the ussual way, but isn't sent to network. This patch solves
>> all described problems and handles tcp_sendpages.
 ...
>> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied and queued up for -stable, thanks.
