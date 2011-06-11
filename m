From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] drivers/ssb/driver_chipcommon_pmu.c: uninitilized
 warning
Date: Sat, 11 Jun 2011 20:50:57 +0200
Message-ID: <20110611205057.4b9bf462@maggie>
References: <1307816085-20062-1-git-send-email-cmdkhh@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Connor Hansen <cmdkhh@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307816085-20062-1-git-send-email-cmdkhh@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 11 Jun 2011 11:14:45 -0700
Connor Hansen <cmdkhh@gmail.com> wrote:

> warning message
> drivers/ssb/driver_chipcommon_pmu.c: In function ssb_pmu_resources_init
> drivers/ssb/driver_chipcommon_pmu.c:420:15: warning: updown_tab_size may
> be used uninitilized in this function.
> 
> updown_tab_size and depend_tab_size may not be set in the bus->chip_id
> switch statement, so set to 0 by default to avoid using uninitialized
> stack space.

We wouldn't be using uninitialized stack space or uninitialized variables,
without this patch. However, for the sake of shutting up the compiler, ACK.

> Signed-off-by: Connor Hansen <cmdkhh@gmail.com>
> ---
>  drivers/ssb/driver_chipcommon_pmu.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/ssb/driver_chipcommon_pmu.c b/drivers/ssb/driver_chipcommon_pmu.c
> index 305ade7..a7aef47 100644
> --- a/drivers/ssb/driver_chipcommon_pmu.c
> +++ b/drivers/ssb/driver_chipcommon_pmu.c
> @@ -417,9 +417,9 @@ static void ssb_pmu_resources_init(struct ssb_chipcommon *cc)
>  	u32 min_msk = 0, max_msk = 0;
>  	unsigned int i;
>  	const struct pmu_res_updown_tab_entry *updown_tab = NULL;
> -	unsigned int updown_tab_size;
> +	unsigned int updown_tab_size = 0;
>  	const struct pmu_res_depend_tab_entry *depend_tab = NULL;
> -	unsigned int depend_tab_size;
> +	unsigned int depend_tab_size = 0;
>  
>  	switch (bus->chip_id) {
>  	case 0x4312:
