From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] cdc_ether: Improve ZTE MF823/831/910 handling
Date: Mon, 18 Jul 2016 15:23:44 +0200
Message-ID: <CAKfDRXiqDmJadXL4+v7saM431vPAp_8m8F0wvTkkYt-3tNjYyw@mail.gmail.com>
References: <1468844691-8222-1-git-send-email-kristian.evensen@gmail.com> <1468846886.2280.6.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-usb@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468846886.2280.6.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Jul 18, 2016 at 3:01 PM, Oliver Neukum <oneukum@suse.com> wrote:
> On Mon, 2016-07-18 at 14:24 +0200, Kristian Evensen wrote:
>> The firmware in the ZTE MF823/831/910 modems/mifis use OS fingerprinting to
>> determine which type of device to export. In addition, these devices export
>> a REST API which can also be used to control the type of device. So far, on
>> Linux, the devices have been seen as RNDIS or CDC Ether.
>>
>> When CDC Ether is used, devices of the same type are, as with RNDIS,
>> exported with the same, bogus random MAC address. In addition, the devices
>
> Please explain. If the MAC is random, I fail to see why the host would
> be any better at making up a MAC.

Sorry for not explaining this properly. The problem is that all
devices of the same type store the same value in iMACAddress. On all
MF831/MF910s (that I have seen) 36:4b:50:b7:ef:da is stored in this
value, while 36:4b:50:b7:ef:38 is stored on MF823. In order to ensure
that all devices on a host has a unique MAC-address, I think it is
better to generate a new random MAC on the host than to trust the
value returned from the device.

>> * If a random MAC is read from device, then generate a new random MAC
>> address. This fix will apply to all devices using cdc_ether, but that
>> should be ok as we will also fix similar mistakes from other
>> manufacturers.
>
> I am not really happy with this.
>
> If this is specific to the device a quirk should be used. If it is a
> truly generic misdesign, it does not belong into cdc-ether. It should go
> into the generic layer.

We saw the same behaviour when these devices are exposed as RNDIS and
decided to apply a generic fix instead of limiting ourself to for
example the two, known bogus MAC address. See commit
a5a18bdf7453d505783e40e47ebb84bfdd35f93b and the thread "[PATCH]
rndis_host: Set random MAC for ZTE MF910"
(http://www.spinics.net/lists/linux-usb/msg143727.html) for the
discussion.

However, I have no strong objections towards for example checking
against the two bad MAC addresses before generating a random MAC.

-Kristian
