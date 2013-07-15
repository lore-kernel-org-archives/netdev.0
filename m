From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net 2/2] usb/net/r815x: fix cast to restricted __le32
Date: Mon, 15 Jul 2013 19:45:44 +0100
Message-ID: <1373913944.3745.16.camel@bwh-desktop.uk.level5networks.com>
References: <1373617576-2272-1-git-send-email-hayeswang@realtek.com>
	 <1373617576-2272-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <gregkh@linuxfoundation.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373617576-2272-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-12 at 16:26 +0800, Hayes Wang wrote:
> >> drivers/net/usb/r815x.c:38:16: sparse: cast to restricted __le32
> >> drivers/net/usb/r815x.c:67:15: sparse: cast to restricted __le32
> >> drivers/net/usb/r815x.c:69:13: sparse: incorrect type in assignment (different base types)
>    drivers/net/usb/r815x.c:69:13:    expected unsigned int [unsigned] [addressable] [assigned] [usertype] tmp
>    drivers/net/usb/r815x.c:69:13:    got restricted __le32 [usertype] <noident>
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> Spotted-by: kbuild test robot <fengguang.wu@intel.com>
> ---
>  drivers/net/usb/r815x.c | 21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
> index 6516737..8523922 100644
> --- a/drivers/net/usb/r815x.c
> +++ b/drivers/net/usb/r815x.c
> @@ -26,16 +26,18 @@ static int pla_read_word(struct usb_device *udev, u16 index)
>  {
>  	int data, ret;
>  	u8 shift = index & 2;
> +	__le32 ocp_data;
>  
>  	index &= ~3;
>  
>  	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
>  			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
> -			      index, MCU_TYPE_PLA, &data, sizeof(data), 500);
> +			      index, MCU_TYPE_PLA, &ocp_data, sizeof(ocp_data),
> +			      500);
[...]

There seems to be another bug here: USB buffers must be DMA-able,
therefore cannot be placed on the stack.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
