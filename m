From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 7/8] openvswitch: Drop user features if old user
 space attempted to create datapath
Date: Mon, 25 Nov 2013 15:40:25 -0800
Message-ID: <CAEP_g=8nADwqAJ81gtpJ-6v2XW4Se+OK1RPcEZ7mh-_PAwyo7g@mail.gmail.com>
References: <cover.1385137618.git.tgraf@suug.ch> <a207b27c2830c9098045455808e1ca6d203a5d9a.1385137618.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>, ffusco@redhat.com,
	fleitner@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:37345 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750756Ab3KYXkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 18:40:46 -0500
Received: by mail-la0-f52.google.com with SMTP id y1so1795044lam.11
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 15:40:45 -0800 (PST)
In-Reply-To: <a207b27c2830c9098045455808e1ca6d203a5d9a.1385137618.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 22, 2013 at 8:56 AM, Thomas Graf <tgraf@suug.ch> wrote:
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 07ef2c3..a6863e2 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -40,7 +40,15 @@ struct ovs_header {
>
>  #define OVS_DATAPATH_FAMILY  "ovs_datapath"
>  #define OVS_DATAPATH_MCGROUP "ovs_datapath"
> -#define OVS_DATAPATH_VERSION 0x1
> +
> +/* V2:
> + *   - API users are expected to provide OVS_DP_ATTR_USER_FEATURES
> + *     with NLM_F_REPLACE when creating the datapath.
> + */
> +#define OVS_DATAPATH_VERSION 2

I'm not sure that I understand this comment - I guess it means that
there's no legacy path when using NLM_F_REPLACE?
