From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Tue, 12 May 2015 17:06:02 +0200
Message-ID: <555216DA.3020105@6wind.com>
References: <20150511175355.GA3130@nanopsycho> <1431443035-4265-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38251 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932761AbbELPGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:06:06 -0400
Received: by wicnf17 with SMTP id nf17so19786499wic.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:06:05 -0700 (PDT)
In-Reply-To: <1431443035-4265-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/05/2015 17:03, Nicolas Dichtel a =C3=A9crit :
[snip]
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -3273,7 +3273,8 @@ static int rtnetlink_event(struct notifier_bloc=
k *this, unsigned long event, voi
>   	case NETDEV_BONDING_INFO:
>   		break;
>   	default:
> -		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
> +		if (dev->reg_state =3D=3D NETREG_REGISTERED)
> +			rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
In fact, it's probably better to put this in rtmsg_ifinfo().
Will send a v3, sorry for the noise.
