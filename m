From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/6] bridge: support sending rntl info when we
 set attributes through sysfs/ioctl
Date: Wed, 16 Mar 2016 15:30:20 +0100
Message-ID: <56E96DFC.7090608@cumulusnetworks.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36801 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933471AbcCPOaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:30:23 -0400
Received: by mail-wm0-f53.google.com with SMTP id l124so50985167wmf.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:30:22 -0700 (PDT)
In-Reply-To: <cover.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 02:34 PM, Xin Long wrote:
> This patchset is used to support sending rntl info to user in some places,
> and ensure that whenever those attributes change internally or from sysfs,
> that a netlink notification is sent out to listeners.
> 
> It also make some adjustment in bridge sysfs so that we can implement this
> easily.
> 
> I've done some tests on this patchset, like:
> [br_sysfs]
>   1. change all the attribute values of br or brif:
>   $ echo $value > /sys/class/net/br0/bridge/{*}
>   $ echo $value > /sys/class/net/br0/brif/eth1/{*}
> 
>   2. meanwhile, on another terminal to observe the msg:
>   $ bridge monitor
> 
> [br_ioctl]
>   1. in bridge-utils package, do some changes in br_set, let brctl command
>   use ioctl to set attribute:
>          if ((ret = set_sysfs(path, value)) < 0) { -->
>          if (1) {
> 
>   $ brctl set*
> 
>   2. meanwhile, on another terminal to observe the msg:
>   $ bridge monitor
> 
> This test covers all the attributes that brctl and sysfs support to set.
> 

Please also include the bridge maintainers (CCed).
