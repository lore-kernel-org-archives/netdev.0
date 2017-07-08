From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Request to add bluetooth module identifier to
 net/rfkill/rfkill-gpio.c
Date: Sat, 8 Jul 2017 14:20:15 +0200
Message-ID: <985A2192-C2F2-4361-BE23-9E9A5F53DAFA@holtmann.org>
References: <CALnajPDkZi5tOTcghFCRHg8EiLgXXy1nWo+b7R4DxX8iEd1g0Q@mail.gmail.com>
 <CALnajPCeYP6W4iECCsDegwTmq7UsPcH04C=K0h-zZQD6pf6rZw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Sundar Nagarajan <sun.nagarajan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALnajPCeYP6W4iECCsDegwTmq7UsPcH04C=K0h-zZQD6pf6rZw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sundar,

> I have a Cherry Trail laptop with an Atom X5-Z8300. It has a bluetooth
> chip that needs the r8723bs (coexisting RTL 8723BS wifi and
> bluetooth).
> 
> I am using linux-next (20150817) with the r8723bs staging driver and
> the firmware and utility from https://github.com/lwfinger/rtl8723bs_bt
> by Larry finger.
> 
> With linux-next the bluetooth works SOMETIMES, but on reboot, it does
> not work any more (no bluetooth interfaces are detected and hciconfig
> shows nothing).
> 
> I am a kernel novice, but I saw that another kernel that I had tried
> had the following line added in struct acpi_device_id
> rfkill_acpi_match:
> 
> { "OBDA8723",RFKILL_TYPE_BLUETOOTH }
> 
> With the attached patch applied (one line added), my bluetooth works every time.
> 
> Does this belong in rfkill-gpio.c, or should I contact someone else?

it does not belong in rfkill-gpio.c since this controls the power of the Bluetooth device. This belongs in the Bluetooth driver. We already moved all the Intel and Broadcom ones into hci_intel.c and respectively hci_bcm.c. So have the staging driver deal with the power GPIO.

Regards

Marcel
