From: AceLan Kao <acelan.kao@canonical.com>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Thu, 28 Sep 2017 16:28:26 +0800
Message-ID: <CAFv23Qn4OMuHaSA6UG+Q7L1sTt+ZO8T-JYVaBM1FxZtGNxOhdQ@mail.gmail.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
 <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
 <20170926064456.GA28611@infradead.org> <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
 <20170926140413.GA19977@infradead.org> <878th14kde.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Christoph Hellwig <hch@infradead.org>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
        Daniel Drake <drake@endlessm.com>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878th14kde.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christoph,

I'm okay with ether ways, but just worrying the regression if we
switch to use MSI by default.

Hi Daniel,

I've tried your patch, but it doesn't work for me.
Wifi can scan AP, but can't get connected.
It keeps showing
[   48.362297] wlp2s0: authenticate with 3c:ce:73:48:0e:40
[   48.374445] wlp2s0: send auth to 3c:ce:73:48:0e:40 (try 1/3)
[   49.824071] wlp2s0: send auth to 3c:ce:73:48:0e:40 (try 2/3)
[   50.848143] wlp2s0: send auth to 3c:ce:73:48:0e:40 (try 3/3)
[   51.840078] wlp2s0: authentication with 3c:ce:73:48:0e:40 timed out
[   52.038561] wlp2s0: authenticate with 3c:ce:73:48:04:80
[   52.058930] wlp2s0: send auth to 3c:ce:73:48:04:80 (try 1/3)
[   52.832063] wlp2s0: send auth to 3c:ce:73:48:04:80 (try 2/3)
[   53.824135] wlp2s0: send auth to 3c:ce:73:48:04:80 (try 3/3)
[   54.816067] wlp2s0: authentication with 3c:ce:73:48:04:80 timed out
[   55.904797] wlp2s0: authenticate with 3c:ce:73:48:04:80
[   55.921771] wlp2s0: send auth to 3c:ce:73:48:04:80 (try 1/3)
[   56.800151] wlp2s0: send auth to 3c:ce:73:48:04:80 (try 2/3)
[   57.824072] wlp2s0: send auth to 3c:ce:73:48:04:80 (try 3/3)

02:00.0 Network controller [0280]: Qualcomm Atheros QCA9565 / AR9565
Wireless Network Adapter [168c:0036] (rev 01)
       Subsystem: Dell QCA9565 / AR9565 Wireless Network Adapter [1028:020e]
       Kernel driver in use: ath9k
       Kernel modules: ath9k

Do you have a chance to see if my patch works on your side?

Best regards,
AceLan Kao.

2017-09-26 22:14 GMT+08:00 Kalle Valo <kvalo@codeaurora.org>:
> Christoph Hellwig <hch@infradead.org> writes:
>
>> On Tue, Sep 26, 2017 at 03:26:51PM +0800, AceLan Kao wrote:
>>> Ath9k is an old driver for old chips, and they work fine with legacy INTx.
>>> But some new platforms are using it, so I think we should list those
>>> new platforms which blocks INTx in the driver.
>>
>> And unless they are broken and need a quirk they should work even better
>> with MSI if the device advertises MSI support in the PCI capabilities.
>
> Daniel Drake (CCed) already found problems with the MSI implementation:
>
> https://lkml.kernel.org/r/20170925041153.26574-1-drake@endlessm.com
>
> --
> Kalle Valo
