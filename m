From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] BUG in xennet_make_frags with paged skb data
Date: Fri, 07 Nov 2014 03:22:00 -0800
Message-ID: <1415359320.13896.105.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141106214940.GD44162@ubuntu-hedt>
	 <545C9013.1090406@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: Zoltan Kiss <zoltan.kiss@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <545C9013.1090406@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-11-07 at 09:25 +0000, Zoltan Kiss wrote:

Please do not top post.

> Hi,
> 
> AFAIK in this scenario your skb frag is wrong. The page pointer should 
> point to the original compound page (not a member of it), and offset 
> should be set accordingly.
> For example, if your compound page is 16K (4 page), then the page 
> pointer should point to the first page, and if the data starts at the 
> 3rd page, then offset should be >8K

This is not accurate.

This BUG_ON() is wrong.

It should instead be :

BUG_ON(len + offset > PAGE_SIZE<<compound_order(compound_head(page)));

splice() code can generate such cases.
