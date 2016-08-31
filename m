From: Robert Foss <robert.foss@collabora.com>
Subject: Re: [PATCH v3 0/5] net/usb: asix driver improvements
Date: Wed, 31 Aug 2016 13:28:34 -0400
Message-ID: <b1afa44f-7c41-c9bc-bb0f-9ccced25a0ef@collabora.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: freddy@asix.com.tw, Dean_Jenkins@mentor.com,
        Mark_Craske@mentor.com, davem@davemloft.net, ivecera@redhat.com,
        john.stultz@linaro.org, vpalatin@chromium.org,
        stephen@networkplumber.org, grundler@chromium.org,
        changchias@gmail.com, allan@asix.com.tw, andrew@lunn.ch,
        tremyfr@gmail.com, colin.king@canonical.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vpalatin@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Additional testing has been done the hardware that is available to me.
I'm not seeing any dmesg warnings/errors that are new to this series:

AX88772A
- Pass network_EthernetStressPlug
- Pass phy up/down + iperf3 UDP stress
- Pass network_EthernetStressPlug + iperf3 UDP stress

AX88772B
- Pass network_EthernetStressPlug
- Pass phy up/down + iperf3 UDP stress
- Pass network_EthernetStressPlug + iperf3 UDP stress

Cisco AX88772 A(?)
- Pass network_EthernetStressPlug
- Pass phy up/down + iperf3 UDP stress
- Pass network_EthernetStressPlug + iperf3 UDP stress

Cisco AX88772 B(?)
- Pass network_EthernetStressPlug
- Pass phy up/down + iperf3 UDP stress
- Pass network_EthernetStressPlug + iperf3 UDP stress

AX88178
- Pass network_EthernetStressPlug
- Pass phy up/down + iperf3 UDP stress
- Pass network_EthernetStressPlug + iperf3 UDP stress

AX88179
- Pass network_EthernetStressPlug
- Pass phy up/down + iperf3 UDP stress?
-- [ 8794.555902] ax88179_178a 1-1.3:1.0 eth1: kevent 4 may have been
    dropped
- Pass network_EthernetStressPlug + iperf3 UDP stresss


I also saw some sporadic header checksum errors.
But those too are seen on upstream/master.

asix_rx_fixup() Bad Header Length 0x98a993c8, offset 4


Test details:
network_EthernetStressPlug:
     http://memcpy.io/ethernet-device-stress-testing.html

phy up/down:
     for i in
         {1..10}
     do
         sudo ifdown eth1
         if sudo ifup eth1; then
            echo "Command success"
        else
            echo "Command failed"
        fi
     done

iperf3 UDP:
     sudo iperf3 -c 192.168.0.28 -u  -b 100M -t 0





On 2016-08-29 09:32 AM, robert.foss@collabora.com wrote:
> From: Robert Foss <robert.foss@collabora.com>
>
> This is a resubmission of v3, since the netdev
> mailinlist was not sent the previous submission.
>
> This series improves power management of the asix driver.
>
>  - Suspend/resume support is improved to save needed registers.
>  - Device disconnection is improved.
>  - Fixes AX88772x resume failures
>  - Implementes IEEE 802.3 spec section "22.2.4.1.1 Reset" correctly
>  - Fixes AX_CMD_WRITE_MEDIUM_MODE being set incorrectly
>
> Changes since v1:
> - Added proper metadata tags to series.
> - Added two more patches to series.
>
> Changes since v2:
> - Added coverletter
> - Tested patches on AX88772A/AX88772B/AX88178/AX88179 hardware
>
> Allan Chou (1):
>   net: asix: Fix AX88772x resume failures
>
> Freddy Xin (1):
>   net: asix: Add in_pm parameter
>
> Grant Grundler (2):
>   net: asix: see 802.3 spec for phy reset
>   net: asix: autoneg will set WRITE_MEDIUM reg
>
> Vincent Palatin (1):
>   net: asix: Avoid looping when the device is disconnected
>
>  drivers/net/usb/asix.h         |  40 ++-
>  drivers/net/usb/asix_common.c  | 212 ++++++++++++----
>  drivers/net/usb/asix_devices.c | 450 +++++++++++++++++++++++++++-------
>  drivers/net/usb/ax88172a.c     |  29 +-
>  4 files changed, 575 insertions(+), 156 deletions(-)
>
