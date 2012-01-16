From: Alan Cox <alan@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of
 failing probe
Date: Mon, 16 Jan 2012 12:31:10 +0000
Message-ID: <20120116123110.7ce91f2d@bob.linux.org.uk>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
	<20120114.001430.787918662083526597.davem@davemloft.net>
	<4F11A533.4040406@linux.intel.com>
	<20120114.115604.2101782124431552110.davem@davemloft.net>
	<20120114214658.4ddfec30@pyramind.ukuu.org.uk>
	<4F120357.3020808@linux.intel.com>
	<CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Darren Hart <dvhart@linux.intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Saving MAC address into external ROM is generic method, I think.
> Though I know the ROM-less system using eg20t-pch, however I think
> this system is not common.
> So, I think pch_gbe shouldn't have auto-mac address assignment.

The problem is the module load fails for those cases. You cannot load
the module and use the standard ifconfig eth0 hw aa:bb:cc:dd:ee:ff
interface. The better fix might be to make sure it loads.

So change from

        memcpy(netdev->dev_addr, adapter->hw.mac.addr,
        netdev->addr_len);   
        if (!is_valid_ether_addr(netdev->dev_addr)) {
                dev_err(&pdev->dev, "Invalid MAC Address\n");
                ret = -EIO; 
                goto err_free_adapter;
        }

to just printing a warning, and check the current address when a user
tries to ifconfig it up and refuse to allow the port to go active.

Alan
