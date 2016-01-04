From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V3 0/4] Introduce mlx5 ethernet timestamping
Date: Mon, 4 Jan 2016 23:59:25 +0200
Message-ID: <CALzJLG_QujkPHB=VviGFCJjoi1BSG385ODwXmBTmaYTA_aaNdQ@mail.gmail.com>
References: <1451393912-13736-1-git-send-email-saeedm@mellanox.com>
	<CALzJLG_BH1uZR=R49Kzjvv7Gm3NGw0tiL9k61Hw_tra4CGhkHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:32992 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbcADV7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 16:59:46 -0500
Received: by mail-yk0-f169.google.com with SMTP id k129so240252295yke.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:59:26 -0800 (PST)
In-Reply-To: <CALzJLG_BH1uZR=R49Kzjvv7Gm3NGw0tiL9k61Hw_tra4CGhkHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry my mistake,

please ignore my last email, just got your response on the matter,

On Mon, Jan 4, 2016 at 11:57 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> Hi Dave,
>
> Any chance you are giving this a shot ?
>
> On Tue, Dec 29, 2015 at 2:58 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> Hi Dave,
>>
>> This patch series introduces the support for ConnectX-4 timestamping
>> and the PTP kernel interface.
>>
>> Changes from V2:
>> net/mlx5_core: Introduce access function to read internal_timer
>>         - Remove one line function
>>         - Change function name
>>
>> net/mlx5e: Add HW timestamping (TS) support:
>>         - Data path performance optimization (caching tstamp struct in rq,sq)
>>         - Change read/write_lock_irqsave to read/write_lock
>>         - Move ioctl functions to en_clock file
>>         - Changed overflow start algorithm according to comments from Richard
>>         - Move timestamp init/cleanup to open/close ndos.
>>
>> In details:
>>
>> 1st patch prevents the driver from modifying skb->data and SKB CB in
>> device xmit function.
>>
>> 2nd patch adds the needed low level helpers for:
>>         - Fetching the hardware clock (hardware internal timer)
>>         - Parsing CQEs timestamps
>>         - Device frequency capability
>>
>> 3rd patch adds new en_clock.c file that handles all needed timestamping
>> operations:
>>         - Internal clock structure initialization and other helper functions
>>         - Added the needed ioctl for setting/getting the current timestamping
>>           configuration.
>>         - used this configuration in RX/TX data path to fill the SKB with
>>           the timestamp.
>>
>> 4th patch Introduces PTP (PHC) support.
>>
>> Achiad Shochat (1):
>>   net/mlx5e: Do not modify the TX SKB
>>
>> Eran Ben Elisha (3):
>>   net/mlx5_core: Introduce access function to read internal timer
>>   net/mlx5e: Add HW timestamping (TS) support
>>   net/mlx5e: Add PTP Hardware Clock (PHC) support
>>
>>  drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
>>  drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
>>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |   31 ++-
>>  drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  287 ++++++++++++++++++++
>>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   30 ++
>>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   24 ++-
>>  drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +
>>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   85 ++++--
>>  drivers/net/ethernet/mellanox/mlx5/core/main.c     |   13 +
>>  .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
>>  include/linux/mlx5/device.h                        |   20 ++-
>>  include/linux/mlx5/mlx5_ifc.h                      |    6 +-
>>  12 files changed, 467 insertions(+), 42 deletions(-)
>>  create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
>>
