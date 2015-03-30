From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Return vport module ref before destruction
Date: Mon, 30 Mar 2015 11:19:07 -0700
Message-ID: <CALnjE+pC2V3XV5wvoT90_0-sscHzK=0NkVpQNjKfPQn-z2Kufg@mail.gmail.com>
References: <9cf67a5f127d80bb7db0bd1af1e33505f93e1a01.1427715582.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:50736 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753109AbbC3STI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 14:19:08 -0400
Received: by mail-ig0-f178.google.com with SMTP id m3so78148615ign.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 11:19:07 -0700 (PDT)
In-Reply-To: <9cf67a5f127d80bb7db0bd1af1e33505f93e1a01.1427715582.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 4:57 AM, Thomas Graf <tgraf@suug.ch> wrote:
> Return module reference before invoking the respective vport
> ->destroy() function. This is needed as ovs_vport_del() is not
> invoked inside an RCU read side critical section so the kfree
> can occur immediately before returning to ovs_vport_del().
>
> Returning the module reference before ->destroy() is safe because
> the module unregistration is blocked on ovs_lock which we hold
> while destroying the datapath.
>
> Fixes: 62b9c8d0372d ("ovs: Turn vports with dependencies into separate modules")
> Reported-by: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>
