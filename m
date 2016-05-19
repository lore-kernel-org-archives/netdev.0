From: Mathias Kresin <openwrt@kresin.me>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Thu, 19 May 2016 12:03:10 +0200
Message-ID: <CABwW5nm9itJUrfP6yNEgQPDcPojKvsPbxv6tdoJ0DFPDY9XrSw@mail.gmail.com>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com>
	<573C9738.4040402@gmail.com>
	<2a059454-279b-4ade-6f0e-837013bb323f@phrozen.org>
	<1712340.89M2Ezzzk6@ws-stein>
	<5f2d9a6d-bcf1-5aa1-7c45-f8cfd723bc3a@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Stein <alexander.stein@systec-electronic.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andrew@lunn.ch, "Mehrtens, Hauke" <hauke.mehrtens@intel.com>
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5f2d9a6d-bcf1-5aa1-7c45-f8cfd723bc3a@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-05-19 9:03 GMT+02:00 John Crispin <john@phrozen.org>:
> On 19/05/2016 08:57, Alexander Stein wrote:
>> Thanks for the link, I wasn't aware of that patch. I like it in general, but
>> there are some things I'd like to get addressed first:
>> * vr9_gphy_of_reg_init() writes uncoditionally to led3h and led3l even on
>>   PEf7071 which does not have this register at all
>
> we use this driver mainly on the 11g and 22f version. mathias recently
> added the led3 handling.
>
> @Mathias, can you have a look at this and fix it inside the lede tree ?

Well, I haven't added the led3 handling, I've only changed the initial
value (function) of led3.

Maybe it's cleaner to not use a default value for the led function and
completely rely on the device tree bindings. But by adjusting the
initial values, I had to change only the led function of one board in
the openwrt xrx200 subtarget instead of touching all dts files.

I know that the LTQ Datasheet for the PEF 7071 Version 1.5 mentions
the led3 control register albeit there is no pin for a forth led. So I
guess it's safe to write to the led3 register even for the PEF 7071.

Mathias
