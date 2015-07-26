From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 4/4] mlxsw: Introduce Mellanox SwitchX-2 ASIC
 support
Date: Sun, 26 Jul 2015 19:14:11 +0200
Message-ID: <20150726171410.GB2207@nanopsycho.fritz.box>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <1437666216-3149-5-git-send-email-jiri@resnulli.us>
 <CAE4R7bAk_nUCuqcJxuAAr6pOqNX7zXWv1zFZDVGwBi7_nk8=kQ@mail.gmail.com>
 <20150726071010.GA2150@nanopsycho.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, idosch@mellanox.com,
	eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34373 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755181AbbGZROP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 13:14:15 -0400
Received: by wibud3 with SMTP id ud3so113842391wib.1
        for <netdev@vger.kernel.org>; Sun, 26 Jul 2015 10:14:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150726071010.GA2150@nanopsycho.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<snip>

>
>
>>
>>> +               struct sk_buff *skb_new;
>>> +
>>> +               skb_new = skb_realloc_headroom(skb, MLXSW_TXHDR_LEN);
>>> +               dev_kfree_skb_any(skb);
>>> +               if (!skb_new) {
>>> +                       this_cpu_inc(mlxsw_sx_port->pcpu_stats->tx_dropped);
>>> +                       return NETDEV_TX_OK;
>>> +               }
>>> +               skb = skb_new;
>>> +       }
>>> +       mlxsw_sx_txhdr_construct(skb, &tx_info);
>>> +       err = mlxsw_core_skb_transmit(mlxsw_sx, skb, &tx_info);
>>> +       if (err == -EAGAIN)
>>> +               return NETDEV_TX_BUSY;
>>
>>I think there is a problem here when returning NETDEV_TX_BUSY when
>>original skb might have been freed above in the headroom check. (ref
>>Documentation/networking/driver.txt).
>
>I have to check this out a bit more. Thanks for pointing that out.

You are right. In case queue is busy we obviously cannot free
the original skb. Will fix that in V2. Thanks!
