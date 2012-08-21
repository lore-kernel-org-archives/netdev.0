From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [iproute2][PATCH] utils: invarg: msg precedes the faulty arg
Date: Tue, 21 Aug 2012 08:54:45 +0800
Message-ID: <5032DC55.5010804@cn.fujitsu.com>
References: <1345119956-16863-1-git-send-email-danken@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Dan Kenigsberg <danken@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56011 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754143Ab2HUAzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 20:55:44 -0400
In-Reply-To: <1345119956-16863-1-git-send-email-danken@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2012 08:25 PM, Dan Kenigsberg wrote:
> fix all call which reversed the arg order.

To send a patch for iproute2, you'd better to or cc the
maintainer(Stephen Hemminger <shemminger@vyatta.com>).

Thanks

> 
> Signed-off-by: Dan Kenigsberg <danken@redhat.com>
> ---
>  ip/ip.c        |    2 +-
>  ip/ipaddress.c |    2 +-
>  tc/tc_class.c  |   10 +++++-----
>  tc/tc_filter.c |   12 ++++++------
>  tc/tc_qdisc.c  |    4 ++--
>  5 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/ip/ip.c b/ip/ip.c
> index 20dc3b5..4e8ac5c 100644
> --- a/ip/ip.c
> +++ b/ip/ip.c
> @@ -188,7 +188,7 @@ int main(int argc, char **argv)
>  			else if (strcmp(argv[1], "help") == 0)
>  				usage();
>  			else
> -				invarg(argv[1], "invalid protocol family");
> +				invarg("invalid protocol family", argv[1]);
>  		} else if (strcmp(opt, "-4") == 0) {
>  			preferred_family = AF_INET;
>  		} else if (strcmp(opt, "-6") == 0) {
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 69a63b3..cbff143 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1147,7 +1147,7 @@ static int ipaddr_modify(int cmd, int flags, int argc, char **argv)
>  			unsigned scope = 0;
>  			NEXT_ARG();
>  			if (rtnl_rtscope_a2n(&scope, *argv))
> -				invarg(*argv, "invalid scope value.");
> +				invarg("invalid scope value.", *argv);
>  			req.ifa.ifa_scope = scope;
>  			scoped = 1;
>  		} else if (strcmp(*argv, "dev") == 0) {
> diff --git a/tc/tc_class.c b/tc/tc_class.c
> index de18fd1..95bf615 100644
> --- a/tc/tc_class.c
> +++ b/tc/tc_class.c
> @@ -74,7 +74,7 @@ int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
>  			if (req.t.tcm_handle)
>  				duparg("classid", *argv);
>  			if (get_tc_classid(&handle, *argv))
> -				invarg(*argv, "invalid class ID");
> +				invarg("invalid class ID", *argv);
>  			req.t.tcm_handle = handle;
>  		} else if (strcmp(*argv, "handle") == 0) {
>  			fprintf(stderr, "Error: try \"classid\" instead of \"handle\"\n");
> @@ -91,7 +91,7 @@ int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
>  			if (req.t.tcm_parent)
>  				duparg("parent", *argv);
>  			if (get_tc_classid(&handle, *argv))
> -				invarg(*argv, "invalid parent ID");
> +				invarg("invalid parent ID", *argv);
>  			req.t.tcm_parent = handle;
>  		} else if (matches(*argv, "estimator") == 0) {
>  			if (parse_estimator(&argc, &argv, &est))
> @@ -252,13 +252,13 @@ int tc_class_list(int argc, char **argv)
>  			if (filter_qdisc)
>  				duparg("qdisc", *argv);
>  			if (get_qdisc_handle(&filter_qdisc, *argv))
> -				invarg(*argv, "invalid qdisc ID");
> +				invarg("invalid qdisc ID", *argv);
>  		} else if (strcmp(*argv, "classid") == 0) {
>  			NEXT_ARG();
>  			if (filter_classid)
>  				duparg("classid", *argv);
>  			if (get_tc_classid(&filter_classid, *argv))
> -				invarg(*argv, "invalid class ID");
> +				invarg("invalid class ID", *argv);
>  		} else if (strcmp(*argv, "root") == 0) {
>  			if (t.tcm_parent) {
>  				fprintf(stderr, "Error: \"root\" is duplicate parent ID\n");
> @@ -271,7 +271,7 @@ int tc_class_list(int argc, char **argv)
>  				duparg("parent", *argv);
>  			NEXT_ARG();
>  			if (get_tc_classid(&handle, *argv))
> -				invarg(*argv, "invalid parent ID");
> +				invarg("invalid parent ID", *argv);
>  			t.tcm_parent = handle;
>  		} else if (matches(*argv, "help") == 0) {
>  			usage();
> diff --git a/tc/tc_filter.c b/tc/tc_filter.c
> index 04c3b82..c9e09d8 100644
> --- a/tc/tc_filter.c
> +++ b/tc/tc_filter.c
> @@ -93,7 +93,7 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
>  			if (req.t.tcm_parent)
>  				duparg("parent", *argv);
>  			if (get_tc_classid(&handle, *argv))
> -				invarg(*argv, "Invalid parent ID");
> +				invarg("Invalid parent ID", *argv);
>  			req.t.tcm_parent = handle;
>  		} else if (strcmp(*argv, "handle") == 0) {
>  			NEXT_ARG();
> @@ -106,14 +106,14 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
>  			if (prio)
>  				duparg("priority", *argv);
>  			if (get_u32(&prio, *argv, 0) || prio > 0xFFFF)
> -				invarg(*argv, "invalid priority value");
> +				invarg("invalid priority value", *argv);
>  		} else if (matches(*argv, "protocol") == 0) {
>  			__u16 id;
>  			NEXT_ARG();
>  			if (protocol_set)
>  				duparg("protocol", *argv);
>  			if (ll_proto_a2n(&id, *argv))
> -				invarg(*argv, "invalid protocol");
> +				invarg("invalid protocol", *argv);
>  			protocol = id;
>  			protocol_set = 1;
>  		} else if (matches(*argv, "estimator") == 0) {
> @@ -290,7 +290,7 @@ int tc_filter_list(int argc, char **argv)
>  			if (t.tcm_parent)
>  				duparg("parent", *argv);
>  			if (get_tc_classid(&handle, *argv))
> -				invarg(*argv, "invalid parent ID");
> +				invarg("invalid parent ID", *argv);
>  			filter_parent = t.tcm_parent = handle;
>  		} else if (strcmp(*argv, "handle") == 0) {
>  			NEXT_ARG();
> @@ -303,7 +303,7 @@ int tc_filter_list(int argc, char **argv)
>  			if (prio)
>  				duparg("priority", *argv);
>  			if (get_u32(&prio, *argv, 0))
> -				invarg(*argv, "invalid preference");
> +				invarg("invalid preference", *argv);
>  			filter_prio = prio;
>  		} else if (matches(*argv, "protocol") == 0) {
>  			__u16 res;
> @@ -311,7 +311,7 @@ int tc_filter_list(int argc, char **argv)
>  			if (protocol)
>  				duparg("protocol", *argv);
>  			if (ll_proto_a2n(&res, *argv))
> -				invarg(*argv, "invalid protocol");
> +				invarg("invalid protocol", *argv);
>  			protocol = res;
>  			filter_protocol = protocol;
>  		} else if (matches(*argv, "help") == 0) {
> diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
> index 3f932a7..c8d7335 100644
> --- a/tc/tc_qdisc.c
> +++ b/tc/tc_qdisc.c
> @@ -83,7 +83,7 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
>  				duparg("handle", *argv);
>  			NEXT_ARG();
>  			if (get_qdisc_handle(&handle, *argv))
> -				invarg(*argv, "invalid qdisc ID");
> +				invarg("invalid qdisc ID", *argv);
>  			req.t.tcm_handle = handle;
>  		} else if (strcmp(*argv, "root") == 0) {
>  			if (req.t.tcm_parent) {
> @@ -111,7 +111,7 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
>  			if (req.t.tcm_parent)
>  				duparg("parent", *argv);
>  			if (get_tc_classid(&handle, *argv))
> -				invarg(*argv, "invalid parent ID");
> +				invarg("invalid parent ID", *argv);
>  			req.t.tcm_parent = handle;
>  		} else if (matches(*argv, "estimator") == 0) {
>  			if (parse_estimator(&argc, &argv, &est))
