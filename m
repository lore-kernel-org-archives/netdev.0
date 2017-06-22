From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Thu, 22 Jun 2017 10:04:56 +0200
Message-ID: <20170622080456.GC6104@unicorn.suse.cz>
References: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
 <20170621.173655.1945994342723484710.davem@davemloft.net>
 <CALRmy5tn6cgWF5LP5i7w+UTwP1UJCyQoC7Mx7=RvETBUVD-yuw@mail.gmail.com>
 <20170621.175651.854625612625047729.davem@davemloft.net>
 <125b4ae9-2cb7-3532-5391-24404cf6eaec@gmail.com>
 <24691.1498084768@famine>
 <6dd7cfa3-9d3f-ed54-3278-af37e9d0f266@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
        David Miller <davem@davemloft.net>, vfalico@gmail.com,
        andy@greyhouse.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, joe@perches.com
To: Michael J Dilmore <michael.j.dilmore@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6dd7cfa3-9d3f-ed54-3278-af37e9d0f266@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2017 at 12:04:54AM +0100, Michael J Dilmore wrote:
> 
> Is it worth at least wrapping BUG_ON in an unlikely macro then?

See BUG_ON() definition:

#ifndef HAVE_ARCH_BUG_ON
#define BUG_ON(condition) do { if (unlikely(condition)) BUG(); } while (0)
#endif

where HAVE_ARCH_BUG_ON is defined only on powerpc and mips. It makes
good sense, you don't want to BUG_ON() on a condition unless it's
extremely unlikely. (Except for debugging purpose but even then you
don't really care about fine optimization when you are going to oops.)

Michal Kubecek
