From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v9 7/8] thunderbolt: Networking doc
Date: Wed, 9 Nov 2016 17:00:02 +0100
Message-ID: <20161109160002.GA9111@kroah.com>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <1478701208-4585-8-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478701208-4585-8-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 09, 2016 at 04:20:07PM +0200, Amir Levy wrote:
> Adding Thunderbolt(TM) networking documentation.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  Documentation/00-INDEX                   |   2 +
>  Documentation/thunderbolt/networking.txt | 132 +++++++++++++++++++++++++++++++

Note, new files should be in .rst format, and live in the new
subdirectory for them (somewhere in Documentation, don't know off the
top of my head...)

>  2 files changed, 134 insertions(+)
>  create mode 100644 Documentation/thunderbolt/networking.txt
> 
> diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
> index 3acc4f1..0239e68 100644
> --- a/Documentation/00-INDEX
> +++ b/Documentation/00-INDEX
> @@ -440,6 +440,8 @@ this_cpu_ops.txt
>  	- List rationale behind and the way to use this_cpu operations.
>  thermal/
>  	- directory with information on managing thermal issues (CPU/temp)
> +thunderbolt/
> +	- directory with info regarding Thunderbolt.
>  trace/
>  	- directory with info on tracing technologies within linux
>  unaligned-memory-access.txt

This change is probably not needed.

> diff --git a/Documentation/thunderbolt/networking.txt b/Documentation/thunderbolt/networking.txt
> new file mode 100644
> index 0000000..88d1c12
> --- /dev/null
> +++ b/Documentation/thunderbolt/networking.txt
> @@ -0,0 +1,132 @@
> +Intel Thunderbolt(TM) Networking driver
> +=======================================
> +
> +Copyright(c) 2013 - 2016 Intel Corporation.
> +
> +Contact Information:
> +Intel Thunderbolt mailing list <thunderbolt-software@lists.01.org>
> +Edited by Amir Levy <amir.jer.levy@intel.com>
> +
> +Overview
> +========
> +
> +* The Thunderbolt Networking driver enables peer to peer networking on non-Apple
> +  platforms running Linux.
> +
> +* The driver creates a virtual Ethernet device that enables computer to computer
> +  communication over the Thunderbolt cable.
> +
> +* Using Thunderbolt Networking you can perform high speed file transfers between
> +  computers, perform PC migrations and/or set up small workgroups with shared
> +  storage without compromising any other Thunderbolt functionality.
> +
> +* The driver is located in drivers/thunderbolt/icm.
> +
> +* This driver will function only on non-Apple platforms with firmware based
> +  Thunderbolt controllers that support Thunderbolt Networking.
> +
> +  +----------------+            +----------------+
> +  |Host 1          |            |Host 2          |
> +  |                |            |                |
> +  |   +-------+    |            |    +-------+   |
> +  |   |Network|    |            |    |Network|   |
> +  |   |Stack  |    |            |    |Stack  |   |
> +  |   +-------+    |            |    +-------+   |
> +  |       ^        |            |        ^       |
> +  |       |        |            |        |       |
> +  |       v        |            |        v       |
> +  | +-----------+  |            |  +-----------+ |
> +  | |Thunderbolt|  |            |  |Thunderbolt| |
> +  | |Networking |  |            |  |Networking | |
> +  | |Driver     |  |            |  |Driver     | |
> +  | +-----------+  |            |  +-----------+ |
> +  |       ^        |            |        ^       |
> +  |       |        |            |        |       |
> +  |       v        |            |        v       |
> +  | +-----------+  |            |  +-----------+ |
> +  | |Thunderbolt|  |            |  |Thunderbolt| |
> +  | |Controller |<-+------------+->|Controller | |
> +  | |with ICM   |  |            |  |with ICM   | |
> +  | |enabled    |  |            |  |enabled    | |
> +  | +-----------+  |            |  +-----------+ |
> +  +----------------+            +----------------+
> +
> +Files
> +=====
> +
> +The following files are located in the drivers/thunderbolt/icm directory:
> +
> +- icm_nhi.c/h:	These files allow communication with the firmware (Intel
> +  Connection Manager) based controller. They also create an interface for
> +  netlink communication with a user space daemon.
> +
> +- net.c/net.h:	These files implement the 'eth' interface for the
> +  Thunderbolt(TM) Networking.

You don't have to list the files, right?

> +
> +Interface to User Space
> +=======================
> +
> +The interface to the user space module is implemented through a Generic Netlink.

Huh?  Not a normal network device?

> +This is the communications protocol between the Thunderbolt driver and the user
> +space application.

What userspace application?

> +Note that this interface mediates user space communication with ICM.

What is ICM?

> +(Existing Linux tools can be used to configure the network interface.)

Why aren't they sufficient for everything here?

> +
> +The Thunderbolt Daemon utilizes this interface to communicate with the driver.

What "Thunderbolt Daemon"?  What is "this"?

> +To be accessed by the user space module, both kernel and user space modules
> +have to register with the same GENL_NAME.

What userspace modules?

How do you set GENL_NAME?  What is that?

> +For the purpose of the Thunderbolt Network driver, "thunderbolt" is used.

What do you mean?

> +The registration is done at driver initialization time for all instances
> +of the Thunderbolt controllers.

Who does this?

> The communication is carried through pre-defined
> +Thunderbolt messages. Each specific message has a callback function that is
> +called when the related message is received.

Is this the internal structure of the driver?  If so, why not just put
it all in the code itself and build the documentation from it?

> +
> +Message Definitions:
> +* NHI_CMD_UNSPEC: Not used.
> +* NHI_CMD_SUBSCRIBE: Subscription request from daemon to driver to open the
> +  communication channel.
> +* NHI_CMD_UNSUBSCRIBE: Request from daemon to driver to unsubscribe and
> +  to close communication channel.
> +* NHI_CMD_QUERY_INFORMATION: Request information from the driver such as
> +  driver version, FW version offset, number of ports in the controller
> +  and DMA port.
> +* NHI_CMD_MSG_TO_ICM: Message from user space module to FW.
> +* NHI_CMD_MSG_FROM_ICM: Response from FW to user space module.
> +* NHI_CMD_MAILBOX: Message that uses mailbox mechanism such as FW policy
> +  changes or disconnect path.
> +* NHI_CMD_APPROVE_TBT_NETWORKING: Request from user space module to FW to
> +  establish path.
> +* NHI_CMD_ICM_IN_SAFE_MODE: Indication that the FW has entered safe mode.
> +
> +Communication with Intel Connection Manager(ICM) Firmware
> +=========================================================
> +
> +There are several circular buffers in Thunderbolt each using Direct Memory
> +Access (DMA).

Again, internal documentation?

Isn't this just a "normal" network device?  Why document any of this in
a separate way?  What can a user do with this?  Who is the audience of
this file?

still confused,

greg k-h
