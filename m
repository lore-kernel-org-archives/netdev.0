From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 7/7] netpoll: avoid kfree_skb on packets with destructo
Date: Thu, 3 Mar 2005 13:00:31 -0800
Message-ID: <20050303130031.066f0862.davem@davemloft.net>
References: <7.454130102@selenic.com>
	<8.454130102@selenic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, jmoyer@redhat.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <8.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 03 Mar 2005 14:46:32 -0600
Matt Mackall <mpm@selenic.com> wrote:

> Packets that have destructors should not be zapped here as that might
> produce additional printk warnings via netconsole.
> 
> Signed-off-by: Matt Mackall <mpm@selenic.com>

Then where will they be freed, eh? :-)

This patch adds an SKB leak.  Since you've NULL'd out the list, any
SKB skipped will never be freed up at all.
