From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6]: keep fragment queues private to each user
Date: Tue, 25 Jan 2005 21:41:58 -0800
Message-ID: <20050125214158.4be3798c.davem@davemloft.net>
References: <41F5D1CB.9050804@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F5D1CB.9050804@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Jan 2005 05:57:47 +0100
Patrick McHardy <kaber@trash.net> wrote:

> This patch keeps fragment queues private to each ip_defrag user to avoid
> skbs jumping between different callers. It shouldn't change any wanted
> behaviour, the only questionable one was ip_call_ra_chain, but the RA
> option is included in each fragment. If you're fine with the patch I'm going
> to send a 2.4 version later.

Please fix the CONFIG_SMP build.  You use some variable "user"
in ip_frag_intern(), yet don't add this as an argument or
anything like that.

The "user" use you added is protected by CONFIG_SMP, so my guess
is that you compile and tested this without SMP enabled.
