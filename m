From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Wed, 17 Aug 2016 09:40:46 +0200
Message-ID: <7B1B501B-73E5-49E8-B147-25D9EEFC789D@holtmann.org>
References: <1469939084-15603-1-git-send-email-guodong.xu@linaro.org> <1394C970-3726-4C42-A06D-0B3B3015D980@holtmann.org> <CAFGCpxz6j_7aOTX+uShdpyxmt71k61v=Abdw=7MfrRjvdygmTg@mail.gmail.com> <30869CE7-FE5E-4CAF-86FC-D140E2C0963D@holtmann.org> <CAFGCpxx7teWAGzw+-uy+nwoHgsS__8S-CdfGuNuycCUuWJRC+Q@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:BLUETOOTH DRIVERS" <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Guodong Xu <guodong.xu@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFGCpxx7teWAGzw+-uy+nwoHgsS__8S-CdfGuNuycCUuWJRC+Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guodong,

>>>>> Two LED triggers are added into hci_dev: tx_led and rx_led. Upon ACL/SCO
>>>>> packets available in tx or rx, the LEDs will blink.
>>>>> 
>>>>> For each hci registration, two triggers are added into LED subsystem:
>>>>> [hdev->name]-tx and [hdev-name]-rx.
>>>>> Refer to Documentation/leds/leds-class.txt for usage.
>>>>> 
>>>>> Verified on HiKey 96boards, which uses HiSilicon hi6220 SoC and TI
>>>>> WL1835 WiFi/BT combo chip.
>>>> 
>>>> so I have no idea what to do with adding adding hci0-rx and hci0-tx triggers. Combined with hci0-power trigger these are already 3 triggers. And if you have 2 Bluetooth controllers in your system, then you have 6 triggers.
>>>> 
>>> 
>>> True, 6 triggers. But, taking example for other subsytems, eg. cpu
>>> cores. On my board, I have "heartbeat cpu0 cpu1 cpu2 cpu3 cpu4 cpu5
>>> cpu6 cpu7". It doesn't have to mean you need all of them connected to
>>> some LED(s). Actually, in most of the case, I only need heartbeat.
>>> 
>>> 
>>> 
>>>> If we then maybe add another trigger, then this number just goes up and up.
>>>> 
>>>> As far as I can tell you can only assign a single trigger to a LED.
>>>> 
>>> 
>>> That's true. And people got a choice of which feature he wants to visualize.
>> 
>> and as a result we keep adding senseless triggers to the kernel and bloating it up for no reason. Especially since it feels like 99% of the LED triggers are not used at all. This makes no sense to me.
>> 
>>>> So this means to even use these triggers, you need now 3 LEDs per Bluetooth controller. How is that useful for anybody in a real system? Maybe I am missing something here and somehow there is magic to combine triggers, but I have not found it yet. So please someone enlighten me on how this is suppose to be used with real devices.
>>>> 
>>>> Recently I have added a simple bluetooth-power trigger that combines all Bluetooth controllers into a single trigger. If any of them is enabled, then you can control your LED. Which makes a lot more sense to me since you most likely have a single Bluetooth LED on your system. And you want it to show the correct state no matter what Bluetooth controller is in use. However I can see the case that someone might want to assign one specific Bluetooth controller to a LED status.
>>>> 
>>>> So instead of adding many independent triggers to each controller, why not create one global bluetooth trigger and one individual bluetooth-hci0 trigger for each controller. And the combine power, tx, rx and whatever else we need to trigger the LED for?
>>>> 
>>> 
>>> When I starting this work, I referred to WiFi system. See
>>> CONFIG_MAC80211_LEDS. WiFi system implements these types of triggers "
>>> phy0rx phy0tx phy0assoc phy0radio" for each 'controller'.
>> 
>> And I actually wonder who ever used these triggers. You need 4 LEDs to visualize the WiFi status. Which systems has 4 LEDs to spare to visualize this.
>> 
>>> Besides, there are also RFKILL which stands for WiFi/BT power status.
>>> RFKILL adds triggers for each module too. Eg. in the below example, I
>>> have one WiFi (phy0), one BT (hci0). Trigger rfkill1 equals to
>>> hci0-power.
>>> 
>>> Ref: here are all LED triggers I found in my 96boards/HiKey:
>>> 
>>> # cat trigger
>>> none kbd-scrollock kbd-numlock kbd-capslock kbd-kanalock kbd-shiftlock
>>> kbd-altgrlock kbd-ctrllock kbd-altlock kbd-shiftllock kbd-shiftrlock
>>> kbd-ctrlllock kbd-ctrlrlock mmc0 mmc1 heartbeat cpu0 cpu1 cpu2 cpu3
>>> cpu4 cpu5 cpu6 cpu7 mmc2 rfkill0 phy0rx phy0tx phy0assoc phy0radio
>>> hci0-power hci0-tx [hci0-rx] rfkill1
>> 
>> And how many LEDs do you have in the your system? I think you are making my point here.
>> 
>> So I think what we need to do is to not add to this madness and instead create one "bluetooth" LED trigger that combines power and TX/RX for all controllers. And then allow for individual "bluetooth-hci0" LED triggers so that you can bind a single Bluetooth controller to a single LED.
>> 
>> For me, if I can not combine hci0-power, hci0-tx and hci0-rx into a single LED,
> 
> By combining them into a single LED, do you mean such a use case?
> - when hci0 is powered on, this LED starts on.
> - then, when there is tx/rx traffic, this LED should blink (reversely
> of course).
> - when hci0 is powered off, this LED turns off.

yes, that is what I am thinking of.

Regards

Marcel
