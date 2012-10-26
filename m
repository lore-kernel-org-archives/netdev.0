From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: Fix memory leak on Tx data path
Date: Fri, 26 Oct 2012 03:43:48 -0400 (EDT)
Message-ID: <20121026.034348.679271630151161129.davem@davemloft.net>
References: <1351225074-2078-1-git-send-email-hemantk@codeaurora.org>
	<4122165.gxBpJlT6o2@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hemantk@codeaurora.org, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org
To: oneukum@suse.de
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <4122165.gxBpJlT6o2@linux-lqwf.site>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oneukum@suse.de>
Date: Fri, 26 Oct 2012 09:39:16 +0200

> On Thursday 25 October 2012 21:17:54 Hemant Kumar wrote:
>> Driver anchors the tx urbs and defers the urb submission if
>> a transmit request comes when the interface is suspended.
>> Anchoring urb increments the urb reference count. These
>> deferred urbs are later accessed by calling usb_get_from_anchor()
>> for submission during interface resume. usb_get_from_anchor()
>> unanchors the urb but urb reference count remains same.
>> This causes the urb reference count to remain non-zero
>> after usb_free_urb() gets called and urb never gets freed.
>> Hence call usb_put_urb() after anchoring the urb to properly
>> balance the reference count for these deferred urbs. Also,
>> unanchor these deferred urbs during disconnect, to free them
>> up.
> 
> Good catch. This needs to go into stable, too.
>> 
>> Signed-off-by: Hemant Kumar <hemantk@codeaurora.org>
> Acked-by: Oliver Neukum <oneukum@suse.de>

Applied and queued up for -stable.
