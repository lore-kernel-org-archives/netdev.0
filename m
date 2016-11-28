From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Add the sanity check for
 ipvlan mode
Date: Mon, 28 Nov 2016 11:08:03 -0800
Message-ID: <CAF2d9jhvh1czfp3jDUj8fN1uejsybosOHjHmo=siKVTQJhAXQA@mail.gmail.com>
References: <1480339435-15551-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-netdev <netdev@vger.kernel.org>, gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:36401 "EHLO
        mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbcK1TIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 14:08:24 -0500
Received: by mail-yw0-f172.google.com with SMTP id a10so122737834ywa.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 11:08:24 -0800 (PST)
In-Reply-To: <1480339435-15551-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 5:23 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The ipvlan mode variable "nval" is from userspace, so the ipvlan codes
> should check if the mode variable "nval" is valid.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/ipvlan/ipvlan_main.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index ab90b22..537b5a9 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -65,6 +65,9 @@ static int ipvlan_set_port_mode(struct ipvl_port *port, u16 nval)
>         struct net_device *mdev = port->dev;
>         int err = 0;
>
> +       if (nval >= IPVLAN_MODE_MAX)
> +               return -EINVAL;
> +
I'm curious to know how you encountered this issue? The values are
validated in ipvlan_nl_validate() and it should fail at that time
itself.
>         ASSERT_RTNL();
>         if (port->mode != nval) {
>                 if (nval == IPVLAN_MODE_L3S) {
> --
> 1.9.1
>
>
