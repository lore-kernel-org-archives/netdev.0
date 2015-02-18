From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 2/3] Packet sniffer core framework
Date: Wed, 18 Feb 2015 16:42:06 +0100
Message-ID: <54E4B2CE.2090104@iogearbox.net>
References: <cover.1424181053.git.stathis.voukelatos@linn.co.uk> <9202ff9a629935ada672415bf071a1cf31ac09b6.1424181053.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: abrestic@chromium.org, richardcochran@gmail.com
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9202ff9a629935ada672415bf071a1cf31ac09b6.1424181053.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2015 03:03 PM, Stathis Voukelatos wrote:
> The framework registers each backend sniffer channel as a netdev,
> which can be accessed from user space through a raw packet socket.
> Packets received from user space are treated as a command string
> configuration. Each match event from the backend driver will
> generate a packet with the matching bytes plus an optional
> timestamp, if configured by the command string.
>
> Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
> ---
>   MAINTAINERS                             |   6 +
>   drivers/net/Kconfig                     |   2 +
>   drivers/net/Makefile                    |   2 +
>   drivers/net/pkt-sniffer/Kconfig         |   8 +
>   drivers/net/pkt-sniffer/Makefile        |   3 +
>   drivers/net/pkt-sniffer/core/module.c   |  37 +++++
>   drivers/net/pkt-sniffer/core/netdev.c   | 254 ++++++++++++++++++++++++++++++++
>   drivers/net/pkt-sniffer/core/snf_core.h |  60 ++++++++
>   include/uapi/linux/pkt_sniffer.h        |  33 +++++
>   9 files changed, 405 insertions(+)
>   create mode 100644 drivers/net/pkt-sniffer/Kconfig
>   create mode 100644 drivers/net/pkt-sniffer/Makefile
>   create mode 100644 drivers/net/pkt-sniffer/core/module.c
>   create mode 100644 drivers/net/pkt-sniffer/core/netdev.c
>   create mode 100644 drivers/net/pkt-sniffer/core/snf_core.h
>   create mode 100644 include/uapi/linux/pkt_sniffer.h
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index aaa039d..7d882de 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5754,6 +5754,12 @@ M:	Sasha Levin <sasha.levin@oracle.com>
>   S:	Maintained
>   F:	tools/lib/lockdep/
>
> +LINN PACKET SNIFFER DRIVER
> +M: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
> +S: Maintained
> +F: drivers/net/pkt-sniffer/
> +F: Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt

This whole framework really looks like only tailored to your specific
driver, I have no idea who else should reuse that?! So, I don't think
putting this under drivers/net/pkt-sniffer/ is a good idea.

Also it looks slightly confusing as if I understand you correctly, your
module's purpose is to pass down some "packet pattern" to the hardware
and match that in order to get a precise timestamp in return?

Might perhaps be better to have everything vendor-specific under something
like drivers/net/ethernet/linn/ and have the framework squashed into the
driver itself (if parts cannot be generalized in net/packet/).

It would be good if you can also avoid the extra uapi export. Perhaps
it's possible to reuse at least some of the existing timestamping
infrastructure?
