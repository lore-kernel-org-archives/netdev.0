From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/ncsi: Don't assume last available channel
 exists
Date: Wed, 20 Sep 2017 16:05:19 -0700 (PDT)
Message-ID: <20170920.160519.764603868579556859.davem@davemloft.net>
References: <20170920041251.14635-1-sam@mendozajonas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: sam@mendozajonas.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170920041251.14635-1-sam@mendozajonas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Date: Wed, 20 Sep 2017 14:12:51 +1000

> When handling new VLAN tags in NCSI we check the maximum allowed number
> of filters on the last active ("hot") channel. However if the 'add'
> callback is called before NCSI has configured a channel, this causes a
> NULL dereference.
> 
> Check that we actually have a hot channel, and warn if it is missing.
> 
> Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>

Well, a few things.

We should not allow this driver method to be invoked in the first
place if the device is not in a state where the operation is legal
yet.

Second of all, if !ndp is true, you should not return 0 to indicate
success.

But more fundamentally, we should block this method from being
callable unless the device is in the proper state and can complete the
operation.

Seriously, these checks should be completely unnecessary if those
issues are handled properly.
