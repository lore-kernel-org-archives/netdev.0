From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [RFC: add openvswitch actions using BPF 7/9] ofproto-dpif: Add
 eBPF program loader and runtime infrasturcure.
Date: Fri, 6 Feb 2015 10:49:34 -0800
Message-ID: <CANr6G5wMjsrJ4GuGhAT-_4yt0iq_Q=iYG+pH3nzTFg23+Dxt2g@mail.gmail.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com> <1423090163-19902-8-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:55415 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757496AbbBFSt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 13:49:56 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so15289909wgh.6
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 10:49:55 -0800 (PST)
In-Reply-To: <1423090163-19902-8-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2015 at 14:49, Andy Zhou <azhou@nicira.com> wrote:
> Added a eBPF program loader in ofproto-dpif layer. It only loades
> the OVS programs.
>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---

A little more precise: It only loads BPF programs with sections that
begin with the 'ovs' prefix.

There's a few scattered OVS style things like using ovs_scan(),
removing commented lines.

> +#define BPF_UNIXCTL_CHECK(conn) \
> +    if (bpf_unixctl_check_enable(conn) == -1) return

It seems unusual for OVS code to skimp on some "if(foo()) return"
logic by using a macro.

> +static int
> +bpf_unixctl_check_enable(struct unixctl_conn *conn)

Another minor style thing here, I think "check_enable" is ambiguous.
It's actually checking for datapath support for the feature. (I
realise there are other places in OVS that we do this, and I've been
meaning to clean them up).

> diff --git a/vswitchd/automake.mk b/vswitchd/automake.mk
> index 80affe9..a94720b 100644
> --- a/vswitchd/automake.mk
> +++ b/vswitchd/automake.mk
> @@ -19,6 +19,11 @@ vswitchd_ovs_vswitchd_LDFLAGS = $(AM_LDFLAGS) $(DPDK_vswitchd_LDFLAGS)
>  EXTRA_DIST += vswitchd/INTERNALS
>  MAN_ROOTS += vswitchd/ovs-vswitchd.8.in
>
> +if LINUX
> +vswitchd_ovs_vswitchd_LDADD += lib/libbpf.la
> +vswitchd_ovs_vswitchd_LDADD += -lelf
> +endif
> +

Do we perform a check for the libelf dev headers and library anywhere
in the build process?
