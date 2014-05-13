From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: resume phydev when PHY_RESUMING
Date: Tue, 13 May 2014 12:46:05 -0700
Message-ID: <CAGVrzca9_KFtgjOywvjSm4gqL7OH5BtmQjk8e0xs3Nb+h-qZDA@mail.gmail.com>
References: <1399972998-21772-1-git-send-email-zhangfei.gao@linaro.org> <53726999.4050103@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jiancheng Xue <xuejiancheng@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:62405 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364AbaEMTqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 15:46:46 -0400
Received: by mail-qc0-f170.google.com with SMTP id i8so1172748qcq.1
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 12:46:45 -0700 (PDT)
In-Reply-To: <53726999.4050103@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-13 11:51 GMT-07:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
>
> On 05/13/2014 01:23 PM, Zhangfei Gao wrote:
>
>> Commit be9dad1f9f26604fb suspend phydev when going to HALTED.
>
>
>    Please also specify that commit's summary line in parens.

That, and please rephrase your commit message such that we can
understand the problem this fixes. Something along the lines of:

"With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
to HALTED"), an unused PHY device will be put in a low-power mode
using BMCR_PDOWN. Some Ethernet drivers might be calling phy_connect()
and phy_disconnect() from their ndo_open, respectively ndo_close()
callbacks, in such a case, the PHY will be powered down during the
phy_disconnect() call, but will fail to be powered up in
phy_connect(). This patch fixes the following scenario."

Thanks

>
>
>> However not to resume phydev when going to RESUMING.
>> BMCR_PDOWN remains set "ifconfig eth0 down" -> "ifconfig eth0 up".
>> Unless phy_attach_direct is called in open function.
>
>
>> Fix the issue via phy_resume in PHY_RESUMING
>
>
>> Signed-off-by: Jiancheng Xue <xuejiancheng@huawei.com>
>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>
>
> WBR, Sergei
>



-- 
Florian
