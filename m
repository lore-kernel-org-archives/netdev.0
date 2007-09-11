From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 3/3 v2] rfkill: Add rfkill documentation
Date: Tue, 11 Sep 2007 12:59:10 -0700
Message-ID: <20070911125910.3a1ea9c6.randy.dunlap@oracle.com>
References: <200709101954.50852.IvDoorn@gmail.com>
	<200709101956.03861.IvDoorn@gmail.com>
	<200709111901.02137.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Dmitry Torokhov <dtor@insightbb.com>,
	netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky@linux.intel.com>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:44424 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757846AbXIKUAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 16:00:05 -0400
In-Reply-To: <200709111901.02137.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2007 19:01:01 +0200 Ivo van Doorn wrote:

Almost done.  See below.


>  Documentation/rfkill.txt |   89 ++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 89 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/rfkill.txt
> 
> diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
> new file mode 100644
> index 0000000..0f35134
> --- /dev/null
> +++ b/Documentation/rfkill.txt
> @@ -0,0 +1,89 @@
+===============================================================================
> +1: Implementation details
> +
> +The rfkill switch subsystem offers support for keys often found on laptops
> +to enable wireless devices like WiFi and Bluetooth.
> +
> +This is done by providing the user 3 possibilities:
> + 1 - The rfkill system handles all events, userspace is not aware of events;
> + 2 - The rfkill system handles all events, userspace is informed about the event;
> + 3 - The rfkill system does not handle events, userspace handles all events;

In the above 3 lines,
change "events," to "events;"
and then end each line with a period (".").


> +The buttons to enable and disable the wireless radios are important in
> +situations where the user is for example using his laptop on a location where
> +wireless radios _must_ be disabled (e.g. airplanes).
> +Because of this requirement, userspace support for the keys should not be
> +made mandatory. Because userspace might want to perform some additional smarter
> +tasks when the key is pressed, rfkill still provides userspace the possibility
> +to take over the task to handle the key events.
> +
> +The system inside the kernel has been split into 2 separate sections:
> +	1 - RFKILL
> +	2 - RFKILL_INPUT
> +
> +The first option enables rfkill support and will make sure userspace will
> +be notified of any events through the input device. It also creates several
> +sysfs entries which can be used by userspace. See section "Userspace support".
> +
> +The second option provides an rfkill input handler. This handler will
> +listen to all rfkill key events and will toggle the radio accordingly.
> +With this option enabled userspace could either do nothing or simply
> +perform monitoring tasks.
> +
> +====================================
> +2: Driver support

...

> +====================================
> +3: Userspace support
> +
> +For each key an input device will be created which will send out the correct
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
> +this means that when 1 or 0 is written all radios, not yet in the requested
> +state, will be will be toggled accordingly.
> +For the "claim" entry writing 1 to it means that the kernel no longer handles
> +handle key events even though RFKILL_INPUT input was enabled. When "claim" has

  Drop "handle" above.

> +been set to 0, userspace should make sure that it listens for the input events
> +or check the sysfs "state" entry regularly to correctly perform the required
> +tasks when the rkfill key is pressed.

Thanks.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
