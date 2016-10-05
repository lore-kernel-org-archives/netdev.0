From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: kernel v4.8: iptables logs are truncated with the 4.8 kernel?
Date: Wed, 5 Oct 2016 08:58:38 +0800
Message-ID: <CAML_gOcpW=9PEJiE=XoSTRJVjGqAb-DwsWv6JSzkEwp3ivOLfA@mail.gmail.com>
References: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f45.google.com ([209.85.213.45]:36329 "EHLO
        mail-vk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754474AbcJEA6o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 20:58:44 -0400
In-Reply-To: <CAO9zADwLwLLvxmqiLzxK9A5+--ZnvewMzmUvQ4xdm8HHeFNOsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Justin,

2016-10-05 6:02 GMT+08:00 Justin Piszcz <jpiszcz@lucidpixels.com>:
> Hello,
>
> kernel 4.8 with ulogd-2.0.5- IPs are no longer logged:
>
> Oct  4 17:51:30 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
> TTL=0 ID=0 PROTO=0 MARK=0
> Oct  4 17:51:31 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
> TTL=0 ID=0 PROTO=0 MARK=0
> Oct  4 17:51:32 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 LEN=0 TOS=00 PREC=0x00
> TTL=0 ID=0 PROTO=0 MARK=0
>
> (reboot back to kernel 4.7, works fine)
>
> kernel 4.7 with ulogd-2.0.5:
> Oct  4 17:56:44 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 SRC=74.125.22.125
> DST=1.2.3.4 LEN=397 TOS=00 PREC=0x00 TTL=48 ID=58093 PROTO=TCP
> SPT=5222 DPT=19804 SEQ=2032644254 ACK=2273184383 WINDOW=55272 ACK PSH
> URGP=0 MARK=0
> Oct  4 17:56:45 atom INPUT_BLOCK IN=eth1 OUT=
> MAC=00:1b:21:9c:3b:fa:3e:94:d5:d2:49:1e:08:00 SRC=74.125.22.125
> DST=1.2.3.4 LEN=397 TOS=00 PREC=0x00 TTL=48 ID=58725 PROTO=TCP
> SPT=5222 DPT=19804 SEQ=2032644254 ACK=2273184383 WINDOW=55272 ACK PSH
> URGP=0 MARK=0
>
> Looks like there were some changes in the 4.8 kernel regarding ulogd,
> has anyone else run into this problem?
>
>                 } ulog;
> +               if ((li->u.ulog.flags & NF_LOG_F_COPY_LEN) &&
> +                   (li->u.ulog.copy_len < data_len))
> +                       data_len = li->u.ulog.copy_len;
>                 li->u.ulog.group = ntohs(nla_get_be16(tb[NFTA_LOG_GROUP]));
> +                       li->u.ulog.flags |= NF_LOG_F_COPY_LEN;
>                         li->u.ulog.copy_len =
>                 if (nla_put_be16(skb, NFTA_LOG_GROUP, htons(li->u.ulog.group)))
> -               if (li->u.ulog.copy_len) {
> +               if (li->u.ulog.flags & NF_LOG_F_COPY_LEN) {
>                                          htonl(li->u.ulog.copy_len)))
>         li.u.ulog.group      = info->group;
>         li.u.ulog.qthreshold = info->threshold;
> +               li.u.ulog.flags |= NF_LOG_F_COPY_LEN;
>
> Thanks,
>
> Justin.

Which one are you using? iptables or nftables?

Could you please paste the related iptables/nftables rules here?
