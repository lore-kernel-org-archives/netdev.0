From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: Re: [PATCH 3.7.0-rc4] of/net/mdio-gpio: Fix pdev->id issue when using
 devicetrees.
Date: Fri, 16 Nov 2012 09:54:47 +0000
Message-ID: <50A60D67.6000100@st.com>
References: <1352816773-17837-1-git-send-email-srinivas.kandagatla@st.com> <20121114.185940.648295821386414260.davem@davemloft.net>
Reply-To: srinivas.kandagatla@st.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org
To: David Miller <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:33319 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751243Ab2KPJ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 04:56:37 -0500
In-Reply-To: <20121114.185940.648295821386414260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/11/12 23:59, David Miller wrote:
> From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
> Date: Tue, 13 Nov 2012 14:26:13 +0000
>
>> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>>
>> When the mdio-gpio driver is probed via device trees, the platform
>> device id is set as -1, However the id is re-used in the code while
>> creating an mdio bus.
>> So, setting up the id via aliases from device tree is a sensible
>> solution to fix this issue.
>>
>> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> This seems rather pointless unless you also update every single device
> tree out there.
>
> Also you need to describe what are the ramifications of this problem
> otherwise it is impossible to figure out how serious this change is.
>
> Does it prevent probing?  Does it cause a crash?
I apologies, I should have explained the full use-case.

use-case is if the mac driver want to connect via phy_connect() to
mdio-gpio phy it would use bus name to do so.

mdio-gpio phy bus name is formated as "gpio-<bus-number>:<phy-addr>.
In the existing code the bus number for mdio-gpio if probed from device
trees will be set to -1 which results in bus name set to
"gpio-ffffffff:<phy-addr>" which is the problem here.
fffffff is result of pdev->id set to -1 which should be set to a logical
number, and this is only possible via aliases.

Having fffffff as bus-id also means that we can't have two mdio-gpio
buses via device trees as it will result in same bus-id.
This patch attempts to fix this issue.
So getting the id from alias would be a right choice.

I also agree with Grant's comments about setting up pdev->id.

Will send v2 patch with considering Grant's comments.

>
> Basically, what I'm saying is that this is a very poor submission and
> you need to substantially improve it and communicate better.
>
> If the problem is basically benign, then you should target this change
> to net-next instead of the net tree, along with the necessary dt file
> updates.
I have looked in net-next and there are no dt files which use this driver.

Thanks,
srini
> Thanks.
>
>
