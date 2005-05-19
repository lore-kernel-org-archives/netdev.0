From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Thu, 19 May 2005 13:43:03 -0700
Message-ID: <428CFA57.1020501@us.ibm.com>
References: <E1DYayB-0005Sk-00@gondolin.me.apana.org.au>	<428CAC55.4000202@us.ibm.com> <20050519.115141.21926463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050519.115141.21926463.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> I think instead we should look at ways to propagate
> the hardware device features to the bridge.  Even if
> a bridge is composed of multiple devices, we just
> advertise the subset of features actually supported.

Just for some background:

In the typical Xen virtual environment, the primary
interface is typically bridged with virtual interfaces
that talk to other partitions.

Since currently the bridge doesn't advertise them,
this results in the loss of hw checksum offload,
segmentation offload, and sendfile exploitation
(sendfile() falls down to the usual tcp_sendmsg()
case) etc on the primary partition traffic talking
to remote hosts.

This can be rather painful, and performance comparisons
with other OSs which don't do this are even more of
an apples to oranges comparison since this is
somewhat silently happening.

Hence the need for enhancing the bridging environment
somewhat :).

thanks,
Nivedita
