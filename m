From: "tiejun.chen" <tiejun.chen@windriver.com>
Subject: Re: [PATCH v4 06/12] ARM: dove: add gigabit ethernet and mvmdio device
 tree nodes
Date: Wed, 22 May 2013 18:04:18 +0800
Message-ID: <519C9822.9040909@windriver.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-7-git-send-email-sebastian.hesselbarth@gmail.com>
 <20130521174849.GL26249@lunn.ch> <519C9333.20609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, Lennert Buytenhek <buytenh@wantstofly.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <519C9333.20609@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 05/22/2013 05:43 PM, Sebastian Hesselbarth wrote:
> On 05/21/2013 07:48 PM, Andrew Lunn wrote:
>> On Tue, May 21, 2013 at 06:41:44PM +0200, Sebastian Hesselbarth wrote:
>>> This patch adds orion-eth and mvmdio device tree nodes for DT enabled
>>> Dove boards. As there is only one ethernet controller on Dove, a default
>>> phy node is also added with a note to set its reg property on a per-board
>>> basis.
>>>
>>> Signed-off-by: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
>>> ---
> ...
>>> +            ethernet-port@0 {
>>> +                device_type = "network";
>>> +                compatible = "marvell,orion-eth-port";
>>> +                reg =<0>;
>>> +                interrupts =<29>;
>>> +                /* overwrite MAC address in bootloader */
>>> +                local-mac-address = [00 00 00 00 00 00];
>>
>> Hi Sebastian
>>
>> Its probably a good idea to set the local administration bit in this
>> MAC address. i.e. first byte is 02.
>
> Andrew,
>
> we just need an invalid address here to trigger the default behavior of
> the driver and load the MAC address from its register. As PPC binding
> documentation also has all zero, I just took it.

The truth is in PPC case, often we set the real mac address with some variables 
like 'eth[x]addr' in u-boot prompt, then u-boot will parse that value to fill 
the dtb. At last the associated driver can get the actual mac address from the 
dtb. And especially for those older u-boot version, even you have to reset the 
'local-mac-address' property in dts directly with the real mac address before 
generate the dtb since the older u-boot have no this ability to fill dtb again 
before pass the kernel.

Tiejun
