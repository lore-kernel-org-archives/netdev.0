From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] fix tcp_default_win_scale.
Date: Wed, 7 Jul 2004 15:47:30 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.NEB.4.33.0407071541380.19720-100000@dexter.psc.edu>
References: <20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, bert hubert <ahu@ds9a.nl>,
	Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	<netdev@oss.sgi.com>, <alessandro.suardi@oracle.com>,
	<phyprabab@yahoo.com>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040706114741.1bf98bbe@dell_ss3.pdx.osdl.net>
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004, Stephen Hemminger wrote:

> +/* Default window scaling based on the size of the maximum window  */
> +static inline __u8 tcp_default_win_scale(void)
> +{
> +	int b = ffs(sysctl_tcp_rmem[2]);
> +	return (b < 17) ? 0 : b-16;
> +}


I would actually change this to be:

static inline __u8 tcp_select_win_scale(void)
{
	int b = ffs(tcp_win_from_space(max(sysctl_tcp_rmem[2], sysctl_rmem_max)));
	b = (b < 17) ? 0 : b-16;
	return max(b, 14);
}

Then you can also get rid of all the window scale calculation code in
tcp_select_initial_window().

  -John

