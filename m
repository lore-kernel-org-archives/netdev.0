From: "David B. Robins" <linux@davidrobins.net>
Subject: Re: [PATCH] net: usb: asix: Fix crash on skb alloc failure
Date: Mon, 05 Oct 2015 09:40:04 -0400
Message-ID: <69f8994562da8cb064f138b162a99c4d@i4031.net>
References: <1443644404-6452-1-git-send-email-linux@davidrobins.net>
 <20151005.033155.2121849340240343993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151005.033155.2121849340240343993.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015-10-05 06:31, David Miller wrote:
> From: "David B. Robins" <linux@davidrobins.net>
> Date: Wed, 30 Sep 2015 16:20:04 -0400
> 
>> If asix_rx_fixup_internal() fails to allocate rx->ax_skb, it will 
>> return
>> but not clear rx->size. rx points to driver private data. A later call
>> assumes that nonzero size means ax_skb was allocated and passes a null
>> ax_skb to skb_put. Changed allocation failure return to clear size 
>> first.
>> 
>> Found testing board with AX88772B devices.
>> 
>> Signed-off-by: David B. Robins <linux@davidrobins.net>
> 
> Applied, thanks.

While I am happy for the patch I submitted to be applied, and it is 
consistent with existing error handling and does fix the specific issue, 
I believe a later series of 5 patches by Dean Jenkins that more 
comprehensively address the issue (grouped under subject "Improve ASIX 
RX memory allocation error handling") should be preferred.
