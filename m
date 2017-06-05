From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/6] introduce trap control action to tc and
 offload it
Date: Mon, 5 Jun 2017 21:56:12 +0200
Message-ID: <20170605195612.GB1986@nanopsycho>
References: <20170605143832.7025-1-jiri@resnulli.us>
 <20170605154651.GE11772@lunn.ch>
 <20170605194317.GA1986@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34869 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdFET4P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:56:15 -0400
Received: by mail-wm0-f65.google.com with SMTP id g15so31530387wmc.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:56:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170605194317.GA1986@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 05, 2017 at 09:43:17PM CEST, jiri@resnulli.us wrote:
>Mon, Jun 05, 2017 at 05:46:51PM CEST, andrew@lunn.ch wrote:
>>On Mon, Jun 05, 2017 at 04:38:26PM +0200, Jiri Pirko wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>> 
>>> This patchset introduces a control action dedicated to indicate
>>> to trap the matched packet to CPU. This is specific action for
>>> HW offloads. Also, the patchset offloads the action to mlxsw driver.
>>> 
>>> Example usage:
>>> $ tc filter add dev enp3s0np19 parent ffff: protocol ip prio 20 flower skip_sw dst_ip 192.168.10.1 action trap
>>
>>Hi Jiri
>>
>>So i assume this means a frame ingressing on the switch port
>>enp3s0np19 matching the filter is now visible on the linux enp3s0np19
>
>Yes.
>
>
>>interface?  How do you avoid Linux processing it? If enp3s0np19 is a
>
>On contrary. I want Linux to process it. The packet was stolen from the
>offloaded fastpath to kernel.
>
>
>>member of a bridge, we don't want the software bridge processing it
>>and forwarding it out another port, since i assume the hardware has
>>already done this. Or does the trap stop further processing of the
>>frame by the hardware?
>
>Exactly the latter :) Thanks!

Btw, if you would like to just sample the traffic and not really
influence it in any way, there is a special action "sample" for that.
mlxsw offloads that.
