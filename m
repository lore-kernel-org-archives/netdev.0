From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Tue, 16 Aug 2016 08:03:33 +0200
Message-ID: <1394C970-3726-4C42-A06D-0B3B3015D980@holtmann.org>
References: <1469939084-15603-1-git-send-email-guodong.xu@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Guodong Xu <guodong.xu@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469939084-15603-1-git-send-email-guodong.xu@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guodong,

> Two LED triggers are added into hci_dev: tx_led and rx_led. Upon ACL/SCO
> packets available in tx or rx, the LEDs will blink.
> 
> For each hci registration, two triggers are added into LED subsystem:
> [hdev->name]-tx and [hdev-name]-rx.
> Refer to Documentation/leds/leds-class.txt for usage.
> 
> Verified on HiKey 96boards, which uses HiSilicon hi6220 SoC and TI
> WL1835 WiFi/BT combo chip.

so I have no idea what to do with adding adding hci0-rx and hci0-tx triggers. Combined with hci0-power trigger these are already 3 triggers. And if you have 2 Bluetooth controllers in your system, then you have 6 triggers. If we then maybe add another trigger, then this number just goes up and up.

As far as I can tell you can only assign a single trigger to a LED. So this means to even use these triggers, you need now 3 LEDs per Bluetooth controller. How is that useful for anybody in a real system? Maybe I am missing something here and somehow there is magic to combine triggers, but I have not found it yet. So please someone enlighten me on how this is suppose to be used with real devices.

Recently I have added a simple bluetooth-power trigger that combines all Bluetooth controllers into a single trigger. If any of them is enabled, then you can control your LED. Which makes a lot more sense to me since you most likely have a single Bluetooth LED on your system. And you want it to show the correct state no matter what Bluetooth controller is in use. However I can see the case that someone might want to assign one specific Bluetooth controller to a LED status.

So instead of adding many independent triggers to each controller, why not create one global bluetooth trigger and one individual bluetooth-hci0 trigger for each controller. And the combine power, tx, rx and whatever else we need to trigger the LED for?

Regards

Marcel
