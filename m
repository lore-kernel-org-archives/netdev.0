From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [RFC PATCH net-next 1/4] perf tools: Enable pre-event inherit
 setting by config terms
Date: Wed, 28 Oct 2015 14:21:26 +0100
Message-ID: <20151028132126.GD5216@krava.brq.redhat.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
 <1446029705-199659-2-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@kernel.org, ast@kernel.org, brendan.d.gregg@gmail.com,
	jolsa@kernel.org, lizefan@huawei.com, pi3orama@163.com,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Wang Nan <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446029705-199659-2-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2015 at 10:55:02AM +0000, Wang Nan wrote:

SNIP

> diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
> index f820906..397fb4e 100644
> --- a/tools/perf/util/evsel.c
> +++ b/tools/perf/util/evsel.c
> @@ -653,6 +653,15 @@ static void apply_config_terms(struct perf_evsel *evsel,
>  		case PERF_EVSEL__CONFIG_TERM_STACK_USER:
>  			dump_size = term->val.stack_user;
>  			break;
> +		case PERF_EVSEL__CONFIG_TERM_INHERIT:
> +			/*
> +			 * attr->inherit should has already been set by
> +			 * perf_evsel__config. If user explicitly set
> +			 * inherit using config terms, override global
> +			 * opt->no_inherit setting.
> +			 */
> +			attr->inherit = term->val.inherit ? 1 : 0;
> +			break;
>  		default:
>  			break;
>  		}
> diff --git a/tools/perf/util/evsel.h b/tools/perf/util/evsel.h
> index 9a95e73..e402f83 100644
> --- a/tools/perf/util/evsel.h
> +++ b/tools/perf/util/evsel.h
> @@ -43,6 +43,7 @@ enum {
>  	PERF_EVSEL__CONFIG_TERM_TIME,
>  	PERF_EVSEL__CONFIG_TERM_CALLGRAPH,
>  	PERF_EVSEL__CONFIG_TERM_STACK_USER,
> +	PERF_EVSEL__CONFIG_TERM_INHERIT,
>  	PERF_EVSEL__CONFIG_TERM_MAX,
>  };
>  
> @@ -55,6 +56,7 @@ struct perf_evsel_config_term {
>  		bool	time;
>  		char	*callgraph;
>  		u64	stack_user;
> +		u64	inherit;

seems like bool would be enough

jirka
