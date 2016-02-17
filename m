From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next] vlan: change return type of vlan_proc_rem_dev
Date: Wed, 17 Feb 2016 15:19:12 -0800
Message-ID: <CAM_iQpXj1DFfu_DAV=M+=v-Ri2XKCuUP869=ckH=UvVZn4fm2A@mail.gmail.com>
References: <1455709458-1439-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34796 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965013AbcBQXTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 18:19:13 -0500
Received: by mail-yw0-f177.google.com with SMTP id h129so26622242ywb.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 15:19:13 -0800 (PST)
In-Reply-To: <1455709458-1439-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 3:44 AM, Zhang Shengju
<zhangshengju@cmss.chinamobile.com> wrote:
> Since function vlan_proc_rem_dev() will only return 0, it's better to
> return void instead of int.
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>  net/8021q/vlanproc.c | 3 +--
>  net/8021q/vlanproc.h | 2 +-
>  2 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
> index ae63cf7..5f1446c 100644
> --- a/net/8021q/vlanproc.c
> +++ b/net/8021q/vlanproc.c
> @@ -184,12 +184,11 @@ int vlan_proc_add_dev(struct net_device *vlandev)
>  /*
>   *     Delete directory entry for VLAN device.
>   */
> -int vlan_proc_rem_dev(struct net_device *vlandev)
> +void vlan_proc_rem_dev(struct net_device *vlandev)
>  {
>         /** NOTE:  This will consume the memory pointed to by dent, it seems. */
>         proc_remove(vlan_dev_priv(vlandev)->dent);
>         vlan_dev_priv(vlandev)->dent = NULL;
> -       return 0;
>  }
>
>  /****** Proc filesystem entry points ****************************************/
> diff --git a/net/8021q/vlanproc.h b/net/8021q/vlanproc.h
> index 063f60a..a9d8734 100644
> --- a/net/8021q/vlanproc.h
> +++ b/net/8021q/vlanproc.h
> @@ -5,7 +5,7 @@
>  struct net;
>
>  int vlan_proc_init(struct net *net);
> -int vlan_proc_rem_dev(struct net_device *vlandev);
> +void vlan_proc_rem_dev(struct net_device *vlandev);
>  int vlan_proc_add_dev(struct net_device *vlandev);
>  void vlan_proc_cleanup(struct net *net);

You forget to change the !PROC_FS case:

#define vlan_proc_rem_dev(dev)  ({(void)(dev), 0; })
