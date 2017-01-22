From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch] samples/bpf: silence shift wrapping warning
Date: Sun, 22 Jan 2017 14:51:25 -0800
Message-ID: <20170122225123.GA73160@ast-mbp.thefacebook.com>
References: <20170121045143.GC15269@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <ast@kernel.org>,
        Joe Stringer <joe@ovn.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170121045143.GC15269@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 21, 2017 at 07:51:43AM +0300, Dan Carpenter wrote:
> max_key is a value in the 0-63 range, so on 32 bit systems the shift
> could wrap.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Looks fine. I think 'net-next' is ok.

Acked-by: Alexei Starovoitov <ast@kernel.org>

> diff --git a/samples/bpf/lwt_len_hist_user.c b/samples/bpf/lwt_len_hist_user.c
> index ec8f3bb..bd06eef 100644
> --- a/samples/bpf/lwt_len_hist_user.c
> +++ b/samples/bpf/lwt_len_hist_user.c
> @@ -68,7 +68,7 @@ int main(int argc, char **argv)
>  	for (i = 1; i <= max_key + 1; i++) {
>  		stars(starstr, data[i - 1], max_value, MAX_STARS);
>  		printf("%8ld -> %-8ld : %-8ld |%-*s|\n",
> -		       (1l << i) >> 1, (1l << i) - 1, data[i - 1],
> +		       (1ULL << i) >> 1, (1ULL << i) - 1, data[i - 1],
>  		       MAX_STARS, starstr);
>  	}
>  
