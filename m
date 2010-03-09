From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: tcp_recvmesg hang under NET_DMA
Date: Tue, 09 Mar 2010 14:44:59 -0600
Message-ID: <1268167499.2985.32.camel@iscandar.digidescorp.com>
Reply-To: steve@digidescorp.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I've run into a case where using NET_DMA seems to cause a PUT to a
modified ftpd to hang. AFAICT this is because the NET_DMA design queues
up lots of memcpy operations, but doesn't issue or wait for them (and
thus free the associated skbs) until it is time for tcp_recvmesg() to
return. In a case where userland requests a large read (as is the case
in my modified ftpd), packet transfer can grind to a halt because so
many packets are buffered up and there is no event that causes them to
be freed.

I can submit a patch that would issue pending memcpys and clean up
completed ones around tcp_recvmsg's call to sk_wait_data(), but first I
wanted to understand the design better. Were there specific reasons for
deferring the async operations so long?

Thanks,
------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>
