From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v3 net-next 1/2] net: ethernet: slicoss: add slicoss
 gigabit ethernet driver
Date: Sun, 27 Nov 2016 02:02:27 +0100
Message-ID: <48c6a5d1-cde3-6e23-9c6c-d26838fce332@gmx.de>
References: <1480162850-8014-1-git-send-email-LinoSanfilippo@gmx.de>
 <1480162850-8014-2-git-send-email-LinoSanfilippo@gmx.de>
 <CAKoUArncMYtQZQZ62efWsXr25RZPiAx4USJFjf2emzVRkhELjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, andrew@lunn.ch, gregkh@linuxfoundation.org,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 liodot@gmail.com, Netdev <netdev@vger.kernel.org>,
 David Miller <davem@davemloft.net>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <CAKoUArncMYtQZQZ62efWsXr25RZPiAx4USJFjf2emzVRkhELjg@mail.gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


Hi Rami,


On 26.11.2016 16:48, Rami Rosen wrote:
>> @@ -0,0 +1,28 @@
>> +config NET_VENDOR_ALACRITECH
>> +        bool "Alacritech devices"
>> +        default y
>> +        ---help---
>> +          If you have a network (Ethernet) card belonging to this class, say Y.
>> +
>> +          Note that the answer to this question doesn't directly affect the
>> +          kernel: saying N will just cause the configurator to skip all
> 
> Shouldn't it be "Alacritech devices" here, as appears earlier ?
> 
>> +          the questions about Renesas devices. If you say Y, you will be asked

Yes, it definitely should not be Renesas :). This is a stupid copy and paste error, I will fix it,
thank you! 

>> +          for your specific device in the following questions.
>> +
> 
> ...
> ...
> ...
>> +struct slic_device {
>> +       struct pci_dev *pdev;
> ...
>> +       bool promisc;
> 
> Seems that the autoneg boolean is not used anywhere, apart from
> setting it once to true in
> the slic_set_link_autoneg() method. Apart from this member it is not
> accessed anywhere, so it seems it should be removed.
> 
>> +       bool autoneg;
>> +       int speed;

Agreed, this variable can be removed.

> ...
> 
>> +static int slic_load_rcvseq_firmware(struct slic_device *sdev)
>> +{
>> +       const struct firmware *fw;
>> +       const char *file;
>> +       u32 codelen;
>> +       int idx = 0;
>> +       u32 instr;
>> +       u32 addr;
>> +       int err;
>> +
> ...
>> +       /* Do an initial sanity check concerning firmware size now. A further
>> +        * check follows below.
>> +        */
>> +       if (fw->size < SLIC_FIRMWARE_MIN_SIZE) {
>> +               dev_err(&sdev->pdev->dev,
>> +                       "invalid firmware size %zu (min %u expected)\n",
>> +                       fw->size, SLIC_FIRMWARE_MIN_SIZE);
>> +               err = -EINVAL;
> 
> in the release label, always 0 is returned:
> 
>> +               goto release;
>> +       }
>> +
>> +       codelen = slic_read_dword_from_firmware(fw, &idx);
>> +
>> +       /* do another sanity check against firmware size */
>> +       if ((codelen + 4) > fw->size) {
>> +               dev_err(&sdev->pdev->dev,
>> +                       "invalid rcv-sequencer firmware size %zu\n", fw->size);
>> +               err = -EINVAL;
> 
> Again, in the release label, always 0 is returned:
> 
>> +               goto release;
>> +       }
>> +
>>
>> +release:
>> +       release_firmware(fw);
>> +
>> +       return 0;
>> +}

This should return "err", I will fix it.

Thanks a lot for the review!

Regards,
Lino
