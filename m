From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 29 Jan 2016 14:38:15 -0600
Message-ID: <56ABCDB7.5080203@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org, Christopher Covington <cov@codeaurora.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
>> The emac is present on a lot of Qualcomm SOCs, and there are only a few
>> variations of it.  It's not really SOC-specific, and the hardware version
>> can be queried by the driver.
>
> Can the integration bugs be queried, too?
>
> Come on, you know how compatible strings work.

Fine.  I'll figure something out.

>> What did you have in mind?  I don't know even have a list of which SOCs has
>> an emac, especially since it's mostly on MSM parts, and I work on the server
>> SOC.
>
> You only need the one you care about. Figure out the part number
> already. Or find the closest MSM part.

Ironically, the only SOC I actually care about is not supported by this 
driver yet.

>>>> +- qcom,emac-gpio-mdc  : GPIO pin number of the MDC line of MDIO bus.
>>>> +- qcom,emac-gpio-mdio : GPIO pin number of the MDIO line of MDIO bus.
>>>
>>>
>>> Use the standard binding for GPIO controlled MDIO bus.
>>
>> I'm not familiar with that one.  Are you talking about
>> bindings/net/mdio-gpio.txt?
>
> Yes.

Thanks.

>> That, I can't answer.  Aren't all MDIO devices basically the same?  It's
>> been a while since I've worked on them.
>
> No. There was some discussion just this week about needing to require
> phy devices to have compatible strings.

Ok, I'll check it out.

>>> Isn't this a user enabled feature if the h/w supports it?
>>
>>
>> Is there a sysfs entry for that?  We were planning on having a similar ACPI
>> property.
>
> It would be in ethtool I think.

Ah, this driver does not support ethtool yet.

However, based on a cursory look of ethtool, it appears that there's 
only an option to query the current timestamp, but not actually 
enable/disable the feature.  The e1000e driver, for example, just forces 
the feature by default for various chips.  Is there any reason why we 
shouldn't enable it if the hardware supports it?
