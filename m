From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8152: reduce memory copy for rx
Date: Tue, 02 Dec 2014 22:07:38 -0800
Message-ID: <1417586858.5303.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394712342-15778-105-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-105-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-03 at 13:14 +0800, Hayes Wang wrote:
> If the data size is more than half of the AGG_BUG_SZ, allocate a new
> rx buffer and use skb_clone() to avoid the memory copy.
> 
> The original method is that allocate the memory and copy data for each
> packet in a rx buffer. The new one is that when the data size for a rx
> buffer is more than RX_THRESHOLD_CLONED, allocate a new rx buffer and
> use skb_clone for each packet in the rx buffer. According to the
> experiment, the new mothod has better performance.

Better performance for what workload exactly ?

cloning in rx path has many drawbacks, with skb->truesize being usually
wrong.
