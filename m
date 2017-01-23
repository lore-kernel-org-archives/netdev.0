From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [patch] samples/bpf: silence shift wrapping warning
Date: Mon, 23 Jan 2017 11:27:59 -0200
Message-ID: <20170123132759.GA8227@redhat.com>
References: <20170121045143.GC15269@mwanda>
 <20170122225123.GA73160@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <ast@kernel.org>,
        Joe Stringer <joe@ovn.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170122225123.GA73160@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Sun, Jan 22, 2017 at 02:51:25PM -0800, Alexei Starovoitov escreveu:
> On Sat, Jan 21, 2017 at 07:51:43AM +0300, Dan Carpenter wrote:
> > max_key is a value in the 0-63 range, so on 32 bit systems the shift
> > could wrap.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Looks fine. I think 'net-next' is ok.

I could process these patches, if that would help,

- Arnaldo
 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
 
> > diff --git a/samples/bpf/lwt_len_hist_user.c b/samples/bpf/lwt_len_hist_user.c
> > index ec8f3bb..bd06eef 100644
> > --- a/samples/bpf/lwt_len_hist_user.c
> > +++ b/samples/bpf/lwt_len_hist_user.c
> > @@ -68,7 +68,7 @@ int main(int argc, char **argv)
> >  	for (i = 1; i <= max_key + 1; i++) {
> >  		stars(starstr, data[i - 1], max_value, MAX_STARS);
> >  		printf("%8ld -> %-8ld : %-8ld |%-*s|\n",
> > -		       (1l << i) >> 1, (1l << i) - 1, data[i - 1],
> > +		       (1ULL << i) >> 1, (1ULL << i) - 1, data[i - 1],
> >  		       MAX_STARS, starstr);
> >  	}
> >  
