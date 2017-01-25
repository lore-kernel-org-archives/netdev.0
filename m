From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch] samples/bpf: silence shift wrapping warning
Date: Wed, 25 Jan 2017 11:08:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026DD27@AcuExch.aculab.com>
References: <20170121045143.GC15269@mwanda>
 <20170122225123.GA73160@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
        Thomas Graf <tgraf@suug.ch>,
        Alexei Starovoitov <ast@kernel.org>,
        Joe Stringer <joe@ovn.org>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
        Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.191]:59332 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751741AbdAYLJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 06:09:00 -0500
In-Reply-To: <20170122225123.GA73160@ast-mbp.thefacebook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov
> Sent: 22 January 2017 22:51
> On Sat, Jan 21, 2017 at 07:51:43AM +0300, Dan Carpenter wrote:
> > max_key is a value in the 0-63 range, so on 32 bit systems the shift
> > could wrap.
> >
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Looks fine. I think 'net-next' is ok.
> 
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 
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

The format effectors are wrong on 32bit systems.

	David
