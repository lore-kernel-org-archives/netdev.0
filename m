From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Wed, 3 Feb 2016 14:31:33 +0100
Message-ID: <20160203143133.1b70bcb5@redhat.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, yishaih@mellanox.com, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	eugenia@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	jbenc@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756033AbcBCNbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 08:31:42 -0500
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  3 Feb 2016 11:47:56 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> From: Jiri Pirko <jiri@mellanox.com>
> 
> There a is need for some userspace API that would allow to expose things
> that are not directly related to any device class like net_device of
> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
> 
> Use cases:
> 1) get/set of port type (Ethernet/InfiniBand)
> 2) monitoring of hardware messages to and from chip
> 3) setting up port splitters - split port into multiple ones and squash again,
>    enables usage of splitter cable
> 4) setting up shared buffers - shared among multiple ports within one chip
> 
> First patch of this set introduces a new generic Netlink based interface,
> called "devlink". It is similar to nl80211 model and it is heavily
> influenced by it, including the API definition. The devlink introduction patch
> implements use cases 1) and 2). Other 2 are in development atm and will
> be addressed by follow-ups.
> 
> It is very convenient for drivers to use devlink, as you can see in other
> patches in this set.
> 
> Counterpart for devlink is userspace tool called "dl". Command line interface
> and outputs are derived from "ip" tool so it should be easy for users to get
> used to it.
> 
> It is available here:
> https://github.com/jpirko/devlink

IHMO this very short command name "dl" is not an advantage.  It is
simply too unspecific and short for a good Google search.  E.g. when
searching for good examples for using "dl".  I think "devlink" would be
better.  If you like short commands do: alias dl="devlink"


> Example usage:
> butter:~$ dl help
> Usage: dl [ OPTIONS ] OBJECT { COMMAND | help }
> where  OBJECT := { dev | port | monitor }
>        OPTIONS := { -v/--verbose }
> 
> butter:~$ dl dev show
> 0: devlink0: bus pci dev 0000:01:00.0
> 
> butter:~$ dl port help
> Usage: dl port show [DEV/PORT_INDEX]
> Usage: dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]
> 
> butter:~$ dl port show
> devlink0/1: type ib ibdev mlx4_0
> devlink0/2: type ib ibdev mlx4_0
> 
> butter:~$ sudo dl port set devlink0/1 type eth
> 
> butter:~$ dl port show
> devlink0/1: type eth netdev ens4
> devlink0/2: type ib ibdev mlx4_0
> 
> butter:~$ sudo dl port set devlink0/1 type auto
> 
> butter:~$ dl port show
> devlink0/1: type eth(auto) netdev ens4
> devlink0/2: type ib ibdev mlx4_0

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
