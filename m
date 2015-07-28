From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 4/4] mlxsw: Introduce Mellanox SwitchX-2 ASIC
 support
Date: Tue, 28 Jul 2015 20:06:25 +0200
Message-ID: <20150728180625.GA2046@nanopsycho>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <1437666216-3149-5-git-send-email-jiri@resnulli.us>
 <CAE4R7bAk_nUCuqcJxuAAr6pOqNX7zXWv1zFZDVGwBi7_nk8=kQ@mail.gmail.com>
 <20150726071010.GA2150@nanopsycho.fritz.box>
 <20150726171410.GB2207@nanopsycho.fritz.box>
 <9B0331B6EBBD0E4684FBFAEDA55776F919405E0B@HASMSX110.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
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
To: "Rosen, Rami" <rami.rosen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34231 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbG1SG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 14:06:29 -0400
Received: by wibud3 with SMTP id ud3so191330444wib.1
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 11:06:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <9B0331B6EBBD0E4684FBFAEDA55776F919405E0B@HASMSX110.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jul 27, 2015 at 08:17:22AM CEST, rami.rosen@intel.com wrote:
>Hi, Jiri,
>
>Keep on the good work!
>
>The .func  member of the mlxsw_rx_listener object has this prototype:
>void (*func)(struct sk_buff *skb, u8 local_port, u16 trap_id, void *priv);
>
>Is the trap_id  parameter needed ?
>In the three use cases of .func, which are either mlxsw_emad_rx_listener_func(), mlxsw_core_event_listener_func(), or mlxsw_sx_rx_listener_func(), this parameter is not used at all.

You are right. We intended to use MLXSW_TRAP_ID_DONT_CARE and use
trap_id in the callback, but when user registers a callback for exact
trap_id, this is not needed. Will remove in v2.

Thanks.
