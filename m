From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net v2 0/4] r8152: fix scheduling napi
Date: Thu, 26 Jan 2017 03:04:45 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A13865@RTITMBSV06.realtek.com.tw>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
        <1394712342-15778-242-Taiwan-albertk@realtek.com>
 <20170125.143119.411717735878453521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170125.143119.411717735878453521.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, January 26, 2017 3:31 AM
[...]
> I think the fundamental issue is that since you can't stop URBs from
> queueing up, you cannot properly synchronize NAPI and schedule polling
> properly.
> 
> From my perspective what happened here is you want GRO support, but it
> comes at the expense of this extremely racey NAPI support which does
> not at all achieve one of the main advantages of NAPI which is
> interrupt mitigation.

May you apply these patches first, until I find another way to replace
current one? The driver uses NAPI now and I have no idea to find better
way to replace current one. I think it would take me long time to find
out the solution. And the issue is still there until I finish this work.
If now I give up the NAPI and its advantages except for the interrupt
mitigation, some things would become worse.

Our hw supports packet aggregation. The purpose is interrupt mitigation,
too. I wouldn't say it is better than what the NAPI does. However, I
could say we try to improve it. If the interrupt could be disabled, I
would be happy to do it. However, it is the limitation of USB devices.
That is why I still use NAPI even though the interrupt cannot be disabled
for USB devices. Because one of the advantages of NAPI couldn't be
satisfied, I must not use the NAPI. Doesn't it seem too strict?

Best Regards,
Hayes
