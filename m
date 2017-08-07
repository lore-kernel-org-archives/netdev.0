From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/6] In-kernel QMI handling
Date: Mon, 7 Aug 2017 21:19:30 +0200
Message-ID: <08647880-96CF-4A0A-A75D-0A324022CF32@holtmann.org>
References: <20170804145938.25427-1-bjorn.andersson@linaro.org>
 <1501860967.939.6.camel@redhat.com> <20170807173842.GI29306@minitux>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Dan Williams <dcbw@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org,
        Netdev list <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20170807173842.GI29306@minitux>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

>>> This series starts by moving the common definitions of the QMUX
>>> protocol to the
>>> uapi header, as they are shared with clients - both in kernel and
>>> userspace.
>>> 
>>> This series then introduces in-kernel helper functions for aiding the
>>> handling
>>> of QMI encoded messages in the kernel. QMI encoding is a wire-format
>>> used in
>>> exchanging messages between the majority of QRTR clients and
>>> services.
>> 
>> This raises a few red-flags for me.
> 
> I'm glad it does. In discussions with the responsible team within
> Qualcomm I've highlighted a number of concerns about enabling this
> support in the kernel. Together we're continuously looking into what
> should be pushed out to user space, and trying to not introduce
> unnecessary new users.
> 
>> So far, we've kept almost everything QMI related in userspace and
>> handled all QMI control-channel messages from libraries like libqmi or
>> uqmi via the cdc-wdm driver and the "rmnet" interface via the qmi_wwan
>> driver.  The kernel drivers just serve as the transport.
>> 
> 
> The path that was taken to support the MSM-style devices was to
> implement net/qrtr, which exposes a socket interface to abstract the
> physical transports (QMUX or IPCROUTER in Qualcomm terminology).
> 
> As I share you view on letting the kernel handle the transportation only
> the task of keeping track of registered services (service id -> node and
> port mapping) was done in a user space process and so far we've only
> ever have to deal with QMI encoded messages in various user space tools.

I think that the transport and multiplexing can be in the kernel as long as it is done as proper subsystem. Similar to Phonet or CAIF. Meaning it should have a well defined socket interface that can be easily used from userspace, but also a clean in-kernel interface handling.

If Qualcomm is supportive of this effort and is willing to actually assist and/or open some of the specs or interface descriptions, then this is a good thing. Service registration and cleanup is really done best in the kernel. Same applies to multiplexing. Trying to do multiplexing in userspace is always cumbersome and leads to overhead that is of no gain. For example within oFono, we had to force everything to go via oFono since it was the only sane way of handling it. Other approaches were error prone and full of race conditions. You need a central entity that can clean up.

For the definition of an UAPI to share some code, I am actually not sure that is such a good idea. For example the QMI code in oFono follows a way simpler approach. And I am not convinced that all the macros are actually beneficial. For example, the whole netlink macros are pretty cumbersome. Adding some Documentation/qmi.txt on how the wire format looks like and what is expected seems to be a way better approach.

Regards

Marcel
