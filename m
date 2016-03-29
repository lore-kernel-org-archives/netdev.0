From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] team: team should sync the port's uc/mc addrs when
 add a port
Date: Mon, 28 Mar 2016 21:56:14 -0700
Message-ID: <CAM_iQpV2Ed=6FaWQP29PKjA=DtpMdH06OgVb+D9XvNt4DhbkFw@mail.gmail.com>
References: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:33488 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbcC2E4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 00:56:16 -0400
Received: by mail-yw0-f169.google.com with SMTP id h65so5496035ywe.0
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 21:56:15 -0700 (PDT)
In-Reply-To: <320fc71dbbf5ed164ca506cf5750b7bf4e048d44.1459183351.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 9:42 AM, Xin Long <lucien.xin@gmail.com> wrote:
> There is an issue when we use mavtap over team:
> When we replug nic links from team0, the real nics's mc list will not
> include the maddr for macvtap any more. then we can't receive pkts to
> macvtap device, as they are filterred by mc list of nic.
>
> In Bonding Driver, it syncs the uc/mc addrs in bond_enslave().
>
> We will fix this issue on team by adding the port's uc/mc addrs sync in
> team_port_add.
>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  drivers/net/team/team.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 26c64d2..17ff367 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1198,6 +1198,9 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
>                 goto err_dev_open;
>         }
>
> +       dev_uc_sync_multiple(port_dev, dev);
> +       dev_mc_sync_multiple(port_dev, dev);
> +
>         err = vlan_vids_add_by_dev(port_dev, dev);

You need to call dev_{uc,mc}_unsync() on error path, don't you?
