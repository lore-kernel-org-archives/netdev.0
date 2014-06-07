From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: Re: [PATCH] net: wimax: i2400m: control.c: Cleaning up conjunction
 always evaluates to false
Date: Sat, 7 Jun 2014 13:52:59 +0200
Message-ID: <CAFo99gbsds_O12h+9FOayvdODxRNeKUKXUs1_XjszFfr8yjR2Q@mail.gmail.com>
References: <1402140397-17404-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<1402141375.28369.2.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402141375.28369.2.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Thought about it, and now it becomes clearer.
But if someone decides to change the X or Y to a larger range than 1
and 2, it will not be correct ..?
Or, will it not happen?

But I'm no expert on this code :)
I just wanted to point out the logical error.


Best regards
Rickard Strandqvist


2014-06-07 13:42 GMT+02:00 Joe Perches <joe@perches.com>:
> On Sat, 2014-06-07 at 13:26 +0200, Rickard Strandqvist wrote:
>> Logical conjunction always evaluates to false:  minor < 2 && minor > 1
>> I guess what you wanted is rather: minor > 2 || minor < 1
> []
>> diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
> []
>> @@ -1061,7 +1061,7 @@ int i2400m_firmware_check(struct i2400m *i2400m)
>>               goto error_bad_major;
>>       }
>>       result = 0;
>> -     if (minor < I2400M_HDIv_MINOR_2 && minor > I2400M_HDIv_MINOR)
>> +     if (minor > I2400M_HDIv_MINOR_2 || minor < I2400M_HDIv_MINOR)
>
> perhaps clearer as:
>
>         if (!(minor == I2400M_HDIv_MINOR || minor == I2400M_HDIv_MINOR_2))
>
>>               dev_warn(dev, "untested minor fw version %u.%u.%u\n",
>>                        major, minor, branch);
>>       /* Yes, we ignore the branch -- we don't have to track it */
>
>
>
