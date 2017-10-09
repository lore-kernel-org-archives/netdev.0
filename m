From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: linux-next: manual merge of the drivers-x86 tree with the
 net-next tree
Date: Mon, 9 Oct 2017 22:43:01 +0300
Message-ID: <20171009194301.GP2761@lahna.fi.intel.com>
References: <20171009175633.dm7hjmgoxusspue5@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Darren Hart <dvhart@infradead.org>,
        Mario Limonciello <mario.limonciello@dell.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Michael Jamet <michael.jamet@intel.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009175633.dm7hjmgoxusspue5@sirena.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 06:56:33PM +0100, Mark Brown wrote:
>  +Networking over Thunderbolt cable
>  +---------------------------------
>  +Thunderbolt technology allows software communication across two hosts
>  +connected by a Thunderbolt cable.
>  +
>  +It is possible to tunnel any kind of traffic over Thunderbolt link but
>  +currently we only support Apple ThunderboltIP protocol.
>  +
>  +If the other host is running Windows or macOS only thing you need to
>  +do is to connect Thunderbolt cable between the two hosts, the
>  +``thunderbolt-net`` is loaded automatically. If the other host is also
>  +Linux you should load ``thunderbolt-net`` manually on one host (it does
>  +not matter which one)::
>  +
>  +  # modprobe thunderbolt-net
>  +
>  +This triggers module load on the other host automatically. If the driver
>  +is built-in to the kernel image, there is no need to do anything.
>  +
>  +The driver will create one virtual ethernet interface per Thunderbolt
>  +port which are named like ``thunderbolt0`` and so on. From this point
>  +you can either use standard userspace tools like ``ifconfig`` to
>  +configure the interface or let your GUI to handle it automatically.
> ++
> + Forcing power
> + -------------
> + Many OEMs include a method that can be used to force the power of a
> + thunderbolt controller to an "On" state even if nothing is connected.
> + If supported by your machine this will be exposed by the WMI bus with
> + a sysfs attribute called "force_power".
> + 
> + For example the intel-wmi-thunderbolt driver exposes this attribute in:
> +   /sys/devices/platform/PNP0C14:00/wmi_bus/wmi_bus-PNP0C14:00/86CCFD48-205E-4A77-9C48-2021CBEDE341/force_power
> + 
> +   To force the power to on, write 1 to this attribute file.
> +   To disable force power, write 0 to this attribute file.
> + 
> + Note: it's currently not possible to query the force power state of a platform.

If possible, I would rather move this chapter to be before "Networking
over Thunderbolt cable". Reason is that it then follows NVM flashing
chapter which is typically where you need to force power in the first
place.
