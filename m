From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] libertas: Avoid reading past end of buffer
Date: Wed, 10 May 2017 16:05:06 -0700
Message-ID: <1494457506.2028.1.camel@perches.com>
References: <20170510192451.GA115771@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        Daniel Micay <danielmicay@gmail.com>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170510192451.GA115771@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-05-10 at 12:24 -0700, Kees Cook wrote:
> Using memcpy() from a string that is shorter than the length copied means
[]
> diff --git a/drivers/net/wireless/marvell/libertas/mesh.c b/drivers/net/wireless/marvell/libertas/mesh.c
[]
> @@ -1170,17 +1170,11 @@ int lbs_mesh_ethtool_get_sset_count(struct net_device *dev, int sset)
>  void lbs_mesh_ethtool_get_strings(struct net_device *dev,
>  	uint32_t stringset, uint8_t *s)
>  {
> -	int i;
> -
>  	lbs_deb_enter(LBS_DEB_ETHTOOL);
>  
>  	switch (stringset) {
>  	case ETH_SS_STATS:
> -		for (i = 0; i < MESH_STATS_NUM; i++) {
> -			memcpy(s + i * ETH_GSTRING_LEN,
> -					mesh_stat_strings[i],
> -					ETH_GSTRING_LEN);
> -		}
> +		memcpy(s, *mesh_stat_strings, sizeof(mesh_stat_strings));
>  		break;
>  	}
>  	lbs_deb_enter(LBS_DEB_ETHTOOL);

unrelated trivia:

lbs_deb_enter is used incorrectly here at
function exit as both enter and leave calls.

That type of copy/paste defect may be common.

$ git grep -w lbs_deb_enter | wc -l
148
$ git grep -w lbs_deb_leave | wc -l
71

One would expect these numbers to be the same.

Another option would be to delete all these
calls as ftrace function tracing works well.
