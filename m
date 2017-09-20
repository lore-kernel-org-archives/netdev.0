From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/i4l: fetch the ppp_write buffer in one shot
Date: Wed, 20 Sep 2017 16:01:55 -0700 (PDT)
Message-ID: <20170920.160155.1154864064570909831.davem@davemloft.net>
References: <1505872195-46627-1-git-send-email-mengxu.gatech@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, johannes.berg@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        meng.xu@gatech.edu, sanidhya@gatech.edu, taesoo@gatech.edu
To: mengxu.gatech@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505872195-46627-1-git-send-email-mengxu.gatech@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meng Xu <mengxu.gatech@gmail.com>
Date: Tue, 19 Sep 2017 21:49:55 -0400

> In isdn_ppp_write(), the header (i.e., protobuf) of the buffer is
> fetched twice from userspace. The first fetch is used to peek at the
> protocol of the message and reset the huptimer if necessary; while the
> second fetch copies in the whole buffer. However, given that buf resides
> in userspace memory, a user process can race to change its memory content
> across fetches. By doing so, we can either avoid resetting the huptimer
> for any type of packets (by first setting proto to PPP_LCP and later
> change to the actual type) or force resetting the huptimer for LCP
> packets.
> 
> This patch changes this double-fetch behavior into two single fetches
> decided by condition (lp->isdn_device < 0 || lp->isdn_channel <0).
> A more detailed discussion can be found at
> https://marc.info/?l=linux-kernel&m=150586376926123&w=2
> 
> Signed-off-by: Meng Xu <mengxu.gatech@gmail.com>

Applied, thank you.
