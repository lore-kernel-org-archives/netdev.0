From: "David S. Miller" <davem@redhat.com>
Subject: Re: MOD_{INC,SEC}_USE_COUNT() in net/ipv{4,6}
Date: Wed, 09 Apr 2003 18:00:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030409.180004.08009488.davem@redhat.com>
References: <20030409.204157.51648508.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030409.204157.51648508.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 09 Apr 2003 20:41:57 +0900 (JST)

   This patch (against 2.5.67) converts MOD_{INC,DEC}_USE_COUNT in 
   net/ipv{4,6} to try_module_get() and module_put().

Applied, but let's recognize that ipv6 is totally broken
in this area.

The try_module_get()'s, in order to work, would need to happen
at a higher layer (socket ops or similar).  But even this is
broken, module unloading of ipv6 needs to be done via some kind
of callback scheme, the simple counter mechanism that modules
use now is inappropriate for things like ipv6 which already keeps
track of it's own references internally and only it knows how to
interlock properly to cleanly check for module references and to
shut down the whole module.
