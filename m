From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3.5 10/19] mac8011: slight optimization of addr compare
Date: Mon, 06 Jan 2014 16:11:51 +0100
Message-ID: <1389021111.5891.21.camel@jlt4.sipsolutions.net>
References: <52BC15C8.2080400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52BC15C8.2080400@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-12-26 at 19:40 +0800, Ding Tianhong wrote:
> Use the possibly more efficient ether_addr_equal
> to instead of memcmp.

This is a slow-path, I don't think that's really worth it. It kinda
makes sense, but relies on the struct mac_address allocation for
alignment and the fact that there are no other members in that struct,
so it seems to me that this ought to also add some alignment attributes?

johannes
