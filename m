From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] mac80211: fix memory leak
Date: Mon, 1 Feb 2016 11:03:35 +1100
Message-ID: <CAGRGNgXc9PtYY=hb8nNRt4T5YGm2vexcJ01Z1fCCcb=57WRZ3g@mail.gmail.com>
References: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sudip,

On Fri, Jan 29, 2016 at 8:49 PM, Sudip Mukherjee
<sudipm.mukherjee@gmail.com> wrote:
> On error we jumped to the error label and returned the error code but we
> missed releasing sinfo.
>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

Should the From: and Signed-off-by: email addresses be the same?

> ---
>  net/mac80211/sta_info.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
> index 6c198e6..36e75c4 100644
> --- a/net/mac80211/sta_info.c
> +++ b/net/mac80211/sta_info.c
> @@ -561,6 +561,7 @@ static int sta_info_insert_finish(struct sta_info *sta) __acquires(RCU)
>         __cleanup_single_sta(sta);
>   out_err:
>         mutex_unlock(&local->sta_mtx);
> +       kfree(sinfo);
>         rcu_read_lock();
>         return err;
>  }

Looks sane to me. I must note that the bug this is fixing is only in
the mac80211-next tree.

Fixes: 5fe74014172d ("mac80211: avoid excessive stack usage in sta_info")
Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
