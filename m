From: Nish Aravamudan <nish.aravamudan@gmail.com>
Subject: Re: msleep_interruptible() in ethtool ioctl and keyboard input
Date: Fri, 29 Apr 2005 11:40:19 -0700
Message-ID: <29495f1d050429114048da1847@mail.gmail.com>
References: <468F3FDA28AA87429AD807992E22D07E05195E08@orsmsx408>
Reply-To: Nish Aravamudan <nish.aravamudan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E05195E08@orsmsx408>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 4/29/05, Venkatesan, Ganesh <ganesh.venkatesan@intel.com> wrote:

<snip>
 
> Please send me comments/ideas for further tests/questions for more data.
> 
> Following is the logic that implements the blinking:

<snip>

> static int
> e1000_phys_id(struct net_device *netdev, uint32_t data)
> {
>         struct e1000_adapter *adapter = netdev->priv;
> 
>         if(!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
>                 data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
> 
>         if(!adapter->blink_timer.function) {
>                 init_timer(&adapter->blink_timer);
>                 adapter->blink_timer.function =
> e1000_led_blink_callback;
>                 adapter->blink_timer.data = (unsigned long) adapter;
>         }
> 
>         e1000_setup_led(&adapter->hw);
>         mod_timer(&adapter->blink_timer, jiffies);

You really want this timer to go off immediately?

Regardless....

>         msleep_interruptible(data * 1000);

Does the same issue occur if you revert this change and make it

set_current_state(TASK_INTERRUPTIBLE);
schedule_timeout(data * HZ);

?

Thanks,
Nish
