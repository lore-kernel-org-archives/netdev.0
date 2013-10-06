From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] net: secure_seq: Move net_secret_init() definition into
 CONFIG_IPV6 if block
Date: Sat, 5 Oct 2013 22:25:11 -0700
Message-ID: <CAOesGMi6LuP7uVJnHOgpG2RK2Q0R3bJ4kG1ZY3=b-W3k0YhnBg@mail.gmail.com>
References: <1381003790-12731-1-git-send-email-festevam@gmail.com>
	<20131005.162752.155685316245760253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Fabio Estevam <festevam@gmail.com>, edumazet@google.com,
	hannes@strressinduktion.org,
	Network Development <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:37070 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3JFFZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 01:25:12 -0400
Received: by mail-qe0-f41.google.com with SMTP id 1so4313718qee.14
        for <netdev@vger.kernel.org>; Sat, 05 Oct 2013 22:25:11 -0700 (PDT)
In-Reply-To: <20131005.162752.155685316245760253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 5, 2013 at 1:27 PM, David Miller <davem@davemloft.net> wrote:
> From: Fabio Estevam <festevam@gmail.com>
> Date: Sat,  5 Oct 2013 17:09:50 -0300
>
>> From: Fabio Estevam <fabio.estevam@freescale.com>
>>
>> Commit 9a3bab6b05 (net: net_secret should not depend on TCP) introduced
>> the following build warning when CONFIG_IPV6 is not selected:
>>
>> net/core/secure_seq.c:17:13: warning: 'net_secret_init' defined but not used [-Wunused-function]
>>
>> Fix it by moving net_secret_init(void) inside the '#if IS_ENABLED(CONFIG_IPV6)'
>> block.
>>
>> Reported-by: Olof Johansson <olof@lixom.net>
>> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
>
> seq_scale is used by secure_tcp_sequence_number, which is only protected
> by CONFIG_INET.  I have no idea how you can get this build problem.
>
> And I cannot reproduce it here:

You get it if you have CONFIG_NET enabled, but CONFIG_INET off. We
seem to have a few defconfigs on arm that has that setting, likely
because they lack native network interfaces but need local unix
sockets. Or whatever. But that's how you hit it.

Steps to reproduce, even with ARCH=sparc:

make allnoconfig
edit .config, set CONFIG_NET=y
yes "" | make oldconfig
make


-Olof
