From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 02/11] inet_diag: pass inet_diag module to
 netlink_dump_start
Date: Wed, 26 Sep 2012 09:07:14 -0700
Message-ID: <20120926090714.618a4b39@nehalam.linuxnetplumber.net>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
	<1348635140-20225-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, pablo@netfilter.org,
	steffen.klassert@secunet.com, linux-crypto@vger.kernel.org,
	jengelh@inai.de, stephen.hemminger@vyatta.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1348635140-20225-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Sep 2012 12:52:11 +0800
Gao feng <gaofeng@cn.fujitsu.com> wrote:

>  			struct netlink_dump_control c = {
>  				.dump = inet_diag_dump_compat,
> +				.done = netlink_dump_done,
> +				.module = THIS_MODULE,
>  			};

Since these are immutable, why the netlink_dump_control structures
on the stack (which requires code to generate at runtime), and instead
make them global

static const struct netlink_dump_control unix_diag_ctrl = {
...
