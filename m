From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio device
 tree nodes
Date: Wed, 22 May 2013 12:13:58 +0200
Message-ID: <519C9A66.3050807@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369154510-4927-7-git-send-email-sebastian.hesselbarth@gmail.com> <20130521174849.GL26249@lunn.ch> <519C9333.20609@gmail.com> <519C9822.9040909@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	linux-kernel@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: "tiejun.chen" <tiejun.chen@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <519C9822.9040909@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 12:04 PM, tiejun.chen wrote:
> On 05/22/2013 05:43 PM, Sebastian Hesselbarth wrote:
>> On 05/21/2013 07:48 PM, Andrew Lunn wrote:
>>> On Tue, May 21, 2013 at 06:41:44PM +0200, Sebastian Hesselbarth wrote:
>>>> This patch adds orion-eth and mvmdio device tree nodes for DT enabled
>>>> Dove boards. As there is only one ethernet controller on Dove, a
>>>> default
>>>> phy node is also added with a note to set its reg property on a
>>>> per-board
>>>> basis.
>>>>
>>>> Signed-off-by: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
>>>> ---
>> ...
>>>> + ethernet-port@0 {
>>>> + device_type = "network";
>>>> + compatible = "marvell,orion-eth-port";
>>>> + reg =<0>;
>>>> + interrupts =<29>;
>>>> + /* overwrite MAC address in bootloader */
>>>> + local-mac-address = [00 00 00 00 00 00];
>>>
>>> Hi Sebastian
>>>
>>> Its probably a good idea to set the local administration bit in this
>>> MAC address. i.e. first byte is 02.
>>
>> Andrew,
>>
>> we just need an invalid address here to trigger the default behavior of
>> the driver and load the MAC address from its register. As PPC binding
>> documentation also has all zero, I just took it.
>
> The truth is in PPC case, often we set the real mac address with some
> variables like 'eth[x]addr' in u-boot prompt, then u-boot will parse
> that value to fill the dtb. At last the associated driver can get the
> actual mac address from the dtb. And especially for those older u-boot
> version, even you have to reset the 'local-mac-address' property in dts
> directly with the real mac address before generate the dtb since the
> older u-boot have no this ability to fill dtb again before pass the kernel.

Tiejun,

with Marvell SoCs it is no different, except that there is almost no dtb
support in their u-boot. The default behavior of the driver always was
to load the MAC address from its register if there is no valid overwrite
value. Using an invalid address (and all zero above is invalid) will
cause of_get_mac_address() to fail (which we allow), the corresponding
platform_data will never be written, and cause the default behavior.

We only need an invalid address passed initially on local-mac-address.
DT aware boot loader will overwrite but DT agnositic boot loader will
not. I can put any invalid MAC address in here, so I have chosen the
very first I can think of.

Sebastian
