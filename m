From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [net-next:master 630/633] net/bridge/br_netlink.c:1110:1:
 warning: the frame size of 2160 bytes is larger than 2048 bytes
Date: Mon, 5 Oct 2015 11:33:42 +0200
Message-ID: <561243F6.1060009@cumulusnetworks.com>
References: <201510051053.L0S9UKIW%fengguang.wu@intel.com>
 <20151005.024717.1982719584385972843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35931 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbbJEJdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 05:33:45 -0400
Received: by wicgb1 with SMTP id gb1so110469667wic.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 02:33:44 -0700 (PDT)
In-Reply-To: <20151005.024717.1982719584385972843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2015 11:47 AM, David Miller wrote:
> From: kbuild test robot <fengguang.wu@intel.com>
> Date: Mon, 5 Oct 2015 10:42:54 +0800
> 
>> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>> head:   3e087caa23ef36370bfb925d3bbca78e8302d3ce
>> commit: 7e4df51eb35deedd3ba8d4db92a6c36fb7eff90a [630/633] bridge: netlink: add support for igmp's intervals
>> config: x86_64-randconfig-s0-10051005 (attached as .config)
>> reproduce:
>>         git checkout 7e4df51eb35deedd3ba8d4db92a6c36fb7eff90a
>>         # save the attached .config to linux build tree
>>         make ARCH=x86_64 
>>
>> All warnings (new ones prefixed by >>):
>>
>>    net/bridge/br_netlink.c: In function 'br_fill_info':
>>>> net/bridge/br_netlink.c:1110:1: warning: the frame size of 2160 bytes is larger than 2048 bytes [-Wframe-larger-than=]
>>     }
> 
> Nikolay, please look into this.
> 

I am, this looks like to be caused by enabling KASAN (kernel address sanitizer), there's 
a lot of additional code generated and the frame grows bigger.
The same thing is being discussed here:
http://www.spinics.net/lists/linux-media/msg93925.html

The real size is much smaller without kasan.
