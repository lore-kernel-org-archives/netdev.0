From: Sathya Perla <sathya.perla@avagotech.com>
Subject: Re: [PATCH net] be2net: check properly status in lancer_cmd_get_file_len()
Date: Mon, 16 Nov 2015 14:27:44 +0530
Message-ID: <CAKvpyk2qLc7gqd3mQ5oBpzG5QCnjQCawhx4kvsn9Z5buj3tg0w@mail.gmail.com>
References: <1447408361-7498-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>,
	Ajit Kumar Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:36369 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbKPI5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 03:57:45 -0500
Received: by ykdr82 with SMTP id r82so227565169ykd.3
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 00:57:44 -0800 (PST)
In-Reply-To: <1447408361-7498-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2015 at 3:22 PM, Ivan Vecera <ivecera@redhat.com> wrote:
> The lancer_cmd_get_file_len() calls lancer_cmd_read_object() to get
> the current size of registers for ethtool registers dump. The size
> is stored in data_read but only when the returned status is 0 otherwise
> it is uninitialized thus random.
>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_ethtool.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> index f4cb8e4..26b6192 100644
> --- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
> +++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
> @@ -248,6 +248,8 @@ static u32 lancer_cmd_get_file_len(struct be_adapter *adapter, u8 *file_name)
>         status = lancer_cmd_read_object(adapter, &data_len_cmd, 0, 0,
>                                         file_name, &data_read, &eof,
>                                         &addn_status);
> +       if (status)
> +               return 0;
>
>         return data_read;

Ivan, unless I'm missing something...I see that "data_read" is
initialized to 0 in this routine. So, this routine will return 0 when
lancer_cmd_read_object() returns a non-zero status.
