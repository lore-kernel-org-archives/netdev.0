From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 3/3] rfkill: Add rfkill documentation
Date: Mon, 10 Sep 2007 11:26:25 -0700
Message-ID: <20070910112625.376efc50.randy.dunlap@oracle.com>
References: <200709101954.50852.IvDoorn@gmail.com>
	<200709101956.03861.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Dmitry Torokhov <dtor@insightbb.com>,
	netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12239 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755191AbXIJXTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 19:19:04 -0400
In-Reply-To: <200709101956.03861.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Sep 2007 19:56:03 +0200 Ivo van Doorn wrote:

> Add a documentation file which contains
> a short description about rfkill with some
> notes about drivers and the userspace interface.

Thanks.  I have noted a few typo/editorial changes below.


> Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>
> Acked-by: Dmitry Torokhov <dtor@mail.ru>
> ---
>  Documentation/rfkill.txt |   88 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 88 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/rfkill.txt
> 
> diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
> new file mode 100644
> index 0000000..93c76fc
> --- /dev/null
> +++ b/Documentation/rfkill.txt
> @@ -0,0 +1,88 @@
> +rfkill - RF switch subsystem support
> +====================================
> +
> +1 Implementation details
> +2 Driver support
> +3 Userspace support
> +
> +===============================================================================
> +1: Implementation details
> +
> +The rfkill switch subsystem offers support for keys often found on laptops
> +to enable wireless devices like WiFi and Bluetooth.
> +
> +This is done by providing the user 3 possibilities:
> + - The rfkill system handles all events, userspace is not aware of events.
> + - The rfkill system handles all events, userspace is informed about the event.
> + - The rfkill system does not handle events, userspace handles all events.

I would s/,/;/ in the 3 lines above.

> +The buttons to enable and disable the wireless radios are important in
> +situations where the user is for example using his laptop on a location where
> +wireless radios _must_ be disabled (e.g airplanes).
> +Because of this requirement, userspace support for the keys should not be
> +made mandatory. Because userspace might want to perform some additional smarter
> +tasks when the key is pressed, rfkill still provides userspace the possibility
> +to take over the task to handle the key events.
> +
> +The system inside the kernel has been split into 2 seperate sections:

                                                      separate

> +	1 - RFKILL
> +	2 - RFKILL_INPUT
> +
> +The first option enables rfkill support and will make sure userspace will
> +be notified of any events through the input device. It also creates several
> +sysfs entries which can be used by userspace. See section "Userspace support".
> +
> +The second option provides a rfkill input handler. This handler will

                              an

> +listen to all rfkill key events and will toggle the radio accordingly,

end above with ; or .  If '.', s/with/With/ on next line.

> +with this option enabled userspace could either do nothing or simply
> +perform monitoring tasks.
> +
> +====================================
> +2: Driver support
> +
> +Drivers who wish to build in rfkill subsystem support should

   Drivers that

But, drivers can't/don't wish, so it would be better to say something
like:

To build a driver with rfkill subsystem support, the driver should
depend on the Kconfig symbol RFKILL; it should _not_ depend on
RKFILL_INPUT.


> +make sure their driver depends of the Kconfig option RFKILL, it should
> +_not_ depend on RFKILL_INPUT.
> +
> +Unless key events trigger a interrupt to which the driver listens, polling

                             an interrupt

> +will be required to determine the key state changes. For this the input
> +layer providers the input-polldev handler.
> +
> +A driver should implement a few steps to correctly make use of the
> +rfkill subsystem. First for non-polling drivers:
> +
> +	- rfkill_allocate()
> +	- input_allocate_device()
> +	- rfkill_register()
> +	- input_register_device()
> +
> +For polling drivers:
> +
> +	- rfkill_allocate()
> +	- input_allocate_polled_device()
> +	- rfkill_register()
> +	- input_register_polled_device()
> +
> +When a key event has been detected, the correct event should be
> +send over the input device which has been registered by the driver.

   sent

> +
> +====================================
> +3: Userspace support
> +
> +For each key a input device will be created which will send out the correct

                an

> +key event when the rfkill key has been pressed.
> +
> +The following sysfs entries will be created:
> +
> +	name: Name assigned by driver to this key (interface or driver name).
> +	type: Name of the key type ("wlan", "bluetooth", etc).
> +	state: Current state of the key. 1: On, 0: Off.
> +	claim: 1: Userspace handles events, 0: Kernel handles events
> +
> +Both the "state" and "claim" entries are also writable. For the "state" entry
> +this means that when 1 or 0 is written all radios will be toggled accordingly.

will be written even if they are already in that state?

> +For the "claim" entry writing 1 to it will mean that the kernel will no longer

s/will mean/means/
s/will no longer handle/no longer handles/

> +handle key events even though RFKILL_INPUT input was enabled. When "claim" has
> +been set to 0, userspace should make sure it will listen for the input events

s/it will listen/that it listens/

> +or check the sysfs "state" entry regularly to correctly perform the required
> +tasks when the rkfill key is pressed.
> -- 

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
