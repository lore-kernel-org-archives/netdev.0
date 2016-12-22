From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 2/3] Bluetooth: btusb: Add out-of-band wakeup support
Date: Thu, 22 Dec 2016 16:39:46 -0600
Message-ID: <20161222223946.ylywkzd7abl55y4l@rob-hp-laptop>
References: <1482352432-38302-1-git-send-email-rajatja@google.com>
 <1482352432-38302-2-git-send-email-rajatja@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland@arm.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Amitkumar Karwar <akarwar@marvell.com>,
        Wei-Ning Huang <wnhuang@chromium.org>,
        Xinming Hu <huxm@marvell.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        Brian Norris <briannorris@google.com>,
        linux-kernel@vger.kernel.org, rajatxjain@gmail.com
To: Rajat Jain <rajatja@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482352432-38302-2-git-send-email-rajatja@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 12:33:51PM -0800, Rajat Jain wrote:
> Some onboard BT chips (e.g. Marvell 8997) contain a wakeup pin that
> can be connected to a gpio on the CPU side, and can be used to wakeup
> the host out-of-band. This can be useful in situations where the
> in-band wakeup is not possible or not preferable (e.g. the in-band
> wakeup may require the USB host controller to remain active, and
> hence consuming more system power during system sleep).
> 
> The oob gpio interrupt to be used for wakeup on the CPU side, is
> read from the device tree node, (using standard interrupt descriptors).
> A devcie tree binding document is also added for the driver. The
> compatible string is in compliance with
> Documentation/devicetree/bindings/usb/usb-device.txt
> 
> Signed-off-by: Rajat Jain <rajatja@google.com>
> Reviewed-by: Brian Norris <briannorris@chromium.org>
> ---
> v4: Move the set_bit(BTUSB_OOB_WAKE_DISABLED,..) call to the beginning of
>     btusb_config_oob_wake() - caught by Brian.
> v3: Add Brian's "Reviewed-by"
> v2: * Use interrupt-names ("wakeup") instead of assuming first interrupt.
>     * Leave it on device tree to specify IRQ flags (level /edge triggered)
>     * Mark the device as non wakeable on exit.
> 
>  Documentation/devicetree/bindings/net/btusb.txt | 40 ++++++++++++

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/bluetooth/btusb.c                       | 84 +++++++++++++++++++++++++
>  2 files changed, 124 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/btusb.txt
