From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Mon, 16 Jan 2012 07:38:06 -0800
Message-ID: <4F14445E.8040307@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001430.787918662083526597.davem@davemloft.net> <4F11A533.4040406@linux.intel.com> <20120114.115604.2101782124431552110.davem@davemloft.net> <20120114214658.4ddfec30@pyramind.ukuu.org.uk> <4F120357.3020808@linux.intel.com> <CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, jeffrey.t.kirsher@intel.com,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	netdev@vger.kernel.org
To: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/15/2012 11:38 PM, Tomoya MORINAGA wrote:
> 2012/1/16 Darren Hart <darren.hart@intel.com>:
>> I have since resolved this particular issue. I did not disable the
>> pcieqos driver I forward ported. With that disabled, pch_phub works as
>> expected.
> Yes, you can not use both pcieqos and pch_phub at the same time.
> Because pcieqos is previous version of pch_phub which is upstreamed.

Right, they both claim the same PCI ID.

> 
>> Which is to say it lists pch_mac, reads all 0's, and does
>> nothing on write (since the MAC ROM doesn't exist). Please see the patch
>> thread from Friday to address this using a random mac if the ROM is
>> missing or invalid.
> Saving MAC address into external ROM is generic method, I think.
> Though I know the ROM-less system using eg20t-pch, however I think
> this system is not common.
> So, I think pch_gbe shouldn't have auto-mac address assignment.
> 
> BTW, as you know, a use can write MAC address using sysfs file system
> like below.
> echo aa:bb:cc:dd:ee:ff > pch_mac

Right, this doesn't work on the ROM-less system. At least, the
subsequent read returns all 0's. The same is true with the phub-util-mac
and pcieqos. I believe this is due to pci_map_rom failing.

Also, if you don't build the driver as a module, then the above still
isn't sufficient as the pci probe fails and the device isn't created.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
