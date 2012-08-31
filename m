From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 0/12] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Fri, 31 Aug 2012 18:36:47 -0400
Message-ID: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:6468 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755147Ab2HaWxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 18:53:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

>From: David Miller [mailto:davem@davemloft.net]

>Firstly, I'm not going to let you create arbitrary new sysfs
>and debugfs crap for facilities that are already supported by
>the kernel via other interfaces.

>For example, providing a facility to read and write the PCI BARs
>is completely pointless.  Use the PCI config space access APIs for
>this if you want to do this from userspace.

>The patches are also much more verbose than they need to be.
>When you move an operation to the new hwops, keep the existing function
>name but make it an inline function that invokes the hwop.

>That way you won't need hundreds of lines in your patch that look like this:

>-	qlcnic_clear_lb_mode(adapter);
>+	ahw->hw_ops->clear_loopback(adapter, mode);

>Instead you'd have:

>static inline void qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter,
>							u8 mode) {
>	struct qlcnic_hardware_context *ahw = &adapter->ahw;

>	ahw->hw_ops->clear_loopback(adapter, mode); }

>From: David Miller [mailto:davem@davemloft.net] 
>Sent: Friday, August 31, 2012 1:05 PM

> +static inline int
> +qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 
> +rate) {
> +	return adapter->nic_ops->config_led(adapter, state, rate);
> +
> +}
> +

>Please get rid of those unnecessary empty lines in the function bodies.


I have made the changes as you suggested above,
please drop all the previous 12 patches.
We are not creating new sysfs nodes.

Please apply the updated patch series to net-next.

Thanks,
Sony
