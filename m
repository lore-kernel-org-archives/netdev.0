From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/6] In-kernel QMI handling
Date: Tue, 8 Aug 2017 13:13:22 +0200
Message-ID: <43B553C5-4473-482D-9648-6031088AAAD5@holtmann.org>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
 <8737921fw2.fsf@miraculix.mork.no>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Bjorn Andersson <bjorn.andersson@linaro.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        Netdev list <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737921fw2.fsf@miraculix.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

>> This series starts by moving the common definitions of the QMUX protocol to the
>> uapi header, as they are shared with clients - both in kernel and userspace.
>> 
>> This series then introduces in-kernel helper functions for aiding the handling
>> of QMI encoded messages in the kernel. QMI encoding is a wire-format used in
>> exchanging messages between the majority of QRTR clients and services.
> 
> Interesting!  I tried to add some QMI handling in the kernel a few years
> ago, but was thankfully voted down.  See
> https://www.spinics.net/lists/netdev/msg183101.html and the following
> discussion. I am convinced that was the right decision, for the client
> side at least. The protocol is just too extensive and ever-growing to be
> implemented in the kernel. We would be catching up forever.

I think that even back then I said, that it has to be done as a proper subsystem if it has a chance to be in the kernel. So something similar to Phonet and CAIF where the service registration is handled by the kernel, but applications can be fully in userspace. None of this is actually brand new Qualcomm design since Nokia has had its Phonet long before QMI existed.

The real importance is that Qualcomm is behind this and wants to get this done a clean way with a proper API. The /dev/qmi thing was a pretty broken interface. Any subsystem has to support multiple QMI devices. Even if this is unlikely in a phone design, it has to be supported so that attaching two USB QMI based dongles does not end up with some pointless errors.

Regards

Marcel
