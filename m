From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 0/6] introduce trap control action to tc and
 offload it
Date: Mon, 5 Jun 2017 17:46:51 +0200
Message-ID: <20170605154651.GE11772@lunn.ch>
References: <20170605143832.7025-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36736 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751077AbdFEPqz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Jun 2017 11:46:55 -0400
Content-Disposition: inline
In-Reply-To: <20170605143832.7025-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 04:38:26PM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This patchset introduces a control action dedicated to indicate
> to trap the matched packet to CPU. This is specific action for
> HW offloads. Also, the patchset offloads the action to mlxsw driver.
> 
> Example usage:
> $ tc filter add dev enp3s0np19 parent ffff: protocol ip prio 20 flower skip_sw dst_ip 192.168.10.1 action trap

Hi Jiri

So i assume this means a frame ingressing on the switch port
enp3s0np19 matching the filter is now visible on the linux enp3s0np19
interface?  How do you avoid Linux processing it? If enp3s0np19 is a
member of a bridge, we don't want the software bridge processing it
and forwarding it out another port, since i assume the hardware has
already done this. Or does the trap stop further processing of the
frame by the hardware?

Thanks
      Andrew
