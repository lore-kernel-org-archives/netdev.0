From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/1] ixgbevf: replace enum with MACROs
Date: Wed, 20 Jul 2016 07:29:18 -0700
Message-ID: <CAKgT0UefaX0aqV+mC77zrpWZAQWBKygDCG0Bpq0x2sVyeMpyYw@mail.gmail.com>
References: <1469011313-30044-1-git-send-email-zyjzyj2000@gmail.com> <1469011313-30044-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34469 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbcGTO3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 10:29:19 -0400
Received: by mail-io0-f196.google.com with SMTP id g86so3577904ioj.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 07:29:19 -0700 (PDT)
In-Reply-To: <1469011313-30044-2-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 3:41 AM,  <zyjzyj2000@gmail.com> wrote:
> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
> With the original enum, when a several bits state is set, it is
> possible that the wrong test occurs.
>
> For example,
>
> a state is 0x3, its bits are 11. When testing a state 0x2 whose
> bits are 10, it is difficult to confirm that state 0x2 is set or
> not.
>
> As such, the MACROs are defined to avoid the above error.
>
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf.h | 22 ++++++++++------------
>  1 file changed, 10 insertions(+), 12 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> index 60fc63b..d37b910 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
> @@ -436,18 +436,16 @@ struct ixgbevf_adapter {
>         u8 rss_indir_tbl[IXGBEVF_X550_VFRETA_SIZE];
>  };
>
> -enum ixbgevf_state_t {
> -       __IXGBEVF_TESTING,
> -       __IXGBEVF_RESETTING,
> -       __IXGBEVF_DOWN,
> -       __IXGBEVF_DISABLED,
> -       __IXGBEVF_REMOVING,
> -       __IXGBEVF_SERVICE_SCHED,
> -       __IXGBEVF_SERVICE_INITED,
> -       __IXGBEVF_RESET_REQUESTED,
> -       __IXGBEVF_QUEUE_RESET_REQUESTED,
> -       __IXGBEVF_HW_RESETTING,
> -};
> +#define        __IXGBEVF_TESTING               0x0001
> +#define        __IXGBEVF_RESETTING             0x0002
> +#define        __IXGBEVF_DOWN                  0x0004
> +#define        __IXGBEVF_DISABLED              0x0008
> +#define        __IXGBEVF_REMOVING              0x0010
> +#define        __IXGBEVF_SERVICE_SCHED         0x0020
> +#define        __IXGBEVF_SERVICE_INITED        0x0040
> +#define        __IXGBEVF_RESET_REQUESTED       0x0080
> +#define        __IXGBEVF_QUEUE_RESET_REQUESTED 0x0100
> +#define        __IXGBEVF_HW_RESETTING          0x0200
>
>  enum ixgbevf_boards {
>         board_82599_vf,

You cannot replace a bit offset with a mask without also having to
update all the spots where the bit offset is used.

There isn't much point to replacing the enum with a macro anyway.
Using multiple test_bit expressions should be valid for testing
multiple bits.

- Alex
