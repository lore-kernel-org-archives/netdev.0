From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Mon, 16 Jan 2012 07:42:55 -0800
Message-ID: <4F14457F.8060509@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001430.787918662083526597.davem@davemloft.net> <4F11A533.4040406@linux.intel.com> <20120114.115604.2101782124431552110.davem@davemloft.net> <20120114214658.4ddfec30@pyramind.ukuu.org.uk> <4F120357.3020808@linux.intel.com> <CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com> <20120116123110.7ce91f2d@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Tomoya MORINAGA <tomoya.rohm@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: Alan Cox <alan@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120116123110.7ce91f2d@bob.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/16/2012 04:31 AM, Alan Cox wrote:
>> Saving MAC address into external ROM is generic method, I think.
>> Though I know the ROM-less system using eg20t-pch, however I think
>> this system is not common.
>> So, I think pch_gbe shouldn't have auto-mac address assignment.
> 
> The problem is the module load fails for those cases. You cannot load
> the module and use the standard ifconfig eth0 hw aa:bb:cc:dd:ee:ff
> interface. The better fix might be to make sure it loads.
> 
> So change from
> 
>         memcpy(netdev->dev_addr, adapter->hw.mac.addr,
>         netdev->addr_len);   
>         if (!is_valid_ether_addr(netdev->dev_addr)) {
>                 dev_err(&pdev->dev, "Invalid MAC Address\n");
>                 ret = -EIO; 
>                 goto err_free_adapter;
>         }
> 
> to just printing a warning, and check the current address when a user
> tries to ifconfig it up and refuse to allow the port to go active.

I can go this route I suppose. I don't really understand the objection
to the use of a random mac addr in the special case given the prevalence
of this approach within existing drivers.

One reason I don't care for this alternative approach is that this
particular hardware is targeted at embedded use where we can't assume a
full init system is available, etc. It can be made to work of course, it
just isn't as automated.

David, would you orefer/accept an alternative patch which allows the
driver to load without a MAC address so the user can set it via ifconfig
after boot?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
