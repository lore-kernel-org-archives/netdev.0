From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC] PCI: Allow sysfs control over totalvfs
Date: Wed, 21 Sep 2016 07:55:27 +0200
Message-ID: <20160921055527.GB2078@nanopsycho.orion>
References: <1474386588-16337-1-git-send-email-Yuval.Mintz@qlogic.com>
 <20160920193645.GA12677@nanopsycho.orion>
 <BL2PR07MB23061E60A3ABC771F05764C98DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23061E60A3ABC771F05764C98DF70@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Sep 20, 2016 at 10:27:24PM CEST, Yuval.Mintz@cavium.com wrote:
>> >Some of the HW capable of SRIOV has resource limitations, where the
>> >PF and VFs resources are drawn from a common pool.
>> >In some cases, these limitations have to be considered early during
>> >chip initialization and can only be changed by tearing down the
>> >configuration and re-initializing.
>> >As a result, drivers for such HWs sometimes have to make unfavorable
>> >compromises where they reserve sufficient resources to accomadate
>> >the maximal number of VFs that can be created - at the expanse of
>> >resources that could have been used by the PF.
>> >
>> >If users were able to provide 'hints' regarding the required number
>> >of VFs *prior* to driver attachment, then such compromises could be
>> >avoided. As we already have sysfs nodes that can be queried for the
>> >number of totalvfs, it makes sense to let the user reduce the number
>> >of said totalvfs using same infrastrucure.
>> >Then, we can have drivers supporting SRIOV take that value into account
>> >when deciding how much resources to reserve, allowing the PF to benefit
>> >from the difference between the configuration space value and the actual
>> >number needed by user.
>
>> One of the motivations for introducing devlink interface was to allow
>> user to pass some kind of well defined option parameters or as you call
>> it hints to driver module. That would allow to replace module options
>> and introduce similar possibility to pre-configure hardware on probe time.
>> We plan to use devlink to allow user to change resource allocation for
>> mlxsw devices.
>
>Is IOV configuration something you're going to explore in the near
>future for mlxsw devices? Or are you merely pointing out that

No, not sriov related directly.


>devlink could provide a superior configuration infrastrucutre and
>should be investigated as a better alternative?

Exactly. It is a general problem of how to pre-configure driver modules.


>
>> The plan is to allow to pre-create devlink instance before driver module
>> is loaded. Then the user will use this placeholder to do the options
>> setting. Once the driver module is loaded, it will fetch the options
>> from devlink core and process it accordingly.
>
>> I believe this is exactly what you need.
>
>While this sounds far-superior to anything we can do via pci sysfs,
>question is whether adding a devlink support for a device is 
>a reasonable cost for adding this specific configuration [given
>the existing sysfs nodes we already have].

Adding devlink support is trivial in most cases, I bet you can do it in
couple of minutes for your driver.


>I'm not sufficiently familiar with the infrastrucutre there, and I
>wonder whether it will set the bar too high for this sort of
>configuration to be used.
