From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF
 is configured or used
Date: Mon, 17 Aug 2015 15:14:56 -0700
Message-ID: <55D25CE0.6040203@roeck-us.net>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net> <55D24FEE.8040505@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jeremy Linton <jeremy.linton@arm.com>,
	Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55D24FEE.8040505@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2015 02:19 PM, Jeremy Linton wrote:
> On 08/17/2015 03:45 PM, Guenter Roeck wrote:
>> Commit 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT") makes
>> the call to smsc911x_probe_config() unconditional, and no longer fails if
>> there is no device node. device_get_phy_mode() is called unconditionally,
>> and if there is no phy node configured returns an error code. This error
>> code is assigned to phy_interface, and interpreted elsewhere in the code
>> as valid phy mode. This in turn causes qemu to crash when running a
>> variant of realview_pb_defconfig.
>
> Thanks for catching that! I have a couple other minor cleanups per the reviewers.
>

One nitpick I noticed after sending my patch: dev can never be NULL in
smsc911x_probe_config(), so it does not really make sense to check if it is NULL.

Guenter
