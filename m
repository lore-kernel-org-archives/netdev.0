From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 net-next] nstat: add sctp snmp support
Date: Fri, 2 Sep 2016 12:09:12 +0200
Message-ID: <20160902100912.GC5252@orbyte.nwl.cc>
References: <1472800358-31881-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55566 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753202AbcIBKJO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 06:09:14 -0400
Content-Disposition: inline
In-Reply-To: <1472800358-31881-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2016 at 03:12:38PM +0800, Hangbin Liu wrote:
> SCTP module was not load by default. But this should be OK since we will not
> load table if fdopen() failed.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> ---
>  misc/nstat.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> diff --git a/misc/nstat.c b/misc/nstat.c
> index 6143719..8035be4 100644
> --- a/misc/nstat.c
> +++ b/misc/nstat.c
> @@ -76,6 +76,11 @@ static int net_snmp6_open(void)
>  	return generic_proc_open("PROC_NET_SNMP6", "net/snmp6");
>  }
>  
> +static int net_sctp_snmp_open(void)
> +{
> +	return generic_proc_open("PROC_NET_SCTP_SNMP", "net/sctp/snmp");
> +}
> +
>  struct nstat_ent {
>  	struct nstat_ent *next;
>  	char		 *id;
> @@ -247,6 +252,16 @@ static void load_ugly_table(FILE *fp)
>  	}
>  }
>  
> +static void load_sctp_snmp(void)
> +{
> +	FILE *fp = fdopen(net_sctp_snmp_open(), "r");
> +
> +	if (fp) {
> +		load_good_table(fp);
> +		fclose(fp);
> +	}
> +}
> +
>  static void load_snmp(void)
>  {
>  	FILE *fp = fdopen(net_snmp_open(), "r");
> @@ -450,6 +465,7 @@ static void server_loop(int fd)
>  	load_netstat();
>  	load_snmp6();
>  	load_snmp();
> +	load_sctp_snmp();
>  
>  	for (;;) {
>  		int status;
> @@ -706,6 +722,7 @@ int main(int argc, char *argv[])
>  		load_netstat();
>  		load_snmp6();
>  		load_snmp();
> +		load_sctp_snmp();
>  		if (info_source[0] == 0)
>  			strcpy(info_source, "kernel");
>  	}

Did you forget to add the load call to update_db(), or am I missing
something?

Apart from that, looks nice and clean.

Cheers, Phil
