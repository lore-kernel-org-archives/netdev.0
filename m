From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH V2] r8152: add Linksys USB3GIGV1 id
Date: Tue, 26 Sep 2017 08:19:46 -0700
Message-ID: <CAD=FV=Uk=oPuF7LMhHPM_CTPNEa_G26R6Ce023pTNCCsyqts1Q@mail.gmail.com>
References: <20170926010925.114436-1-grundler@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hayes Wang <hayeswang@realtek.com>,
        linux-usb <linux-usb@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Grant Grundler <grundler@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926010925.114436-1-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On Mon, Sep 25, 2017 at 6:09 PM, Grant Grundler <grundler@chromium.org> wrote:
> This linksys dongle by default comes up in cdc_ether mode.
> This patch allows r8152 to claim the device:
>    Bus 002 Device 002: ID 13b1:0041 Linksys
>
> Signed-off-by: Grant Grundler <grundler@chromium.org>
> ---
>  drivers/net/usb/cdc_ether.c | 8 ++++++++
>  drivers/net/usb/r8152.c     | 2 ++
>  2 files changed, 10 insertions(+)
>
> V2: add LINKSYS_VENDOR_ID to cdc_ether blacklist

I understand that in v1 people pointed out that if we didn't add this
to the cdc_ether blacklist that we might end up picking the wrong
driver.  ...but one thing concerns me: what happens if someone has the
CDC_ETHER driver configured in their system but _not_ the R8152
driver?  All of a sudden this USB Ethernet adapter which used to work
fine with the CDC Ethernet driver will stop working.

I know that for at least some of the adapters in the CDC Ethernet
blacklist it was claimed that the CDC Ethernet support in the adapter
was kinda broken anyway so the blacklist made sense.  ...but for the
Linksys Gigabit adapter the CDC Ethernet driver seems to work OK, it's
just not quite as full featured / efficient as the R8152 driver.

Is that not a concern?  I guess you could tell people in this
situation that they simply need to enable the R8152 driver to get
continued support for their Ethernet adapter?


-Doug
