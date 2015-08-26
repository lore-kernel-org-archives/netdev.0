From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF
 is configured or used
Date: Wed, 26 Aug 2015 13:55:25 -0700
Message-ID: <55DE27BD.600@roeck-us.net>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net> <20150826170410.GP4215@atomide.com> <55DE069C.7000402@roeck-us.net> <20150826201628.GU4215@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeremy Linton <jeremy.linton@arm.com>,
	linux-omap@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150826201628.GU4215@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tony,

On 08/26/2015 01:16 PM, Tony Lindgren wrote:
[ ... ]

>> We may need two separate patches, one to fix up device_property_read_u32()
>> to return -ENXIO, and one to fix smsc911x_probe_config() to ignore the error
>> from device_get_phy_mode(), and to bail out if device_property_read_u32()
>> returns -ENXIO.
>
> I guess the device_property_read_u32() change needs to be discussed
> separately.. So probably best to fix up the regression to smsc911x
> first.
>
Not sure myself. Jeremy has a point - we don't really know for sure how
safe it is to check for -ENODATA (in addition to -ENXIO). Also, fixing
device_property_read_u32() turned out to be much easier than I thought.

>> The simpler alternative would be to check the return value from
>> device_property_read_u32() for both -ENXIO and -ENODATA.
>> This would make the code independent of the necessary core changes
>> (which may take a while). I tested this variant, and it works, at least
>> for the non-DT case.
>>
>> Does this make sense ?
>
> Yeh I think that would allow fixing up the smsc911x regression while
> discussing the device_property_read_u32() change. Got a test patch
> for me to try?
>

You should have two by now to choose from.

Guenter
